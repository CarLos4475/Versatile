import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
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

  static const _screens = [
    HomeScreen(),
    RoutinesScreen(),
    ExercisesScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final activeRoutineId = ref.watch(activeWorkoutRoutineIdProvider);
    if (activeRoutineId != null) {
      ref.watch(activeWorkoutProvider(activeRoutineId));
    }

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          const _ActiveWorkoutIsland(),
          Positioned(
            left: 12,
            right: 12,
            bottom: 14,
            child: VersatileBottomNav(
              currentIndex: _currentIndex,
              onChanged: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveWorkoutIsland extends ConsumerWidget {
  const _ActiveWorkoutIsland();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineId = ref.watch(activeWorkoutRoutineIdProvider);
    if (routineId == null) return const SizedBox.shrink();

    final workoutState = ref.watch(activeWorkoutProvider(routineId));

    return Positioned(
      left: 12,
      right: 12,
      bottom: 92,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActiveWorkoutScreen(routineId: routineId),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                  Text(
                    FormatUtils.timer(workoutState.elapsedSeconds),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()],
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
    _anim = Tween<double>(begin: 1.0, end: 0.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
