import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../routines/view_models/routines_view_model.dart';

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
  final _customCtrl = TextEditingController();
  bool _customCtrlSeeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Seed the custom-label text field once we have a BuildContext for l10n.
    // Preset labels (Rest/Cardio/Mobility/Stretching) show up as a selected
    // chip instead of pre-filling the free-text input.
    if (_customCtrlSeeded) return;
    _customCtrlSeeded = true;
    final saved = widget.current?.labelText ?? '';
    if (widget.current?.kind == SlotKind.label &&
        saved.isNotEmpty &&
        !isPresetSlotLabel(context, saved)) {
      _customCtrl.text = saved;
    }
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final routines = ref.watch(routinesProvider).value ?? <Routine>[];
    final mq = MediaQuery.of(context);

    final presetLabels = [
      l10n.labelRest,
      l10n.labelCardio,
      l10n.labelMobility,
      l10n.labelStretch,
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
        decoration: BoxDecoration(
          color: context.colors.bgFrame,
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
                color: context.colors.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.editDayTitle(_weekdayName(context, widget.weekday)),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.colors.ink900,
                      ),
                    ),
                  ),
                  if (widget.current != null)
                    PressableScale(
                      onTap: () =>
                          Navigator.of(context).pop(const SlotEditResult.clear()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.clear,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pickRoutineSection.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: context.colors.ink400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (routines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.noRoutinesYet,
                          style: TextStyle(color: context.colors.ink400),
                        ),
                      )
                    else
                      ...routines.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PressableScale(
                            onTap: () => Navigator.of(context)
                                .pop(SlotEditResult.routine(r.id)),
                            child: GlassContainer(
                              radius: 14,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Color(r.colorValue),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      IconData(
                                        r.iconCode,
                                        fontFamily: 'MaterialIcons',
                                      ),
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      r.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: context.colors.ink900,
                                      ),
                                    ),
                                  ),
                                  if (widget.current?.kind == SlotKind.routine &&
                                      widget.current?.routineId == r.id)
                                    Icon(
                                      Icons.check_circle,
                                      color: context.colors.accent,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.pickLabelSection.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: context.colors.ink400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presetLabels
                          .map(
                            (label) {
                              final savedLabel = widget.current?.labelText;
                              final isSelected =
                                  widget.current?.kind == SlotKind.label &&
                                      savedLabel != null &&
                                      localizeSlotLabel(context, savedLabel) ==
                                          label;
                              return _LabelChip(
                                label: label,
                                selected: isSelected,
                                onTap: () => Navigator.of(context)
                                    .pop(SlotEditResult.label(label)),
                              );
                            },
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.customLabelSection.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: context.colors.ink400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: context.colors.glassBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: context.colors.glassBorder,
                          width: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _customCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.colors.ink900,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.customLabelHint,
                          hintStyle: TextStyle(color: context.colors.ink300),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassButton(
                      label: l10n.applyCustomLabel,
                      variant: GlassButtonVariant.glass,
                      size: GlassButtonSize.md,
                      expand: true,
                      onPressed: () {
                        final txt = _customCtrl.text.trim();
                        if (txt.isEmpty) return;
                        Navigator.of(context).pop(SlotEditResult.label(txt));
                      },
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

  String _weekdayName(BuildContext context, int weekday) {
    final l10n = AppLocalizations.of(context)!;
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

class _LabelChip extends StatelessWidget {
  const _LabelChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? context.colors.accentTint : context.colors.glassBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? context.colors.accent
                : context.colors.glassBorder,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? context.colors.accentDeep
                : context.colors.ink700,
          ),
        ),
      ),
    );
  }
}
