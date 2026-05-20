import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_utils.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/motion.dart';
import '../../routines/view_models/routines_view_model.dart';
import 'routine_sheet_card.dart';

/// Result of editing a slot. `null` from the sheet means "cancel". A
/// SlotEditResult with [clear] true means "make this cell empty".
class SlotEditResult {
  final bool clear;
  final SlotKind? kind;
  final String? routineId;
  final String? labelText;
  const SlotEditResult.clear()
      : clear = true,
        kind = null,
        routineId = null,
        labelText = null;
  const SlotEditResult.routine(String id)
      : clear = false,
        kind = SlotKind.routine,
        routineId = id,
        labelText = null;
  const SlotEditResult.label(String text)
      : clear = false,
        kind = SlotKind.label,
        routineId = null,
        labelText = text;
}

Future<SlotEditResult?> showSlotEditorSheet(
  BuildContext context, {
  required int weekIndex,
  required int weekday,
  ProgramSlot? current,
}) {
  return showModalBottomSheet<SlotEditResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _SlotEditorSheet(
      weekIndex: weekIndex,
      weekday: weekday,
      current: current,
    ),
  );
}

const _kLabelColors = <String, Color>{
  'Cardio': Color(0xFF7A8C5B),
  'Mobility': Color(0xFF8C7A5B),
  'Movilidad': Color(0xFF8C7A5B),
  'Stretching': Color(0xFF5B7A8C),
  'Estiramiento': Color(0xFF5B7A8C),
  'Yoga': Color(0xFF8C5B7A),
};

class _SlotEditorSheet extends ConsumerStatefulWidget {
  const _SlotEditorSheet({
    required this.weekIndex,
    required this.weekday,
    this.current,
  });
  final int weekIndex;
  final int weekday;
  final ProgramSlot? current;

  @override
  ConsumerState<_SlotEditorSheet> createState() => _SlotEditorSheetState();
}

class _SlotEditorSheetState extends ConsumerState<_SlotEditorSheet> {
  SlotEditResult? _pending;

  @override
  void initState() {
    super.initState();
    final cur = widget.current;
    if (cur != null) {
      if (cur.kind == SlotKind.routine && cur.routineId != null) {
        _pending = SlotEditResult.routine(cur.routineId!);
      } else if (cur.kind == SlotKind.label &&
          (cur.labelText ?? '').isNotEmpty) {
        _pending = SlotEditResult.label(cur.labelText!);
      }
    }
  }

  void _pickRoutine(String id) {
    setState(() => _pending = SlotEditResult.routine(id));
  }

  void _pickLabel(String label) {
    setState(() => _pending = SlotEditResult.label(label));
  }

  Future<void> _pickCustom() async {
    final l10n = AppLocalizations.of(context)!;
    final currentLabel = _pending?.kind == SlotKind.label
        ? (_pending?.labelText ?? '')
        : '';
    final isPreset = isPresetSlotLabel(context, currentLabel);
    final ctrl = TextEditingController(text: isPreset ? '' : currentLabel);
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgFrame,
        title: Text(
          l10n.customLabelSection,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.colors.ink900,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(color: context.colors.ink900),
          decoration: InputDecoration(
            hintText: l10n.customLabelHint,
            hintStyle: TextStyle(color: context.colors.ink400),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.colors.ink400),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: Text(
              l10n.done,
              style: TextStyle(
                color: context.colors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (text != null && text.isNotEmpty) {
      _pickLabel(text);
    }
  }

  bool get _hasPending => _pending != null;

  void _save() {
    if (_pending == null) {
      Navigator.of(context).pop(const SlotEditResult.clear());
    } else {
      Navigator.of(context).pop(_pending);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final routines = ref.watch(routinesProvider).value ?? <Routine>[];
    final mq = MediaQuery.of(context);
    final dayName = _weekdayName(l10n, widget.weekday);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
        decoration: BoxDecoration(
          color: colors.bgFrame,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n
                              .editDayEyebrow(widget.weekIndex + 1, dayName)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: colors.accentDeep,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.whatTodayQuestion(dayName),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.44,
                            color: colors.ink900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PressableScale(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colors.ink900.withValues(alpha: 0.08),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: colors.ink700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick rest day CTA
                    _RestDayCta(
                      selected: _pending?.kind == SlotKind.label &&
                          (_pending?.labelText ?? '').toLowerCase() == 'rest',
                      title: l10n.restDayCta,
                      subtitle: l10n.restDayCtaSubtitle,
                      onTap: () => _pickLabel('Rest'),
                    ),
                    const SizedBox(height: 20),
                    _DividerLabel(text: l10n.orPickRoutine),
                    const SizedBox(height: 10),
                    if (routines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.noRoutinesYet,
                          style: TextStyle(color: colors.ink400),
                        ),
                      )
                    else
                      ...routines.map((r) {
                        final isSelected =
                            _pending?.kind == SlotKind.routine &&
                                _pending?.routineId == r.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: RoutineSheetCard(
                            name: r.name,
                            subtitle: null,
                            exerciseCount: r.exercises.length,
                            exerciseCountLabel: l10n.routineExerciseCount(
                              r.exercises.length,
                            ),
                            color: Color(r.colorValue),
                            icon: IconData(
                              r.iconCode,
                              fontFamily: 'MaterialIcons',
                            ),
                            selected: isSelected,
                            onTap: () => _pickRoutine(r.id),
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    _DividerLabel(text: l10n.orUseLabel),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final entry in <(String, String)>[
                          ('Cardio', l10n.labelCardio),
                          ('Mobility', l10n.labelMobility),
                          ('Stretching', l10n.labelStretch),
                          ('Yoga', l10n.labelYoga),
                        ])
                          _LabelChip(
                            label: entry.$2,
                            color: _kLabelColors[entry.$1] ??
                                colors.accent,
                            selected: _pending?.kind == SlotKind.label &&
                                (_pending?.labelText ?? '').toLowerCase() ==
                                    entry.$1.toLowerCase(),
                            onTap: () => _pickLabel(entry.$1),
                          ),
                        _CustomChip(
                          label: l10n.customLabelChip,
                          selected: _pending?.kind == SlotKind.label &&
                              (_pending?.labelText ?? '').isNotEmpty &&
                              !isPresetSlotLabel(
                                context,
                                _pending?.labelText ?? '',
                              ),
                          onTap: _pickCustom,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    PressableScale(
                      onTap: _save,
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              lightenColor(colors.accent, 0.06),
                              colors.accent,
                              darkenColor(colors.accent, 0.12),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: darkenColor(colors.accent, 0.12)
                                  .withValues(alpha: 0.40),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Text(
                          _hasPending
                              ? l10n.saveSelection
                              : l10n.clear,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayName(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case 1:
        return l10n.weekdayMon;
      case 2:
        return l10n.weekdayTue;
      case 3:
        return l10n.weekdayWed;
      case 4:
        return l10n.weekdayThu;
      case 5:
        return l10n.weekdayFri;
      case 6:
        return l10n.weekdaySat;
      case 7:
        return l10n.weekdaySun;
      default:
        return '';
    }
  }
}

class _RestDayCta extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RestDayCta({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const oliveLight = Color(0xFF7A8C5B);
    const oliveDark = Color(0xFF4A5A38);
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              oliveLight.withValues(alpha: selected ? 0.30 : 0.18),
              oliveDark.withValues(alpha: selected ? 0.20 : 0.10),
            ],
          ),
          border: Border.all(
            color: oliveLight.withValues(alpha: selected ? 0.55 : 0.3),
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: oliveLight.withValues(alpha: 0.30),
              ),
              child: const Icon(
                Icons.bedtime_outlined,
                size: 18,
                color: Color(0xFFB8CE93),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.ink900,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: colors.ink500),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: oliveLight, size: 20)
            else
              Icon(
                Icons.chevron_right,
                size: 16,
                color: colors.ink400,
              ),
          ],
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  final String text;
  const _DividerLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Divider(
            height: 0.5,
            color: colors.hairline.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            color: colors.ink400,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            height: 0.5,
            color: colors.hairline.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _LabelChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _LabelChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: selected ? 0.30 : 0.20),
              color.withValues(alpha: selected ? 0.16 : 0.10),
            ],
          ),
          border: Border.all(
            color: color.withValues(alpha: selected ? 0.6 : 0.33),
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.ink900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CustomChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected
              ? colors.accentTint
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? colors.accent.withValues(alpha: 0.6)
                : colors.hairline.withValues(alpha: 0.5),
            width: 1,
            style: selected ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 11,
              color: selected ? colors.accentDeep : colors.ink500,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? colors.accentDeep : colors.ink500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
