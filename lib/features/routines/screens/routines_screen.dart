import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_utils.dart';
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

class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});

  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends ConsumerState<RoutinesScreen> {
  final _addBtnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(routinesAddKeyProvider.notifier).state = _addBtnKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final routinesAsync = ref.watch(routinesProvider);
    final exercises = ref.watch(exercisesAsyncProvider).value ?? [];
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              prefix: isEs ? 'Tus' : 'Your',
              accent: '${l10n.routines.toLowerCase()}.',
              eyebrow: routinesAsync.maybeWhen(
                data: (r) => l10n.routinesInLibrary(r.length),
                orElse: () => null,
              ),
              trailing: KeyedSubtree(
                key: _addBtnKey,
                child: IconCircleButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreateRoutineScreen(),
                    ),
                  ),
                  accent: true,
                ),
              ),
            ),
            Expanded(
              child: routinesAsync.when(
                loading: () => _LoadingBody(label: l10n.preparingWorkout),
                error: (e, _) => Center(
                  child: Text(
                    'Error: $e',
                    style: TextStyle(color: context.colors.ink500),
                  ),
                ),
                data: (routines) => routines.isEmpty
                    ? const _EmptyRoutines()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 96),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
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
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRoutines extends StatelessWidget {
  const _EmptyRoutines();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                color: context.colors.accentTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.fitness_center,
                size: 34,
                color: context.colors.accentDeep,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noRoutinesYet,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: context.colors.ink900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.createFirstOne,
              style: TextStyle(fontSize: 13, color: context.colors.ink400),
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
    final l10n = AppLocalizations.of(context)!;
    final color = Color(routine.colorValue);
    final muscles = routine.exercises
        .map((re) {
          try {
            final ex = exercises.firstWhere((ex) => ex.id == re.exerciseId);
            return ex.getLocalizedMuscle(context);
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
                      colors: [color, color.withValues(alpha: 0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    IconData(routine.iconCode, fontFamily: 'MaterialIcons'),
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
                        '${routine.exercises.length} ${l10n.exercisesLabel} · ~${routine.estimatedMinutes} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.ink500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: color.withValues(alpha: 0.4),
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
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color.withValues(alpha: 0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          m,
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
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
          CircularProgressIndicator(
            color: context.colors.accent,
            strokeWidth: 2,
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: context.colors.ink400),
          ),
        ],
      ),
    );
  }
}
