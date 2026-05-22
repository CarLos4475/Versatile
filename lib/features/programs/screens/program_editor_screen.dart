import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../routines/view_models/routines_view_model.dart';
import '../data/program_templates.dart';
import '../view_models/programs_view_model.dart';
import '../widgets/day_box.dart';
import '../widgets/numbered_step.dart';
import '../widgets/slot_editor_sheet.dart';

class ProgramEditorScreen extends ConsumerStatefulWidget {
  const ProgramEditorScreen({super.key, this.programId, this.template});
  final String? programId;
  final ProgramTemplate? template;

  @override
  ConsumerState<ProgramEditorScreen> createState() =>
      _ProgramEditorScreenState();
}

class _ProgramEditorScreenState extends ConsumerState<ProgramEditorScreen> {
  final _nameCtrl = TextEditingController();
  Color _color = kProgramColors.first;
  int _weeks = 4;
  Set<int> _deload = {};
  List<ProgramSlot> _slots = [];
  String? _id;
  DateTime? _createdAt;
  int _activeWeekTab = 0;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final template = widget.template;
    if (template != null &&
        widget.programId == null &&
        _nameCtrl.text.isEmpty) {
      _nameCtrl.text = template.name(AppLocalizations.of(context)!);
    }
  }

  List<ProgramSlot> _slotsFromTemplate(
    String programId,
    ProgramTemplate template,
    int weeks,
  ) {
    final slots = <ProgramSlot>[];
    for (var w = 0; w < weeks; w++) {
      for (final pattern in template.pattern) {
        if (pattern.isRest) continue;
        final label = pattern.labelKey ?? '';
        if (label.isEmpty) continue;
        slots.add(
          ProgramSlot(
            id: const Uuid().v4(),
            programId: programId,
            weekIndex: w,
            weekday: pattern.weekday,
            kind: SlotKind.label,
            labelText: label,
          ),
        );
      }
    }
    return slots;
  }

  Future<void> _loadOrInit() async {
    if (widget.programId == null) {
      final id = const Uuid().v4();
      final template = widget.template;
      setState(() {
        _id = id;
        _createdAt = DateTime.now();
        if (template != null) {
          _color = template.color;
          _weeks = template.weeksCount;
          _deload = {...template.deloadWeeks};
          _slots = _slotsFromTemplate(id, template, _weeks);
        }
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
      _activeWeekTab = 0;
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
      _slots.removeWhere((s) => s.weekIndex >= newWeeks);
      _deload.removeWhere((w) => w >= newWeeks);
      if (_activeWeekTab >= newWeeks) _activeWeekTab = newWeeks - 1;
    });
  }

  void _toggleDeload(int weekIndex) {
    setState(() {
      if (_deload.contains(weekIndex)) {
        _deload.remove(weekIndex);
      } else {
        _deload.add(weekIndex);
      }
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

    final canSave = _nameCtrl.text.trim().isNotEmpty && !_saving;
    final routines = ref.watch(routinesProvider).value ?? const <Routine>[];
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              prefix: isEs
                  ? (widget.programId == null ? 'Nuevo' : 'Edita')
                  : (widget.programId == null ? 'New' : 'Edit'),
              accent: isEs ? 'programa.' : 'program.',
              eyebrow: l10n.newProgramSubtitle,
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
              trailing: _SaveButton(
                label: _saving ? l10n.saving : l10n.save,
                enabled: canSave,
                onTap: canSave ? _save : null,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.template != null &&
                        widget.programId == null &&
                        _slots.any((s) => s.kind == SlotKind.label))
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: _TemplateNotice(
                          title: l10n.templateBannerTitle,
                          body: l10n.templateBannerBody,
                        ),
                      ),
                    NumberedStep(
                      number: 1,
                      label: l10n.stepName,
                      child: _NameField(
                        controller: _nameCtrl,
                        hint: l10n.programNameHint,
                      ),
                    ),
                    NumberedStep(
                      number: 2,
                      label: l10n.stepColor,
                      child: _ColorStep(
                        selected: _color,
                        programName: _nameCtrl.text.trim().isEmpty
                            ? (widget.programId == null
                                ? l10n.newProgramTitle
                                : l10n.editProgram)
                            : _nameCtrl.text.trim(),
                        onSelected: (c) => setState(() => _color = c),
                      ),
                    ),
                    NumberedStep(
                      number: 3,
                      label: l10n.stepWeeks,
                      child: _WeeksStep(
                        weeks: _weeks,
                        deload: _deload,
                        onChangeWeeks: _changeWeeks,
                        onToggleDeload: _toggleDeload,
                      ),
                    ),
                    NumberedStep(
                      number: 4,
                      label: l10n.stepCalendar,
                      child: _CalendarStep(
                        weeks: _weeks,
                        activeWeek: _activeWeekTab,
                        deload: _deload,
                        slots: _slots,
                        routines: routines,
                        programColor: _color,
                        onSelectWeek: (w) =>
                            setState(() => _activeWeekTab = w),
                        onEditSlot: (wd) => _editSlot(_activeWeekTab, wd),
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
}

class _SaveButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _SaveButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? colors.accent : colors.ink900.withValues(alpha: 0.04),
          border: Border.all(
            color: enabled
                ? colors.accentDeep.withValues(alpha: 0.6)
                : colors.hairline,
            width: 0.6,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.18,
            color: enabled ? Colors.white : colors.ink400,
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(
          fontSize: 15,
          color: colors.ink900,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.ink400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _ColorStep extends StatelessWidget {
  final Color selected;
  final String programName;
  final ValueChanged<Color> onSelected;

  const _ColorStep({
    required this.selected,
    required this.programName,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: selected),
                child: const Icon(
                  Icons.fitness_center,
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
                      programName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.ink900,
                        letterSpacing: -0.18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.colorPreviewHint,
                      style: TextStyle(fontSize: 11, color: colors.ink500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 0.5, color: colors.hairline),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemCount: kProgramColors.length,
            itemBuilder: (context, i) {
              final c = kProgramColors[i];
              final active = c.toARGB32() == selected.toARGB32();
              return PressableScale(
                onTap: () => onSelected(c),
                child: Container(
                  color: c,
                  alignment: Alignment.center,
                  child: active
                      ? Container(
                          width: 16,
                          height: 16,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeeksStep extends StatelessWidget {
  final int weeks;
  final Set<int> deload;
  final ValueChanged<int> onChangeWeeks;
  final ValueChanged<int> onToggleDeload;

  const _WeeksStep({
    required this.weeks,
    required this.deload,
    required this.onChangeWeeks,
    required this.onToggleDeload,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.6,
                      height: 1,
                      color: colors.ink900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    children: [
                      TextSpan(text: '$weeks '),
                      TextSpan(
                        text: weeks == 1 ? l10n.weeksUnitOne : l10n.weeksUnit,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: colors.accentLight,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _MinusPlus(
                isPlus: false,
                enabled: weeks > 1,
                onTap: () => onChangeWeeks(weeks - 1),
              ),
              const SizedBox(width: 8),
              _MinusPlus(
                isPlus: true,
                enabled: weeks < 12,
                onTap: () => onChangeWeeks(weeks + 1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(weeks, (w) {
              final isDeload = deload.contains(w);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: w == weeks - 1 ? 0 : 5),
                  child: PressableScale(
                    onTap: () => onToggleDeload(w),
                    child: Container(
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDeload
                            ? const Color(0xFF7A8C5B).withValues(alpha: 0.18)
                            : Colors.transparent,
                        border: Border.all(
                          color: isDeload
                              ? const Color(0xFF7A8C5B).withValues(alpha: 0.6)
                              : colors.hairline,
                          width: isDeload ? 0.8 : 0.5,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'W${w + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: colors.ink700,
                                letterSpacing: 0.18,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            if (isDeload) ...[
                              const SizedBox(width: 5),
                              Text(
                                l10n.deloadShort.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF7A8C5B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MinusPlus extends StatelessWidget {
  final bool isPlus;
  final bool enabled;
  final VoidCallback onTap;

  const _MinusPlus({
    required this.isPlus,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = isPlus && enabled;
    return PressableScale(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent
              ? colors.accent
              : colors.ink900.withValues(alpha: enabled ? 0.04 : 0.02),
          border: Border.all(
            color: accent
                ? colors.accentDeep.withValues(alpha: 0.6)
                : colors.hairline,
            width: 0.6,
          ),
        ),
        child: Icon(
          isPlus ? Icons.add : Icons.remove,
          size: 16,
          color: accent
              ? Colors.white
              : (enabled ? colors.ink700 : colors.ink300),
        ),
      ),
    );
  }
}

class _CalendarStep extends StatelessWidget {
  final int weeks;
  final int activeWeek;
  final Set<int> deload;
  final List<ProgramSlot> slots;
  final List<Routine> routines;
  final Color programColor;
  final ValueChanged<int> onSelectWeek;
  final ValueChanged<int> onEditSlot;

  const _CalendarStep({
    required this.weeks,
    required this.activeWeek,
    required this.deload,
    required this.slots,
    required this.routines,
    required this.programColor,
    required this.onSelectWeek,
    required this.onEditSlot,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final routinesById = {for (final r in routines) r.id: r};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(weeks, (w) {
              final active = w == activeWeek;
              final isDeload = deload.contains(w);
              return Padding(
                padding: EdgeInsets.only(right: w == weeks - 1 ? 0 : 6),
                child: PressableScale(
                  onTap: () => onSelectWeek(w),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active ? colors.accent : Colors.transparent,
                      border: Border.all(
                        color: active
                            ? colors.accentDeep.withValues(alpha: 0.6)
                            : colors.hairline,
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.weekN(w + 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.18,
                            color: active ? Colors.white : colors.ink500,
                          ),
                        ),
                        if (isDeload) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : const Color(0xFF7A8C5B)
                                      .withValues(alpha: 0.55),
                            ),
                            child: Text(
                              l10n.deloadShort.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(7, (i) {
            final weekday = i + 1;
            final slot = slots.firstWhere(
              (s) => s.weekIndex == activeWeek && s.weekday == weekday,
              orElse: () => ProgramSlot(
                id: '',
                programId: '',
                weekIndex: activeWeek,
                weekday: weekday,
                kind: SlotKind.label,
              ),
            );
            final hasSlot = slot.id.isNotEmpty;
            String? routineLabel;
            Color? routineColor;
            bool isRest = !hasSlot;
            if (hasSlot) {
              if (slot.kind == SlotKind.routine) {
                final r = routinesById[slot.routineId];
                if (r != null) {
                  routineLabel = r.name;
                  routineColor = Color(r.colorValue);
                } else {
                  isRest = true;
                }
              } else {
                final lbl = slot.labelText ?? '';
                if (lbl.isEmpty || lbl.toLowerCase() == 'rest') {
                  isRest = true;
                } else {
                  routineLabel = localizeSlotLabel(context, lbl);
                  routineColor = programColor;
                }
              }
            }
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 6 ? 0 : 5),
                child: DayBox(
                  dayLabel: const ['L', 'M', 'X', 'J', 'V', 'S', 'D'][i],
                  routineLabel: routineLabel,
                  routineColor: routineColor,
                  isRest: isRest,
                  restShortLabel: l10n.labelRest.toUpperCase(),
                  onTap: () => onEditSlot(weekday),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            border: Border.all(color: colors.hairline, width: 0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: colors.ink400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.calendarHint,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.ink500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemplateNotice extends StatelessWidget {
  const _TemplateNotice({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: colors.accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: colors.accentDeep,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.18,
                              color: colors.accentDeep,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: colors.ink500,
                            ),
                          ),
                        ],
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
}
