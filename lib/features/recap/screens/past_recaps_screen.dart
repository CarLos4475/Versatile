import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/recap_view_model.dart';
import 'monthly_recap_screen.dart';

class PastRecapsScreen extends ConsumerWidget {
  const PastRecapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final keys = ref.watch(availableRecapsProvider);

    return Scaffold(
      backgroundColor: colors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: l10n.recapPastRecaps,
              subtitle: l10n.recapPastRecapsSubtitle,
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: keys.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 44,
                            color: colors.ink300,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.recapPastRecapsEmpty,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.ink900,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                      itemCount: keys.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final key = keys[i];
                        return _PastRecapCard(monthKey: key);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PastRecapCard extends ConsumerWidget {
  const _PastRecapCard({required this.monthKey});
  final MonthKey monthKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final recap = ref.watch(monthlyRecapProvider(monthKey));
    if (recap == null) return const SizedBox.shrink();

    final monthLabel = FormatUtils.monthYear(
      '${monthKey.year.toString().padLeft(4, '0')}-'
      '${monthKey.month.toString().padLeft(2, '0')}-01',
    );

    return PressableScale(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MonthlyRecapScreen(monthKey: monthKey),
        ),
      ),
      child: GlassContainer(
        radius: 18,
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.accentLight, colors.accentDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colors.accentDeep.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monthLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.ink900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.recapEntryCardSubtitle(
                      recap.sessionsCount,
                      FormatUtils.volume(recap.totalVolumeKg),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.ink500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.ink300,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
