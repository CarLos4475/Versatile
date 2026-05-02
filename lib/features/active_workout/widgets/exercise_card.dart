import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/workout_set.dart';
import '../../../shared/widgets/motion.dart';
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
    this.onToggleSplit,
    this.onLeftWeightChanged,
    this.onLeftRepsChanged,
  });

  final int index;
  final ExerciseWorkoutState data;
  final Exercise exercise;
  final List<WorkoutSet> prevSets;
  final VoidCallback onToggle;
  final VoidCallback onFinishSet;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;
  final VoidCallback? onToggleSplit;
  final ValueChanged<double>? onLeftWeightChanged;
  final ValueChanged<int>? onLeftRepsChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: context.colors.bgFrame,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.glassBorder, width: 0.5),
        boxShadow: context.colors.glassShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CardHeader(
            index: index,
            data: data,
            exercise: exercise,
            onToggle: onToggle,
            onToggleSplit: onToggleSplit,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: data.isExpanded
                ? _CardBody(
                    data: data,
                    prevSets: prevSets,
                    onFinishSet: onFinishSet,
                    onWeightChanged: onWeightChanged,
                    onRepsChanged: onRepsChanged,
                    onLeftWeightChanged: onLeftWeightChanged,
                    onLeftRepsChanged: onLeftRepsChanged,
                  )
                : const SizedBox.shrink(),
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
    this.onToggleSplit,
  });

  final int index;
  final ExerciseWorkoutState data;
  final Exercise exercise;
  final VoidCallback onToggle;
  final VoidCallback? onToggleSplit;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            _IndexBadge(
              index: index,
              isDone: data.isDone,
              hasProgress: data.completedSets.isNotEmpty,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.colors.ink900,
                      letterSpacing: -0.15,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    '${data.completedSets.length}/${data.targetSets} sets · '
                    '${data.targetReps} reps · ${exercise.muscle}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.ink500,
                    ),
                  ),
                ],
              ),
            ),
            if (data.isUnilateral && onToggleSplit != null) ...[
              PressableScale(
                onTap: onToggleSplit,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: data.isSplitMode
                        ? context.colors.accentTint
                        : const Color(0x0A000000),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: data.isSplitMode
                          ? context.colors.accent
                          : context.colors.glassBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'Split',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: data.isSplitMode
                          ? context.colors.accentDeep
                          : context.colors.ink400,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
            ],
            AnimatedRotation(
              turns: data.isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: context.colors.ink400,
              ),
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
            ? context.colors.accent.withValues(alpha: 0.15)
            : context.colors.fieldBg,
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
                  color: hasProgress ? context.colors.accent : context.colors.ink500,
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
    this.onLeftWeightChanged,
    this.onLeftRepsChanged,
  });

  final ExerciseWorkoutState data;
  final List<WorkoutSet> prevSets;
  final VoidCallback onFinishSet;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;
  final ValueChanged<double>? onLeftWeightChanged;
  final ValueChanged<int>? onLeftRepsChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Divider(color: context.colors.hairline, thickness: 0.5, height: 14),

          const _ColumnHeaders(),
          SizedBox(height: 2),

          // Completed sets
          ...data.completedSets.asMap().entries.map(
            (e) => _CompletedSetRow(
              setIndex: e.key,
              set: e.value,
              isSplitMode: data.isSplitMode,
            ),
          ),

          // Current set + ghost row
          if (!data.isDone && data.currentInput != null) ...[
            if (data.nextSetIndex < prevSets.length)
              _GhostRow(
                prevSet: prevSets[data.nextSetIndex],
                isSplitMode: data.isSplitMode,
              )
            else if (prevSets.isNotEmpty)
              _GhostRow(prevSet: prevSets.last, isSplitMode: data.isSplitMode),

            _ActiveSetRow(
              setIndex: data.nextSetIndex,
              currentInput: data.currentInput!,
              isSplitMode: data.isSplitMode,
              onFinishSet: onFinishSet,
              onWeightChanged: onWeightChanged,
              onRepsChanged: onRepsChanged,
              onLeftWeightChanged: onLeftWeightChanged,
              onLeftRepsChanged: onLeftRepsChanged,
            ),
          ],

          if (!data.isDone)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: PressableScale(
                onTap: onFinishSet,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: context.colors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Finish set ${data.nextSetIndex + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: context.colors.accent,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('SET', style: _headerStyle(context))),
          SizedBox(width: 8),
          Expanded(child: Text('WEIGHT', style: _headerStyle(context))),
          SizedBox(width: 8),
          Expanded(child: Text('REPS', style: _headerStyle(context))),
          SizedBox(width: 8),
          SizedBox(width: 36),
        ],
      ),
    );
  }

  TextStyle _headerStyle(BuildContext context) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.06,
    color: context.colors.ink400,
  );
}

class _CompletedSetRow extends StatelessWidget {
  const _CompletedSetRow({
    required this.setIndex,
    required this.set,
    required this.isSplitMode,
  });
  final int setIndex;
  final WorkoutSet set;
  final bool isSplitMode;

  TextStyle _weightStyle(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: context.colors.ink900,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  TextStyle _repsStyle(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: context.colors.ink900,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: context.colors.doneTint,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${setIndex + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colors.ink700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            SizedBox(width: 8),
            if (set.isSplit) ...[
              // WEIGHT column with L / R labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SideValueRow(
                      side: 'L',
                      text: '${FormatUtils.weight(set.leftKg!)} kg',
                      style: _weightStyle(context),
                    ),
                    SizedBox(height: 3),
                    _SideValueRow(
                      side: 'R',
                      text: '${FormatUtils.weight(set.kg)} kg',
                      style: _weightStyle(context),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              // REPS column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${set.leftReps}', style: _repsStyle(context)),
                    SizedBox(height: 3),
                    Text('${set.reps}', style: _repsStyle(context)),
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: Text(
                  '${FormatUtils.weight(set.kg)} kg',
                  style: _weightStyle(context),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text('${set.reps}', style: _repsStyle(context)),
              ),
            ],
            SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: context.colors.doneIconBg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.check,
                size: 13,
                color: context.colors.doneStrong,
              ),
            ),
            SizedBox(width: 7),
          ],
        ),
      ),
    );
  }
}

class _GhostRow extends StatelessWidget {
  const _GhostRow({required this.prevSet, required this.isSplitMode});
  final WorkoutSet prevSet;
  final bool isSplitMode;

  TextStyle _ghostStyle(BuildContext context) => TextStyle(
    fontSize: 11,
    color: context.colors.ink300,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @override
  Widget build(BuildContext context) {
    final showSplit = isSplitMode && prevSet.isSplit;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: showSplit
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('↑', style: _ghostStyle(context)),
                      Text('Last', style: _ghostStyle(context)),
                    ],
                  )
                : Text('↑ Last', style: _ghostStyle(context)),
          ),
          SizedBox(width: 8),
          if (showSplit) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SideValueRow(
                    side: 'L',
                    text: '${FormatUtils.weight(prevSet.leftKg!)} kg',
                    style: _ghostStyle(context),
                  ),
                  SizedBox(height: 3),
                  _SideValueRow(
                    side: 'R',
                    text: '${FormatUtils.weight(prevSet.kg)} kg',
                    style: _ghostStyle(context),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${prevSet.leftReps}', style: _ghostStyle(context)),
                  SizedBox(height: 3),
                  Text('${prevSet.reps}', style: _ghostStyle(context)),
                ],
              ),
            ),
          ] else ...[
            Expanded(
              child: Text(
                '${FormatUtils.weight(prevSet.kg)} kg',
                style: _ghostStyle(context),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text('${prevSet.reps}', style: _ghostStyle(context)),
            ),
          ],
          SizedBox(width: 8),
          SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _ActiveSetRow extends StatelessWidget {
  const _ActiveSetRow({
    required this.setIndex,
    required this.currentInput,
    required this.isSplitMode,
    required this.onFinishSet,
    required this.onWeightChanged,
    required this.onRepsChanged,
    this.onLeftWeightChanged,
    this.onLeftRepsChanged,
  });

  final int setIndex;
  final WorkoutSet currentInput;
  final bool isSplitMode;
  final VoidCallback onFinishSet;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;
  final ValueChanged<double>? onLeftWeightChanged;
  final ValueChanged<int>? onLeftRepsChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.accent.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.accent.withValues(alpha: 0.7),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${setIndex + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.colors.accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: isSplitMode
                  ? _SplitInputs(
                      currentInput: currentInput,
                      onWeightChanged: onWeightChanged,
                      onRepsChanged: onRepsChanged,
                      onLeftWeightChanged: onLeftWeightChanged ?? (_) {},
                      onLeftRepsChanged: onLeftRepsChanged ?? (_) {},
                    )
                  : Row(
                    children: [
                      Expanded(
                        child: NumberInputWidget(
                          value: currentInput.kg,
                          onDecrement: () => onWeightChanged(
                            (currentInput.kg - 2.5).clamp(0, 999),
                          ),
                          onIncrement: () =>
                              onWeightChanged(currentInput.kg + 2.5),
                          onChanged: (val) =>
                              onWeightChanged(val.toDouble()),
                          suffix: 'kg',
                          isDouble: true,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: NumberInputWidget(
                          value: currentInput.reps,
                          onDecrement: () => onRepsChanged(
                            (currentInput.reps - 1).clamp(0, 999),
                          ),
                          onIncrement: () =>
                              onRepsChanged(currentInput.reps + 1),
                          onChanged: (val) => onRepsChanged(val.toInt()),
                        ),
                      ),
                    ],
                  ),            ),
            SizedBox(width: 8),
            PressableScale(
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
                      color: context.colors.accentDeep.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitInputs extends StatelessWidget {
  const _SplitInputs({
    required this.currentInput,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onLeftWeightChanged,
    required this.onLeftRepsChanged,
  });

  final WorkoutSet currentInput;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;
  final ValueChanged<double> onLeftWeightChanged;
  final ValueChanged<int> onLeftRepsChanged;

  TextStyle _sideStyle(BuildContext context) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: context.colors.accentDeep,
  );

  @override
  Widget build(BuildContext context) {
    final leftKg = currentInput.leftKg ?? currentInput.kg;
    final leftReps = currentInput.leftReps ?? currentInput.reps;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // WEIGHT column — L/R labels live here so they align with the header
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    child: Text('L', style: _sideStyle(context)),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: NumberInputWidget(
                      value: leftKg,
                      onDecrement: () =>
                          onLeftWeightChanged((leftKg - 2.5).clamp(0, 999)),
                      onIncrement: () => onLeftWeightChanged(leftKg + 2.5),
                      onChanged: (val) => onLeftWeightChanged(val.toDouble()),
                      suffix: 'kg',
                      isDouble: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    child: Text('R', style: _sideStyle(context)),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: NumberInputWidget(
                      value: currentInput.kg,
                      onDecrement: () =>
                          onWeightChanged((currentInput.kg - 2.5).clamp(0, 999)),
                      onIncrement: () => onWeightChanged(currentInput.kg + 2.5),
                      onChanged: (val) => onWeightChanged(val.toDouble()),
                      suffix: 'kg',
                      isDouble: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // REPS column — aligned with the REPS header
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NumberInputWidget(
                value: leftReps,
                onDecrement: () =>
                    onLeftRepsChanged((leftReps - 1).clamp(0, 999)),
                onIncrement: () => onLeftRepsChanged(leftReps + 1),
                onChanged: (val) => onLeftRepsChanged(val.toInt()),
              ),
              const SizedBox(height: 4),
              NumberInputWidget(
                value: currentInput.reps,
                onDecrement: () =>
                    onRepsChanged((currentInput.reps - 1).clamp(0, 999)),
                onIncrement: () => onRepsChanged(currentInput.reps + 1),
                onChanged: (val) => onRepsChanged(val.toInt()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SideValueRow extends StatelessWidget {
  const _SideValueRow({
    required this.side,
    required this.text,
    required this.style,
  });

  final String side;
  final String text;
  final TextStyle style;

  TextStyle _sideStyle(BuildContext context) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: context.colors.accentDeep,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 12, child: Text(side, style: _sideStyle(context))),
        SizedBox(width: 4),
        Text(text, style: style),
      ],
    );
  }
}
