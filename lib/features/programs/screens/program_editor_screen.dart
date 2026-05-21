import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_utils.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/glass_container.dart';
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

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              prefix: Localizations.localeOf(context).languageCode == 'es'
                  ? (widget.programId == null ? 'Nuevo' : 'Edita')
                  : (widget.programId == null ? 'New' : 'Edit'),
              accent: Localizations.localeOf(context).languageCode == 'es'
                  ? 'programa.'
                  : 'program.',
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
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        child: _TemplateNotice(
                          title: l10n.templateBannerTitle,
                          body: l10n.templateBannerBody,
                        ),
                      ),
                    NumberedStep(
                      number: 1,
                      label: l10n.stepName,
                      child: GlassContainer(
                        radius: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                            fontSize: 15,
                            color: context.colors.ink900,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.programNameHint,
                            hintStyle: TextStyle(
                              color: context.colors.ink300,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
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
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: enabled
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lightenColor(colors.accent, 0.04),
                    darkenColor(colors.accent, 0.10),
                  ],
                )
              : null,
          color: enabled ? null : colors.ink900.withValues(alpha: 0.08),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.07,
            color: enabled ? Colors.white : colors.ink400,
          ),
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
    return GlassContainer(
      radius: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [selected, darkenColor(selected, 0.18)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selected.withValues(alpha: 0.40),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.ink900,
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
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [c, darkenColor(c, 0.18)],
                          ),
                        ),
                      ),
                    ),
                    if (active)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
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
    return GlassContainer(
      radius: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.56,
                      color: colors.ink900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    children: [
                      TextSpan(text: '$weeks '),
                      TextSpan(
                        text: weeks == 1 ? l10n.weeksUnitOne : l10n.weeksUnit,
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.ink500,
                          fontWeight: FontWeight.w500,
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
              const SizedBox(width: 6),
              _MinusPlus(
                isPlus: true,
                enabled: weeks < 12,
                onTap: () => onChangeWeeks(weeks + 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(weeks, (w) {
              final isDeload = deload.contains(w);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: w == weeks - 1 ? 0 : 4),
                  child: PressableScale(
                    onTap: () => onToggleDeload(w),
                    child: Container(
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDeload
                              ? [
                                  const Color(0xFF7A8C5B).withValues(alpha: 0.45),
                                  const Color(0xFF4A5A38).withValues(alpha: 0.30),
                                ]
                              : [
                                  context.colors.accent.withValues(alpha: 0.30),
                                  context.colors.accent.withValues(alpha: 0.15),
                                ],
                        ),
                        border: Border.all(
                          color: context.colors.hairline.withValues(alpha: 0.5),
                          width: 0.5,
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
                                fontWeight: FontWeight.w600,
                                color: colors.ink700,
                                letterSpacing: 0.4,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            if (isDeload) ...[
                              const SizedBox(width: 4),
                              Text(
                                '· ${l10n.deloadShort}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFA6BE82),
                                  letterSpacing: 0.6,
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
    return PressableScale(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isPlus && enabled
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lightenColor(colors.accent, 0.04),
                    darkenColor(colors.accent, 0.10),
                  ],
                )
              : null,
          color: (isPlus && enabled)
              ? null
              : colors.ink900.withValues(alpha: enabled ? 0.06 : 0.03),
        ),
        child: Icon(
          isPlus ? Icons.add : Icons.remove,
          size: 16,
          color: isPlus && enabled
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
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: active
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                lightenColor(colors.accent, 0.04),
                                darkenColor(colors.accent, 0.10),
                              ],
                            )
                          : null,
                      color: active
                          ? null
                          : colors.ink900.withValues(alpha: 0.06),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.weekN(w + 1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.07,
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
                              color: const Color(0xFF7A8C5B)
                                  .withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              l10n.deloadShort,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.7,
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
        const SizedBox(height: 12),
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
                padding: EdgeInsets.only(right: i == 6 ? 0 : 6),
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
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colors.accent.withValues(alpha: 0.08),
            border: Border.all(
              color: colors.accent.withValues(alpha: 0.18),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 13,
                color: colors.accentDeep,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.calendarHint,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.ink500,
                    height: 1.3,
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.accentTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.22),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: colors.accentDeep,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.08,
                    color: colors.accentDeep,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: colors.ink500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
