import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/session.dart';
import '../../../shared/widgets/coachmark_overlay.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../core/utils/format_utils.dart';
import '../widgets/history_exercise_detail.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  const SessionDetailScreen({super.key, required this.session});
  final Session session;

  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  final _chartBtnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkChartCoachmark());
  }

  Future<void> _checkChartCoachmark() async {
    if (!mounted) return;
    final exercises = widget.session.exercises;
    if (exercises == null || exercises.isEmpty) return;
    final service = ref.read(coachmarkServiceProvider);
    final should = await service.shouldShow('session_chart');
    if (!should || !mounted) return;
    if (_chartBtnKey.currentContext?.findRenderObject() == null) return;
    final l10n = AppLocalizations.of(context)!;
    CoachmarkOverlay.show(
      context: context,
      targetKey: _chartBtnKey,
      title: l10n.coachmarkSessionChartTitle,
      body: l10n.coachmarkSessionChartBody,
      gotItLabel: l10n.coachmarkGotIt,
      skipLabel: l10n.coachmarkSkipAll,
      onDone: () => service.markSeen('session_chart'),
      onSkipAll: () => service.markSeen('session_chart'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Color(widget.session.colorValue);

    final session = widget.session;

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: l10n.sessionDetail,
              subtitle: FormatUtils.date(
                session.date,
                locale: Localizations.localeOf(context).languageCode,
              ),
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 40),
                children: [
                  GlassContainer(
                    radius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                IconData(session.iconCode,
                                    fontFamily: 'MaterialIcons'),
                                color: color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.routineName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.ink900,
                                      letterSpacing: -0.18,
                                    ),
                                  ),
                                  Text(
                                    l10n.workoutSummary,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.ink400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _SummaryStat(
                              label: l10n.duration,
                              value: '${session.durationMin}',
                              unit: 'min',
                            ),
                            _SummaryStat(
                              label: l10n.volumeTotal,
                              value: FormatUtils.weight(session.volumeKg),
                              unit: 'kg',
                            ),
                            _SummaryStat(
                              label: l10n.exercises,
                              value: '${session.exercises?.length ?? 0}',
                              unit: '',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      l10n.exercisesPerformed,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.05,
                        color: context.colors.ink400,
                      ),
                    ),
                  ),
                  if (session.exercises != null)
                    ...List.generate(session.exercises!.length, (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HistoryExerciseDetail(
                            exercise: session.exercises![i],
                            chartBtnKey: i == 0 ? _chartBtnKey : null,
                          ),
                        )),
                ],
              ),
            ),
          ],
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: context.colors.ink400,
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: context.colors.ink900,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.ink500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
