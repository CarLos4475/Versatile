# Documentación — Versatile

Documentación interna del código, organizada por feature. Pensada como **referencia de trabajo**, no como manual de usuario.

Cuando llegue el momento de generar documentación final de producción, estos archivos son los building blocks: cada uno cubre una feature con su modelo de datos, decisiones de diseño, archivos clave, y deuda conocida.

---

## Índice

### Foundation (leer primero)

- **[arquitectura.md](arquitectura.md)** — Stack, estructura de carpetas, capas, patrones Riverpod, navegación, design system, l10n. La vista de águila.
- **[base-de-datos.md](base-de-datos.md)** — Schema completo de las 10 tablas, historial de migraciones v2→v7, diagrama de relaciones, patrones para futuras migraciones.

### Features principales

- **[sesion-activa.md](sesion-activa.md)** — Pantalla de workout en curso, foreground service Android, rest timer, recuperación tras kill del proceso. La feature más compleja.
- **[rutinas-y-ejercicios.md](rutinas-y-ejercicios.md)** — Biblioteca de ejercicios (seed + custom), creación/edición de rutinas, exercise picker.
- **[historial-y-progreso.md](historial-y-progreso.md)** — Lista de sesiones, detalle, gráficas de progreso por ejercicio (1RM + volumen), heatmap del home.
- **[plan-de-entrenamiento.md](plan-de-entrenamiento.md)** — Programs multisemana con días de descanso (la feature más reciente, v7 del schema).

### Sistemas transversales

- **[onboarding-y-coachmarks.md](onboarding-y-coachmarks.md)** — Primer launch (5 páginas) + sistema de coachmarks spotlight (15 IDs) + el bug del SlideTransition.
- **[settings-y-datos.md](settings-y-datos.md)** — Configuración (theme, idioma, accent, sonido, perfil) + export/import/wipe.

---

## Cómo leer estos docs

Cada feature doc sigue un mismo formato aproximado:

1. **Resumen** — qué es, archivos involucrados.
2. **Flujo del usuario** — descripción de la UX.
3. **Modelo de datos / estado** — entidades, providers, SQL.
4. **Decisiones clave** — por qué se hizo así, qué se descartó.
5. **Deuda / limitaciones** — lo que no está hecho, lo que requiere atención futura.

Cuando algo es no-obvio o tiene una razón detrás, está marcado explícitamente. Si en el código encuentras algo que parezca raro, primero busca aquí — probablemente hay contexto.

---

## Convenciones del proyecto

- **Comentarios en código**: solo cuando el *por qué* no es obvio. No comentar el qué.
- **No emojis** en código ni docs (salvo que el usuario los pida).
- **l10n**: editar `.arb` y sincronizar manualmente los `app_localizations*.dart`. No correr `flutter gen-l10n`.
- **Colors**: siempre vía `context.colors.X`, nunca hardcodear.
- **Tappable**: envolver en `PressableScale`.
- **Comentar decisiones, no implementaciones**: si una elección tiene una razón histórica (incidente pasado, constraint del SO, bug evitado), eso va comentado en el código y/o documentado aquí.

---

## Estado del proyecto

| Aspecto | Estado |
|---|---|
| Plataforma principal | Android |
| iOS | El proyecto compila, pero notification + audio focus son Android-only |
| Tests | Solo el `widget_test.dart` default — sin suite real |
| CI/CD | No hay |
| Privacy | 100% local, sin cuenta, sin internet, sin analytics |
| Schema actual | v7 |
| Idiomas | EN, ES (auto-detect) |
| Versión | 1.0.0 |

---

## Pendientes y deuda

Los pendientes activos del proyecto están en `~/.claude/projects/.../memory/project_pending_tasks.md` (memoria automática). Resumen al momento de esta documentación:

- **Battery whitelist prompt** — pedir `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` para foreground service en OEMs agresivos.
- **Workout intelligence** — PR auto-detect, sugerencia de progresión, plate calculator, supersets.
- **Tracking adicional** — medidas corporales, fotos de progreso, notas libres.
- **Sharing / recap** — tarjeta compartible, recap anual, widget Android.

Cada feature doc también lista su propia "deuda" al final.
