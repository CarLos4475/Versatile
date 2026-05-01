import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/session.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/screen_header.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key, required this.session});
  final Session session;

  Color get _accent => Color(session.colorValue);

  @override
  Widget build(BuildContext context) {
    final totalSets = session.exercises
            ?.fold(0, (s, e) => s + e.sets.length) ??
        0;

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: session.routineName,
                subtitle: FormatUtils.longDate(session.date),
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),

              // Stats header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: GlassContainer(
                  radius: 18,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DetailStat(
                          icon: Icons.timer_outlined,
                          label: 'Duration',
                          value: FormatUtils.duration(session.durationMin),
                        ),
                      ),
                      Container(
                        width: 0.5,
                        height: 40,
                        color: const Color(0x14000000),
                      ),
                      Expanded(
                        child: _DetailStat(
                          icon: Icons.fitness_center,
                          label: 'Volume',
                          value: FormatUtils.volume(session.volumeKg),
                        ),
                      ),
                      Container(
                        width: 0.5,
                        height: 40,
                        color: const Color(0x14000000),
                      ),
                      Expanded(
                        child: _DetailStat(
                          icon: Icons.bar_chart,
                          label: 'Sets',
                          value: '$totalSets',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Exercises
              if (session.exercises != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    children: session.exercises!.asMap().entries.map((entry) {
                      final i = entry.key;
                      final ex = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassContainer(
                          radius: 16,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: _accent.withOpacity(0.13),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _accent,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures()
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      ex.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${ex.sets.length} sets',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.ink400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Column headers
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 32,
                                      child: Text('SET', style: _hStyle),
                                    ),
                                    Expanded(child: Text('WEIGHT', style: _hStyle)),
                                    Expanded(child: Text('REPS', style: _hStyle)),
                                    SizedBox(
                                      width: 72,
                                      child: Text('VOLUME',
                                          style: _hStyle,
                                          textAlign: TextAlign.right),
                                    ),
                                  ],
                                ),
                              ),
                              ...ex.sets.asMap().entries.map((setEntry) {
                                final idx = setEntry.key;
                                final s = setEntry.value;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 7),
                                  decoration: idx < ex.sets.length - 1
                                      ? const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Color(0x0D000000),
                                              width: 0.5,
                                            ),
                                          ),
                                        )
                                      : null,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        child: Text(
                                          '${idx + 1}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.ink500,
                                            fontFeatures: [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${FormatUtils.weight(s.kg)} kg',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.ink900,
                                            fontFeatures: [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${s.reps}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.ink900,
                                            fontFeatures: [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 72,
                                        child: Text(
                                          '${s.volume.toStringAsFixed(0)} kg',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.ink500,
                                            fontFeatures: [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No detailed data for this session.',
                      style: TextStyle(fontSize: 13, color: AppColors.ink400),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static const _hStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.06,
    color: AppColors.ink400,
  );
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.ink400),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.06,
                  color: AppColors.ink400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.36,
            ),
          ),
        ],
      ),
    );
  }
}
