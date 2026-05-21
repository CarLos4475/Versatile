import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../home/view_models/home_view_model.dart';
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
              prefix: Localizations.localeOf(context).languageCode == 'es'
                  ? 'Tu'
                  : 'Your',
              accent: Localizations.localeOf(context).languageCode == 'es'
                  ? 'historial.'
                  : 'history.',
              eyebrow: sessionsAsync.value != null
                  ? '${sessionsAsync.value!.length} ${l10n.total}'
                  : null,
            ),
            const SizedBox(height: 6),
            Container(height: 0.6, color: context.colors.hairline),
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

                  return FadeSlideIn(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: sessions.length,
                      separatorBuilder: (_, __) =>
                          Container(height: 0.6, color: context.colors.hairline),
                      itemBuilder: (context, i) => HistorySessionCard(
                        session: sessions[i],
                        containerKey: i == 0 ? _firstCardKey : null,
                      ),
                    ),
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

