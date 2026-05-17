import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/program.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/programs_view_model.dart';
import 'program_editor_screen.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final programsAsync = ref.watch(programsListProvider);
    final activeAsync = ref.watch(activeProgramProvider);
    final activeId = activeAsync.value?.id;

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
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
            const SizedBox(height: 16),
            Expanded(
              child: programsAsync.when(
                loading: () =>
                    Center(child: CircularProgressIndicator(color: context.colors.accent)),
                error: (e, _) => Center(
                  child: Text('$e', style: TextStyle(color: context.colors.ink500)),
                ),
                data: (programs) {
                  if (programs.isEmpty) {
                    return _EmptyState(
                      onCreate: () => _openEditor(context, null),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      for (final p in programs)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                          child: _ProgramCard(
                            program: p,
                            isActive: p.id == activeId,
                            onTap: () => _openEditor(context, p.id),
                            onActivate: () => _activate(context, ref, p),
                            onDeactivate: () => _deactivate(ref),
                            onDelete: () => _delete(context, ref, p),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: GlassButton(
                          label: l10n.createProgram,
                          leading: const Icon(Icons.add, color: Colors.white, size: 18),
                          variant: GlassButtonVariant.primary,
                          size: GlassButtonSize.md,
                          expand: true,
                          onPressed: () => _openEditor(context, null),
                        ),
                      ),
                    ],
                  );
                },
              ),
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

  Future<void> _activate(BuildContext context, WidgetRef ref, Program p) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Default to Monday of this week so weekIndex/weekday math is intuitive.
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

  Future<void> _delete(BuildContext context, WidgetRef ref, Program p) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgFrame,
        scrollable: true,
        title: Text(l10n.deleteProgramTitle, style: TextStyle(color: context.colors.ink900)),
        content: Text(
          l10n.deleteProgramContent(p.name),
          style: TextStyle(color: context.colors.ink500, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: context.colors.ink400)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(programRepositoryProvider).delete(p.id);
    // Repository CASCADE handles slots; settings cleanup happens lazily via
    // activeProgramProvider's stale-pointer detection.
    ref.invalidate(programsListProvider);
    ref.invalidate(activeProgramProvider);
    ref.invalidate(todaysPlannedSlotProvider);
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.isActive,
    required this.onTap,
    required this.onActivate,
    required this.onDeactivate,
    required this.onDelete,
  });

  final Program program;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Color(program.colorValue);
    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        radius: 20,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.9), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconData(program.iconCode, fontFamily: 'MaterialIcons'),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.colors.ink900,
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.accentTint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.active,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.08,
                              color: context.colors.accentDeep,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.programWeeksSummary(
                      program.weeksCount,
                      program.deloadWeeks.length,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.ink500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: context.colors.ink500, size: 20),
              color: context.colors.bgFrame,
              onSelected: (v) {
                if (v == 'activate') onActivate();
                if (v == 'deactivate') onDeactivate();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (ctx) => [
                if (!isActive)
                  PopupMenuItem(value: 'activate', child: Text(l10n.activateProgram)),
                if (isActive)
                  PopupMenuItem(value: 'deactivate', child: Text(l10n.deactivateProgram)),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                ),
              ],
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
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.colors.accentTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 32,
                color: context.colors.accentDeep,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.noProgramsYet,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: context.colors.ink900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.programsEmptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.colors.ink500, height: 1.4),
            ),
            const SizedBox(height: 22),
            GlassButton(
              label: l10n.createProgram,
              leading: const Icon(Icons.add, color: Colors.white, size: 18),
              variant: GlassButtonVariant.primary,
              size: GlassButtonSize.md,
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}
