import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../home/view_models/home_view_model.dart';
import '../../recap/screens/monthly_recap_screen.dart';
import '../../recap/view_models/recap_view_model.dart';
import '../widgets/history_session_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _firstCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(historyFirstCardKeyProvider.notifier).state = _firstCardKey;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sessionsAsync = ref.watch(sessionsAsyncProvider);

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: l10n.history,
              subtitle: sessionsAsync.value != null
                  ? '${sessionsAsync.value!.length} ${l10n.total}'
                  : null,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: sessionsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: context.colors.accent,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e', style: TextStyle(color: context.colors.ink500)),
                ),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 48,
                            color: context.colors.ink300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noHistoryYet,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.colors.ink900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.startTrainingToSee,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.ink400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                    children: [
                      Consumer(
                        builder: (context, ref, _) {
                          final banner =
                              ref.watch(unseenLastRecapProvider).value;
                          if (banner == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _RecapBanner(monthKey: banner),
                          );
                        },
                      ),
                      for (var i = 0; i < sessions.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i < sessions.length - 1 ? 10 : 0,
                          ),
                          child: HistorySessionCard(
                            session: sessions[i],
                            containerKey: i == 0 ? _firstCardKey : null,
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
}

class _RecapBanner extends ConsumerWidget {
  const _RecapBanner({required this.monthKey});
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
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.accentLight, colors.accent, colors.accentDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.accentDeep.withValues(alpha: 0.32),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
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
                  Text(
                    l10n.recapEntryCardTitle(monthLabel),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l10n.recapBannerCta,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
