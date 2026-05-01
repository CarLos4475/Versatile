import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/workout_set.dart';
import '../view_models/active_workout_view_model.dart';
import 'number_input_widget.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.index,
    required this.data,
    required this.exercise,
    required this.prevSets,
    required this.onToggle,
    required this.onFinishSet,
    required this.onWeightChanged,
    required this.onRepsChanged,
  });

  final int index;
  final ExerciseWorkoutState data;
  final Exercise exercise;
  final List<WorkoutSet> prevSets;
  final VoidCallback onToggle;
  final VoidCallback onFinishSet;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3C2814).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CardHeader(
            index: index,
            data: data,
            exercise: exercise,
            onToggle: onToggle,
          ),
          if (data.isExpanded)
            _CardBody(
              data: data,
              prevSets: prevSets,
              onFinishSet: onFinishSet,
              onWeightChanged: onWeightChanged,
              onRepsChanged: onRepsChanged,
            ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.index,
    required this.data,
    required this.exercise,
    required this.onToggle,
  });

  final int index;
  final ExerciseWorkoutState data;
  final Exercise exercise;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            _IndexBadge(index: index, isDone: data.isDone,
                hasProgress: data.completedSets.isNotEmpty),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                      letterSpacing: -0.15,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${data.completedSets.length}/${data.targetSets} sets · '
                    '${data.targetReps} reps · ${exercise.muscle}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: data.isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: AppColors.ink400),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  const _IndexBadge({
    required this.index,
    required this.isDone,
    required this.hasProgress,
  });

  final int index;
  final bool isDone;
  final bool hasProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isDone
            ? const LinearGradient(
                colors: [Color(0xFF4A8A5A), Color(0xFF3A6E48)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isDone
            ? null
            : hasProgress
                ? AppColors.accentTint
                : const Color(0x0D000000),
        borderRadius: BorderRadius.circular(10),
      ),
      child: isDone
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: hasProgress ? AppColors.accentDeep : AppColors.ink500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.data,
    required this.prevSets,
    required this.onFinishSet,
    required this.onWeightChanged,
    required this.onRepsChanged,
  });

  final ExerciseWorkoutState data;
  final List<WorkoutSet> prevSets;
  final VoidCallback onFinishSet;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(
            color: Color(0x0F000000),
            thickness: 0.5,
            height: 14,
          ),

          // Column headers
          const _ColumnHeaders(),
          const SizedBox(height: 2),

          // Completed sets
          ...data.completedSets.asMap().entries.map((e) => _CompletedSetRow(
                setIndex: e.key,
                set: e.value,
              )),

          // Current set + ghost row
          if (!data.isDone && data.currentInput != null) ...[
            // Ghost row (previous performance)
            if (data.nextSetIndex < prevSets.length)
              _GhostRow(prevSet: prevSets[data.nextSetIndex])
            else if (prevSets.isNotEmpty)
              _GhostRow(prevSet: prevSets.last),

            // Active input row
            _ActiveSetRow(
              setIndex: data.nextSetIndex,
              currentInput: data.currentInput!,
              onFinishSet: onFinishSet,
              onWeightChanged: onWeightChanged,
              onRepsChanged: onRepsChanged,
            ),
          ],

          // "Finish set N" shortcut link
          if (!data.isDone)
            GestureDetector(
              onTap: onFinishSet,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 13, color: AppColors.accentDeep),
                    const SizedBox(width: 4),
                    Text(
                      'Finish set ${data.nextSetIndex + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  const _ColumnHeaders();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('SET', style: _headerStyle),
          ),
          SizedBox(width: 8),
          Expanded(child: Text('WEIGHT', style: _headerStyle)),
          SizedBox(width: 8),
          Expanded(child: Text('REPS', style: _headerStyle)),
          SizedBox(width: 8),
          SizedBox(width: 36),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.06,
    color: AppColors.ink400,
  );
}

class _CompletedSetRow extends StatelessWidget {
  const _CompletedSetRow({required this.setIndex, required this.set});
  final int setIndex;
  final WorkoutSet set;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x0F4A8A5A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${setIndex + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${FormatUtils.weight(set.kg)} kg',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${set.reps}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0x2E4A8A5A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.check,
                  size: 13, color: AppColors.green700),
            ),
            const SizedBox(width: 7),
          ],
        ),
      ),
    );
  }
}

class _GhostRow extends StatelessWidget {
  const _GhostRow({required this.prevSet});
  final WorkoutSet prevSet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
      child: Row(
        children: [
          const SizedBox(
            width: 32,
            child: Text(
              '↑ Last',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.ink300,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${FormatUtils.weight(prevSet.kg)} kg',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.ink300,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${prevSet.reps}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.ink300,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _ActiveSetRow extends StatelessWidget {
  const _ActiveSetRow({
    required this.setIndex,
    required this.currentInput,
    required this.onFinishSet,
    required this.onWeightChanged,
    required this.onRepsChanged,
  });

  final int setIndex;
  final WorkoutSet currentInput;
  final VoidCallback onFinishSet;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0x0DD97757),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.accent.withOpacity(0.35),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${setIndex + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentDeep,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberInputWidget(
                value: currentInput.kg,
                onDecrement: () =>
                    onWeightChanged((currentInput.kg - 2.5).clamp(0, 999)),
                onIncrement: () => onWeightChanged(currentInput.kg + 2.5),
                suffix: 'kg',
                isDouble: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberInputWidget(
                value: currentInput.reps,
                onDecrement: () =>
                    onRepsChanged((currentInput.reps - 1).clamp(0, 999)),
                onIncrement: () => onRepsChanged(currentInput.reps + 1),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onFinishSet,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE08866), Color(0xFFD97757)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentDeep.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
