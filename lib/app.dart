import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_page_transitions.dart';
import 'core/services/workout_notification_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/glass_effect.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/format_utils.dart';
import 'features/active_workout/screens/active_workout_screen.dart';
import 'features/active_workout/view_models/active_workout_view_model.dart';
import 'features/exercises/screens/exercises_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/routines/screens/routines_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'shared/widgets/bottom_nav_bar.dart';
import 'shared/widgets/motion.dart';

class VersatileApp extends StatelessWidget {
  const VersatileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Versatile',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  final List<int> _tabHistory = [0];

  @override
  void initState() {
    super.initState();
    _restoreActiveWorkoutIfNeeded();
  }

  Future<void> _restoreActiveWorkoutIfNeeded() async {
    final info = await WorkoutNotificationService.getActiveWorkout();
    if (info == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).push(
          AppRoute(
            page: ActiveWorkoutScreen(
              routineId: info.routineId,
              restoredStartedAt: info.startedAt,
            ),
          ),
        );
      }
    });
  }

  static const _screens = [
    HomeScreen(),
    RoutinesScreen(),
    ExercisesScreen(),
    HistoryScreen(),
  ];

  void _selectTab(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
      _tabHistory.remove(index);
      _tabHistory.add(index);
    });
  }

  void _goBackTab() {
    if (_tabHistory.length <= 1) return;

    setState(() {
      _tabHistory.removeLast();
      _currentIndex = _tabHistory.last;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeRoutineId = ref.watch(activeWorkoutRoutineIdProvider);
    if (activeRoutineId != null) {
      ref.watch(activeWorkoutProvider(activeRoutineId));
    }

    return PopScope(
      canPop: _tabHistory.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBackTab();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgApp,
        body: Stack(
          children: [
            Positioned.fill(
              child: _AnimatedShellPages(
                index: _currentIndex,
                children: _screens,
              ),
            ),
            const _ActiveWorkoutIsland(),
            Positioned(
              left: 12,
              right: 12,
              bottom: 14,
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: VersatileBottomNav(
                  currentIndex: _currentIndex,
                  onChanged: _selectTab,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedShellPages extends StatelessWidget {
  const _AnimatedShellPages({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(18 * (1 - value), 0),
            child: Transform.scale(
              scale: 0.992 + (0.008 * value),
              child: child,
            ),
          ),
        );
      },
      child: IndexedStack(index: index, children: children),
    );
  }
}

class _ActiveWorkoutIsland extends ConsumerWidget {
  const _ActiveWorkoutIsland();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineId = ref.watch(activeWorkoutRoutineIdProvider);
    return Positioned(
      left: 12,
      right: 12,
      bottom: 92,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        reverseDuration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        child: routineId == null
            ? const SizedBox.shrink(key: ValueKey('no-workout'))
            : _ActiveWorkoutIslandCard(
                key: ValueKey(routineId),
                routineId: routineId,
              ),
      ),
    );
  }
}

class _ActiveWorkoutIslandCard extends ConsumerWidget {
  const _ActiveWorkoutIslandCard({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(activeWorkoutProvider(routineId));

    return PressableScale(
      onTap: () => Navigator.of(
        context,
      ).push(AppRoute(page: ActiveWorkoutScreen(routineId: routineId))),
      child: GlassEffect.wrap(
        sigma: 10,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.accentDeep.withOpacity(0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentDeep.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _IslandPulseDot(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workoutState.routine.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Workout in progress',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Text(
                  FormatUtils.timer(workoutState.elapsedSeconds),
                  key: ValueKey(workoutState.elapsedSeconds),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IslandPulseDot extends StatefulWidget {
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
      end: 0.35,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
