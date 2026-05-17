# Rutinas y biblioteca de ejercicios

Dos features tightly coupled: la **biblioteca de ejercicios** (catálogo seed + custom) y las **rutinas** (plantillas que combinan ejercicios con sets/reps/rest específicos).

**Archivos principales:**
- `lib/features/exercises/screens/exercises_screen.dart` — biblioteca + filtros + edit mode
- `lib/features/exercises/screens/add_exercise_screen.dart` — crear ejercicio custom
- `lib/features/exercises/screens/exercise_progress_screen.dart` — gráfica de progreso (cubierta en `historial-y-progreso.md`)
- `lib/features/routines/screens/routines_screen.dart` — lista de rutinas
- `lib/features/routines/screens/create_routine_screen.dart` — crear rutina vacía
- `lib/features/routines/screens/routine_detail_screen.dart` — ver/editar rutina
- `lib/features/routines/screens/exercise_picker_screen.dart` — agregar ejercicios con config
- `lib/data/repositories/exercise_repository.dart`, `routine_repository.dart`
- `lib/domain/entities/exercise.dart`, `routine.dart`

---

## 1. Ejercicios

### Entidad

```dart
class Exercise {
  final String id;
  final String name;
  final String muscle;       // Chest, Back, Biceps, Quadriceps, etc.
  final String equipment;    // Barbell, Dumbbell, Cable, Bodyweight, Machine
  final bool isCustom;       // false = seed, true = creado por usuario
  final bool isUnilateral;   // habilita split mode en workout
}
```

### Catálogo seed (19 ejercicios)

Definido en `database_helper.dart::_seed`. IDs `ex-1` … `ex-17` para los principales, `ex-c1`/`ex-c2` como ejemplos de custom marcados con `is_custom=1`.

Cobertura: Chest, Back, Quadriceps, Hamstrings, Shoulders, Biceps, Triceps, Core. Con variedad de equipment.

Los seed son **inmutables** (no se pueden borrar desde la app — el toggle "Edit" en la biblioteca solo permite operar sobre los custom).

### Ejercicios custom

Creados en `AddExerciseScreen`. Campos editables:
- **Name** (required, autofocus, `TextCapitalization.words`).
- **Muscle group**: 6 opciones principales (Chest, Back, Shoulders, Core, Arms, Legs).
- **Sub-muscle** (condicional): si elige Arms → Biceps/Triceps/Forearms. Si elige Legs → Quadriceps/Hamstrings/Glutes/Calves. La columna `muscle` guarda el sub-músculo si se seleccionó, sino el principal.
- **Equipment**: Barbell / Dumbbell / Cable / Bodyweight / Machine.
- **Bilateral / Unilateral** toggle.

ID generado con `Uuid().v4()`. Persistido en `exercises` con `is_custom=1`.

### Unilateral vs bilateral

Un ejercicio con `isUnilateral=true` (ej. lateral raise, bicep curl):
- En la sesión activa, el card del ejercicio muestra un toggle "Split mode".
- Si **OFF**: se loguea un solo set (kg/reps), se aplica simétricamente.
- Si **ON**: aparecen dos columnas (izq / der), se persisten `left_kg` y `left_reps` además de `kg`/`reps` en `session_sets`.

Visible en el catálogo con un badge "UNILATERAL".

### Pantalla `ExercisesScreen` (biblioteca)

Tabs:
- **All** — total seed + custom, con conteo `${count} en biblioteca`.
- **Custom** — solo los creados por el usuario.

Filtros (chips):
- Muscle group: All + 7 principales (Chest, Back, Legs, Shoulders, Arms, Core).
- Submuscle (visible solo cuando Arms o Legs está seleccionado): para narrowing.
- Laterality: All / Bilateral / Unilateral.
- Search: texto libre, match contra nombre.

**Edit mode**: toggle con icono de checkmark. Permite seleccionar múltiples ejercicios custom para borrar. AlertDialog con plural-aware confirmation:
> "This will permanently delete {count} custom {exercise/exercises}. This cannot be undone."

Al borrar, también limpia referencias en `routine_exercises` (cascada vía `RoutineRepository.deleteReferencesToExercise`).

**Coachmarks**: `exercises` (search bar) + `exercise_add` (botón +) — encadenados.

---

## 2. Rutinas

### Entidad

```dart
class Routine {
  final String id;
  final String name;
  final int colorValue;            // ARGB32
  final int iconCode;              // codepoint Material
  final List<RoutineExercise> exercises;

  int get estimatedMinutes => exercises.fold(
    0,
    (sum, e) => sum + ((e.targetSets * (e.restSeconds + 30)) ~/ 60),
  );
}

class RoutineExercise {
  final int? dbId;            // PK auto-incrementado, null hasta inserción
  final String exerciseId;
  final int targetSets;
  final String targetReps;    // "8-12" o "5"
  final int restSeconds;
}
```

`estimatedMinutes` asume ~30s por set + el rest configurado. Aproximación útil para el hero card del home.

### Crear rutina

`CreateRoutineScreen`:
- Name (autofocus, TextCapitalization.words).
- 8 colores predefinidos (`_kColors` — paleta accent + complementarios).
- 11 iconos predefinidos (`_kIcons` — fitness_center, bolt, timer, favorite, trending_up, directions_run, etc.).
- "Create" → inserta rutina vacía y push (replace) a `RoutineDetailScreen` para que el usuario agregue ejercicios.

### Editar rutina (`RoutineDetailScreen`)

Dos modos:

**View mode** (default):
- Header con icono + nombre + meta ("{count} ejercicios · ~{min} min").
- ListView con cards por ejercicio: drag handle, icono de músculo, nombre, "{sets} × {reps} · {rest}s rest".
- Botón "Start this workout" → `ActiveWorkoutScreen`.
- Botón "Edit" → cambia a edit mode.

**Edit mode**:
- Name editable (GlassContainer + TextField).
- Color picker (8 colores, mismo `_kColors`).
- Icon picker (11 iconos).
- ReorderableListView con drag handles para los ejercicios.
- Botón "+" para agregar más → push a `ExercisePickerScreen`.
- Tap a un ejercicio existente → dialog "Configure Exercise" (sets, reps, rest).
- Long-press / icono de delete → remueve ejercicio.
- Botón "Done" → guarda y vuelve a view.

**Eliminar rutina**: confirmación con AlertDialog ("Delete routine 'X'?"). CASCADE en BD limpia `routine_exercises`.

**Coachmark**: `routine_edit` se dispara la primera vez que entras a la rutina en view mode.

### Configurar ejercicio (dialog)

Aparece al agregar uno nuevo (`ExercisePickerScreen`) o al tappear uno existente (`RoutineDetailScreen` edit mode).

Tres controles:
- **Sets** (1–20): stepper +/-.
- **Reps** (free text, default "8-12"): TextField con `scrollable: true` en el AlertDialog para no overflow con teclado.
- **Rest seconds** (15–600, incrementos de 15): stepper +15/-15.

### Exercise picker

`ExercisePickerScreen` se llama con la lista actual de ejercicios de la rutina como argumento.

- Lista filtrable (search + muscle filter).
- Checkboxes para multi-select.
- Al final, "Add" → muestra el dialog de config **una vez por cada ejercicio seleccionado**, en secuencia.
- Inserción en `routine_exercises` preservando el `sort_order` correcto.

---

## 3. Patrones reutilizados

- **Color picker**: `RoutineColorPicker` (en `routines/widgets/`). Recibe lista de Colors + selected + callback. Se reutiliza también en el **editor de programas** (ver `plan-de-entrenamiento.md`).
- **GlassContainer + GlassButton** para todas las cards y CTAs.
- **PressableScale** envuelve todo elemento tappable.
- **FadeSlideIn** anima las cards al aparecer.
- **AlertDialog con `scrollable: true`** para confirmaciones (defensa contra fuentes del sistema grandes).

---

## 4. Cómo se ata todo

```
ExercisesScreen          ← muestra catálogo
       ↓ tap +
AddExerciseScreen        ← crea custom (is_custom=1)
       ↓ guardar
exercises table
       ↑
       │ referenciado por
       │
routine_exercises ←──── RoutineDetailScreen (edit)
       ↑                      ↑
       │ pertenece a          │ tap "Add exercise"
       │                      ↓
   routines ←──── ExercisePickerScreen
       ↑
       │
CreateRoutineScreen      ← inserta routine vacía
```

Y para sesión:

```
RoutineDetailScreen
       ↓ tap "Start workout"
ActiveWorkoutScreen (con routineId)
       ↓ usa workoutInitProvider
RoutineRepository.findById + ExerciseRepository.getAll + SessionRepository.getPreviousPerformance
```

`getPreviousPerformance(routineId)` retorna un `Map<exerciseId, List<WorkoutSet>>` con los sets de la última sesión que usó esa rutina. Eso alimenta `prevSets` del view model activo y sugiere los pesos/reps iniciales.

---

## 5. Limitaciones / deuda

- No hay **categorías de rutina** (push/pull/legs, upper/lower, etc.) — pero el feature de programas (ver `plan-de-entrenamiento.md`) cubre la planificación.
- No hay **supersets** ni **circuits**. Cada ejercicio tiene su rest independiente. Está pendiente en `MEMORY.md` como idea de la dirección 1 (workout intelligence).
- No hay **plate calculator** — pendiente en backlog.
- No hay **warmup sets** automáticos.
- No hay **drop sets** o **rest-pause** marcados explícitamente.
- Los ejercicios seed no son editables (por diseño — para preservar integridad del catálogo).
