import 'package:flutter/material.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/motion.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/entities/workout_set.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/exercise.dart';
import '../../exercises/screens/exercise_progress_screen.dart';

String? _muscleAsset(String muscle) => switch (muscle) {
  'Chest' =>
    'assets/assets/Torso/pecho/pecho_edit_24359279032740.png',
  'Back' =>
    'assets/assets/Torso/espalda/back_edit_24411266380648.png',
  'Shoulders' =>
    'assets/assets/Torso/hombro/shoulder_edit_24384715995236.png',
  'Core' => 'assets/assets/Torso/core/Core_edit_24439960498352.png',
  'Biceps' =>
    'assets/assets/Torso/brazos/biceps_edit_24565456161875.png',
  'Triceps' =>
    'assets/assets/Torso/brazos/triceps_edit_24496361907719.png',
  'Forearms' =>
    'assets/assets/Torso/brazos/forearm_edit_24532082903547.png',
  'Quadriceps' => 'assets/assets/Piernas/cuadriceps.png',
  'Hamstrings' =>
    'assets/assets/Piernas/femoral_edit_24694965504563.png',
  'Glutes' => 'assets/assets/Piernas/glutes_edit_24675899562379.png',
  'Calves' => 'assets/assets/Piernas/calf_edit_24757805204033.png',
  _ => null,
};

class HistoryExerciseDetail extends StatelessWidget {
  const HistoryExerciseDetail({super.key, required this.exercise, this.chartBtnKey});
  final SessionExercise exercise;
  final GlobalKey? chartBtnKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sets = exercise.sets;
    final colors = context.colors;
    final dummy = Exercise(
      id: exercise.exerciseId,
      name: exercise.name,
      muscle: exercise.muscle,
      equipment: '',
    );
    final asset = _muscleAsset(exercise.muscle);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.accent,
                ),
                child: asset != null
                    ? Padding(
                        padding: const EdgeInsets.all(7),
                        child: Image.asset(asset, fit: BoxFit.contain),
                      )
                    : Icon(
                        Icons.fitness_center,
                        size: 18,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dummy.getLocalizedName(context),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.ink900,
                        letterSpacing: -0.15,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      dummy.getLocalizedMuscle(context),
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.ink400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Builder(builder: (context) {
                final btn = PressableScale(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ExerciseProgressScreen(
                        exerciseId: exercise.exerciseId,
                        exerciseName: exercise.name,
                        muscle: exercise.muscle,
                      ),
                    ),
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.ink900.withValues(alpha: 0.04),
                      border: Border.all(
                        color: colors.hairline,
                        width: 0.6,
                      ),
                    ),
                    child: Icon(
                      Icons.show_chart_rounded,
                      size: 16,
                      color: colors.accentDeep,
                    ),
                  ),
                );
                return chartBtnKey != null
                    ? KeyedSubtree(key: chartBtnKey!, child: btn)
                    : btn;
              }),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 0.5, color: colors.hairline),
          const SizedBox(height: 8),
          _ColumnHeaders(l10n: l10n),
          ...List.generate(sets.length, (i) => Column(
            children: [
              Container(
                height: 0.5,
                color: colors.accent.withValues(alpha: 0.18),
              ),
              _SetRow(setIndex: i, set: sets[i]),
            ],
          )),
        ],
      ),
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  const _ColumnHeaders({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: context.colors.ink300,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text(l10n.set_label, style: style)),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.weight_label, style: style)),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.reps_label, style: style)),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.setIndex, required this.set});
  final int setIndex;
  final WorkoutSet set;

  TextStyle _numStyle(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: context.colors.ink900,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle _sideStyle(BuildContext context) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: context.colors.ink300,
  );

  @override
  Widget build(BuildContext context) {
    final indexStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: context.colors.ink700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    if (set.isSplit) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('${setIndex + 1}', style: indexStyle),
                      const SizedBox(width: 3),
                      Text('L', style: _sideStyle(context)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${FormatUtils.weight(set.leftKg!)} kg',
                    style: _numStyle(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${set.leftReps}', style: _numStyle(context)),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Text('R', style: _sideStyle(context)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${FormatUtils.weight(set.kg)} kg',
                    style: _numStyle(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${set.reps}', style: _numStyle(context)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('${setIndex + 1}', style: indexStyle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${FormatUtils.weight(set.kg)} kg',
              style: _numStyle(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${set.reps}', style: _numStyle(context)),
          ),
        ],
      ),
    );
  }
}
