import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/home_view_model.dart';
import '../widgets/session_card.dart';
import '../widgets/stat_card.dart';
import '../../active_workout/screens/active_workout_screen.dart';
import '../../history/screens/session_detail_screen.dart';
import '../../routines/screens/create_routine_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final now = DateTime.now();
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final firstRoutine =
        state.routines.isNotEmpty ? state.routines.first : null;

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Today',
                subtitle:
                    '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}',
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: firstRoutine != null
                    ? _HeroCard(
                        routineId: firstRoutine.id,
                        routineName: firstRoutine.name,
                        exerciseCount: firstRoutine.exercises.length,
                        estimatedMin: firstRoutine.estimatedMinutes,
                      )
                    : _EmptyHeroCard(
                        onCreateRoutine: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CreateRoutineScreen(),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'This week',
                        value: state.weekSessions.toString(),
                        unit: 'sessions',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Volume',
                        value: state.weekVolume >= 1000
                            ? (state.weekVolume / 1000).toStringAsFixed(1)
                            : state.weekVolume.toStringAsFixed(0),
                        unit: state.weekVolume >= 1000 ? 'k kg' : 'kg',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Streak',
                        value: '${state.streak}',
                        unit: 'days',
                        accent: true,
                      ),
                    ),
                  ],
                ),
              ),

              if (state.sessions.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'Recent sessions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.18,
                          color: AppColors.ink900,
                        ),
                      ),
                      Text(
                        '${state.sessions.length} total',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.ink400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    children: state.sessions.take(4).map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SessionCard(
                            session: s,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    SessionDetailScreen(session: s),
                              ),
                            ),
                          ),
                        )).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.routineId,
    required this.routineName,
    required this.exerciseCount,
    required this.estimatedMin,
  });

  final String routineId;
  final String routineName;
  final int exerciseCount;
  final int estimatedMin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE08866), Color(0xFFD97757), Color(0xFFB85432)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentDeep.withOpacity(0.35),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x40FFFFFF), Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text(
                  "NEXT WORKOUT",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.06,
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Text(
                routineName,
                style: const TextStyle(
                  fontSize: 34,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.68,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$exerciseCount exercises · ~$estimatedMin min',
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ActiveWorkoutScreen(routineId: routineId),
                  ),
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 0.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Start workout',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyHeroCard extends StatelessWidget {
  const _EmptyHeroCard({required this.onCreateRoutine});
  final VoidCallback onCreateRoutine;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCreateRoutine,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No routines yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppColors.ink900,
                letterSpacing: -0.44,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tap here to create your first workout template.',
              style: TextStyle(fontSize: 14, color: AppColors.ink500),
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Icon(Icons.add_circle_outline,
                    size: 16, color: AppColors.accentDeep),
                SizedBox(width: 6),
                Text(
                  'Create routine',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentDeep,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
