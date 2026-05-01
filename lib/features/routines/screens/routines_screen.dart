import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../exercises/view_models/exercises_view_model.dart';
import '../view_models/routines_view_model.dart';
import 'create_routine_screen.dart';
import 'routine_detail_screen.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesProvider);
    final exercises = ref.watch(exercisesAsyncProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: routinesAsync.when(
          loading: () => const _LoadingBody(label: 'Loading routines…'),
          error: (e, _) => Center(
            child: Text(
              'Error: $e',
              style: const TextStyle(color: AppColors.ink500),
            ),
          ),
          data: (routines) => SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: 'Routines',
                  subtitle: '${routines.length} workout templates',
                  trailing: IconCircleButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateRoutineScreen(),
                      ),
                    ),
                    accent: true,
                  ),
                ),
                const SizedBox(height: 16),
                if (routines.isEmpty)
                  const _EmptyRoutines()
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: routines
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RoutineCard(
                                routine: r,
                                exercises: exercises,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyRoutines extends StatelessWidget {
  const _EmptyRoutines();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accentTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 34,
                color: AppColors.accentDeep,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No routines yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap + to create your first workout template.',
              style: TextStyle(fontSize: 13, color: AppColors.ink400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.routine, required this.exercises});
  final Routine routine;
  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    final color = Color(routine.colorValue);
    final muscles = routine.exercises
        .map((re) {
          try {
            return exercises.firstWhere((ex) => ex.id == re.exerciseId).muscle;
          } catch (_) {
            return null;
          }
        })
        .whereType<String>()
        .toSet()
        .toList();

    return FadeSlideIn(
      child: GlassContainer(
        radius: 20,
        padding: const EdgeInsets.all(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RoutineDetailScreen(routineId: routine.id),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${routine.exercises.length} exercises · ~${routine.estimatedMinutes} min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.ink500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.ink900.withOpacity(0.3),
                ),
              ],
            ),
            if (muscles.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: muscles
                    .map(
                      (m) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentTint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          m,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.accentDeep,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2,
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.ink400),
          ),
        ],
      ),
    );
  }
}
