import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../home/widgets/session_card.dart';
import '../view_models/history_view_model.dart';
import 'session_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final histState = historyAsync;

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'History',
                subtitle: '${histState.sessions.length} sessions completed',
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: GlassContainer(
                    radius: 18,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryStat(
                            label: 'Total volume',
                            value: histState.totalVolume >= 1000
                                ? (histState.totalVolume / 1000)
                                      .toStringAsFixed(1)
                                : histState.totalVolume.toStringAsFixed(0),
                            unit: histState.totalVolume >= 1000 ? 'k kg' : 'kg',
                          ),
                        ),
                        Container(
                          width: 0.5,
                          height: 40,
                          color: const Color(0x14000000),
                        ),
                        Expanded(
                          child: _SummaryStat(
                            label: 'Avg duration',
                            value: '${histState.avgDuration}',
                            unit: 'min',
                          ),
                        ),
                        Container(
                          width: 0.5,
                          height: 40,
                          color: const Color(0x14000000),
                        ),
                        Expanded(
                          child: _SummaryStat(
                            label: 'Sessions',
                            value: '${histState.sessions.length}',
                            unit: 'total',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x0A000000),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 0.5,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppColors.ink400,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sessions are automatically deleted after 30 days.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.ink400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (histState.sessions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                    child: Text(
                      'No sessions yet.\nFinish your first workout to see history here.',
                      style: TextStyle(fontSize: 14, color: AppColors.ink400),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: histState.grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.06,
                                color: AppColors.ink400,
                              ),
                            ),
                          ),
                          ...entry.value.map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SessionCard(
                                session: s,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SessionDetailScreen(session: s),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.06,
              color: AppColors.ink400,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.44,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: const TextStyle(fontSize: 11, color: AppColors.ink400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
