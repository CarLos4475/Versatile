# MEMORY.md — Versatile Project Overview

## Pending tasks

See `project_pending_tasks.md`.

## What is Versatile?

A workout-tracking Flutter app. Users create routines with exercises, start workouts, log sets (weight × reps), and review history. Supports custom exercises, bilateral/unilateral modes, rest timers with alerts, accent color theming, ES/EN localization, and an Android foreground service notification.

## Tech Stack

- **Flutter** (Dart) with `flutter_riverpod` for state management
- **SQLite** via `sqflite` — single `DatabaseHelper` singleton (`lib/data/database/database_helper.dart`)
 - **Localization**: gen-l10n via `l10n.yaml`. **Source files are the `.arb` files** (`app_en.arb`, `app_es.arb`). The `.dart` files (`app_localizations.dart`, `_en.dart`, `_es.dart`) are auto-regenerated on build. NEVER edit the `.dart` l10n files directly — always add strings to the `.arb` files first, then run `flutter gen-l10n`.
- **Android**: `WorkoutService.kt` (foreground service), MethodChannel for rest alerts (vibration-only notification; sound is played from Dart)
- **Audio**: `audioplayers` (`^6.6.0`) for rest timer alert sounds. Custom sounds set `AudioContext` with `gainTransientMayDuck` to avoid pausing background music. Native (MainActivity.kt) does NOT play audio — it only shows the notification + vibration.

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

## Session Repository Queries

- Always order session queries by `date DESC, rowid DESC` — never rely on `rowid` alone. SQLite can reuse rowid values after deletions, so `rowid DESC` may return stale rows. The `date` column is the chronologically correct sort key.
- `getPreviousPerformance()` is used by the active workout screen to show "↑ Last" ghost rows per exercise. It fetches sets from the most recent session for the given routine.

### Cancel Workout
- Cancel button (X icon in header, next to back arrow) shows `AlertDialog` using `discardWorkoutTitle`/`discardWorkoutContent` l10n strings
- On confirm: calls `cancelWorkout()` on notifier (stops all timers), stops `WorkoutNotificationService`, clears `activeWorkoutRoutineIdProvider`, pops back
- `dispose()` also stops the notification service as a safety net

### Skip Exercise
- Skip button in `_CardHeader` (styled like the pause button: `accentTint` bg, `accentDeep` icon, 36x36, border-radius 12), visible when `!isDone && !skipped`
- Tapping shows a confirmation dialog (`skipExercise`/`skipExerciseContent` l10n)
- On confirm: `skipExercise()` fills `completedSets` with `prevSets` data copied from last session (repeating last prevSet to meet `targetSets`), marks `skipped = true` on the exercise state
- Skipped card shows only: exercise name (tiny, 11px, top-left) + accent overlay with "SKIPPED" centered — no other UI leaks through
- Skipped exercises save the filled sets into the session history (no empty gaps)

## Three features added (2026-05-17)

- **PR auto-detect realtime** — `epleyOneRm` + `detectRealtimePR` in `recap_view_model.dart`, hooked into `finishSet()` in `active_workout_view_model.dart`. Celebration banner (`pr_celebration_banner.dart`) with packageless sparkles + haptic feedback. Cached for share card.
- **Tags Nivel 1** — `ExerciseCategory` enum (push/pull/legs/other) in `exercise_category.dart`. Filter chips in exercises list screen. `volumeByCategory` on `MonthlyRecap`.
- **Deload sugerido** — `deload_view_model.dart` with stagnation + volume drop signals. Banner on home screen (_DeloadBanner) dismissable 7 days.

## Recap redesign (Stories-style)

Fully rewritten as Instagram/Spotify Stories takeover:
- **7 slides**: Cover, Sessions, Volume, Calendar, TopLift, MuscleBalance, Outro (`recap_slides.dart:1-1315`).
- **Stories container**: auto-advance per slide, tap left/right zones, long-press pause, progress bars top (`monthly_recap_screen.dart:1-305`).
- **Static backdrop**: dark base `#0E0B07` + two radial accent glows + grain texture (`recap_backdrop.dart`). No more animated aurora.
- **Banner moved to Home** — `_RecapHomeBanner` in `home_screen.dart`. `_DebugRecapPreviewPill` also on Home. History screen cleaned up.
- **Data model extended**: `MonthlyRecap` gained `prevSessionsCount`, `bestWeekSessions`, `newPRsCount`, `weeklyVolumeKg`, `volumeByMuscle`, `topLift` (new `RecapTopLift` sub-entity).
- **Key fix**: `_SlideShell` must NOT wrap its content in `Positioned.fill` (it's inside another `Positioned.fill` in the screen, which is already a direct child of Stack). Use `StackFit.expand` on the parent Stack instead.
- **Key fix**: Use `DefaultTextStyle` (pure override) instead of `DefaultTextStyle.merge` — the merge inherited a background Paint from the app theme that painted over the backdrop.
- **L10n**: ~20 new ES/EN strings. ES uses Mexican Spanish (no "vos" forms, no "lifts", "PRs" → "Récords", etc.).

## L10n ARB File Trap

The `.dart` l10n files are auto-generated on build from the `.arb` files. Adding getters directly to the `.dart` files WILL be reverted on the next build. Always edit `app_en.arb` and `app_es.arb` first, then run `flutter gen-l10n` or let the build regenerate.
