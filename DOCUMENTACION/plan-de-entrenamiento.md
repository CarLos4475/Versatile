# Feature: Plan de entrenamiento

Sistema de programas multisemana que asignan una rutina (o un label tipo "Descanso", "Cardio", etc.) a cada día de la semana. El home muestra automáticamente qué toca hoy según el programa activo.

**Estado:** Implementada. DB v7.
**Carácter:** 100% opcional — sin programa activo, la app se comporta exactamente como antes (sugerencia LRU del home).

---

## 1. Comportamiento desde el usuario

### Sin programa activo (estado por defecto)
Nada cambia respecto a la versión previa. El hero card del home sigue mostrando la sugerencia "least-recently-done" calculada en `home_view_model.dart`.

### Con programa activo
- El hero card muestra **la rutina planeada para hoy** (sobrescribe la sugerencia LRU).
- Si hoy es un label (Descanso, Cardio, Movilidad, Estiramiento, o texto custom), aparece una **tarjeta alterna sin botón "Start Workout"**, con badge `HOY` y descripción.
- Aparece un badge `PLANEADO` (o `DESCARGA` si la semana está marcada como deload) en la esquina superior del hero card.
- Si la celda de hoy en el programa está sin configurar → cae al LRU.
- Si la rutina referenciada por el slot fue eliminada → cae al LRU silenciosamente.

### Acceso
**Settings → Plan de entrenamiento.**
No hay banners, nudges, ni paso en onboarding. La feature es invisible hasta que el usuario decide explorarla.

### Flujo de creación
1. Pantalla *Programs* (lista). Botón "Crear programa".
2. Editor:
   - Nombre (obligatorio).
   - Color (8 presets, mismo palette que las rutinas).
   - Número de semanas (1–12, stepper).
   - Por semana: switch "Descarga" + grilla de 7 días.
   - Tap en un día → bottom sheet con:
     - Lista de rutinas existentes (toca = asignar).
     - 4 chips de preset: Descanso, Cardio, Movilidad, Estiramiento.
     - Campo de texto libre para label custom.
     - Botón "Vaciar" (solo si el slot ya tenía algo).
3. "Guardar" persiste el programa como template.

### Flujo de activación
1. En la lista, menú `⋯` → "Activar".
2. Se abre `showDatePicker` para elegir la fecha de inicio de semana 1 (por defecto el lunes de la semana actual).
3. Se guardan `active_program_id` y `active_program_start_date` en la tabla `settings`.

### Cálculo de "qué toca hoy"
```
daysSinceStart = today - active_program_start_date
weeksElapsed   = daysSinceStart ÷ 7
weekIndex      = weeksElapsed mod weeksCount   // loop infinito
weekday        = today.weekday                 // 1=Lun ... 7=Dom
slot           = program.slots[weekIndex][weekday]
```

El loop es siempre activo: cuando se acaban las N semanas, vuelve a la semana 1 indefinidamente. (Decisión cerrada por el usuario.)

### Override
Cualquier sesión que el usuario haga ese día cuenta como entrenado, sin importar si era la rutina planeada o no. El programa es sugerencia, no contabilidad estricta. (Decisión cerrada.)

---

## 2. Modelo de datos

### Tabla `programs`
```sql
CREATE TABLE programs (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  color_value   INTEGER NOT NULL,
  icon_code     INTEGER NOT NULL DEFAULT 58713,
  weeks_count   INTEGER NOT NULL,
  deload_weeks  TEXT NOT NULL DEFAULT '',  -- CSV de índices, p.ej. "2,5"
  created_at    TEXT NOT NULL
)
```

### Tabla `program_slots`
```sql
CREATE TABLE program_slots (
  id          TEXT PRIMARY KEY,
  program_id  TEXT NOT NULL,
  week_index  INTEGER NOT NULL,    -- 0-based
  weekday     INTEGER NOT NULL,    -- 1..7 (1=Lun, 7=Dom, alineado con DateTime.weekday)
  slot_kind   TEXT NOT NULL,       -- 'routine' | 'label'
  routine_id  TEXT,                -- nullable, FK a routines
  label_text  TEXT,                -- nullable
  UNIQUE(program_id, week_index, weekday),
  FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
  FOREIGN KEY (routine_id) REFERENCES routines(id) ON DELETE SET NULL
)
```

**Celda no configurada = ausencia de fila.** No se generan slots vacíos por defecto al crear un programa. Esto deja a la home caer al LRU para días sin asignación.

### Estado activo en `settings` (key-value existente)
- `active_program_id` → `String` (UUID del programa)
- `active_program_start_date` → `String` ISO `YYYY-MM-DD`

Razones para no agregar columnas a `programs`:
- Solo un programa activo a la vez → no es un atributo del programa, es estado global.
- "Desactivar" se reduce a borrar dos keys, sin ALTER ni transacciones.

---

## 3. Estructura de archivos

### Nuevos
| Archivo | Rol |
|---|---|
| `lib/domain/entities/program.dart` | `Program`, `ProgramSlot`, enum `SlotKind` |
| `lib/data/repositories/program_repository.dart` | CRUD + `getSlot(programId, weekIndex, weekday)` |
| `lib/features/programs/view_models/programs_view_model.dart` | `programsListProvider`, `activeProgramProvider`, `todaysPlannedSlotProvider` |
| `lib/features/programs/screens/programs_screen.dart` | Lista + activar/desactivar/eliminar |
| `lib/features/programs/screens/program_editor_screen.dart` | Editor con grilla semanal |
| `lib/features/programs/widgets/slot_editor_sheet.dart` | Bottom sheet para asignar slot |

### Modificados
| Archivo | Cambio |
|---|---|
| `lib/data/database/database_helper.dart` | Bump v6→v7; nuevas tablas en `_onCreate` y `_onUpgrade`; limpieza en `wipeUserData` |
| `lib/data/repositories/settings_repository.dart` | Getters/setters de `active_program_id`, `active_program_start_date`, `clearActiveProgram()` |
| `lib/core/providers/repository_providers.dart` | Registrado `programRepositoryProvider` |
| `lib/features/home/view_models/home_view_model.dart` | `HomeState` agregó `todayLabel`, `plannedFromProgram`, `isDeloadWeek`. Override del LRU cuando hay slot planeado |
| `lib/features/home/screens/home_screen.dart` | Variante `_LabelHeroCard`; badges `PLANEADO`/`DESCARGA` en `_HeroCard` |
| `lib/features/settings/screens/settings_screen.dart` | Fila "Plan de entrenamiento" en sección Profile |
| `lib/l10n/app_en.arb`, `app_es.arb`, `app_localizations*.dart` | ~50 strings nuevas (sincronizadas a mano según workflow del proyecto) |

---

## 4. Decisiones de diseño

### Loop siempre activo
Se descartó tanto el "one-shot" (terminar al llegar a la semana N) como el "configurable por programa". El loop infinito es la opción más común para mesociclos típicos de 4–6 semanas; agregar configurabilidad innecesaria habría complicado el modelo de datos y la UI sin demanda real.

### Labels: preset + custom
Cuatro presets cubren ~90% de los casos (Descanso, Cardio, Movilidad, Estiramiento) y dan velocidad de configuración. El campo custom da flexibilidad para casos raros ("Fútbol con amigos", "Recuperación activa", etc.). No se usa enum porque las preset son solo strings localizadas → si en el futuro se agregan más presets, no hay migración de datos.

### Celdas vacías permitidas
Una alternativa era forzar al usuario a llenar las 7 × N celdas al crear un programa. Se descartó porque:
- Onboarding más doloroso.
- Funcionalmente equivalente: día vacío = caer al LRU = "lo que el algoritmo elija".
- El usuario puede ir llenando el programa progresivamente.

### Override "cuenta cualquier sesión"
Se descartó el modo estricto ("solo la rutina planeada cumple el día"). Aunque permitiría métricas de adherencia exactas, hace al programa más rígido y castiga al usuario por cambios espontáneos. El modelo soporta agregar adherencia más adelante sin cambios de schema.

### Sin coachmark
La memoria del proyecto indica que el sistema de coachmarks está cerrado. Esta feature no agrega uno — la fila en Settings es descubrible y la UX del editor es lo suficientemente guiada.

### Programa activo en `settings` (no en `programs`)
Decisión a favor de "single source of truth" para estado global. Si se agregara un flag `is_active` en `programs`, habría dos lugares donde garantizar invariantes ("solo uno puede ser true"). Con las keys en settings es trivial.

---

## 5. Garantías de degradación

| Escenario | Comportamiento |
|---|---|
| Sin `active_program_id` | `todaysPlannedSlotProvider` retorna `null`. Home usa LRU sin cambios. |
| `active_program_id` apunta a programa borrado | `activeProgramProvider` detecta y llama `clearActiveProgram()` silenciosamente. |
| Slot apunta a rutina borrada (CASCADE puso `routine_id=NULL`) | Home cae al LRU. Editor muestra "Rutina eliminada". |
| Slot kind='label' con texto null | No debería ocurrir en escritura; defensivo: home cae al LRU. |
| Fecha de inicio futura | Programa "aún no comenzó". `todaysPlannedSlotProvider` retorna null. Home usa LRU. |
| Cambio de fecha del sistema | El cálculo es `today - startDate`. Si el usuario adelanta días, salta semanas. Si lo retrasa, vuelve atrás. Comportamiento correcto sin estado extra. |

---

## 6. Notas técnicas

### Riverpod
- `activeProgramProvider` es `FutureProvider` (lee settings + programa entero).
- `todaysPlannedSlotProvider` es `FutureProvider` que depende del anterior.
- `homeProvider` (sync `Provider`) hace `.watch(todaysPlannedSlotProvider).value`, que retorna `null` mientras carga — el home renderiza LRU durante ese instante y reconstruye cuando llega el slot. Ese flicker es aceptable porque solo dura un frame en la práctica.

### Migración v7
Las tablas usan `CREATE TABLE IF NOT EXISTS` y no tocan tablas existentes — la migración es **estrictamente aditiva**, no hay riesgo de pérdida de datos al actualizar la app desde una versión previa.

### Foreign keys
`ON DELETE CASCADE` en `program_slots → programs` significa que borrar un programa elimina sus slots automáticamente. `ON DELETE SET NULL` en `program_slots → routines` permite que borrar una rutina no destruya la estructura del programa — los slots quedan "rotos" pero el editor los muestra como "Rutina eliminada" en lugar de fallar.

### L10n
El proyecto no corre `flutter gen-l10n` automáticamente (ver `MEMORY.md`). Los tres archivos generados (`app_localizations.dart`, `_en.dart`, `_es.dart`) se sincronizaron a mano siguiendo el patrón existente. Plurales usan `intl.Intl.pluralLogic`.

### Pixel overflow
El editor usa `SingleChildScrollView` envolviendo todo el contenido, así que crece con la cantidad de semanas (hasta 12) sin riesgo de overflow vertical. El bottom sheet del slot editor se ajusta con `MediaQuery.viewInsets.bottom` y `maxHeight: 85% screen`.

---

## 7. Extensiones futuras posibles

Lo siguiente no se implementó pero el modelo de datos lo soporta sin cambios de schema:

- **Métricas de adherencia**: % de días planeados completados, gráfica por semana.
- **Notificación matutina**: "Hoy toca: Push Day" con el contenido del slot.
- **Plantillas de programa**: programas pre-armados (PPL, Upper/Lower, etc.) que el usuario puede importar.
- **Copiar semana → semana**: shortcut para duplicar la configuración de una semana en otra.
- **Indicador en historial**: marcar visualmente las sesiones que coincidieron con el plan.

Nada de esto está agendado. Documentado solo como ideas si se retoma la feature.
