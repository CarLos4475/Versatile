import 'package:flutter/material.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/workout_set.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/l10n_utils.dart';
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
    this.onSkip,
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
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
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
                onSkip: onSkip,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: data.isExpanded && !data.skipped
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
        ),
        if (data.skipped)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.colors.accent.withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.skipped.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.08,
                      color: context.colors.accentDeep,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
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
    this.onSkip,
  });

  final int index;
  final ExerciseWorkoutState data;
  final Exercise exercise;
  final VoidCallback onToggle;
  final VoidCallback? onToggleSplit;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PressableScale(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _IndexBadge(
              index: index,
              isDone: data.isDone,
              hasProgress: data.completedSets.isNotEmpty,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.getLocalizedName(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.ink900,
                      letterSpacing: -0.16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${data.completedSets.length}/${data.targetSets} ${l10n.sets} · ${data.targetReps} reps · ${exercise.getLocalizedMuscle(context)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.ink500,
                    ),
                  ),
                ],
              ),
            ),
            if (onSkip != null && !data.isDone && !data.skipped)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PressableScale(
                  onTap: onSkip,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: context.colors.hairline.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.skip_next_rounded,
                      size: 16,
                      color: context.colors.ink300,
                    ),
                  ),
                ),
              ),
            if (onToggleSplit != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PressableScale(
                  onTap: onToggleSplit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: data.isSplitMode
                          ? context.colors.accentTint
                          : context.colors.fieldBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.split_label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: data.isSplitMode
                            ? context.colors.accentDeep
                            : context.colors.ink400,
                      ),
                    ),
                  ),
                ),
              ),
            Icon(
              data.isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: context.colors.ink300,
            ),
          ],
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Divider(color: context.colors.hairline, thickness: 0.5, height: 14),

          const _ColumnHeaders(),
          const SizedBox(height: 2),

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
                      l10n.finishSet(data.nextSetIndex + 1),
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
    final l10n = AppLocalizations.of(context)!;
    final style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: context.colors.ink300,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text(l10n.set_label, style: style)),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.weight_label, style: style)),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.reps_label, style: style)),
          const SizedBox(width: 8),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
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
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  TextStyle _repsStyle(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: context.colors.ink900,
    fontFeatures: const [FontFeature.tabularFigures()],
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
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (set.isSplit) ...[
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
                    const SizedBox(height: 3),
                    _SideValueRow(
                      side: 'R',
                      text: '${FormatUtils.weight(set.kg)} kg',
                      style: _weightStyle(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${set.leftReps}', style: _repsStyle(context)),
                    const SizedBox(height: 3),
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
              const SizedBox(width: 8),
              Expanded(child: Text('${set.reps}', style: _repsStyle(context))),
            ],
            const SizedBox(width: 8),
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
            const SizedBox(width: 7),
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
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      Text(l10n.last_label, style: _ghostStyle(context)),
                    ],
                  )
                : Text('↑ ${l10n.last_label}', style: _ghostStyle(context)),
          ),
          const SizedBox(width: 8),
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
                  const SizedBox(height: 3),
                  _SideValueRow(
                    side: 'R',
                    text: '${FormatUtils.weight(prevSet.kg)} kg',
                    style: _ghostStyle(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${prevSet.leftReps}', style: _ghostStyle(context)),
                  const SizedBox(height: 3),
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
            const SizedBox(width: 8),
            Expanded(
              child: Text('${prevSet.reps}', style: _ghostStyle(context)),
            ),
          ],
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

  TextStyle _sideStyle(BuildContext context) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: context.colors.accent.withValues(alpha: 0.5),
  );

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
            const SizedBox(width: 8),
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
                            onChanged: (val) => onWeightChanged(val.toDouble()),
                            suffix: 'kg',
                            isDouble: true,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                    ),
            ),
            const SizedBox(width: 8),
            PressableScale(
              onTap: onFinishSet,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.colors.accentLight, context.colors.accent],
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
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
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
    color: context.colors.accent.withValues(alpha: 0.5),
  );

  @override
  Widget build(BuildContext context) {
    final leftKg = currentInput.leftKg ?? currentInput.kg;
    final leftReps = currentInput.leftReps ?? currentInput.reps;

    return Row(
      children: [
        // WEIGHT column
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
                  const SizedBox(width: 4),
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
                      onDecrement: () => onWeightChanged(
                        (currentInput.kg - 2.5).clamp(0, 999),
                      ),
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
        // REPS column
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
                  color: hasProgress
                      ? context.colors.accent
                      : context.colors.ink500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
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
    color: context.colors.ink300,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 12, child: Text(side, style: _sideStyle(context))),
        const SizedBox(width: 4),
        Text(text, style: style),
      ],
    );
  }
}
