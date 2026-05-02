import 'package:flutter/material.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../domain/entities/session.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/exercise.dart';

class HistoryExerciseDetail extends StatelessWidget {
  const HistoryExerciseDetail({super.key, required this.exercise});
  final SessionExercise exercise;

  @override
  Widget build(BuildContext context) {
    final sets = exercise.sets;

    // Create a dummy exercise to use the localization logic
    final dummy = Exercise(
      id: exercise.exerciseId,
      name: exercise.name,
      muscle: exercise.muscle,
      equipment: '',
    );

    return GlassContainer(
      radius: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dummy.getLocalizedName(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.ink900,
                  ),
                ),
              ),
              Text(
                dummy.getLocalizedMuscle(context),
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.ink400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sets.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final isSplit = s.leftKg != null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colors.ink400,
                      ),
                    ),
                  ),
                  if (isSplit) ...[
                    Expanded(
                      child: Text(
                        'L: ${FormatUtils.weight(s.leftKg!)}kg × ${s.leftReps}  '
                        'R: ${FormatUtils.weight(s.kg)}kg × ${s.reps}',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.ink700,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Text(
                        '${FormatUtils.weight(s.kg)}kg × ${s.reps}',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.ink700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
