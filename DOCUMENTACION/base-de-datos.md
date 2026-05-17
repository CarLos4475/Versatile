# Base de datos

Esquema completo de la BD SQLite. Referencia rápida para entender qué guarda la app y cómo evolucionó el schema.

**Archivo:** `lib/data/database/database_helper.dart`
**Versión actual:** v7
**Engine:** sqflite (SQLite via FFI en Android)
**Path:** `getDatabasesPath()/versatile.db`
**Foreign keys:** activadas (`PRAGMA foreign_keys = ON` en `onConfigure`)

---

## 1. Tablas (estado actual, v7)

### `exercises`
Catálogo de ejercicios — incluye los seed (`is_custom = 0`) y los creados por el usuario (`is_custom = 1`).

```sql
CREATE TABLE exercises (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  muscle TEXT NOT NULL,
  equipment TEXT NOT NULL,
  is_custom INTEGER NOT NULL DEFAULT 0,
  is_unilateral INTEGER NOT NULL DEFAULT 0
)
```

- `muscle`: principal o sub-músculo (Chest, Back, Biceps, Triceps, Quadriceps, Hamstrings, Glutes, Calves, Shoulders, Core, Forearms, Other).
- `equipment`: Barbell | Dumbbell | Cable | Bodyweight | Machine.
- `is_unilateral=1` activa el modo "split" en el workout (tracking por lado izquierdo/derecho).
- IDs seed (`ex-1`, `ex-2`, …) son inmutables. IDs custom usan UUID v4.

### `routines`
Plantilla de entrenamiento que el usuario configura.

```sql
CREATE TABLE routines (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color_value INTEGER NOT NULL,
  icon_code INTEGER NOT NULL DEFAULT 58713  -- fitness_center
)
```

### `routine_exercises`
Ejercicios incluidos en una rutina, con su config (sets/reps/rest).

```sql
CREATE TABLE routine_exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  routine_id TEXT NOT NULL,
  exercise_id TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  target_sets INTEGER NOT NULL,
  target_reps TEXT NOT NULL,        -- "8-12", "5", etc.
  rest_seconds INTEGER NOT NULL,
  FOREIGN KEY (routine_id) REFERENCES routines(id) ON DELETE CASCADE,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id)
)
```

- `target_reps` es **string** para soportar rangos ("8-12") tanto como valores exactos ("5").
- `sort_order` define el orden — modificable vía reorder en el editor de rutina.

### `sessions`
Workout completado (snapshot histórico — los campos `routine_name`, `color_value`, `icon_code` se duplican aquí para que el historial sobreviva al borrado de la rutina).

```sql
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  routine_id TEXT NOT NULL,
  routine_name TEXT NOT NULL,
  color_value INTEGER NOT NULL DEFAULT 0xFFD97757,
  icon_code INTEGER NOT NULL DEFAULT 58713,
  date TEXT NOT NULL,           -- YYYY-MM-DD
  duration_min INTEGER NOT NULL,
  volume_kg REAL NOT NULL
)
```

**Decisión clave (en memoria):** las sesiones NUNCA se borran. `deleteOldSessions()` se removió a propósito. El historial es permanente.

### `session_exercises`
Ejercicios realizados en una sesión (también snapshot del nombre + músculo para resistir cambios futuros al exercise).

```sql
CREATE TABLE session_exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT NOT NULL,
  exercise_id TEXT NOT NULL,
  exercise_name TEXT NOT NULL,
  muscle TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
)
```

### `session_sets`
Cada set individual logueado. `left_*` solo se usa en ejercicios unilaterales con modo split.

```sql
CREATE TABLE session_sets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_exercise_id INTEGER NOT NULL,
  set_index INTEGER NOT NULL,
  kg REAL NOT NULL,
  reps INTEGER NOT NULL,
  left_kg REAL,
  left_reps INTEGER,
  FOREIGN KEY (session_exercise_id) REFERENCES session_exercises(id) ON DELETE CASCADE
)
```

### `settings`
Key-value store genérico.

```sql
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
```

Keys conocidas:
| Key | Tipo | Valor |
|---|---|---|
| `user_name` | string | Default `'there'` |
| `onboarded` | bool string | `'1'` cuando ya pasó el onboarding |
| `theme_mode` | string | `'light'` / `'dark'` / `'system'` |
| `language_code` | string | `'en'` / `'es'` |
| `accent_color` | string | `'orange'` / `'blue'` / etc. |
| `rest_alert_enabled` | bool string | `'false'` para silenciar |
| `rest_alert_sound_type` | string | `'default'` / `'custom'` |
| `rest_alert_custom_path` | string | File path |
| `coachmark_v1_{id}` | bool string | `'1'` cuando el coachmark fue visto |
| `active_program_id` | string | UUID del programa activo |
| `active_program_start_date` | ISO date | Fecha de inicio de la semana 1 |

El prefijo `coachmark_v1_` permite bumpear a `v2` y resetear todos los coachmarks de un golpe en una migración futura.

### `workout_log`
Solo registra las fechas en que el usuario entrenó, para el activity grid del home.

```sql
CREATE TABLE workout_log (
  date TEXT PRIMARY KEY  -- YYYY-MM-DD
)
```

Se inserta con `INSERT OR IGNORE` desde `finishWorkout()`. El home combina esto con las fechas de `sessions` para el heatmap estilo GitHub.

### `programs` (v7)
Templates del plan de entrenamiento. Ver `plan-de-entrenamiento.md` para detalle.

```sql
CREATE TABLE programs (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color_value INTEGER NOT NULL,
  icon_code INTEGER NOT NULL DEFAULT 58713,
  weeks_count INTEGER NOT NULL,
  deload_weeks TEXT NOT NULL DEFAULT '',  -- CSV "2,5"
  created_at TEXT NOT NULL
)
```

### `program_slots` (v7)
Una fila por celda (programa, semana, día de la semana).

```sql
CREATE TABLE program_slots (
  id TEXT PRIMARY KEY,
  program_id TEXT NOT NULL,
  week_index INTEGER NOT NULL,
  weekday INTEGER NOT NULL,       -- 1..7 (1=Lun)
  slot_kind TEXT NOT NULL,        -- 'routine' | 'label'
  routine_id TEXT,
  label_text TEXT,
  UNIQUE(program_id, week_index, weekday),
  FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
  FOREIGN KEY (routine_id) REFERENCES routines(id) ON DELETE SET NULL
)
```

---

## 2. Historial de migraciones

`_onUpgrade` ejecuta los bloques en orden si la BD vieja es anterior a esa versión. Cada bloque es idempotente (try/catch sobre duplicate column).

| Versión | Cambio | Razón |
|---|---|---|
| **v2** | + `exercises.is_unilateral`, + `session_sets.left_kg/left_reps`, + tabla `settings` | Soporte para ejercicios unilaterales con split mode |
| **v3** | UPDATE muscle para `ex-7/8/9` → Quadriceps/Hamstrings, `ex-13/14/15` → Biceps/Triceps, remap `Arms`/`Legs` → `Other` | Refactor de taxonomía de músculos |
| **v4** | + tabla `workout_log` | Para el heatmap de actividad |
| **v5** | + `routines.icon_code`, + `sessions.icon_code` (default 58713) | Iconos custom por rutina |
| **v6** | + `session_exercises.muscle` (default 'Other') | Snapshot del músculo en la sesión para que el historial sobreviva renames |
| **v7** | + tabla `programs`, + tabla `program_slots` | Plan de entrenamiento (ver `plan-de-entrenamiento.md`) |

**Patrón para agregar una migración v8 en el futuro:**
```dart
if (oldVersion < 8) {
  for (final sql in [
    'ALTER TABLE X ADD COLUMN Y TEXT NOT NULL DEFAULT ""',
    // ...
  ]) {
    try {
      await db.execute(sql);
    } on DatabaseException catch (e) {
      if (!e.toString().contains('duplicate column')) rethrow;
    }
  }
}
```

Para tablas nuevas: `CREATE TABLE IF NOT EXISTS`. Estrictamente aditivo — nunca DROP, nunca renombrar columnas.

---

## 3. Diagrama de relaciones

```
exercises ◄────────┐
    ▲              │
    │              │
routine_exercises  │
    │              │
    ▼              │
 routines          │
                   │
sessions          program_slots ──► programs
    │                  │
    ▼                  ▼
session_exercises  (FK SET NULL si routine borrada)
    │
    ▼
session_sets

settings (key-value, sin relaciones)
workout_log (sin relaciones)
```

**Cascadas:**
- Borrar `routines` → CASCADE a `routine_exercises`.
- Borrar `sessions` → CASCADE a `session_exercises` → CASCADE a `session_sets`. (Pero nunca borramos sesiones — ver decisión arriba).
- Borrar `programs` → CASCADE a `program_slots`.
- Borrar `routines` → SET NULL en `program_slots.routine_id` (el slot queda "huérfano" en lugar de romperse).

---

## 4. Seed inicial

`_seed(db)` se llama desde `_onCreate` (solo en instalación fresca). Inserta:
- **19 ejercicios** (`ex-1` a `ex-17` + dos custom de ejemplo `ex-c1`, `ex-c2`).
- **3 rutinas**: Push Day, Pull Day, Legs — con sus respectivos `routine_exercises` ya configurados.

Apps actualizadas (no fresh install) NO ejecutan seed — su data permanece intacta.

---

## 5. Operaciones especiales

### `wipeUserData()`
Llamado desde Settings → Wipe All Data. Borra en transacción:
- Todas las rutinas (CASCADE a routine_exercises).
- Todas las sesiones (CASCADE a session_exercises, session_sets).
- Solo los ejercicios `is_custom=1` (los seed se preservan).
- Todo el `workout_log`.
- Todos los `programs` (CASCADE a program_slots).
- Las dos keys de programa activo en `settings`.

**No borra**: ejercicios seed, settings de usuario (theme, language, accent, sound, coachmarks vistos, user_name).

### Export / Import JSON
`DataService.exportJson()` serializa: custom exercises + todas las rutinas + todas las sesiones + meta (version: "1.0", timestamp, user_name). El import limpia user data primero y luego re-inserta. **Programs no están incluidos en el export actual** — sería una adición futura.

---

## 6. Idiomas que vale entender al leer el código

- `targetReps` es TEXT no INT — soporta rangos como "8-12".
- `colorValue` es ARGB32 int (`Color.toARGB32()`).
- `iconCode` es el codepoint de un `IconData` de Material (default `58713` = `Icons.fitness_center`).
- Fechas siempre como `YYYY-MM-DD` string. Para conversión usar `'${date}T00:00:00'` antes de `DateTime.parse`.
- Volumen guardado en kg como `REAL`. La display logic decide formato (`FormatUtils.volume`).
- Time guardado en segundos para timers, minutos para `duration_min` de sesión.
