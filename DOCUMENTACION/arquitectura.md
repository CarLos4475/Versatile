# Arquitectura general

Visión global de cómo está organizada la app. Doc de referencia para entender dónde vive qué cosa antes de leer las features individuales.

---

## 1. Stack

- **Flutter** (Material 3, soporte Android principal — iOS está en el proyecto pero no es el target activo).
- **Riverpod** (`flutter_riverpod`) para estado y dependency injection.
- **SQLite** vía `sqflite` para persistencia (no se usa SharedPreferences en Flutter — todo va a la tabla `settings` o a tablas dedicadas).
- **SharedPreferences nativas (Android)** sí se usan, pero solo en `WorkoutService.kt` para el foreground service (ver `sesion-activa.md`).
- **fl_chart** para gráficas de progreso.
- **audioplayers**, **share_plus**, **file_picker**, **path_provider** como utilities.
- **uuid** para IDs.
- L10n por `flutter_localizations` + ARB files. **NO** corre `flutter gen-l10n` automáticamente — sincronización manual (ver `l10n` en este doc).

## 2. Estructura de carpetas

```
lib/
├── app.dart                    MaterialApp + MainNavigationShell (4 tabs + overlay)
├── core/
│   ├── navigation/             AppRoute (custom PageRouteBuilder)
│   ├── providers/              Repository providers + theme/locale/accent
│   ├── services/               CoachmarkService, SoundService, DataService
│   ├── theme/                  AppColors extension + AccentColors
│   └── utils/                  FormatUtils (date/duration/volume/timer/weight)
├── data/
│   ├── database/               DatabaseHelper singleton + seed data
│   └── repositories/           Un repositorio por agregado
├── domain/
│   └── entities/               Modelos planos (Routine, Exercise, Session, …)
├── features/
│   ├── active_workout/         Sesión activa (screens, view_models, widgets)
│   ├── exercises/              Library + custom + progress
│   ├── history/                Historial + session detail
│   ├── home/                   Hero card + activity grid + recent sessions
│   ├── onboarding/             5 páginas (4 intro + nombre)
│   ├── programs/               Plan de entrenamiento
│   ├── routines/               CRUD rutinas + exercise picker
│   ├── settings/               Toda la pantalla de ajustes
│   └── splash/                 Splash + detección de workout activo
├── l10n/                       ARB files + 3 archivos generados (sync manual)
└── shared/
    └── widgets/                Design system (Glass*, Pressable*, FadeSlideIn, ScreenHeader, CoachmarkOverlay)
```

**Convención feature-first**: cada feature tiene `screens/`, `view_models/`, `widgets/`. Nada se importa entre features sin pasar por `domain/` o `core/`.

## 3. Capas

```
┌──────────────────────────────────────────┐
│   features/*/screens   (UI)              │  ConsumerWidget / ConsumerStatefulWidget
├──────────────────────────────────────────┤
│   features/*/view_models   (Riverpod)    │  Provider, StateNotifierProvider, FutureProvider
├──────────────────────────────────────────┤
│   data/repositories   (CRUD)             │  Sin conocimiento de UI
├──────────────────────────────────────────┤
│   data/database   (DatabaseHelper)       │  Singleton, sqflite
└──────────────────────────────────────────┘
```

Las entidades en `domain/entities/` son **plain Dart classes** (no JSON serialization codegen, no equatable, no immutability libraries). Constructor `const`, métodos `copyWith` cuando hace falta.

## 4. Patrones Riverpod

### Repository providers (en `core/providers/repository_providers.dart`)
```dart
final routineRepositoryProvider = Provider<RoutineRepository>((_) => RoutineRepository());
final sessionRepositoryProvider = Provider<SessionRepository>((_) => SessionRepository());
final programRepositoryProvider = Provider<ProgramRepository>((_) => ProgramRepository());
// ...
```

### Listas async derivadas de repos
```dart
final sessionsAsyncProvider = AsyncNotifierProvider<SessionsAsyncNotifier, List<Session>>(...);
final programsListProvider = FutureProvider<List<Program>>((ref) async { ... });
```

### Estado computado (sync, combina varios providers)
```dart
final homeProvider = Provider<HomeState>((ref) {
  final sessions = ref.watch(sessionsAsyncProvider).value ?? [];
  // ... combina con routines, programs, workout log, etc.
});
```

### View models con estado mutable
- Patrón `StateNotifierProvider.autoDispose.family<Notifier, State, Arg>` — usado en `activeWorkoutProvider`.
- `autoDispose` libera memoria cuando ningún widget está escuchando.
- `family<>` para parametrizar (p. ej., el routineId del workout activo).

### Invalidación manual
Después de mutaciones, los view models llaman `ref.invalidate(provider)` para forzar refresh. Ejemplos: `programsListProvider`, `sessionsAsyncProvider`, `activeProgramProvider`.

## 5. Navegación

**Shell de 4 tabs** (`MainNavigationShell` en `app.dart`):
- Tab 0: Home
- Tab 1: Routines
- Tab 2: Exercises
- Tab 3: History

Usa `IndexedStack` (mantiene el estado de cada tab vivo) envuelto en `FadeTransition` + `SlideTransition` controlados por un `AnimationController` de 320ms. Dirección del slide depende de `forward` o `back` entre tabs.

**Overlay de workout activo**: cuando `activeWorkoutRoutineIdProvider != null`, aparece flotando arriba del navbar con cronómetro y nombre de la rutina. Tap → push a `ActiveWorkoutScreen`.

**Páginas individuales** se pushean con `AppRoute` (custom `PageRouteBuilder` en `core/navigation/app_page_transitions.dart`):
- Duración: 420ms forward, 320ms reverse.
- Combinación de Slide + Fade + Scale para una transición premium.

## 6. Design system

Vive en `lib/shared/widgets/` y `lib/core/theme/`.

**Colores**: extension `context.colors` sobre `BuildContext` que expone tokens: `accent`, `accentLight`, `accentDeep`, `accentTint`, `ink900`, `ink700`, `ink500`, `ink400`, `ink300`, `bgApp`, `bgFrame`, `glassBg`, `glassBorder`, `hairline`, `press`. Nunca hardcodear colores.

**Glass morphism** (lenguaje visual principal):
- `GlassContainer` — `BackdropFilter(blur 8|12) + bg semi-transparente + hairline border + shadow sutil`.
- `GlassButton` — variantes `primary` (gradient accent), `glass` (semi-transparente), `ghost` (solo texto). Tamaños `sm/md/lg`.
- Active workout overlay y nav bar usan blur 28-36 con gradientes accent.

**Motion**:
- `PressableScale` — todo elemento tappable debe envolverse aquí (scale 0.97 + opacity 0.96, 110ms). No usar `InkWell`/`GestureDetector` directo.
- `FadeSlideIn` — animación de entrada de las cards (fade + slide desde abajo).
- `ScreenHeader` — header reutilizable con título, subtítulo, back button opcional, trailing opcional.

## 7. Localización (l10n)

**Source of truth**: `lib/l10n/app_en.arb` + `lib/l10n/app_es.arb`.

**Archivos generados manualmente** (3):
- `lib/l10n/app_localizations.dart` — clase abstracta con todos los getters/métodos.
- `lib/l10n/app_localizations_en.dart` — implementación EN.
- `lib/l10n/app_localizations_es.dart` — implementación ES.

**`flutter gen-l10n` NO se ejecuta automáticamente** — al editar los ARB hay que sincronizar a mano los 3 archivos generados siguiendo el patrón existente. Esto está en `MEMORY.md` como decisión del proyecto.

**Plurales**: usar `intl.Intl.pluralLogic` (`one`/`other`). Ejemplos en `weeksCountValue`, `programWeeksSummary`, `deleteExerciseContent`.

**Detección de idioma**: el primer launch detecta el idioma del sistema (`locale_provider.dart`) y lo persiste en settings como `language_code`. EN y ES soportados.

## 8. Tabla de servicios singletons

| Servicio | Ubicación | Responsabilidad |
|---|---|---|
| `DatabaseHelper.instance` | `data/database/` | Singleton de la BD sqflite |
| `CoachmarkService` | `core/services/` | `shouldShow(id)` / `markSeen(id)` |
| `SoundService` | `core/services/` | Reproducir alarma de rest (custom o default) |
| `DataService` | `core/services/` | Export/import JSON |
| `WorkoutNotificationService` | `core/services/` | Bridge al foreground service nativo |

## 9. Plataforma nativa (Android)

Código Kotlin en `android/app/src/main/kotlin/com/example/versatile/`:
- `MainActivity.kt` — registra `MethodChannel("com.example.versatile/workout")` con handlers: `startWorkoutService`, `stopWorkoutService`, `saveWorkoutProgress`, `getActiveWorkout`, `showRestAlert`. Maneja el sonido de alerta vía `MediaPlayer` (API 28+) o `Ringtone` (legacy).
- `WorkoutService.kt` — `Service` con notificación foreground, ticker de 1Hz, persistencia en `SharedPreferences`.

iOS está en `ios/` pero las features de notificación + audio focus están escritas solo para Android. La app corre en iOS si se necesita pero sin esas integraciones nativas.

## 10. Lo que NO usa la app

Para evitar confusión al llegar al código:

- **No usa GoRouter / auto_route / cualquier librería de routing declarativa.** Solo `Navigator.push` + `MaterialPageRoute` o `AppRoute` custom.
- **No usa freezed / json_serializable / build_runner.** Las entidades son dart puro.
- **No usa get_it / injectable.** DI vía Riverpod providers.
- **No tiene tests** más allá del `widget_test.dart` default.
- **No tiene CI/CD.** Build manual.
- **No tiene analytics / crash reporting.** Privacy-first.
- **No tiene cuenta de usuario / cloud sync.** Todo local.
