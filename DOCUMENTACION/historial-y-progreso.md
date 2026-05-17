# Historial y progreso

Cómo el usuario revisa lo que entrenó (historial de sesiones) y cómo evoluciona en un ejercicio específico (gráfica de progreso).

**Archivos principales:**
- `lib/features/history/screens/history_screen.dart`
- `lib/features/history/screens/session_detail_screen.dart`
- `lib/features/history/widgets/` (HistorySessionCard, HistoryExerciseDetail)
- `lib/features/exercises/screens/exercise_progress_screen.dart` — gráficas
- `lib/data/repositories/session_repository.dart`
- `lib/domain/entities/session.dart`, `workout_set.dart`, `exercise_progress.dart`
- `lib/features/home/screens/home_screen.dart::_ActivityGrid` — heatmap

---

## 1. Vista del historial (tab History)

`HistoryScreen` muestra todas las sesiones en orden reverso (`ORDER BY date DESC, rowid DESC`).

Cada `HistorySessionCard` muestra:
- Icono + color de la rutina (snapshot que se guardó al cerrar la sesión).
- Nombre de la rutina.
- Fecha formateada con `FormatUtils.date` (`DateFormat.yMMMMEEEEd`, locale-aware).
- Duración (`{n} min` o `{h}h {m}m` vía `FormatUtils.duration`).
- Volumen total (`{n} kg` o `{n}.{f}K kg` vía `FormatUtils.volume`).
- Conteo de ejercicios.

**Empty state**: icono + "No history yet" + "Start training to see your progress here".

**Coachmark `history_first_card`**: aparece la primera vez que el usuario llega a la tab y hay al menos una sesión. Targetea el primer card.

Tap a un card → push a `SessionDetailScreen(session)` con `MaterialPageRoute`.

## 2. Detalle de sesión

`SessionDetailScreen` (con la `Session` ya en memoria — no requiere fetch adicional).

Layout:
- Header con icono + color (gradient), nombre de rutina, fecha.
- Tres stat tiles: Duration, Total Volume, Exercises Performed.
- Lista de `HistoryExerciseDetail` por ejercicio:
  - Nombre + músculo.
  - Cada set en orden con peso y reps.
  - Si era unilateral split, dos columnas (izq/der).
- Botón "See progress" en cada ejercicio → push a `ExerciseProgressScreen(exerciseId)`.

**Coachmark `session_chart`**: la primera vez que abres un detalle, apunta al botón "See progress" del primer ejercicio. Se dispara con delay de 400ms (post slide transition de `MaterialPageRoute`) por el bug de `localToGlobal` durante animaciones (ver `onboarding-y-coachmarks.md` o `MEMORY.md`).

## 3. Modelo de Session

```dart
class Session {
  final String id;
  final String routineId;
  final String routineName;       // snapshot
  final int colorValue;           // snapshot
  final int iconCode;             // snapshot
  final String date;              // YYYY-MM-DD
  final int durationMin;
  final double volumeKg;          // pre-computado al cerrar
  final List<SessionExercise>? exercises;
}

class SessionExercise {
  final int? dbId;
  final String exerciseId;
  final String name;              // snapshot
  final String muscle;            // snapshot
  final List<WorkoutSet> sets;

  double get volume => sets.fold(0.0, (s, set) => s + set.volume);
}

class WorkoutSet {
  final double kg;
  final int reps;
  final double? leftKg;
  final int? leftReps;

  double get volume {
    final right = kg * reps;
    if (leftKg != null && leftReps != null) return right + leftKg! * leftReps!;
    return right;
  }
}
```

**Snapshot pattern**: `routineName`, `colorValue`, `iconCode`, `name`, `muscle` se copian al cerrar la sesión. Si después borras la rutina o el ejercicio, el historial sigue mostrándose correctamente.

## 4. Gráfica de progreso por ejercicio

`ExerciseProgressScreen(exerciseId)` muestra una line chart con la evolución del ejercicio.

### Toggle de métrica

Dos vistas, switch arriba:
- **Estimated 1RM**: peso máximo estimado para una sola repetición.
- **Volume**: volumen total del ejercicio en esa sesión.

### Fórmulas

**1RM estimado (Epley)** — por set:
```
1RM = kg × (1 + reps / 30)
```

Por sesión, se toma el **máximo** de los 1RM de todos los sets del ejercicio en esa sesión.

**Volume** — por sesión:
```
volume = Σ (kg × reps + leftKg × leftReps)  // sobre todos los sets
```

### Implementación

`SessionRepository.getExerciseProgress(exerciseId)` ejecuta raw SQL:
- Join `session_exercises` con `sessions`.
- Por cada session-exercise, agrupa sets y calcula 1RM máximo + volume sum.
- Retorna `List<ExerciseProgressPoint>` ordenados por fecha.

```dart
class ExerciseProgressPoint {
  final String date;          // YYYY-MM-DD
  final double estimatedOneRm;
  final double volume;
}
```

Provider:
```dart
final exerciseProgressProvider = FutureProvider.autoDispose
    .family<List<ExerciseProgressPoint>, String>(
      (ref, exerciseId) =>
          ref.read(sessionRepositoryProvider).getExerciseProgress(exerciseId),
    );
```

### Visualización

- `fl_chart` `LineChart` con curva suave.
- Ejes auto-escalados con padding.
- Dos stat cards: **Last** (sesión más reciente) y **Best** (máximo histórico) según la métrica activa.
- Empty state: "No data yet. Complete a workout with this exercise to track your progress."

**Coachmark `progress_toggle`**: targeta el switch, se dispara 400ms post-load.

## 5. Heatmap de actividad (Home)

En `home_screen.dart`, el widget `_ActivityGrid` renderiza un heatmap estilo GitHub con las últimas N semanas.

- Filas: días de la semana (Mon..Sun).
- Columnas: semanas (auto-cliente al ancho disponible — clamp(4, 26)).
- Celdas: cuadrito accent si entrenaste ese día, transparente si futuro, sutil si día pasado sin training.
- Labels de mes encima cuando cambia el mes.

Fuente: `state.workoutDays`, que es la unión de:
- Fechas en `workout_log` (vía `WorkoutLogRepository.getDays(84)` — últimas 84 días).
- Fechas en `sessions` (`sessions.map((s) => s.date).toSet()`).

Esta dualidad es por compatibilidad histórica — `workout_log` se introdujo en v4, sesiones más antiguas no lo tenían. Combinarlos cubre todo.

## 6. Stats del home

Junto al heatmap, tres `StatCard`:
- **This week**: número de sesiones (filtra por `date >= weekStart`).
- **Volume**: suma de `volumeKg` esta semana. Si ≥ 1000, formato "1.2k kg"; si no, "{n} kg".
- **Avg time**: promedio de `durationMin` esta semana.

Calculados en `homeProvider` (sync `Provider`) sobre `sessionsAsyncProvider`. Se recalcula cuando hay una nueva sesión gracias a `ref.invalidate(sessionsAsyncProvider)` que se hace al `finishWorkout`.

## 7. Recientes (en el home)

Debajo del heatmap, lista las últimas 4 sesiones (`state.sessions.take(4)`). Cada una con `SessionCard` (variante simplificada de la del historial) y tap → `SessionDetailScreen`.

## 8. Decisiones notables

- **`volumeKg` pre-computado al cerrar la sesión** y guardado en `sessions.volume_kg`. No se recalcula al leer. Trade-off: cambio retroactivo de fórmula no aplica a sesiones viejas, pero las queries del historial son triviales.

- **Sesiones inmutables después de cerrar**. No hay UI para editar una sesión pasada. Si te equivocaste, el dato queda. Esto simplifica el modelo de datos y evita inconsistencias retroactivas en las gráficas.

- **Sin estadísticas globales** (volume total all-time, conteo total, etc.) — solo agregados de "esta semana". Por simplicidad de UI y porque conforme el historial crezca esos agregados se vuelven menos representativos.

- **Las sesiones nunca se borran** (ver memoria + `base-de-datos.md`). Wipe sí las elimina (es destructivo intencional), pero no hay opción de borrar una sesión individual.

- **`getExerciseProgress` itera en SQL** — para un usuario con 1000 sesiones × 5 ejercicios × 4 sets, eso son 20k filas a procesar. En la práctica está bien para escalas razonables, pero si se vuelve un cuello de botella futuro, vale considerar materializar `ExerciseProgressPoint` en una tabla y actualizarla on-write.
