# Onboarding y coachmarks

Cómo se introduce al usuario en la primera ejecución (onboarding de 5 páginas) y cómo se guía contextualmente después (sistema de coachmarks con spotlight).

**Archivos principales:**
- `lib/features/onboarding/onboarding_screen.dart`
- `lib/core/services/coachmark_service.dart`
- `lib/shared/widgets/coachmark_overlay.dart`
- `lib/features/splash/screens/splash_screen.dart` (detección de primer launch)

---

## 1. Detección de primer launch

`SplashScreen._runStartupTasks`:
```dart
_onboarded = await ref.read(settingsRepositoryProvider).isOnboarded();
```

`isOnboarded()` chequea si la key `onboarded == '1'` en la tabla `settings`. Default: `false`.

Flujo en splash:
- Si hay workout activo (`getActiveWorkout()` no es null) → push `MainNavigationShell` + restore.
- Sino, si `_onboarded == false` → push `OnboardingScreen`.
- Sino → push `MainNavigationShell`.

## 2. Onboarding (5 páginas)

`OnboardingScreen` con `PageView` controlado:

| # | Icono | Contenido |
|---|---|---|
| 1 | `fitness_center` | "Built for every rep" — pitch del producto |
| 2 | `trending_up` | "Log weights. Break records." — tracking |
| 3 | `event_note` | "Routines your way." — rutinas custom |
| 4 | `shield_outlined` | "Your data, your device." — privacidad |
| 5 | `waving_hand_outlined` | Input de nombre opcional + "Let's go" |

### Animaciones por página

`_AnimatedOnboardPage` y `_NamePage` corren un `AnimationController` de ~700ms con secuencias escalonadas (`Interval`):
- Icono: scale + fade (0%-55%, easeOutBack).
- Title: fade + slide desde abajo (22%-55%, easeOutCubic).
- Body: fade (40%-72%).
- Botón: fade + slide (58%-88%).

Cada página se anima al entrar en viewport.

### "Skip"

Skip salta directo a la página 5 (input de nombre). El nombre es opcional — se puede dejar vacío y tappear "Let's go".

### Fin del onboarding

`_finish()`:
1. Si el usuario escribió nombre → `settings.setUserName(name)`.
2. `settings.setOnboarded()` → `onboarded = '1'`.
3. Invalida `userNameProvider`.
4. `pushReplacement` a `MainNavigationShell` con `AppRoute`.

### Fix de overflow (en memoria)

Cada página se envuelve en `LayoutBuilder → SingleChildScrollView → ConstrainedBox(minHeight: viewport) → IntrinsicHeight`. Esto centra el contenido cuando cabe y permite scroll cuando aparece el teclado (especialmente el emoji keyboard en la página 5). Sin esto había overflow en pantallas pequeñas.

---

## 3. Sistema de coachmarks

Los coachmarks son **tooltips spotlight** que aparecen contextualmente la primera vez que el usuario llega a una UI determinada. Marca el target con un círculo claro sobre un fondo oscurecido y muestra una tarjeta con título + body + dos botones (Got it / Skip all).

### CoachmarkService

```dart
class CoachmarkService {
  final SettingsRepository _settings;

  Future<bool> shouldShow(String id) async {
    final v = await _settings.get('coachmark_v1_$id');
    return v == null;  // si nunca se marcó, mostrar
  }

  Future<void> markSeen(String id) =>
      _settings.set('coachmark_v1_$id', '1');
}
```

**Prefijo versionado** (`coachmark_v1_`): permite resetear todos los coachmarks en un futuro bumpeando a `v2`. No es necesario por ahora pero mantiene la puerta abierta.

### CoachmarkOverlay (widget)

API:
```dart
CoachmarkOverlay.show(
  context: context,
  targetKey: someGlobalKey,
  title: 'Title',
  body: 'Body...',
  gotItLabel: 'Got it',
  skipLabel: 'Skip all',
  onDone: () { /* markSeen, opcionalmente trigger next */ },
  onSkipAll: () { /* opcional */ },
);
```

Implementación:
- Computa el bounding rect del target (via `RenderBox.localToGlobal`).
- Crea una `OverlayEntry` con un `CustomPainter` que dibuja:
  - Backdrop oscuro (72% alpha negro).
  - "Recorte" claro alrededor del target con padding de 16px.
- Anima en secuencia: backdrop fade → spotlight scale → card fade+slide.
- Posiciona la tarjeta arriba o abajo del target según el espacio disponible.
- Card con título (19px bold), body (14px), dos botones (Skip ghost a la izquierda, Got it primary con gradient).

### IDs de coachmark (15 totales)

Lista completa en `MEMORY.md`. Resumen:

| ID | Dónde se dispara | Target |
|---|---|---|
| `home` | Primera vez en Home | Hero card |
| `tab_routines` | Después del home | Tab "Routines" del navbar |
| `tab_exercises` | Después de routines | Tab "Exercises" |
| `tab_history` | Cuando hay ≥1 sesión | Tab "History" |
| `routines` | Primera vez en tab Routines | Botón "+" |
| `exercises` | Primera vez en tab Exercises | Search bar |
| `exercise_add` | Después de `exercises` | Botón "+" |
| `routine_edit` | Primera vez en RoutineDetailScreen | Botón "Edit" |
| `history_first_card` | Primera vez en History con sesiones | Primer card |
| `session_chart` | Primera vez en SessionDetail | Botón "See progress" del primer ejercicio |
| `progress_toggle` | Primera vez en ExerciseProgressScreen | Toggle 1RM/Volume |
| `rest_timer` | Primera vez que aparece el rest timer en workout activo | Barra de rest |
| `settings_colors` | Primera vez en Settings | Sección Appearance |
| `settings_sound` | Después de colors en Settings | Sección Sound |
| `settings_data` | Después de sound en Settings | Sección Data |

**El sistema está completo** — no se planean más coachmarks (decisión en `MEMORY.md`). Cualquier feature nueva (como Plan de entrenamiento) NO debe agregar coachmark.

### Encadenamiento

Algunos coachmarks dependen del anterior. Por ejemplo, en Settings: cuando el usuario hace "Got it" en `settings_colors`, el `onDone` callback dispara el chequeo de `settings_sound`. Si lo visto, sigue con `settings_data`.

Esto se implementa con callbacks recursivos: `onDone: () { markSeen; _checkNext(); }`.

### "Skip all"

Cualquier coachmark tiene el botón Skip all. Generalmente marca *solo el actual* como visto, no toda la cadena. Pero algunos screens deciden marcar también los siguientes — por ejemplo, en `exercises`, "Skip all" marca también `exercise_add` para no atosigar.

---

## 4. El bug del SlideTransition (crítico)

Documentado en `MEMORY.md` (`feedback_coachmark_slide_anim.md`).

**Problema**: `RenderBox.localToGlobal` durante una `SlideTransition` (o `AnimatedSlide`, o `FractionalTranslation`) retorna las coordenadas **incluyendo el offset animado en progreso**, no la posición final. Si disparas un coachmark mientras la transición está corriendo, el spotlight aparece desplazado.

**Casos**:
1. **Cambio de tab** (`IndexedStack` + `SlideTransition`, ~320 ms). Solución:
   ```dart
   animFuture.whenCompleteOrCancel(() {
     if (mounted) _triggerCoachmark();
   });
   ```

2. **`Navigator.push` con `MaterialPageRoute`** (slide-in, ~300 ms). Solución:
   ```dart
   Future.delayed(const Duration(milliseconds: 400), () {
     if (mounted) _triggerCoachmark();
   });
   ```

3. **Widget con `FadeSlideIn` propio** (420 ms). Solución:
   ```dart
   Future.delayed(const Duration(milliseconds: 450), () {
     if (mounted) _triggerCoachmark();
   });
   ```

**Si agregas un coachmark nuevo**, verifica qué tipo de transición precede a tu target y aplica el patrón correspondiente. Si lo olvidas, el spotlight aparecerá fuera de lugar.

---

## 5. Patrón de wireup en una pantalla

Ejemplo simplificado de `HomeScreen`:

```dart
class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _heroCardKey = GlobalKey();
  bool _coachmarkChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCoachmark());
  }

  Future<void> _checkCoachmark() async {
    if (!mounted || _coachmarkChecked) return;
    _coachmarkChecked = true;
    final service = ref.read(coachmarkServiceProvider);
    if (await service.shouldShow('home')) {
      CoachmarkOverlay.show(
        context: context,
        targetKey: _heroCardKey,
        title: l10n.coachmarkHomeTitle,
        body: l10n.coachmarkHomeBody,
        gotItLabel: l10n.coachmarkGotIt,
        skipLabel: l10n.coachmarkSkipAll,
        onDone: () {
          service.markSeen('home');
          _checkNext();  // siguiente en la cadena
        },
      );
    } else {
      _checkNext();
    }
  }
  // ...
}
```

- `GlobalKey` en el widget target → permite computar su posición.
- Flag `_coachmarkChecked` evita reentradas.
- `await shouldShow` antes de `show` para respetar lo ya visto.
- `markSeen` siempre en `onDone`.
- Encadenar el siguiente en el callback si aplica.

---

## 6. Storage

Todo el estado de coachmarks vive en la tabla `settings`:

```
key                          value
coachmark_v1_home            '1'
coachmark_v1_tab_routines    '1'
coachmark_v1_routines        '1'
...
```

Wipe data **NO borra** estos registros (los settings se preservan), así que si el usuario reseteó la app y volvió a entrar, no le aparecen los coachmarks de nuevo. Si quisieras forzar re-show, bumpea el prefijo a `coachmark_v2_` y todos los chequeos volverán a fallar contra null.
