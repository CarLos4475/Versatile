# Versatile — UI Summary

## Design System

| Element | Value |
|---------|-------|
| **Style** | Material 3 + custom liquid glass (`GlassContainer`, `GlassButton`) |
| **Theme** | Light (bone white) / Dark (warm dark tones), selectable per user |
| **Accent** | 8 presets: orange (default), blue, green, purple, red, teal, pink, amber |
| **Typography** | System font, weights 400-700 |
| **L10n** | English + Mexican Spanish |
| **Motion** | `PressableScale` wrapper on all interactive elements; `FadeSlideIn` for list entries |
| **Backdrop** | Glassmorphism (`bgApp`, `glassBg`, `glassBorder`) with soft blur + semi-transparent fills |
| **Color access** | Always via `context.colors.accent`, `context.colors.bgApp`, etc. — never hardcoded hex |

---

## 0. Splash Screen
- Centered app logo (Versatile icon, ~140px)
- Animated fade-in + scale
- Checks: onboarding status → pending workout restore → navigates to Onboarding or MainNavigationShell
- Background: `context.colors.bgApp`

---

## 0b. Onboarding (5 pages)

**Layout**: Full-screen `PageView` with animated orbs background (`_BackgroundOrbs`).

| Page | Title | Content |
|------|-------|---------|
| 1 | "Built for every rep" | "A gym tracker that's fast, private, and built for you. No logins, no cloud, just your lifts." |
| 2 | "Log weights. Break records." | "Record every set, rep, and weight. Watch your estimated 1-rep max climb over time." |
| 3 | "Routines your way." | "Build custom workouts with exactly the exercises you need. Reorder them, adjust sets, and keep evolving." |
| 4 | "Your data, your device." | "No internet. No account. No subscription. Everything stays on your phone, always." |
| 5 | "What should we call you?" | Text field for user name. "Optional. You can always skip this." |

- Top-right: "Skip" button → jumps to page 5
- Bottom: "Continue" / "Let's go" button
- Animated floating orbs (accent-tinted, blurred) in background

---

## 1. Main Navigation Shell

**Bottom Tab Bar** — liquid glass style, 4 tabs:

| Tab | Icon | Screen |
|-----|------|--------|
| Home | `home_filled` | `HomeScreen` |
| Routines | `format_list_bulleted` | `RoutinesScreen` |
| Exercises | `fitness_center` | `ExercisesScreen` |
| History | `history` | `HistoryScreen` |

- `IndexedStack` with animated transitions (fade + slide offset between tabs)
- Active tab: accent-colored icon + label; inactive: subdued
- **Active Workout Overlay**: when a workout is running, a floating glass bar appears above the tab bar (104px from bottom) showing routine name + elapsed timer. Tap → resumes workout.

---

## 2. Home Screen

**Header**: greeting ("Hello, {name}") + settings gear icon (top-right)

### Hero Card (main call-to-action)
- Full-width card with routine's accent color gradient
- Routine icon + name + muscle group summary
- "Start" button with glass effect
- Badges: "TODAY'S SESSION" / "PLANNED" / "DELOAD" / "REST DAY"
- Subtitle: last done date or "You haven't done this one yet"

### Recap Banner (if unseen month exists)
- Dark warm gradient card (`#29211A → #3A2A1F → #5C2E1A`)
- Trending-up icon in accent pill (44×44)
- Text: "Your {month} recap is ready" / "{sessions} sessions · {volume} moved"
- Tap → opens `MonthlyRecapScreen`

### Deload Banner (conditional)
- Soft accent-tinted card with bedtime icon
- Title: ¿Toca semana de descarga? / Time for a deload?
- Body varies by signal (stagnation / volume drop / both)
- CTA "Open program" → navigates to `ProgramEditorScreen`
- Dismiss "Not now" → hides 7 days

### Weekly Stats Row
3 horizontal cards:
- **Sessions** — count with icon
- **Volume** — total kg with icon
- **Avg Time** — minutes with icon

### Activity Heatmap
- 26-week grid (7 rows × 26 columns)
- Each cell: trained day = accent gradient fill; rest = subtle border
- Color intensity by volume
- Label: "{n} sessions in the last year"

### Recent Sessions
- Vertical `ListView` of session cards
- Each card: routine icon, name, date, duration, volume, exercise count
- Tap → `SessionDetailScreen`

### Debug (kDebugMode only)
- Pill "Preview recap (debug)" → opens recap with hardcoded fixture

---

## 3. Routines Screen

**Header**: title "Routines" + subtitle "{n} routines in your library" + `+` FAB (accent-filled circle)

**Routine Cards** (vertical list):
- Colored banner strip (routine's color)
- Large routine icon (white, in colored circle)
- Routine name + muscle group summary
- "Last done: {date}" or "Never done"
- "Start" button with play icon
- Tap card → `RoutineDetailScreen`
- Long-press → edit / delete options

**Empty state**: icon + "No routines yet" + "Create your first routine" + glass button

### Create Routine Screen
- Top: "New Routine" header
- Fields: name, color picker (8 presets), icon picker (grid of Material icons)
- "Create routine" glass button
- After save → navigates to `RoutineDetailScreen` to add exercises

### Routine Detail Screen
- Header: routine name + color swatch
- **Exercise list** — drag-reorderable cards:
  - Exercise name + muscle tag
  - Target sets × reps
  - Rest seconds
  - Swipe-to-delete
  - Tap → configure (sets, reps, rest)
- **Add exercise** button (+)
- **Start workout** button — pushes `ActiveWorkoutScreen`
- **Edit** (pencil) → rename, change color/icon
- **Delete** (trash) → confirmation dialog

### Exercise Picker Screen
- Search bar + muscle group filter chips
- Exercise list with checkboxes
- Select exercises → "Add {n}" button
- "Create new" → `AddExerciseScreen`

---

## 4. Exercises Screen

**Header**: title "Exercises" + `+` FAB

**Filter row** — horizontal scrollable chips:
- Category: Push / Pull / Legs (outline accent style when active)
- Divider
- Laterality: Bilateral / Unilateral (filled when active)
- Muscle group dropdown

**Search bar**: text field with search icon

**Exercise list** — vertical `ListView`:
- Each card: exercise name + muscle label + equipment icon + laterality indicator
- Custom exercises marked with "CUSTOM" badge
- Tap → `ExerciseProgressScreen`
- Edit mode (toggle from header) → multi-select → delete

**Empty state**: "No exercises match"

### Add Exercise Screen
- Text field: exercise name (placeholder: "ej. Press de banca")
- Muscle group picker
- Equipment picker (barbell, dumbbell, cable, bodyweight, machine)
- Unilateral toggle
- "Save exercise" glass button

### Exercise Progress Screen
- Exercise name header
- Two interactive charts (fl_chart):
  1. **Estimated 1RM** over time (line chart)
  2. **Volume** over time (bar chart)
- Time range filter: 3 months / 6 months / 1 year / All
- Toggle button to switch metrics
- Tap data points for details

---

## 5. History Screen

**Header**: title "History" + subtitle "{n} total"

**Session cards** — vertical `ListView`:
- Each card: routine icon/name, date, duration, volume, exercise count
- "NEW PR" badge if the session had a personal record
- Tap → `SessionDetailScreen`

**Empty state**: history icon + "No history yet" + "Train to see your progress here"

### Session Detail Screen
- Routine name + date header
- Duration + total volume summary row
- **Exercise breakdown** — per-exercise cards:
  - Exercise name + muscle
  - Set table: set #, kg, reps (left kg/reps for unilateral)
  - Volume per exercise
- Share button → `ShareSessionScreen`
- Progress chart button → `ExerciseProgressScreen`

---

## 6. Active Workout Screen

**Full-screen takeover** — no tab bar visible.

**Header**: 
- Back arrow (left)
- Routine name + icon
- X button (right) → discard confirmation dialog
- Elapsed timer (MM:SS)

**Exercise cards** — vertical `ListView`:
Each card shows:
- Exercise name + muscle + set counter ("Set 3/4")
- Previous session ghost row ("↑ Last: 60kg × 8")
- **Weight input** (numeric, ± buttons)
- **Reps input** (numeric, ± buttons)
- Unilateral: split toggle → shows left/kg + left/reps inputs
- **"Finish set {n}"** button (accent gradient pill)
- Skip button (visible when not done)
- Skipped card: exercise name + "SKIPPED" overlay

**Progress bar** per exercise: filled segments = completed sets / total sets

**PR Celebration Banner**:
- Top-anchored overlay (80px from top)
- Triggers when closing a set that beats historical 1RM
- Pill with gradient accent + trophy icon + "New record! / ¡Nuevo récord!"
- Subtitle: "{exercise} · {kg} kg × {reps}"
- Packageless sparkles (8 particles radiating out)
- Animation: scale-in (0→18%, easeOutBack) → hold (18→78%) → fade-out (78→100%) — 1.8s total
- Haptic feedback (medium impact)

**Rest Timer**:
- After each set: countdown from configured rest seconds
- Timer bar at bottom with remaining time
- "Skip" button → go to next exercise
- "+15s" button → add 15 seconds
- Sound alert on completion (configurable)
- Android: vibration-only notification via foreground service

**Auto-finish**: when all exercises done → `WorkoutCompleteScreen`

### Workout Complete Screen
- "Workout finished!" / "¡Entrenamiento finalizado!"
- "Great job! / ¡Buen trabajo!"
- Summary: total sets, duration, volume
- "NEW PR" badge if any exercise broke a record
- **Share** → `ShareSessionScreen` (generates shareable card image)
- **Done** → pops back to Home

### Share Session Screen
- Renders a styled square card as image (via `RepaintBoundary`)
- Card shows: routine name, date, exercise list with sets, total volume, PR badge
- "Share" button → OS share sheet (`share_plus`)

---

## 7. Programs Screen

**Header**: "Training Plan" / "Plan de entrenamiento"
- Subtitle: explanation text
- "How it works" tooltip with help cards

**Program cards** — vertical list:
- Active program: highlighted with accent border + "ACTIVE" badge
- Each card: name, start date, week count, deload week count
- Swipe actions: activate, deactivate, edit, delete

**FAB**: `+` to create new program

**Empty state**: "No programs yet" + explanation + "Create program"

### Program Editor Screen
- Name text field
- Color picker (8 warm/dark presets)
- Week count selector (± buttons, min 1)
- **Week grid**: each week has a row of 7 day slots
  - Each slot: tap → bottom sheet with:
    - Pick a routine from list
    - Or pick a preset label (Rest, Cardio, Mobility, Stretching)
    - Or type a custom label
  - Routine slots show: routine name + icon in accent-tinted pill
  - Label slots show: label text + coffee icon
- Deload week toggle: mark/unmark entire weeks as deload
- "Save" glass button
- "Activate" → date picker for start date (typically a Monday)

---

## 8. Monthly Recap (Stories-style)

**Full-screen takeover** — dark backdrop, no chrome.

### Container
- Dark base `#0E0B07` (warm near-black)
- Two static radial accent glows: top-right (accent, 35% alpha) + bottom-left (accentDeep, 30% alpha)
- Subtle grain texture (1px dots, 2.5% white, 3px grid)
- Progress bars at top (N segments, white track + bone fill, 2.5px height)
- Close button: 32×32 glass circle, top-right
- Auto-advance per slide (3.5-5.5s)
- Navigation: tap left 35% → back / right 65% → forward / long-press → pause

### Slide Order (6-7 slides, some conditional):
1. **Cover**: month + year eyebrow, "Recap" gradient text (88px, white→accent), subtitle, floating "TAP TO BEGIN"
2. **Sessions**: "You showed up" eyebrow, count-up big number (160px), "times this month", delta pill ("+N more than {month}"), footer with avg per week
3. **Volume** (conditional): "You moved" eyebrow, count-up kg total (100px), "of total weight lifted", weekly bar chart (4-5 bars, accent gradient fill, staggered growth animation), delta pill
4. **Calendar**: "You showed up on" eyebrow, {trained}/{daysInMonth} days, day-of-week labels (S M T W F S), full-month grid with accent-gradient cells for trained days (staggered entry animation), "Best week: {n} sessions" footer
5. **Top Lift** (conditional): "Top lift" eyebrow, exercise name (38px), count-up best kg (110px), delta pill "+N kg this month", sparkline card ("Weekly best · last 7 weeks") with gradient area + animated line + dot markers
6. **Muscle Balance** (conditional): "You focused on" eyebrow, top muscle gradient text (88px), "{pct}% of your work", 6 horizontal bars (Chest/Back/Legs/Shoulders/Arms/Core) ordered by %, top bar with glow, staggered scaleX animation
7. **Outro**: "{Month} · in summary" eyebrow, 3 stat cards (sessions / hours / new PRs, the last accent-highlighted), headline "Keep showing up" gradient text (44px), footer "{month} is just getting started", "Back to training" CTA button (gradient fill, shadow)

### Shared Helpers
- `_GradientText`: ShaderMask with white→accentLight→accent linear gradient, used for hero numbers and headlines
- `_CountUp`: TweenAnimationBuilder counting 0→target with easeOutCubic, 1300ms
- `_Eyebrow`: uppercase text, 13px, w500, letter-spacing 2.6, bone 55% alpha
- `_DeltaPill`: accent-tinted pill with arrow icon + tabular numbers, pillText color (`#F4C2A9`)

### Color Palette (hardcoded, independent of app theme)
- Bone: `#F5EFE2` (100%), 70%, 55%, 45%
- Pill text: `#F4C2A9`
- Dark base: `#0E0B07`

### Data Model
- `MonthlyRecap`: sessionsCount, totalVolumeKg, topRoutine, topExercise, newPRsCount, prevSessionsCount, bestWeekSessions, weeklyVolumeKg, volumeByMuscle (Chest/Back/Legs/Shoulders/Arms/Core), topLift (RecapTopLift)
- `RecapTopLift`: exerciseId, name, muscle, bestKg, bestReps, estimatedOneRm, deltaKgVsPrevMonth, weeklyBests (7 entries)

---

## 9. Settings Screen

**Header**: title "Settings" / "Ajustes"

### Sections (vertical scroll):

**APPEARANCE**
- Theme mode: Light / Dark / System (3 toggle chips)
- Accent color: row of 8 colored circles, selected has checkmark + ring
- Language: English / Español (2 toggle chips)

**PROFILE**
- User name display + "Change name" button
- Opens dialog with text field

**DATA**
- Export data → share JSON via OS share sheet
- Import data → file picker (.json) → confirmation dialog → replaces all data
- Wipe all data → confirmation dialog ("This will permanently delete...") → delete

**TRAINING PLAN**
- Row: "Plan de entrenamiento" + chevron → `ProgramsScreen`

**PAST RECAPS**
- Row: "Resúmenes anteriores" + chevron → `PastRecapsScreen`

**SOUND**
- Rest timer alert toggle
- Sound picker: default / custom (file picker for audio)

**ABOUT**
- Version number
- Author: "CarLos"

---

## 10. Shared Widgets / Patterns

### GlassContainer
- Background: `glassBg` (semi-transparent white/dark)
- Border: `glassBorder` (subtle gradient)
- Border radius: 18-20px
- Inner padding: 14-20px

### GlassButton
- Similar glass styling
- Often used as primary action (Create, Save, Start)
- Accent variant: accent gradient fill + white text

### ScreenHeader
- Large title (28px, w700)
- Optional subtitle (14px, muted)
- Optional trailing widget (icon button)

### PressableScale
- Wraps any pressable widget
- Scale-down animation on press (0.96)
- Smooth spring animation on release

### FadeSlideIn
- Entry animation for list items
- Fade 0→1 + slide up 12px
- Configurable delay (staggered)

### Coachmarks
- Overlay tooltip with target highlight (spotlight cutout)
- Title, body, "Got it" / "Skip all" buttons
- Sequence of 3-5 per feature, stored in preferences

---

## Navigation Graph

```
SplashScreen
├── OnboardingScreen (5 pages)
└── MainNavigationShell
    ├── [Tab 0] Home
    │   ├── ActiveWorkoutScreen → WorkoutCompleteScreen → ShareSessionScreen
    │   ├── SessionDetailScreen → ShareSessionScreen
    │   ├── MonthlyRecapScreen
    │   ├── ProgramEditorScreen
    │   └── SettingsScreen
    │       ├── ProgramsScreen → ProgramEditorScreen
    │       └── PastRecapsScreen → MonthlyRecapScreen
    ├── [Tab 1] Routines
    │   ├── CreateRoutineScreen → RoutineDetailScreen
    │   ├── RoutineDetailScreen → ExercisePickerScreen → AddExerciseScreen
    │   └── RoutineDetailScreen → ActiveWorkoutScreen → WorkoutCompleteScreen
    ├── [Tab 2] Exercises
    │   ├── AddExerciseScreen
    │   └── ExerciseProgressScreen
    └── [Tab 3] History
        └── SessionDetailScreen → ShareSessionScreen

Active Workout Overlay (floating, above tab bar)
```

---

## Key Visual Notes for Design

1. **Glassmorphism is pervasive** — cards, buttons, bottom nav, and the workout overlay all use semi-transparent fills with blur. Not flat Material.

2. **Accent drives all color** — the user's chosen accent color tints cards, progress bars, active states, badges, and the recap gradients. Everything feels personalized.

3. **Dark backdrop for recaps** — the monthly recap is a deliberate visual break: warm dark base (`#0E0B07`) with soft radial glows. Bone-colored text (`#F5EFE2`). It looks like Spotify Wrapped.

4. **Animations are functional** — count-up numbers, staggered card entries, sparkline tracing, bar growth. Not decorative; they guide attention.

5. **Rest timer is a core UX element** — persistent countdown bar at the bottom of the active workout, with +15s and skip controls. The foreground service keeps it alive even when the app is backgrounded.

6. **Unilateral support** — exercises can be marked unilateral. During a workout, a split toggle shows left-side weight/reps inputs. The recap and history correctly aggregate both sides.

7. **Programs = periodization** — multi-week training plans assign routines or labels to each day. Deload weeks are visually marked. The home screen shows the current day's assignment.
