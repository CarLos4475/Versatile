import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/coachmark_overlay.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/exercise_progress.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';

String? _muscleAsset(String muscle) => switch (muscle) {
  'Chest' => 'assets/assets/Torso/pecho/pecho_edit_24359279032740.png',
  'Back' => 'assets/assets/Torso/espalda/back_edit_24411266380648.png',
  'Shoulders' =>
    'assets/assets/Torso/hombro/shoulder_edit_24384715995236.png',
  'Core' => 'assets/assets/Torso/core/Core_edit_24439960498352.png',
  'Biceps' => 'assets/assets/Torso/brazos/biceps_edit_24565456161875.png',
  'Triceps' =>
    'assets/assets/Torso/brazos/triceps_edit_24496361907719.png',
  'Forearms' =>
    'assets/assets/Torso/brazos/forearm_edit_24532082903547.png',
  'Quadriceps' => 'assets/assets/Piernas/cuadriceps.png',
  'Hamstrings' =>
    'assets/assets/Piernas/femoral_edit_24694965504563.png',
  'Glutes' => 'assets/assets/Piernas/glutes_edit_24675899562379.png',
  'Calves' => 'assets/assets/Piernas/calf_edit_24757805204033.png',
  'Abductors' => 'assets/assets/Piernas/cuadriceps.png',
  'Adductors' => 'assets/assets/Piernas/cuadriceps.png',
  _ => null,
};

String _fmtDate(String date) {
  final p = date.split('-');
  final month = int.parse(p[1]);
  final day = int.parse(p[2]);
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${m[month - 1]} $day';
}

String _fmtDateShort(String date) {
  final p = date.split('-');
  final month = int.parse(p[1]);
  final day = int.parse(p[2]);
  return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}';
}

String _fmtValue(double v, _Metric metric) {
  if (metric == _Metric.oneRm) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);
  }
  if (v >= 10000) return '${(v / 1000).toStringAsFixed(1)}k';
  if (v >= 1000) return v.toStringAsFixed(0);
  return v.toStringAsFixed(0);
}

List<ExerciseProgressPoint> _filterByRange(
  List<ExerciseProgressPoint> points,
  String range,
) {
  final now = DateTime.now();
  final cutoff = switch (range) {
    '1M' => DateTime(now.year, now.month - 1, now.day),
    '3M' => DateTime(now.year, now.month - 3, now.day),
    '6M' => DateTime(now.year, now.month - 6, now.day),
    '1A' => DateTime(now.year - 1, now.month, now.day),
    _ => null,
  };
  if (cutoff == null) return points.toList();

  final cutoffStr =
      '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';
  return points.where((p) => p.date.compareTo(cutoffStr) >= 0).toList();
}

enum _Metric { oneRm, volume }

class ExerciseProgressScreen extends ConsumerStatefulWidget {
  const ExerciseProgressScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.muscle,
  });

  final String exerciseId;
  final String exerciseName;
  final String muscle;

  @override
  ConsumerState<ExerciseProgressScreen> createState() =>
      _ExerciseProgressScreenState();
}

class _ExerciseProgressScreenState
    extends ConsumerState<ExerciseProgressScreen> {
  _Metric _metric = _Metric.oneRm;
  String _range = '3M';
  final _metricToggleKey = GlobalKey();
  bool _coachmarkShown = false;

  Future<void> _triggerMetricToggleCoachmark() async {
    if (!mounted) return;
    final service = ref.read(coachmarkServiceProvider);
    final should = await service.shouldShow('progress_toggle');
    if (!should || !mounted) return;
    if (_metricToggleKey.currentContext?.findRenderObject() == null) return;
    final l10n = AppLocalizations.of(context)!;
    CoachmarkOverlay.show(
      context: context,
      targetKey: _metricToggleKey,
      title: l10n.coachmarkProgressToggleTitle,
      body: l10n.coachmarkProgressToggleBody,
      gotItLabel: l10n.coachmarkGotIt,
      skipLabel: l10n.coachmarkSkipAll,
      onDone: () => service.markSeen('progress_toggle'),
      onSkipAll: () => service.markSeen('progress_toggle'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progressAsync =
        ref.watch(exerciseProgressProvider(widget.exerciseId));
    final dummy = Exercise(
      id: widget.exerciseId,
      name: widget.exerciseName,
      muscle: widget.muscle,
      equipment: '',
    );
    final asset = _muscleAsset(widget.muscle);

    ref.listen(exerciseProgressProvider(widget.exerciseId), (prev, next) {
      next.whenData((points) {
        if (!_coachmarkShown && points.isNotEmpty) {
          _coachmarkShown = true;
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) _triggerMetricToggleCoachmark();
          });
        }
      });
    });

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              prefix: Localizations.localeOf(context).languageCode == 'es'
                  ? 'Progreso —'
                  : 'Progress —',
              accent: '${dummy.getLocalizedName(context)}.',
              eyebrow: dummy.getLocalizedMuscle(context),
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            Expanded(
              child: progressAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: context.colors.accent,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(child: Text('$e')),
                data: (points) {
                  final filteredPoints = _filterByRange(points, _range);
                  if (filteredPoints.isEmpty) {
                    return _EmptyState(asset: asset, l10n: l10n);
                  }

                  final values = _metric == _Metric.oneRm
                      ? filteredPoints.map((p) => p.estimatedOneRm).toList()
                      : filteredPoints.map((p) => p.volume).toList();

                  final latest = values.last;
                  final previous = values.length > 1 ? values[values.length - 2] : latest;
                  final best = values.reduce(max);
                  final avg = values.reduce((a, b) => a + b) / values.length;
                  final delta = latest - previous;
                  final isPos = delta >= 0;
                  final deltaPct = previous != 0
                      ? ((delta / previous) * 100).toStringAsFixed(1)
                      : '0.0';

                  final bestIdx = values.indexOf(best);
                  final prDate = filteredPoints[bestIdx].date;

                  final recentCount = min(6, filteredPoints.length);
                  final recentPoints = filteredPoints.sublist(filteredPoints.length - recentCount);
                  final recentValues = values.sublist(values.length - recentCount);
                  final recentMax = recentValues.reduce(max);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 40),
                    children: [
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 60),
                        child: Column(
                          children: [
                            const _GridDivider(),
                            _MetricToggle(
                              key: _metricToggleKey,
                              metric: _metric,
                              onChanged: (m) => setState(() => _metric = m),
                              l10n: l10n,
                            ),
                            const _GridDivider(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 140),
                        child: _HeroStat(
                          value: latest,
                          delta: delta,
                          deltaPct: deltaPct,
                          isPos: isPos,
                          metric: _metric,
                          l10n: l10n,
                        ),
                      ),
                      const SizedBox(height: 22),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 220),
                        child: _StatsRow(
                          best: best,
                          avg: avg,
                          sessions: filteredPoints.length,
                          metric: _metric,
                          points: filteredPoints,
                          prDate: prDate,
                          l10n: l10n,
                        ),
                      ),
                      const SizedBox(height: 28),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 320),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionEyebrow(
                              label: l10n.progressionLabel,
                              trailing: _RangeMicro(
                                selected: _range,
                                onChanged: (r) => setState(() => _range = r),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _ChartSection(
                              points: filteredPoints,
                              values: values,
                              bestIdx: bestIdx,
                              metric: _metric,
                              l10n: l10n,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionEyebrow(label: l10n.recentSessions),
                            const SizedBox(height: 12),
                            _RecentSessions(
                              recentPoints: recentPoints,
                              recentValues: recentValues,
                              recentMax: recentMax,
                              metric: _metric,
                              l10n: l10n,
                            ),
                          ],
                        ),
                      ),
                      if (_metric == _Metric.oneRm) ...[
                        const SizedBox(height: 28),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 480),
                          child: _FormulaChip(l10n: l10n),
                        ),
                      ],
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

class _GridDivider extends StatelessWidget {
  const _GridDivider();
  @override
  Widget build(BuildContext context) {
    return Container(height: 0.6, color: context.colors.hairline);
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.label, this.trailing});
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
              color: colors.ink500,
              letterSpacing: 0.18,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _MetricToggle extends StatelessWidget {
  const _MetricToggle({
    super.key,
    required this.metric,
    required this.onChanged,
    required this.l10n,
  });
  final _Metric metric;
  final ValueChanged<_Metric> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          _MagTab(
            label: l10n.estimatedOneRm,
            isActive: metric == _Metric.oneRm,
            onTap: () => onChanged(_Metric.oneRm),
          ),
          Container(width: 0.6, color: context.colors.hairline),
          _MagTab(
            label: l10n.volume,
            isActive: metric == _Metric.volume,
            onTap: () => onChanged(_Metric.volume),
          ),
        ],
      ),
    );
  }
}

class _MagTab extends StatelessWidget {
  const _MagTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isActive ? colors.accent : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isActive ? colors.accentDeep : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.18,
                  color: isActive ? Colors.white : colors.ink400,
                ),
                child: Text(label.toUpperCase()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.delta,
    required this.deltaPct,
    required this.isPos,
    required this.metric,
    required this.l10n,
  });
  final double value;
  final double delta;
  final String deltaPct;
  final bool isPos;
  final _Metric metric;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unitLabel = metric == _Metric.oneRm ? 'kg' : 'kg';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 24, height: 1, color: colors.ink900),
            const SizedBox(width: 10),
            Text(
              l10n.last_label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: colors.ink900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: _fmtValue(value, metric),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 64,
                    fontWeight: FontWeight.w500,
                    height: 0.95,
                    letterSpacing: -2.0,
                    color: colors.ink900,
                  ),
                ),
                TextSpan(
                  text: ' $unitLabel',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: colors.ink500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _DeltaPill(
          value: delta.abs(),
          pct: deltaPct,
          isPositive: isPos,
          metric: metric,
        ),
      ],
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({
    required this.value,
    required this.pct,
    required this.isPositive,
    required this.metric,
  });
  final double value;
  final String pct;
  final bool isPositive;
  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? context.colors.doneStrong : context.colors.accent;
    final bg = isPositive
        ? context.colors.doneTint
        : context.colors.accentTint;
    final borderColor = isPositive
        ? context.colors.doneStrong.withValues(alpha: 0.35)
        : context.colors.accent.withValues(alpha: 0.35);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            '${isPositive ? '+' : '−'}${_fmtValue(value, metric)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '${isPositive ? '+' : '−'}${pct.replaceAll('-', '')}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.colors.ink500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.best,
    required this.avg,
    required this.sessions,
    required this.metric,
    required this.points,
    required this.prDate,
    required this.l10n,
  });
  final double best;
  final double avg;
  final int sessions;
  final _Metric metric;
  final List<ExerciseProgressPoint> points;
  final String prDate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hairlineStrong = colors.ink900.withValues(alpha: 0.35);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: hairlineStrong, width: 0.8),
          bottom: BorderSide(color: hairlineStrong, width: 0.8),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                icon: Icons.emoji_events_rounded,
                value: _fmtValue(best, metric),
                label: l10n.recordLabel.toUpperCase(),
                sub: _fmtDateShort(prDate),
              ),
            ),
            Container(width: 0.6, color: colors.hairline),
            Expanded(
              child: _StatCellWithSparkline(
                value: _fmtValue(avg, metric),
                label: l10n.averageLabel.toUpperCase(),
                points: points,
                metric: metric,
              ),
            ),
            Container(width: 0.6, color: colors.hairline),
            Expanded(
              child: _StatCell(
                value: '$sessions',
                label: l10n.sessionsLabel.toUpperCase(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.sub,
    this.icon,
  });

  final String value;
  final String label;
  final String? sub;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(icon, size: 14, color: colors.accentDeep),
            ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                height: 1.0,
                letterSpacing: -0.4,
                color: colors.ink900,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: colors.ink500,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(
              sub!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: colors.ink400,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCellWithSparkline extends StatelessWidget {
  const _StatCellWithSparkline({
    required this.value,
    required this.label,
    required this.points,
    required this.metric,
  });

  final String value;
  final String label;
  final List<ExerciseProgressPoint> points;
  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                height: 1.0,
                letterSpacing: -0.4,
                color: colors.ink900,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: colors.ink500,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 16,
            width: 60,
            child: _Sparkline(
              points: points,
              metric: metric,
              color: colors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({
    required this.points,
    required this.metric,
    required this.color,
  });
  final List<ExerciseProgressPoint> points;
  final _Metric metric;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final values = metric == _Metric.oneRm
        ? points.map((p) => p.estimatedOneRm).toList()
        : points.map((p) => p.volume).toList();
    if (values.length < 2) return const SizedBox.shrink();

    final minVal = values.reduce(min);
    final maxVal = values.reduce(max);
    final valueRange = maxVal - minVal;

    return CustomPaint(
      size: const Size(double.infinity, 22),
      painter: _SparklinePainter(
        values: values,
        minVal: minVal,
        valueRange: valueRange,
        lineColor: color,
        fillColor: color.withValues(alpha: 0.25),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.minVal,
    required this.valueRange,
    required this.lineColor,
    required this.fillColor,
  });
  final List<double> values;
  final double minVal;
  final double valueRange;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    final h = size.height;
    final w = size.width;
    final yPad = h * 0.15;
    final drawH = h - yPad * 2;

    double y(double v) {
      if (valueRange == 0) return h / 2;
      return h - yPad - ((v - minVal) / valueRange) * drawH;
    }

    double x(int i) => n == 1 ? w / 2 : (i / (n - 1)) * w;

    final path = Path();
    path.moveTo(x(0), y(values[0]));

    for (int i = 0; i < n - 1; i++) {
      final p0 = Offset(x(i == 0 ? 0 : i - 1), y(values[i == 0 ? 0 : i - 1]));
      final p1 = Offset(x(i), y(values[i]));
      final p2 = Offset(x(i + 1), y(values[i + 1]));
      final p3 = Offset(x(min(n - 1, i + 2)), y(values[min(n - 1, i + 2)]));

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    final fillPath = Path.from(path);
    fillPath.lineTo(x(n - 1), h);
    fillPath.lineTo(x(0), h);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [fillColor, fillColor.withValues(alpha: 0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.points,
    required this.values,
    required this.bestIdx,
    required this.metric,
    required this.l10n,
  });
  final List<ExerciseProgressPoint> points;
  final List<double> values;
  final int bestIdx;
  final _Metric metric;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spots = values
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final n = spots.length;
    final interval = max(1.0, (n / 5).ceilToDouble());
    final maxY = spots.map((s) => s.y).reduce(max);
    final minY = spots.map((s) => s.y).reduce(min);
    final range = (maxY - minY).clamp(1.0, double.infinity);
    final paddedMin = (minY - range * 0.12).clamp(0.0, double.infinity);
    final paddedMax = maxY + range * 0.12;
    final yRange = paddedMax - paddedMin;
    final yInterval = max(1.0, (yRange / 4).roundToDouble());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.hairline,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        metric == _Metric.oneRm
                            ? l10n.estimatedOneRm
                            : l10n.volume,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: colors.ink700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      color: colors.accent,
                      child: Text(
                        '${_fmtValue(values.last, metric)} kg',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 12, 20, 8),
                child: SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: colors.hairline,
                          strokeWidth: 0.5,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            interval: yInterval,
                            getTitlesWidget: (value, meta) {
                              if (value == meta.min || value == meta.max) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 6,
                                child: Text(
                                  _fmtYLabel(value, metric),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: colors.ink400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: interval,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= points.length || value != idx.toDouble()) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 4,
                                child: Text(
                                  _fmtDate(points[idx].date),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: colors.ink400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.25,
                          color: colors.accent,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: n <= 15,
                            getDotPainter: (spot, percent, bar, index) {
                              final isPr = index == values.lastIndexOf(maxY);
                              if (isPr) {
                                return _PrDotPainter(
                                  accent: colors.accent,
                                  accentSoft: colors.accentSoft,
                                );
                              }
                              return FlDotCirclePainter(
                                radius: 3.5,
                                color: colors.accent,
                                strokeWidth: 2,
                                strokeColor: colors.bgApp,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                colors.accent.withValues(alpha: 0.18),
                                colors.accent.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) =>
                              colors.bgFrame.withValues(alpha: 0.96),
                          tooltipRoundedRadius: 0,
                          tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          getTooltipItems: (touchedSpots) =>
                              touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            final date = (idx >= 0 && idx < points.length)
                                ? _fmtDate(points[idx].date)
                                : '';
                            final valueStr = metric == _Metric.oneRm
                                ? '${spot.y.toStringAsFixed(1)} kg'
                                : '${spot.y.toStringAsFixed(0)} kg';
                            return LineTooltipItem(
                              '$valueStr\n',
                              TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.ink900,
                              ),
                              children: [
                                TextSpan(
                                  text: date,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: colors.ink400,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      minX: 0,
                      maxX: (n - 1).toDouble(),
                      minY: paddedMin,
                      maxY: paddedMax,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 12,
              color: colors.ink400,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                metric == _Metric.oneRm
                    ? l10n.oneRmDescription
                    : l10n.volumeDescription,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.ink400,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrDotPainter extends FlDotPainter {
  _PrDotPainter({
    required this.accent,
    required this.accentSoft,
  });

  final Color accent;
  final Color accentSoft;

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    final c = offsetInCanvas;

    final glowPaint = Paint()
      ..color = accent.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(c, 10, glowPaint);

    canvas.drawCircle(
      c, 5,
      Paint()..color = accentSoft..style = PaintingStyle.fill,
    );

    final badgeRect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(c.dx, c.dy - 19), width: 30, height: 16),
    );
    final badgePaint = Paint()
      ..shader = LinearGradient(
        colors: [accentSoft, accent],
      ).createShader(badgeRect.outerRect);
    canvas.drawRRect(badgeRect, badgePaint);

    final tp = TextPainter(
      text: TextSpan(
        text: 'PR',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Color(0xFF3A1D10),
          letterSpacing: 0.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - 19 - tp.height / 2));
  }

  @override
  Size getSize(FlSpot spot) => const Size(44, 34);

  @override
  Color get mainColor => accentSoft;

  @override
  _PrDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    if (a is _PrDotPainter && b is _PrDotPainter) {
      return _PrDotPainter(
        accent: Color.lerp(a.accent, b.accent, t)!,
        accentSoft: Color.lerp(a.accentSoft, b.accentSoft, t)!,
      );
    }
    return this;
  }

  @override
  List<Object?> get props => [accent, accentSoft];
}

class _RangeMicro extends StatelessWidget {
  const _RangeMicro({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ranges = const ['1M', '3M', '6M', '1A', 'Todo'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ranges.map((r) {
        final isActive = r == selected;
        return PressableScale(
          onTap: () => onChanged(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? context.colors.accent
                  : Colors.transparent,
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.04,
                color: isActive
                    ? Colors.white
                    : context.colors.ink400,
              ),
              child: Text(r),
            ),
          ),
        );
      }).toList(),
    );
  }
}

String _fmtYLabel(double v, _Metric metric) {
  if (metric == _Metric.volume) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k kg';
    return '${v.toStringAsFixed(0)} kg';
  }
  return '${v.toStringAsFixed(0)} kg';
}

class _RecentSessions extends StatelessWidget {
  const _RecentSessions({
    required this.recentPoints,
    required this.recentValues,
    required this.recentMax,
    required this.metric,
    required this.l10n,
  });
  final List<ExerciseProgressPoint> recentPoints;
  final List<double> recentValues;
  final double recentMax;
  final _Metric metric;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final reversedPoints = recentPoints.reversed.toList();
    final reversedValues = recentValues.reversed.toList();
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(reversedPoints.length, (i) {
          final p = reversedPoints[i];
          final v = reversedValues[i];
          final isPr = v == recentValues.reduce(max);
          final w = recentMax > 0 ? (v / recentMax) * 100 : 0;

          return Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: i < reversedPoints.length - 1
                ? BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colors.hairline,
                        width: 0.5,
                      ),
                    ),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _fmtDateShort(p.date),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: colors.ink500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (isPr) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        color: colors.accent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              size: 9,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'PR',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: _fmtValue(v, metric),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                              color: colors.ink900,
                            ),
                          ),
                          TextSpan(
                            text: ' kg',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colors.ink400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.ink300.withValues(alpha: 0.12),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: w.clamp(0.0, 1.0).toDouble(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPr
                              ? [colors.accentSoft, colors.accent]
                              : [
                                  colors.accent.withValues(alpha: 0.6),
                                  colors.accentSoft.withValues(alpha: 0.6),
                                ],
                        ),
                        boxShadow: isPr
                            ? [
                                BoxShadow(
                                  color: colors.accentSoft.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _FormulaChip extends StatelessWidget {
  const _FormulaChip({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionEyebrow(label: l10n.formulaEpley),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            border: Border.all(color: colors.hairline, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    color: colors.ink900,
                    child: Text(
                      'ƒ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.bgApp,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '1RM ≈ kg × (1 + reps / 30)',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.ink700,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.formulaEpleyDescription,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.ink500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.asset, required this.l10n});
  final String? asset;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (asset != null)
              Opacity(
                opacity: 0.25,
                child: Image.asset(asset!, width: 72, height: 72),
              )
            else
              Icon(
                Icons.show_chart_rounded,
                size: 48,
                color: colors.ink300,
              ),
            const SizedBox(height: 20),
            Text(
              l10n.noProgressYet,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.ink400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
