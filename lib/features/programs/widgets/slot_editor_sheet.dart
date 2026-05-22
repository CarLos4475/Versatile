import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
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
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final colors = context.colors;
    final routines = ref.watch(routinesProvider).value ?? <Routine>[];
    final mq = MediaQuery.of(context);
    final dayName = _weekdayName(l10n, widget.weekday);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.88),
        decoration: BoxDecoration(
          color: colors.bgApp,
          border: Border(
            top: BorderSide(color: colors.hairline, width: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 3,
              color: colors.hairline,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 1,
                          color: colors.ink400.withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            l10n
                                .editDayEyebrow(widget.weekIndex + 1, dayName)
                                .toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.18,
                              color: colors.ink500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PressableScale(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.ink900.withValues(alpha: 0.04),
                        border: Border.all(
                          color: colors.hairline,
                          width: 0.6,
                        ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
              child: SizedBox(
                width: double.infinity,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${isEs ? '¿Qué hoy' : 'What today'}\n',
                        style: TextStyle(
                          fontSize: 32,
                          height: 0.96,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.05,
                          color: colors.ink900,
                        ),
                      ),
                      TextSpan(
                        text: '$dayName?',
                        style: TextStyle(
                          fontSize: 32,
                          height: 0.96,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -0.045,
                          color: colors.accentLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RestDayCta(
                      selected: _pending?.kind == SlotKind.label &&
                          (_pending?.labelText ?? '').toLowerCase() == 'rest',
                      title: l10n.restDayCta,
                      subtitle: l10n.restDayCtaSubtitle,
                      onTap: () => _pickLabel('Rest'),
                    ),
                    const SizedBox(height: 24),
                    _SectionEyebrow(text: l10n.orPickRoutine),
                    const SizedBox(height: 12),
                    if (routines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.noRoutinesYet,
                          style: TextStyle(
                            color: colors.ink400,
                            fontSize: 13,
                          ),
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
                    const SizedBox(height: 22),
                    _SectionEyebrow(text: l10n.orUseLabel),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final entry in <(String, String)>[
                          ('Cardio', l10n.labelCardio),
                          ('Mobility', l10n.labelMobility),
                          ('Stretching', l10n.labelStretch),
                          ('Yoga', l10n.labelYoga),
                        ])
                          _LabelChip(
                            label: entry.$2,
                            color: _kLabelColors[entry.$1] ?? colors.accent,
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
                    const SizedBox(height: 24),
                    PressableScale(
                      onTap: _save,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.accent,
                          border: Border.all(
                            color: colors.accentDeep.withValues(alpha: 0.6),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          (_hasPending ? l10n.saveSelection : l10n.clear)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.4,
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

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 22,
          height: 1,
          color: colors.ink400.withValues(alpha: 0.55),
        ),
        const SizedBox(width: 10),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.18,
            color: colors.ink500,
          ),
        ),
      ],
    );
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
    const olive = Color(0xFF7A8C5B);
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: selected ? olive.withValues(alpha: 0.08) : Colors.transparent,
          border: Border.all(
            color: selected ? olive : colors.hairline,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: olive),
              child: const Icon(
                Icons.bedtime_outlined,
                size: 18,
                color: Colors.white,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.ink900,
                      letterSpacing: -0.18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: colors.ink500),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: olive),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              )
            else
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: selected ? color : colors.hairline,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? colors.ink900 : colors.ink700,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? colors.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border.all(
            color: selected ? colors.accent : colors.hairline,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 12,
              color: selected ? colors.accentDeep : colors.ink500,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? colors.accentDeep : colors.ink700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
