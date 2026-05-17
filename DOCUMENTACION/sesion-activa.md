# Sesión activa (Active Workout)

La pantalla central de la app — donde el usuario loguea sets en tiempo real con cronómetro, timer de descanso, alerta sonora, y notificación persistente. También maneja la recuperación de la sesión si el SO mata el proceso.

**Archivos principales:**
- `lib/features/active_workout/screens/active_workout_screen.dart`
- `lib/features/active_workout/view_models/active_workout_view_model.dart`
- `lib/features/active_workout/widgets/exercise_card.dart`, `rest_timer_bar.dart`, `number_input_widget.dart`
- `lib/core/services/workout_notification_service.dart` (bridge Flutter → nativo)
- `android/.../WorkoutService.kt` (foreground service)
- `android/.../MainActivity.kt` (handlers del MethodChannel)

---

## 1. Flujo desde el usuario

1. Tap en "Start Workout" en el hero card del home → push de `ActiveWorkoutScreen(routineId)`.
2. La pantalla muestra: cronómetro de sesión, progreso (X/Y sets), volumen acumulado, una card por ejercicio con sus sets.
3. Cada set: el usuario edita peso + reps (o lado izquierdo/derecho si es unilateral split), tap a "Finish set N" → se guarda y arranca el rest timer.
4. Rest timer cuenta hacia atrás. Al llegar a 0: notificación + vibración + sonido (configurable).
5. Al terminar todos los sets de todos los ejercicios → `autoFinish` dispara una pantalla de "Workout Complete" tras 1.5s.
6. Botón "Finish workout" o "Skip" exit anticipadamente.

Mientras dura la sesión:
- Aparece una **notificación foreground persistente** con el cronómetro.
- Aparece un **overlay flotante** en la app sobre el navbar (al volver al home/tabs).
- Si el usuario sale de la app o el SO la mata → la sesión se recupera al reabrir.

## 2. Modelo de estado (Dart)

`ActiveWorkoutState` (en `active_workout_view_model.dart`):

```dart
class ActiveWorkoutState {
  final Routine routine;
  final List<Exercise> exercises;
  final int elapsedSeconds;
  final bool isRunning;
  final List<ExerciseWorkoutState> exerciseStates;
  final RestTimerState? restTimer;
  final bool autoFinish;
}
```

Por ejercicio:
```dart
class ExerciseWorkoutState {
  final String exerciseId;
  final int targetSets;
  final String targetReps;
  final int restSec;
  final bool isExpanded;
  final List<WorkoutSet> completedSets;
  final WorkoutSet? currentInput;
  final List<WorkoutSet> prevSets;     // de la sesión anterior — para sugerir
  final bool isUnilateral;
  final bool isSplitMode;              // separa lado izq/der
  final bool skipped;
}
```

Provider:
```dart
final activeWorkoutProvider = StateNotifierProvider.autoDispose
    .family<ActiveWorkoutNotifier, ActiveWorkoutState, String>(
      (ref, routineId) => ActiveWorkoutNotifier(routineId, ref),
    );
```

`autoDispose` libera memoria cuando ningún widget escucha (el overlay flotante o la pantalla activa). `family<>` permite tener un view model por rutina.

Provider auxiliar:
```dart
final activeWorkoutRoutineIdProvider = StateProvider<String?>((ref) => null);
```
Cuando es `null`, no hay sesión activa. Cuando tiene valor, el overlay aparece.

## 3. Acciones del notifier

| Método | Qué hace |
|---|---|
| `restoreStartTime(DateTime)` | Setea el cronómetro desde un tiempo previo (restauración) |
| `restoreProgress(jsonStr)` | Recompone sets y rest timer desde un JSON persistido |
| `togglePause()` | Pausa/resume el cronómetro acumulando elapsed |
| `toggleExpand(i)` | Expande/colapsa la card de un ejercicio |
| `toggleSplitMode(i)` | Activa modo izq/der en ejercicios unilaterales |
| `finishSet(i)` | Cierra el set actual, arranca rest, dispara guardado |
| `skipRest()` | Cancela el rest timer manualmente |
| `addRestTime(seconds)` | +15s al rest en curso |
| `skipExercise(i)` | Marca ejercicio como skipped, rellena sets con prev |
| `updateWeight/Reps/LeftWeight/LeftReps` | Edita el input actual |
| `finishWorkout()` | Cierra todo, persiste `Session` y `workout_log`, invalida providers |
| `cancelWorkout()` | Sale sin guardar |
| `persistProgress()` | Wrapper público de `_saveProgress` — guardado manual a SharedPreferences nativos |

## 4. Cálculos

- **Volumen**: `sum(kg × reps + (leftKg × leftReps si split))` sobre todos los sets.
- **Estimated 1RM** por set (usado solo en gráficas, no en la sesión): `kg × (1 + reps/30)`.
- **Sugerencia de input**: la primera vez que se abre un ejercicio, `currentInput = prevSets[0]` (el primer set de la última sesión con esa rutina). En sets sucesivos sugiere `prevSets[setIndex]` con fallback al último.

## 5. Rest timer

Implementado con dos campos:
- `_restEndAt: DateTime?` — momento absoluto en el que termina.
- `_restTicker: Timer.periodic(1s)` — recalcula `remaining = endAt.difference(now).inSeconds`.

Usar **timestamp absoluto** en lugar de contador decrementando garantiza correcto comportamiento si la app duerme, pierde frames, o el SO mata el proceso (se restaura computando contra now).

Cuando llega a 0:
1. Cancela el ticker.
2. Llama `_onRestFinished(exerciseName)`.
3. `HapticFeedback.heavyImpact()`.
4. Invoca método nativo `showRestAlert` (notificación con vibración).
5. Si el sonido custom está habilitado, reproduce vía `audioplayers` con `AudioContext` específico de notification + audio focus `gainTransientMayDuck`.

## 6. Sistema de notificación + foreground service

Bridge: `WorkoutNotificationService` (Dart) → `MethodChannel("com.example.versatile/workout")` → `MainActivity.kt` → `WorkoutService.kt`.

### Métodos del channel

| Método | Argumentos | Acción nativa |
|---|---|---|
| `startWorkoutService` | startedAt, routineId, routineName, subtitle | Lanza `WorkoutService` con `startForegroundService` + guarda en SharedPreferences |
| `stopWorkoutService` | — | `clearPrefs()` + `stopService()` |
| `saveWorkoutProgress` | json | Persiste el JSON de progreso en SharedPreferences (key `progress`) |
| `getActiveWorkout` | — | Lee prefs, retorna `{routineId, startedAt, progressJson, routineName}` o `null` |
| `showRestAlert` | exerciseName | Notificación canal `rest_alert_v2` + manejo de sonido |

### `WorkoutService.kt`

Foreground service que:
- Tick cada 1s, reconstruye y `notify()` la notificación con cronómetro y subtitle motivacional.
- En `onStartCommand` con intent `null` (relanzado por START_STICKY), restaura desde SharedPreferences.
- Si los prefs están vacíos al relanzar, `stopSelf()`.
- `@Volatile companion._isRunning` — flag in-memory.

### Persistencia para recuperación

**SharedPreferences nativos** (no la tabla `settings` de Flutter — esa solo es accesible desde el lado Dart):
- `startedAt` (long)
- `routineId` (string)
- `routineName` (string)
- `subtitle` (string)
- `progress` (JSON string con sets completos, current input, y rest timer)

`_saveProgress()` se llama en momentos clave:
- `finishSet`, `skipRest`, `skipExercise`, `autoFinish`
- En `didChangeAppLifecycleState` cuando la app va a `paused`/`inactive`/`hidden` (fix reciente — ver `MEMORY.md`).

## 7. Recuperación tras kill del proceso

Flujo:
1. SplashScreen llama `WorkoutNotificationService.getActiveWorkout()` en `_runStartupTasks`.
2. Si retorna un `ActiveWorkoutInfo`, lo guarda en `pendingWorkoutRestoreProvider` (StateProvider).
3. SplashScreen pushea `MainNavigationShell` (no la screen activa directamente).
4. `MainNavigationShell.initState` registra un `postFrameCallback` `_restorePendingWorkout` que lee ese provider y, si hay info, pushea `ActiveWorkoutScreen(routineId, restoredStartedAt, restoredProgressJson)`.

Por qué pasar por la shell y no pushear directo desde splash: hubo un bug repetitivo de pantalla negra cuando se pusheaba desde un contexto que ya había sido removido del árbol (commit `e8487d2`). Routear todo a través de la shell estabilizó el flujo.

## 8. Decisiones críticas (de la sesión de fix)

Estas vivían en `active_workout_screen.dart` y `MainActivity.kt`. Cualquier cambio aquí requiere entender por qué:

### El dispose NO debe parar el servicio

```dart
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  super.dispose();  // ← NO llamar WorkoutNotificationService.stop()
}
```

`dispose` se llama también cuando el usuario navega back a la shell (sin terminar el workout). Parar el servicio ahí destruía la recuperación. El servicio solo se detiene en `_finish()` y `_confirmDiscard()`.

### `getActiveWorkout` confía en los prefs, no en `_isRunning`

`_isRunning` es un `@Volatile` in-memory en `WorkoutService.kt`. Cuando el SO mata el proceso, vuelve a `false` aunque los prefs sigan intactos. La implementación previa borraba los prefs si `_isRunning == false`, perdiendo la sesión.

Actualmente: si hay prefs válidos pero el servicio no corre, **se relanza** automáticamente desde `getActiveWorkout` con `startForegroundService`.

### Lifecycle save

`didChangeAppLifecycleState` con `paused`/`inactive`/`hidden` llama `persistProgress()`. Esto garantiza que ediciones recientes de peso/reps que aún no llegaron a un `finishSet` se persistan antes de que Android mate el proceso.

## 9. Limitaciones conocidas

- En OEMs agresivos (MIUI/Xiaomi, One UI/Samsung, EMUI/Huawei), el foreground service puede ser killeado al hacer swipe desde recents. El servicio se relanza al reabrir la app (mitigación implementada), pero la notificación tiene un "blackout" mientras tanto. Mitigación futura: pedir whitelist de batería (`REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`) — pendiente en `MEMORY.md`.
- iOS no tiene un equivalente al `WorkoutService.kt`. La feature de notificación + audio focus solo funciona en Android.
- No hay supersets ni circuitos — cada ejercicio tiene su rest independiente.

## 10. Workout Complete (cierre de sesión)

`finishWorkout()` (en el view model):
1. Cancela timers.
2. Filtra ejercicios con al menos un set completado.
3. Construye `Session` con UUID v4, suma de volumen, fecha de hoy.
4. Inserta en `sessions` + `session_exercises` + `session_sets`.
5. `workoutLogRepository.logDay(today)` (idempotente vía PK conflict).
6. Invalida `sessionsAsyncProvider`, `workoutLogDaysProvider`, `exerciseProgressProvider`.
7. Retorna la `Session` para que la pantalla pueda navegar a `WorkoutCompleteScreen` con confeti/celebración.
