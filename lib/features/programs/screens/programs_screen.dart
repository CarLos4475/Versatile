import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../../shared/widgets/week_strip.dart';
import '../../routines/view_models/routines_view_model.dart';
import '../data/program_templates.dart';
import '../view_models/programs_view_model.dart';
import 'program_editor_screen.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final programsAsync = ref.watch(programsListProvider);
    final activeAsync = ref.watch(activeProgramProvider);
    final routines = ref.watch(routinesProvider).value ?? const <Routine>[];
    final activeId = activeAsync.value?.id;

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: l10n.trainingPlan,
                  subtitle: l10n.programsSubtitle,
                  onBack: () => Navigator.of(context).pop(),
                  accentBack: true,
                  trailing: _HelpButton(
                    tooltip: l10n.programsHelpTooltip,
                    onTap: () => _showHelpDialog(context),
                  ),
                ),
                Expanded(
                  child: programsAsync.when(
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: context.colors.accent,
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        '$e',
                        style: TextStyle(color: context.colors.ink500),
                      ),
                    ),
                    data: (programs) {
                      if (programs.isEmpty) {
                        return _EmptyState(
                          onCreate: () => _openEditor(context, null),
                          onTemplate: (t) => _createFromTemplate(context, ref, t),
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
                        children: [
                          if (activeAsync.value != null) ...[
                            _ThisWeekHero(
                              active: activeAsync.value!,
                              routines: routines,
                            ),
                            const SizedBox(height: 24),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                              right: 4,
                              bottom: 10,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.yourProgramsSection.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1,
                                    color: context.colors.ink400,
                                  ),
                                ),
                                Text(
                                  l10n.programsTotalCount(programs.length),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.colors.ink500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (final p in programs)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _ProgramCard(
                                program: p,
                                isActive: p.id == activeId,
                                routines: routines,
                                onTap: () => _openEditor(context, p.id),
                                onActivate: () => _activate(context, ref, p),
                                onDeactivate: () => _deactivate(ref),
                                onDelete: () => _delete(context, ref, p),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            // FAB
            programsAsync.maybeWhen(
              data: (programs) {
                if (programs.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  left: 22,
                  right: 22,
                  bottom: 22,
                  child: _FabButton(
                    label: l10n.createProgram,
                    onTap: () => _openEditor(context, null),
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHelpDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final sections = <(String, String)>[
      (l10n.programsHelpIntroTitle, l10n.programsHelpIntroBody),
      (l10n.programsHelpSlotsTitle, l10n.programsHelpSlotsBody),
      (l10n.programsHelpDeloadTitle, l10n.programsHelpDeloadBody),
      (l10n.programsHelpActivateTitle, l10n.programsHelpActivateBody),
      (l10n.programsHelpBadgesTitle, l10n.programsHelpBadgesBody),
      (l10n.programsHelpOptionalTitle, l10n.programsHelpOptionalBody),
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgFrame,
        scrollable: true,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: context.colors.accentTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.help_outline_rounded,
                color: context.colors.accentDeep,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.programsHelpTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.colors.ink900,
                  letterSpacing: -0.18,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < sections.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                Text(
                  sections[i].$1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.colors.accentDeep,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sections[i].$2,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: context.colors.ink500,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.close,
              style: TextStyle(
                color: context.colors.accentDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, String? programId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProgramEditorScreen(programId: programId),
      ),
    );
  }

  void _createFromTemplate(
    BuildContext context,
    WidgetRef ref,
    ProgramTemplate template,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProgramEditorScreen(template: template),
      ),
    );
  }

  Future<void> _activate(
    BuildContext context,
    WidgetRef ref,
    Program p,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final defaultStart = today.subtract(Duration(days: today.weekday - 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: defaultStart,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365)),
      helpText: l10n.pickStartDate,
    );
    if (picked == null) return;

    final settings = ref.read(settingsRepositoryProvider);
    await settings.setActiveProgramId(p.id);
    await settings.setActiveProgramStartDate(picked);
    ref.invalidate(activeProgramProvider);
    ref.invalidate(todaysPlannedSlotProvider);
  }

  Future<void> _deactivate(WidgetRef ref) async {
    final settings = ref.read(settingsRepositoryProvider);
    await settings.clearActiveProgram();
    ref.invalidate(activeProgramProvider);
    ref.invalidate(todaysPlannedSlotProvider);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Program p,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgFrame,
        scrollable: true,
        title: Text(
          l10n.deleteProgramTitle,
          style: TextStyle(color: context.colors.ink900),
        ),
        content: Text(
          l10n.deleteProgramContent(p.name),
          style: TextStyle(color: context.colors.ink500, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.colors.ink400),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.delete,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(programRepositoryProvider).delete(p.id);
    ref.invalidate(programsListProvider);
    ref.invalidate(activeProgramProvider);
    ref.invalidate(todaysPlannedSlotProvider);
  }
}

class _ThisWeekHero extends StatelessWidget {
  final ActiveProgramInfo active;
  final List<Routine> routines;

  const _ThisWeekHero({required this.active, required this.routines});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final program = active.program;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      active.startDate.year,
      active.startDate.month,
      active.startDate.day,
    );
    final daysSinceStart = today.isBefore(start)
        ? 0
        : today.difference(start).inDays;
    final weeksElapsed = daysSinceStart ~/ 7;
    final weekIndex = weeksElapsed % program.weeksCount;

    final routinesById = {for (final r in routines) r.id: r};
    final cells = List<WeekStripCell>.generate(7, (i) {
      final weekday = i + 1;
      final slot = program.slotAt(weekIndex, weekday);
      if (slot == null) return const WeekStripCell.rest();
      if (slot.kind == SlotKind.routine) {
        final r = routinesById[slot.routineId];
        if (r == null) return const WeekStripCell.rest();
        return WeekStripCell.routine(label: r.name, color: Color(r.colorValue));
      }
      final label = slot.labelText ?? '';
      if (label.isEmpty || label.toLowerCase() == 'rest') {
        return const WeekStripCell.rest();
      }
      return WeekStripCell.label(
        label: label,
        color: Color(program.colorValue),
      );
    });

    final todaySlot = program.slotAt(weekIndex, today.weekday);
    final todayRoutine = todaySlot != null && todaySlot.kind == SlotKind.routine
        ? routinesById[todaySlot.routineId]
        : null;
    final todayLabelText = todaySlot?.labelText ?? '';
    final todayIsRest = todaySlot == null ||
        (todaySlot.kind == SlotKind.routine && todayRoutine == null) ||
        (todaySlot.kind == SlotKind.label &&
            (todayLabelText.isEmpty ||
                todayLabelText.toLowerCase() == 'rest'));
    final String todayPrefix;
    final String todayAccent;
    if (todayIsRest) {
      todayPrefix = l10n.todayYouRest;
      todayAccent = l10n.todayRestWord;
    } else if (todayRoutine != null) {
      todayPrefix = l10n.todayYouTrain;
      todayAccent = todayRoutine.name;
    } else {
      todayPrefix = l10n.todayLabelPrefix;
      todayAccent = localizeSlotLabel(context, todayLabelText);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
            child: Text(
              l10n.thisWeekSection.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                color: colors.ink400,
              ),
            ),
          ),
          GlassContainer(
            radius: 22,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colors.accentTint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n
                                    .programWeekProgress(
                                      weekIndex + 1,
                                      program.weeksCount,
                                    )
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: colors.accentDeep,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                program.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: colors.ink500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.52,
                              color: colors.ink900,
                              height: 1.1,
                            ),
                            children: [
                              TextSpan(text: '$todayPrefix '),
                              TextSpan(
                                text: todayAccent,
                                style: TextStyle(color: colors.accentDeep),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        WeekStrip(
                          cells: cells,
                          todayIndex: today.weekday - 1,
                          variant: WeekStripVariant.large,
                          dayLabels: const ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
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
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.isActive,
    required this.routines,
    required this.onTap,
    required this.onActivate,
    required this.onDeactivate,
    required this.onDelete,
  });

  final Program program;
  final bool isActive;
  final List<Routine> routines;
  final VoidCallback onTap;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final color = Color(program.colorValue);
    final routinesById = {for (final r in routines) r.id: r};

    final cells = List<WeekStripCell>.generate(7, (i) {
      final weekday = i + 1;
      final slot = program.slotAt(0, weekday);
      if (slot == null) return const WeekStripCell.rest();
      if (slot.kind == SlotKind.routine) {
        final r = routinesById[slot.routineId];
        if (r == null) return const WeekStripCell.rest();
        return WeekStripCell.routine(label: r.name, color: Color(r.colorValue));
      }
      final label = slot.labelText ?? '';
      if (label.isEmpty || label.toLowerCase() == 'rest') {
        return const WeekStripCell.rest();
      }
      return WeekStripCell.label(label: label, color: color);
    });

    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        radius: 18,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [color, darkenColor(color, 0.14)],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              program.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colors.ink900,
                                letterSpacing: -0.16,
                              ),
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.accentTint,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                l10n.activeBadge,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: colors.accentDeep,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.programWeeksSummary(
                          program.weeksCount,
                          program.deloadWeeks.length,
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.ink500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    color: colors.ink500,
                    size: 18,
                  ),
                  color: colors.bgFrame,
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  splashRadius: 18,
                  onSelected: (v) {
                    if (v == 'activate') onActivate();
                    if (v == 'deactivate') onDeactivate();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => [
                    if (!isActive)
                      PopupMenuItem(
                        value: 'activate',
                        child: Text(l10n.activateProgram),
                      ),
                    if (isActive)
                      PopupMenuItem(
                        value: 'deactivate',
                        child: Text(l10n.deactivateProgram),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        l10n.delete,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            WeekStrip(
              cells: cells,
              variant: WeekStripVariant.mini,
            ),
          ],
        ),
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FabButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accent;
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lightenColor(accent, 0.06),
              accent,
              darkenColor(accent, 0.12),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: context.colors.glassBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.glassBorder,
              width: 0.5,
            ),
            boxShadow: context.colors.glassShadow,
          ),
          child: Icon(
            Icons.help_outline_rounded,
            color: context.colors.ink700,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate, required this.onTemplate});
  final VoidCallback onCreate;
  final void Function(ProgramTemplate) onTemplate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 40),
      children: [
        SizedBox(
          height: 160,
          child: Center(child: _EmptyHero(accent: colors.accent)),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.designYourWeek,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.48,
            color: colors.ink900,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.designYourWeekBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colors.ink500,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: PressableScale(
            onTap: onCreate,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 22),
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
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    l10n.createFromScratch,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 13,
                color: colors.ink400,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.orStartFromTemplate.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: colors.ink400,
                ),
              ),
            ],
          ),
        ),
        for (final t in kProgramTemplates)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TemplateCard(template: t, onTap: () => onTemplate(t)),
          ),
      ],
    );
  }
}

class _EmptyHero extends StatelessWidget {
  final Color accent;
  const _EmptyHero({required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 30,
            top: 30,
            child: Transform.rotate(
              angle: -0.14,
              child: Container(
                width: 80,
                height: 100,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF7AA0CC).withValues(alpha: 0.35),
                      const Color(0xFF4A6E94).withValues(alpha: 0.20),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF7AA0CC).withValues(alpha: 0.30),
                    width: 0.5,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'D',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 10,
            child: Transform.rotate(
              angle: 0.10,
              child: Container(
                width: 80,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF8DA4B5),
                      Color(0xFF5B7A8C),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF5B7A8C).withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.bedtime_outlined,
                  size: 28,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
          Positioned(
            left: 67,
            top: 0,
            child: Transform.rotate(
              angle: -0.03,
              child: Container(
                width: 86,
                height: 110,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      lightenColor(accent, 0.04),
                      darkenColor(accent, 0.12),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'UPPER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final ProgramTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final cells = template.pattern.map((p) {
      if (p.isRest) return const WeekStripCell.rest();
      return WeekStripCell.label(
        label: p.labelKey ?? '',
        color: template.color,
      );
    }).toList();

    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        radius: 16,
        padding: const EdgeInsets.all(14),
        child: Row(
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
                  colors: [
                    template.color,
                    darkenColor(template.color, 0.18),
                  ],
                ),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
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
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          template.name(l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.ink900,
                            letterSpacing: -0.07,
                          ),
                        ),
                      ),
                      if (template.recommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.accentTint,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.recommendedBadge,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: colors.accentDeep,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    template.sub(l10n),
                    style: TextStyle(fontSize: 11, color: colors.ink500),
                  ),
                  const SizedBox(height: 8),
                  WeekStrip(cells: cells, variant: WeekStripVariant.mini),
                ],
              ),
            ),
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
