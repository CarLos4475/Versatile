import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/program.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../domain/entities/routine.dart';
import '../../routines/widgets/routine_color_picker.dart';
import '../../routines/view_models/routines_view_model.dart';
import '../view_models/programs_view_model.dart';
import '../widgets/slot_editor_sheet.dart';

const _kProgramColors = [
  Color(0xFFD97757),
  Color(0xFFB85432),
  Color(0xFFE89A7E),
  Color(0xFFB48C64),
  Color(0xFF4A7B6F),
  Color(0xFF7B5EA7),
  Color(0xFF5E7BA7),
  Color(0xFF9B7850),
];

class ProgramEditorScreen extends ConsumerStatefulWidget {
  const ProgramEditorScreen({super.key, this.programId});
  final String? programId;

  @override
  ConsumerState<ProgramEditorScreen> createState() =>
      _ProgramEditorScreenState();
}

class _ProgramEditorScreenState extends ConsumerState<ProgramEditorScreen> {
  final _nameCtrl = TextEditingController();
  Color _color = _kProgramColors.first;
  int _weeks = 4;
  Set<int> _deload = {};
  List<ProgramSlot> _slots = [];
  String? _id;
  DateTime? _createdAt;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onNameChanged);
    _loadOrInit();
  }

  void _onNameChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadOrInit() async {
    if (widget.programId == null) {
      setState(() {
        _id = const Uuid().v4();
        _createdAt = DateTime.now();
        _loading = false;
      });
      return;
    }
    final program = await ref
        .read(programRepositoryProvider)
        .findById(widget.programId!);
    if (!mounted) return;
    if (program == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _id = program.id;
      _nameCtrl.text = program.name;
      _color = Color(program.colorValue);
      _weeks = program.weeksCount;
      _deload = {...program.deloadWeeks};
      _slots = [...program.slots];
      _createdAt = program.createdAt;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.dispose();
    super.dispose();
  }

  void _changeWeeks(int newWeeks) {
    setState(() {
      _weeks = newWeeks;
      // Drop slots and deload markers from removed weeks
      _slots.removeWhere((s) => s.weekIndex >= newWeeks);
      _deload.removeWhere((w) => w >= newWeeks);
    });
  }

  Future<void> _editSlot(int weekIndex, int weekday) async {
    final current = _slots.firstWhere(
      (s) => s.weekIndex == weekIndex && s.weekday == weekday,
      orElse: () => ProgramSlot(
        id: '',
        programId: _id ?? '',
        weekIndex: weekIndex,
        weekday: weekday,
        kind: SlotKind.label,
      ),
    );
    final hasCurrent = current.id.isNotEmpty;

    final result = await showSlotEditorSheet(
      context,
      weekIndex: weekIndex,
      weekday: weekday,
      current: hasCurrent ? current : null,
    );
    if (result == null) return;

    setState(() {
      _slots.removeWhere(
        (s) => s.weekIndex == weekIndex && s.weekday == weekday,
      );
      if (!result.clear) {
        _slots.add(
          ProgramSlot(
            id: hasCurrent ? current.id : const Uuid().v4(),
            programId: _id ?? '',
            weekIndex: weekIndex,
            weekday: weekday,
            kind: result.kind!,
            routineId: result.routineId,
            labelText: result.labelText,
          ),
        );
      }
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _id == null) return;
    setState(() => _saving = true);
    final program = Program(
      id: _id!,
      name: name,
      colorValue: _color.toARGB32(),
      iconCode: Icons.calendar_month_rounded.codePoint,
      weeksCount: _weeks,
      deloadWeeks: _deload,
      createdAt: _createdAt ?? DateTime.now(),
      slots: _slots,
    );
    final repo = ref.read(programRepositoryProvider);
    if (widget.programId == null) {
      await repo.insert(program);
    } else {
      await repo.updateMeta(
        program.id,
        name: program.name,
        colorValue: program.colorValue,
        iconCode: program.iconCode,
        weeksCount: program.weeksCount,
        deloadWeeks: program.deloadWeeks,
      );
      await repo.replaceSlots(program.id, program.slots);
    }
    ref.invalidate(programsListProvider);
    ref.invalidate(activeProgramProvider);
    ref.invalidate(todaysPlannedSlotProvider);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return Scaffold(
        backgroundColor: context.colors.bgApp,
        body: Center(
          child: CircularProgressIndicator(color: context.colors.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: widget.programId == null
                  ? l10n.createProgram
                  : l10n.editProgram,
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(l10n.programName),
                    const SizedBox(height: 8),
                    GlassContainer(
                      radius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.colors.ink900,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.programNameHint,
                          hintStyle: TextStyle(color: context.colors.ink300),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(l10n.color_label),
                    const SizedBox(height: 12),
                    RoutineColorPicker(
                      colors: _kProgramColors,
                      selectedColorValue: _color.toARGB32(),
                      onSelected: (c) => setState(() => _color = c),
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(l10n.weeksLabel),
                    const SizedBox(height: 10),
                    _WeeksStepper(
                      value: _weeks,
                      min: 1,
                      max: 12,
                      onChanged: _changeWeeks,
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(l10n.scheduleLabel),
                    const SizedBox(height: 10),
                    ...List.generate(_weeks, (w) => _WeekSection(
                      weekIndex: w,
                      isDeload: _deload.contains(w),
                      onToggleDeload: () => setState(() {
                        if (_deload.contains(w)) {
                          _deload.remove(w);
                        } else {
                          _deload.add(w);
                        }
                      }),
                      slots: _slots
                          .where((s) => s.weekIndex == w)
                          .toList(),
                      onEditSlot: (weekday) => _editSlot(w, weekday),
                    )),
                    const SizedBox(height: 24),
                    GlassButton(
                      label: _saving ? l10n.saving : l10n.save,
                      variant: GlassButtonVariant.primary,
                      size: GlassButtonSize.md,
                      expand: true,
                      loading: _saving,
                      onPressed: _saving || _nameCtrl.text.trim().isEmpty
                          ? null
                          : _save,
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
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.08,
        color: context.colors.ink400,
      ),
    );
  }
}

class _WeeksStepper extends StatelessWidget {
  const _WeeksStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.weeksCountValue(value),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.colors.ink900,
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.remove,
            enabled: value > min,
            onTap: () => onChanged(value - 1),
          ),
          const SizedBox(width: 12),
          _StepBtn(
            icon: Icons.add,
            enabled: value < max,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? context.colors.accentTint
              : context.colors.press,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? context.colors.accentDeep
              : context.colors.ink300,
        ),
      ),
    );
  }
}

class _WeekSection extends ConsumerWidget {
  const _WeekSection({
    required this.weekIndex,
    required this.isDeload,
    required this.onToggleDeload,
    required this.slots,
    required this.onEditSlot,
  });

  final int weekIndex;
  final bool isDeload;
  final VoidCallback onToggleDeload;
  final List<ProgramSlot> slots;
  final ValueChanged<int> onEditSlot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        radius: 16,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.weekN(weekIndex + 1),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.colors.ink900,
                    ),
                  ),
                ),
                Text(
                  l10n.deloadWeekLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.ink500,
                  ),
                ),
                const SizedBox(width: 6),
                Switch(
                  value: isDeload,
                  onChanged: (_) => onToggleDeload(),
                  activeThumbColor: context.colors.accent,
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (int wd = 1; wd <= 7; wd++)
              _DayRow(
                weekday: wd,
                slot: _slotForDay(wd),
                onTap: () => onEditSlot(wd),
                routines:
                    ref.watch(routinesProvider).value ?? const <Routine>[],
              ),
          ],
        ),
      ),
    );
  }

  ProgramSlot? _slotForDay(int weekday) {
    for (final s in slots) {
      if (s.weekday == weekday) return s;
    }
    return null;
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.weekday,
    required this.slot,
    required this.onTap,
    required this.routines,
  });
  final int weekday;
  final ProgramSlot? slot;
  final VoidCallback onTap;
  final List<Routine> routines;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    String trailing;
    Color? trailingColor;
    IconData? leading;
    if (slot == null) {
      trailing = l10n.labelRest;
      trailingColor = colors.ink400;
      leading = Icons.coffee_outlined;
    } else if (slot!.kind == SlotKind.routine) {
      Routine? r;
      for (final candidate in routines) {
        if (candidate.id == slot!.routineId) {
          r = candidate;
          break;
        }
      }
      trailing = r != null ? r.name : l10n.routineRemoved;
      trailingColor = r != null ? colors.ink900 : colors.ink400;
      leading = Icons.fitness_center;
    } else {
      trailing = slot!.labelText ?? '';
      trailingColor = colors.ink700;
      leading = Icons.coffee_outlined;
    }

    return PressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                _weekdayShort(context, weekday),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: colors.ink400,
                ),
              ),
            ),
            Icon(leading, size: 14, color: colors.ink400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                trailing,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: slot == null ? FontWeight.w400 : FontWeight.w600,
                  color: trailingColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: colors.ink300),
          ],
        ),
      ),
    );
  }

  String _weekdayShort(BuildContext context, int weekday) {
    final l10n = AppLocalizations.of(context)!;
    switch (weekday) {
      case 1:
        return l10n.weekdayMonShort;
      case 2:
        return l10n.weekdayTueShort;
      case 3:
        return l10n.weekdayWedShort;
      case 4:
        return l10n.weekdayThuShort;
      case 5:
        return l10n.weekdayFriShort;
      case 6:
        return l10n.weekdaySatShort;
      case 7:
        return l10n.weekdaySunShort;
      default:
        return '';
    }
  }
}
