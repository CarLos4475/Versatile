import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:versatile/l10n/app_localizations.dart';
import 'core/navigation/app_page_transitions.dart';
import 'core/providers/accent_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/utils/format_utils.dart';
import 'features/home/screens/home_screen.dart';
import 'features/routines/screens/routines_screen.dart';
import 'features/exercises/screens/exercises_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/active_workout/screens/active_workout_screen.dart';
import 'features/active_workout/view_models/active_workout_view_model.dart';
import 'features/exercises/view_models/exercises_view_model.dart';
import 'features/splash/screens/splash_screen.dart';
import 'shared/widgets/coachmark_overlay.dart';
import 'shared/widgets/motion.dart';
import 'core/providers/repository_providers.dart';

class VersatileApp extends ConsumerWidget {
  const VersatileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final accent = ref.watch(accentProvider);

    return MaterialApp(
      title: 'Versatile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent.color),
      darkTheme: AppTheme.dark(accent.color),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => AppWrapper(child: child!),
      home: const SplashScreen(),
    );
  }
}

// ─── Main shell ────────────────────────────────────────────────────────────────

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  int _prevIndex = 0;
  final _historyTabKey = GlobalKey();
  final _routinesTabKey = GlobalKey();
  final _exercisesTabKey = GlobalKey();

  late final AnimationController _pageCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _pages = [
    HomeScreen(),
    RoutinesScreen(),
    ExercisesScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _buildAnimations(forward: true);
    _pageCtrl.value = 1.0; // start fully visible
    WidgetsBinding.instance.addPostFrameCallback(_restorePendingWorkout);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(historyNavKeyProvider.notifier).state = _historyTabKey;
        ref.read(routinesNavKeyProvider.notifier).state = _routinesTabKey;
        ref.read(exercisesNavKeyProvider.notifier).state = _exercisesTabKey;
      }
    });
  }

  void _restorePendingWorkout(_) {
    final activeInfo = ref.read(pendingWorkoutRestoreProvider);
    if (activeInfo == null || !mounted) return;
    ref.read(pendingWorkoutRestoreProvider.notifier).state = null;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(
          routineId: activeInfo.routineId,
          restoredStartedAt: activeInfo.startedAt,
          restoredProgressJson: activeInfo.progressJson,
        ),
      ),
    );
  }

  void _buildAnimations({required bool forward}) {
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOutCubic));
    _slideAnim = Tween<Offset>(
      begin: Offset(forward ? 0.04 : -0.04, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOutCubic));
  }

  void _onTabChanged(int i) {
    if (i == _index) return;
    ref.read(exercisesProvider.notifier).setQuery('');
    _buildAnimations(forward: i > _prevIndex);
    final animFuture = _pageCtrl.forward(from: 0.0);
    setState(() {
      _prevIndex = _index;
      _index = i;
    });
    if (i == 1) {
      // Wait for the slide animation to finish before computing the add-button
      // position, otherwise localToGlobal includes the in-progress transform.
      animFuture.whenCompleteOrCancel(() {
        if (mounted) _triggerRoutinesCoachmark();
      });
    } else if (i == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerExercisesCoachmark());
    }
  }

  Future<void> _triggerExercisesCoachmark() async {
    if (!mounted) return;
    final service = ref.read(coachmarkServiceProvider);
    final shouldSearch = await service.shouldShow('exercises');
    if (!mounted) return;
    if (shouldSearch) {
      final searchKey = ref.read(exercisesSearchKeyProvider);
      if (searchKey == null) return;
      final l10n = AppLocalizations.of(context)!;
      CoachmarkOverlay.show(
        context: context,
        targetKey: searchKey,
        title: l10n.coachmarkExercisesTitle,
        body: l10n.coachmarkExercisesBody,
        gotItLabel: l10n.coachmarkGotIt,
        skipLabel: l10n.coachmarkSkipAll,
        onDone: () async {
          await service.markSeen('exercises');
          if (mounted) _triggerExercisesAddCoachmark();
        },
        onSkipAll: () async {
          await service.markSeen('exercises');
          await service.markSeen('exercise_add');
        },
      );
      return;
    }
    _triggerExercisesAddCoachmark();
  }

  Future<void> _triggerExercisesAddCoachmark() async {
    if (!mounted) return;
    final service = ref.read(coachmarkServiceProvider);
    final should = await service.shouldShow('exercise_add');
    if (!should || !mounted) return;
    final addKey = ref.read(exercisesAddKeyProvider);
    if (addKey == null) return;
    final l10n = AppLocalizations.of(context)!;
    CoachmarkOverlay.show(
      context: context,
      targetKey: addKey,
      title: l10n.coachmarkExerciseAddTitle,
      body: l10n.coachmarkExerciseAddBody,
      gotItLabel: l10n.coachmarkGotIt,
      skipLabel: l10n.coachmarkSkipAll,
      onDone: () => service.markSeen('exercise_add'),
    );
  }

  Future<void> _triggerRoutinesCoachmark() async {
    if (!mounted) return;
    final service = ref.read(coachmarkServiceProvider);
    final should = await service.shouldShow('routines');
    if (!should || !mounted) return;
    final addKey = ref.read(routinesAddKeyProvider);
    if (addKey == null) return;
    final l10n = AppLocalizations.of(context)!;
    CoachmarkOverlay.show(
      context: context,
      targetKey: addKey,
      title: l10n.coachmarkRoutinesTitle,
      body: l10n.coachmarkRoutinesBody,
      gotItLabel: l10n.coachmarkGotIt,
      skipLabel: l10n.coachmarkSkipAll,
      onDone: () => service.markSeen('routines'),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeRoutineId = ref.watch(activeWorkoutRoutineIdProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Animated page content
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: IndexedStack(index: _index, children: _pages),
            ),
          ),

          // Active workout overlay
          if (activeRoutineId != null)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 104,
              child: _ActiveWorkoutOverlay(),
            ),

          // Liquid glass navbar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _LiquidNavBar(
              index: _index,
              onChanged: _onTabChanged,
              routinesKey: _routinesTabKey,
              exercisesKey: _exercisesTabKey,
              historyKey: _historyTabKey,
              items: [
                _NavItem(icon: Icons.home_filled, label: l10n.home),
                _NavItem(
                  icon: Icons.format_list_bulleted_rounded,
                  label: l10n.routines,
                ),
                _NavItem(
                  icon: Icons.fitness_center_rounded,
                  label: l10n.exercises,
                ),
                _NavItem(icon: Icons.history_rounded, label: l10n.history),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Liquid glass navbar ───────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _LiquidNavBar extends StatelessWidget {
  const _LiquidNavBar({
    required this.index,
    required this.onChanged,
    required this.items,
    this.routinesKey,
    this.exercisesKey,
    this.historyKey,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<_NavItem> items;
  final GlobalKey? routinesKey;
  final GlobalKey? exercisesKey;
  final GlobalKey? historyKey;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.50 : 0.18),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.02),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0.12),
                      ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final item = items[i];
                final active = index == i;
                Widget btn = _NavBarButton(
                  item: item,
                  active: active,
                  onTap: () => onChanged(i),
                  isDark: isDark,
                );
                if (i == 1 && routinesKey != null) {
                  btn = KeyedSubtree(key: routinesKey!, child: btn);
                } else if (i == 2 && exercisesKey != null) {
                  btn = KeyedSubtree(key: exercisesKey!, child: btn);
                } else if (i == 3 && historyKey != null) {
                  btn = KeyedSubtree(key: historyKey!, child: btn);
                }
                return btn;
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  const _NavBarButton({
    required this.item,
    required this.active,
    required this.onTap,
    required this.isDark,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: active
              ? context.colors.accent.withValues(alpha: isDark ? 0.25 : 0.12)
              : Colors.transparent,
          border: active
              ? Border.all(
                  color: context.colors.accent.withValues(
                    alpha: isDark ? 0.35 : 0.20,
                  ),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: active ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              child: Icon(
                item.icon,
                size: 22,
                color: active ? context.colors.accent : context.colors.ink300,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? context.colors.accent : context.colors.ink300,
                letterSpacing: active ? 0.0 : 0.1,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App wrapper ───────────────────────────────────────────────────────────────

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

// ─── Active workout overlay — liquid glass ─────────────────────────────────────

class _ActiveWorkoutOverlay extends ConsumerWidget {
  const _ActiveWorkoutOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeRoutineId = ref.watch(activeWorkoutRoutineIdProvider);
    if (activeRoutineId == null) return const SizedBox.shrink();

    final workoutState = ref.watch(activeWorkoutProvider(activeRoutineId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeSlideIn(
      offset: const Offset(0, 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: PressableScale(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ActiveWorkoutScreen(routineId: activeRoutineId),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  // Glass tint in accent color — translucent, shows content behind
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            context.colors.accent.withValues(alpha: 0.30),
                            context.colors.accentDeep.withValues(alpha: 0.22),
                          ]
                        : [
                            context.colors.accentLight.withValues(alpha: 0.55),
                            context.colors.accent.withValues(alpha: 0.48),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.55),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.accent.withValues(alpha: isDark ? 0.25 : 0.20),
                      blurRadius: 24,
                      spreadRadius: -4,
                      offset: const Offset(0, 8),
                    ),
                    // Specular top highlight
                    BoxShadow(
                      color: Colors.white.withValues(
                        alpha: isDark ? 0.05 : 0.30,
                      ),
                      blurRadius: 0,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const _IslandPulseDot(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workoutState.routine.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF3D1A08),
                              letterSpacing: -0.13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            l10n.workoutInProgress,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : const Color(
                                      0xFF3D1A08,
                                    ).withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                      child: Text(
                        FormatUtils.timer(workoutState.elapsedSeconds),
                        key: ValueKey(workoutState.elapsedSeconds),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF3D1A08),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : Colors.white.withValues(alpha: 0.60),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: isDark ? Colors.white : const Color(0xFF3D1A08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pulsing dot ───────────────────────────────────────────────────────────────

class _IslandPulseDot extends StatefulWidget {
  const _IslandPulseDot({super.key});

  @override
  State<_IslandPulseDot> createState() => _IslandPulseDotState();
}

class _IslandPulseDotState extends State<_IslandPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 1.0,
      end: 0.30,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: isDark ? Colors.white : const Color(0xFF3D1A08),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
