# Settings y manejo de datos

Pantalla de configuración (apariencia, idioma, sonido, perfil, datos) y el sistema de export/import/wipe que la app expone.

**Archivos principales:**
- `lib/features/settings/screens/settings_screen.dart`
- `lib/core/providers/theme_provider.dart`, `accent_provider.dart`, `locale_provider.dart`
- `lib/core/theme/accent_colors.dart`, `app_colors.dart`, `app_theme.dart`
- `lib/core/services/sound_service.dart`
- `lib/core/services/data_service.dart`
- `lib/data/repositories/settings_repository.dart`

---

## 1. Estructura de la pantalla

`SettingsScreen` es scroll vertical con secciones (cada una con un `_SectionLabel` mayúscula + cards `GlassContainer` con `_SettingRow`).

| Sección | Items |
|---|---|
| **Profile** | User Name · Training Plan |
| **Appearance** | Theme · Language · Accent Color |
| **Sound** | Rest Timer Alert toggle · Sound type (default/custom) · Pick custom file |
| **Data** | Export · Import · Wipe |
| **About** | Version · Author |

`_SettingRow` es el patrón reutilizable: icono accent + título + subtítulo opcional + valor / control trailing + onTap opcional.

---

## 2. Perfil

### User Name
- Dialog con `TextField` (`scrollable: true` para no overflow con teclado).
- Persistido en `settings.user_name` (default `'there'`).
- El home muestra `Hello, {name}` o `Hello there` si está vacío.

### Training Plan
- Push a `ProgramsScreen` (ver `plan-de-entrenamiento.md`).

---

## 3. Apariencia

### Theme

Dropdown con 3 opciones:
- Light
- Dark
- System (sigue al sistema)

Persistido en `settings.theme_mode` como string `'light'` / `'dark'` / `'system'`.

Riverpod: `themeModeProvider` con su notifier que persiste + actualiza al instante.

### Language

Dropdown con dos opciones:
- English
- Spanish

Persistido en `settings.language_code` como `'en'` / `'es'`. Auto-detectado en el primer launch (`Platform.localeName` resolved al idioma soportado más cercano).

Riverpod: `localeProvider` que emite el `Locale` al `MaterialApp`. Cambio inmediato sin reiniciar.

### Accent Color

Picker con 8 opciones predefinidas (Orange por default, más Blue, Green, Purple, Red, Teal, Pink, Amber). Cada una tiene asociado un set de tokens (`accent`, `accentLight`, `accentDeep`, `accentTint`).

Persistido en `settings.accent_color` como ID string.

Riverpod: `accentProvider` que emite el `AccentColors.options[id]`. La extension `context.colors` lee de aquí.

**Donde se usa el accent**: gradientes del hero card, botones primarios, badges, focus borders, círculos de coachmark spotlight, etc. Todo lo "vibrante" en la app.

---

## 4. Sonido (rest timer)

Tres controles:

### Switch "Rest Timer Alert"
- Persistido en `settings.rest_alert_enabled`. Default `true` (`!= 'false'`).
- Cuando está OFF, el `_onRestFinished` del workout activo retorna early — no hay vibración, notificación, ni sonido.

### Sound type (default / custom)
- Persistido en `settings.rest_alert_sound_type`. Default `'default'`.
- **Default**: usa el `MediaPlayer` / `Ringtone` nativo (`RingtoneManager.getDefaultUri(TYPE_NOTIFICATION)`).
- **Custom**: usa `audioplayers` con el path guardado en `rest_alert_custom_path`.

### File picker (custom)
- `FilePicker.platform.pickFiles(type: FileType.audio)`.
- El archivo seleccionado se copia a `getApplicationDocumentsDirectory()/sounds/custom_alert.{ext}` para garantizar persistencia (los URIs temporales del file picker pueden invalidarse).
- El path final se guarda en `settings.rest_alert_custom_path`.

### Reproducción

`SoundService.playAlertSound(exerciseName)` se llama al expirar el rest timer:
1. `HapticFeedback.heavyImpact()`.
2. MethodChannel `showRestAlert` → notificación con vibración (canal `rest_alert_v2`).
3. Si custom enabled → `AudioPlayer.play(DeviceFileSource(path))` con `AudioContext`:
   - `contentType: sonification`
   - `usageType: notification`
   - `audioFocus: gainTransientMayDuck`
4. El sonido default lo dispara MainActivity.kt directamente.

### Decisión clave (en memoria)

El canal `rest_alert_v2` está **intencionalmente silencio** (`setSound(null, null)`). El sonido lo controlamos manualmente desde Dart con `AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK` + `abandonAudioFocusRequest` al terminar. Razón: el canal de Android no libera el audio focus correctamente — la música de fondo del usuario quedaba pausada después de la alerta. Manejándolo manualmente, la música se duck y luego vuelve sola.

El canal viejo `rest_alert_channel` (con OS-managed sound) se borra en el primer run vía `nm.deleteNotificationChannel("rest_alert_channel")`.

### Sonido en API 28+ vs older

- **API ≥ 28 (Android Pie+)**: usar `MediaPlayer` con `setOnCompletionListener` para liberar focus al terminar.
- **API 26-27 (Oreo)**: `Ringtone` no tiene completion callback; se libera focus con `Handler.postDelayed(3000ms)`.
- **API < 26 (legacy)**: `Ringtone` sin focus management.

---

## 5. Datos (export / import / wipe)

### Export JSON

`DataService.exportJson()` retorna un JSON con:
```json
{
  "version": "1.0",
  "exported_at": "2026-05-16T12:34:56.789Z",
  "user_name": "Carlos",
  "custom_exercises": [ ... ],
  "routines": [ ... ],   // incluye routine_exercises anidados
  "sessions": [ ... ]    // incluye session_exercises + session_sets anidados
}
```

UI:
1. Generar JSON.
2. Escribir a `getTemporaryDirectory()/versatile_backup.json`.
3. `Share.shareXFiles([XFile(path)], text: 'Versatile Backup')` — abre el share sheet del SO.

**Lo que se incluye**:
- Custom exercises (NO seed — esos se regeneran al instalar).
- Todas las rutinas + ejercicios configurados.
- Todas las sesiones completas con sets.
- Nombre de usuario.

**Lo que NO se incluye actualmente** (deuda):
- Programas (de la feature de plan de entrenamiento). Adición futura.
- workout_log (las fechas se reconstruyen de sessions).
- Settings (theme, language, accent, sound config, coachmarks vistos).

### Import JSON

`DataService.importJson(jsonString)`:
1. Parse del JSON.
2. `DatabaseHelper.wipeUserData()` — borra todo lo del usuario actual.
3. Re-insert de custom exercises, routines, sessions, etc.

**Hay un trade-off**: el import **reemplaza** todo. No es "merge". Si tienes data y haces import, pierdes lo actual. Esto es intencional — un import de JSON ajeno con conflictos de IDs sería complicado de resolver.

**No hay version check** en el import — asume formato compatible. Si alguien importa un JSON de versión incompatible (futura) hay riesgo. Idealmente debería checkear el campo `version` y rechazar / migrar. Pendiente como deuda menor.

### Wipe All Data

Dialog de confirmación destructivo. Al aceptar:

```dart
await DatabaseHelper.instance.wipeUserData();
```

Transaction que borra:
- `routines` (CASCADE a `routine_exercises`).
- `sessions` (CASCADE a `session_exercises` → `session_sets`).
- `exercises WHERE is_custom = 1` (seed se preservan).
- `workout_log`.
- `programs` (CASCADE a `program_slots`).
- Las dos keys de programa activo en `settings`.

**No borra**: ejercicios seed, user_name, theme, language, accent, sound config, coachmarks. Esos se conservan porque son preferencias, no data de entrenamiento.

Tras wipe, se invalidan los providers afectados para refresh inmediato.

---

## 6. About

Hardcoded:
- Version: lee `pubspec.yaml` indirectamente (en el código está como `1.0.0` constante).
- Author: "CarLos" (hardcoded).

No hay vínculo a website / GitHub / changelog. Sección puramente informativa.

---

## 7. Persistencia de preferencias resumen

| Preferencia | Key en `settings` | Default |
|---|---|---|
| Nombre | `user_name` | `'there'` |
| Onboarding completado | `onboarded` | sin entrada (= false) |
| Theme mode | `theme_mode` | `'system'` |
| Idioma | `language_code` | `'en'` o detectado |
| Accent color | `accent_color` | `'orange'` |
| Rest alert on/off | `rest_alert_enabled` | `'true'` |
| Sound type | `rest_alert_sound_type` | `'default'` |
| Custom sound path | `rest_alert_custom_path` | null |
| Coachmark visto | `coachmark_v1_{id}` | sin entrada (= no visto) |
| Programa activo | `active_program_id` + `active_program_start_date` | null |

---

## 8. Coachmarks en Settings

Tres coachmarks encadenados (ver `onboarding-y-coachmarks.md`):
1. `settings_colors` — apunta a la sección Appearance.
2. `settings_sound` — apunta a la sección Sound.
3. `settings_data` — apunta a la sección Data.

Targetean con `GlobalKey` cada sección y usan `Future.delayed(450ms)` por el bug del slide transition al entrar a la pantalla.

---

## 9. Deuda / limitaciones

- **Settings no se exportan** — al hacer wipe se preservan, pero al importar un backup no se restauran (porque no se exportan). Si quieres llevarte tu config a otro device, no funciona.
- **Programas no se exportan/importan** — pendiente con baja prioridad ya que las plantillas las puedes recrear.
- **No hay theming custom** — solo 8 accents predefinidos. No editor de colores libre.
- **Idiomas limitados a EN/ES** — agregar uno nuevo implica un nuevo `app_localizations_xx.dart` manual y un nuevo locale en `MaterialApp.supportedLocales`.
- **No hay "Restore defaults"** — para resetear theme/accent/sonido hay que cambiarlos uno por uno.
- **No hay confirmación al cambiar accent / theme** — son instantáneos, lo cual es correcto, pero no tienen "preview".
