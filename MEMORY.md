# MEMORY.md — Versatile Project Overview

## What is Versatile?

A workout-tracking Flutter app. Users create routines with exercises, start workouts, log sets (weight × reps), and review history. Supports custom exercises, bilateral/unilateral modes, rest timers with alerts, accent color theming, ES/EN localization, and an Android foreground service notification.

## Tech Stack

- **Flutter** (Dart) with `flutter_riverpod` for state management
- **SQLite** via `sqflite` — single `DatabaseHelper` singleton (`lib/data/database/database_helper.dart`)
- **Localization**: gen-l10n with `AppLocalizations` (EN + ES)
- **Android**: `WorkoutService.kt` (foreground service), MethodChannel for rest alerts
- **Audio**: `audioplayers` for rest timer alert sounds

## Directory Structure

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp, MainNavigationShell, navbar, active workout overlay
├── core/
│   ├── navigation/                    # Page transitions (app_page_transitions.dart)
│   ├── providers/                     # Riverpod providers (accent, locale, theme, repositories)
│   ├── services/                      # WorkoutNotificationService, SoundService, DataService
│   ├── theme/                         # AppColors (ThemeExtension), AccentColors, AppTheme (light/dark), glass effects
│   └── utils/                         # FormatUtils, l10n_utils
├── data/
│   ├── database/                      # database_helper.dart (SQLite schema v6)
│   ├── repositories/                  # exercise, routine, session, settings, workout_log repositories
│   └── seed_data.dart                 # Predefined exercises + routines
├── domain/entities/
│   ├── exercise.dart                  # Exercise (id, name, muscle, equipment, is_custom, is_unilateral)
│   ├── routine.dart                   # Routine + RoutineExercise (target_sets, target_reps, rest_seconds)
│   ├── session.dart                   # Session + SessionExercise (snapshot of completed workout)
│   └── workout_set.dart               # WorkoutSet (kg, reps, leftKg?, leftReps?)
├── features/
│   ├── active_workout/                # Active workout screen, view model, widgets (exercise_card, rest_timer_bar, number_input)
│   ├── exercises/                     # Exercise library + custom exercise creation
│   ├── history/                       # Session history + detail view
│   ├── home/                          # Dashboard (today's session, week stats, activity grid)
│   ├── onboarding/                    # First-run onboarding flow
│   ├── routines/                      # Routine library, create/edit routines, configure exercises
│   ├── settings/                      # Settings (accent, theme, language, profile, data export/import, sound)
│   └── splash/                        # Splash → restore or home
├── l10n/                              # app_localizations.dart (abstract), _en.dart, _es.dart
└── shared/widgets/                    # GlassContainer, GlassButton, PressableScale, ScreenHeader, BottomNavBar
```

## Database Schema (v6)

| Table | Key Columns | Purpose |
|---|---|---|
| `exercises` | id, name, muscle, equipment, is_custom, is_unilateral | Exercise catalog |
| `routines` | id, name, color_value, icon_code | Routine definitions |
| `routine_exercises` | routine_id, exercise_id, target_sets, target_reps, rest_seconds, sort_order | Join table |
| `sessions` | id, routine_id, routine_name, color_value, icon_code, date, duration_min, volume_kg | Completed workouts |
| `session_exercises` | id, session_id, exercise_id, exercise_name, muscle, sort_order | Per-session exercise snapshots |
| `session_sets` | session_exercise_id, set_index, kg, reps, left_kg, left_reps | Individual set data |
| `settings` | key (TEXT PK), value | Key-value store |
| `workout_log` | date (TEXT PK) | Activity tracking grid |

## Theme System

- `AccentColors` defines 8 presets (orange default, blue, green, purple, red, teal, pink, gray)
- Each preset has `soften()`, `deepen()`, `lighten()` HSL-based variants
- `AppColors` is a `ThemeExtension` with 25+ named properties: `accent`, `accentSoft`, `accentDeep`, `accentLight`, `accentTint`, `bgApp`, `bgFrame`, `glassBg`, `glassBorder`, `hairline`, `press`, `fieldBg`, `doneTint`, etc.
- `AppTheme.light(accentColor)` / `AppTheme.dark(accentColor)` builds the full ThemeData
- **Always use `context.colors.accent`** — never hardcode `Colors.orange` or hex colors

## Navigation

- `MaterialApp.router` NOT used — standard `Navigator.push/pop` via `MaterialPageRoute`
- `MainNavigationShell`: bottom tab bar (Home, Routines, Exercises, History) using `IndexedStack` + animated transitions
- Active workout overlay: floating liquid-glass bar at bottom when `activeWorkoutRoutineIdProvider != null`
- Workout screen: pushed as full-screen `MaterialPageRoute`
- Splash screen checks for active workout → restores via `pendingWorkoutRestoreProvider`

## Key View Model: ActiveWorkoutNotifier

- `ActiveWorkoutState` holds: routine, exercises, elapsedSeconds, isRunning, exerciseStates, restTimer, autoFinish
- `ExerciseWorkoutState` per exercise: exerciseId, targetSets, targetReps, restSec, isExpanded, completedSets, currentInput, prevSets, isUnilateral, isSplitMode, skipped
- `RestTimerState`: total, remaining, exerciseName
- Timer: `_sessionTimer` (1s tick for elapsed), `_restTicker` (1s countdown for rest)
- Progress: saved/restored via JSON in `WorkoutNotificationService`
- On finish: builds `Session` with `SessionExercise` lists, inserts into DB, logs day

## Key Entities

- `Session`: id, routineId, routineName, colorValue, iconCode, date, durationMin, volumeKg, exercises (List<SessionExercise>)
- `SessionExercise`: exerciseId, name, muscle, sets (List<WorkoutSet>), computed volume
- `WorkoutSet`: kg, reps, leftKg?, leftReps?, computed volume, computed isSplit
- `Routine`: id, name, colorValue, iconCode, exercises (List<RoutineExercise>), lastDoneDaysAgo
- `Exercise`: id, name, muscle, equipment, isCustom, isUnilateral, getLocalizedName/muscle (l10n-aware)
