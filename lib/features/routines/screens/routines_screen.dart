import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/glass_button.dart';
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
            const SizedBox(height: 14),
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
                    ? _EmptyRoutines(isEs: isEs)
                    : _RoutinesList(routines: routines, exercises: exercises),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridDivider extends StatelessWidget {
  const _GridDivider();
  @override
  Widget build(BuildContext context) {
    return Container(height: 0.6, color: context.colors.hairline);
  }
}

class _RoutinesList extends StatelessWidget {
  const _RoutinesList({required this.routines, required this.exercises});

  final List<Routine> routines;
  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 96),
        child: Column(
          children: [
            const _GridDivider(),
            for (final r in routines) ...[
              _RoutineRow(routine: r, exercises: exercises),
              const _GridDivider(),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoutineRow extends StatelessWidget {
  const _RoutineRow({required this.routine, required this.exercises});

  final Routine routine;
  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
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

    return PressableScale(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RoutineDetailScreen(routineId: routine.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Row(
          children: [
            Container(width: 3, height: 52, color: color),
            const SizedBox(width: 14),
            Icon(
              IconData(routine.iconCode, fontFamily: 'MaterialIcons'),
              size: 18,
              color: colors.ink700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    routine.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: colors.ink900,
                      letterSpacing: -0.17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${routine.exercises.length} ${l10n.exercisesLabel} · ~${routine.estimatedMinutes} min',
                    style: TextStyle(fontSize: 12, color: colors.ink500),
                  ),
                  if (muscles.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      muscles.join(' · ').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: colors.ink400,
                        letterSpacing: 0.18,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: colors.ink900.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRoutines extends StatelessWidget {
  const _EmptyRoutines({required this.isEs});

  final bool isEs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final prefix = isEs ? 'Crea' : 'Create';
    final accent = isEs ? 'tu primera rutina.' : 'your first one.';

    return FadeSlideIn(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.noRoutinesYet.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: colors.ink400,
                  letterSpacing: 0.18,
                ),
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$prefix\n',
                      style: TextStyle(
                        fontSize: 42,
                        height: 0.94,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.05,
                        color: colors.ink900,
                      ),
                    ),
                    TextSpan(
                      text: accent,
                      style: TextStyle(
                        fontSize: 42,
                        height: 0.94,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.045,
                        color: colors.accentLight,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              const SizedBox(height: 22),
              Text(
                isEs
                    ? 'Toca + arriba para empezar.'
                    : 'Tap + above to start.',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.ink500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: context.colors.accent,
              strokeWidth: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: context.colors.ink400,
              letterSpacing: 0.18,
            ),
          ),
        ],
      ),
    );
  }
}
