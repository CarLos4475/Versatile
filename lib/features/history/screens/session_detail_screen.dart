import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/session.dart';
import '../../../shared/widgets/coachmark_overlay.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../core/utils/format_utils.dart';
import '../../share/screens/share_session_screen.dart';
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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgApp,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              prefix: Localizations.localeOf(context).languageCode == 'es'
                  ? 'Sesión —'
                  : 'Session —',
              accent: '${session.routineName}.',
              accentColor: color,
              eyebrow: FormatUtils.date(
                session.date,
                locale: Localizations.localeOf(context).languageCode,
              ),
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
              trailing: PressableScale(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShareSessionScreen(session: session),
                  ),
                ),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.ink900.withValues(alpha: 0.04),
                    border: Border.all(
                      color: colors.hairline,
                      width: 0.6,
                    ),
                  ),
                  child: Icon(
                    Icons.ios_share_rounded,
                    color: colors.ink700,
                    size: 18,
                  ),
                ),
              ),
            ),
            Container(height: 0.6, color: colors.hairline),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  FadeSlideIn(
                    child: _SummaryBlock(
                      routineName: session.routineName,
                      iconCode: session.iconCode,
                      color: color,
                      durationMin: session.durationMin,
                      volumeKg: session.volumeKg,
                      exerciseCount: session.exercises?.length ?? 0,
                      summaryLabel: l10n.workoutSummary,
                      durationLabel: l10n.duration,
                      volumeLabel: l10n.volumeTotal,
                      exercisesLabel: l10n.exercises,
                    ),
                  ),
                  Container(height: 0.6, color: colors.hairline),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 1,
                            color: colors.ink400.withValues(alpha: 0.55),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.exercisesPerformed.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.18,
                              color: colors.ink500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (session.exercises != null)
                    ...List.generate(session.exercises!.length, (i) => Column(
                      children: [
                        Container(height: 0.6, color: colors.hairline),
                        FadeSlideIn(
                          delay: Duration(milliseconds: 90 + (i * 40)),
                          child: HistoryExerciseDetail(
                            exercise: session.exercises![i],
                            chartBtnKey: i == 0 ? _chartBtnKey : null,
                          ),
                        ),
                      ],
                    )),
                  Container(height: 0.6, color: colors.hairline),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({
    required this.routineName,
    required this.iconCode,
    required this.color,
    required this.durationMin,
    required this.volumeKg,
    required this.exerciseCount,
    required this.summaryLabel,
    required this.durationLabel,
    required this.volumeLabel,
    required this.exercisesLabel,
  });

  final String routineName;
  final int iconCode;
  final Color color;
  final int durationMin;
  final double volumeKg;
  final int exerciseCount;
  final String summaryLabel;
  final String durationLabel;
  final String volumeLabel;
  final String exercisesLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.bgFrame,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(
                  IconData(iconCode, fontFamily: 'MaterialIcons'),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routineName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.ink900,
                        letterSpacing: -0.18,
                      ),
                    ),
                    Text(
                      summaryLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.ink400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                _StatCell(
                  label: durationLabel,
                  value: '$durationMin',
                  unit: 'min',
                ),
                Container(width: 0.6, color: colors.hairline),
                _StatCell(
                  label: volumeLabel,
                  value: FormatUtils.weight(volumeKg),
                  unit: 'kg',
                ),
                Container(width: 0.6, color: colors.hairline),
                _StatCell(
                  label: exercisesLabel,
                  value: '$exerciseCount',
                  unit: '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: colors.ink500,
              letterSpacing: 0.18,
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
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.55,
                  color: colors.ink900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.ink400,
                    fontWeight: FontWeight.w500,
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
