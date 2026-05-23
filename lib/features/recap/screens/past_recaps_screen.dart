import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../l10n/app_localizations.dart';
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
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Scaffold(
      backgroundColor: colors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              prefix: isEs ? 'Resúmenes' : 'Past',
              accent: isEs ? 'anteriores.' : 'recaps.',
              eyebrow: l10n.recapPastRecapsSubtitle,
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: keys.isEmpty
                  ? _EmptyState(label: l10n.recapPastRecapsEmpty)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                      itemCount: keys.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 60 + i * 40),
                          child: _PastRecapCard(monthKey: keys[i]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 1,
            height: 28,
            color: colors.ink400.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.calendar_month_outlined,
            size: 28,
            color: colors.ink400,
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.ink700,
              letterSpacing: -0.18,
            ),
          ),
        ],
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
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.hairline, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: colors.accent),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.ink900,
                      letterSpacing: -0.18,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.recapEntryCardSubtitle(
                      recap.sessionsCount,
                      '${FormatUtils.volume(recap.totalVolumeKg)} kg',
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.ink500,
                    ),
                  ),
                ],
              ),
            ),
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
