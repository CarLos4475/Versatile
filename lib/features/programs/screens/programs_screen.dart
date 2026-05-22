import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/entities/routine.dart';
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
    final isEs = Localizations.localeOf(context).languageCode == 'es';
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
                  prefix: isEs ? 'Plan de' : 'Training',
                  accent: isEs ? 'entrenamiento.' : 'plan.',
                  eyebrow: l10n.programsSubtitle,
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
                          onTemplate: (t) =>
                              _createFromTemplate(context, ref, t),
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 110),
                        children: [
                          if (activeAsync.value != null) ...[
                            _ThisWeekHero(
                              active: activeAsync.value!,
                              routines: routines,
                            ),
                            const SizedBox(height: 28),
                          ],
                          _SectionEyebrow(
                            label: l10n.yourProgramsSection,
                            trailing: Text(
                              l10n.programsTotalCount(programs.length),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: context.colors.ink500,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (var i = 0; i < programs.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ProgramCard(
                                program: programs[i],
                                isActive: programs[i].id == activeId,
                                routines: routines,
                                onTap: () =>
                                    _openEditor(context, programs[i].id),
                                onActivate: () =>
                                    _activate(context, ref, programs[i]),
                                onDeactivate: () => _deactivate(ref),
                                onDelete: () =>
                                    _delete(context, ref, programs[i]),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
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
              alignment: Alignment.center,
              decoration: BoxDecoration(color: context.colors.accent),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
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
                if (i > 0) const SizedBox(height: 16),
                Text(
                  sections[i].$1.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.18,
                    color: context.colors.accentDeep,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  sections[i].$2,
                  style: TextStyle(
                    fontSize: 13,
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

// ═══════════════════════════════════════════════════════════════
// Section helpers
// ═══════════════════════════════════════════════════════════════

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.label, this.trailing});
  final String label;
  final Widget? trailing;

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
        Expanded(
          child: Text(
            label.toUpperCase(),
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
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// This Week Hero
// ═══════════════════════════════════════════════════════════════

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
        return WeekStripCell.routine(
          label: r.name,
          color: Color(r.colorValue),
        );
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
    final todayRoutine =
        todaySlot != null && todaySlot.kind == SlotKind.routine
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionEyebrow(
          label: l10n.thisWeekSection,
          trailing: Text(
            l10n.programWeekProgress(weekIndex + 1, program.weeksCount),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.ink500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.bgFrame,
            border: Border.all(color: colors.hairline, width: 0.5),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: colors.accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.18,
                            color: colors.accentDeep,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.52,
                              height: 1.1,
                              color: colors.ink900,
                            ),
                            children: [
                              TextSpan(text: '$todayPrefix '),
                              TextSpan(
                                text: todayAccent,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: colors.accentLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        WeekStrip(
                          cells: cells,
                          todayIndex: today.weekday - 1,
                          variant: WeekStripVariant.large,
                          dayLabels: const ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Program Card
// ═══════════════════════════════════════════════════════════════

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
        return WeekStripCell.routine(
          label: r.name,
          color: Color(r.colorValue),
        );
      }
      final label = slot.labelText ?? '';
      if (label.isEmpty || label.toLowerCase() == 'rest') {
        return const WeekStripCell.rest();
      }
      return WeekStripCell.label(label: label, color: color);
    });

    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.bgFrame,
          border: Border.all(color: colors.hairline, width: 0.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              program.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.ink900,
                                letterSpacing: -0.18,
                              ),
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(color: colors.accent),
                              child: Text(
                                l10n.activeBadge.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: Colors.white,
                                ),
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
                      const SizedBox(height: 3),
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
                      const SizedBox(height: 14),
                      WeekStrip(cells: cells, variant: WeekStripVariant.mini),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FAB
// ═══════════════════════════════════════════════════════════════

class _FabButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FabButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Help button
// ═══════════════════════════════════════════════════════════════

class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.ink900.withValues(alpha: 0.04),
            border: Border.all(color: colors.hairline, width: 0.6),
          ),
          child: Icon(
            Icons.help_outline_rounded,
            color: colors.ink700,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Empty State
// ═══════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate, required this.onTemplate});
  final VoidCallback onCreate;
  final void Function(ProgramTemplate) onTemplate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
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
            fontSize: 28,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.55,
            height: 1.05,
            color: colors.ink900,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            l10n.designYourWeekBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colors.ink500,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: PressableScale(
            onTap: onCreate,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 26),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.accent,
                border: Border.all(
                  color: colors.accentDeep.withValues(alpha: 0.6),
                  width: 0.6,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    l10n.createFromScratch.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 36),
        _SectionEyebrow(label: l10n.orStartFromTemplate),
        const SizedBox(height: 12),
        for (final t in kProgramTemplates)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
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
                  color: const Color(0xFF5B7A8C),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.6,
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
                  color: const Color(0xFF7A8C5B),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.6,
                  ),
                ),
                child: Icon(
                  Icons.bedtime_outlined,
                  size: 28,
                  color: Colors.white.withValues(alpha: 0.8),
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
                decoration: BoxDecoration(color: accent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'UPPER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 6),
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
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.hairline, width: 0.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: template.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: template.color),
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: colors.ink900,
                                      letterSpacing: -0.18,
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
                                      color: colors.accent,
                                    ),
                                    child: Text(
                                      l10n.recommendedBadge.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              template.sub(l10n),
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.ink500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            WeekStrip(
                              cells: cells,
                              variant: WeekStripVariant.mini,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: colors.ink900.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
