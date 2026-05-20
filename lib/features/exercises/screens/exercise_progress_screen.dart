import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/coachmark_overlay.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/exercise_progress.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';

// ───────────────────────────────────────────────────────────────
// Helpers
// ───────────────────────────────────────────────────────────────

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

enum _Metric { oneRm, volume }

// ═══════════════════════════════════════════════════════════════
// Screen
// ═══════════════════════════════════════════════════════════════

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
              title: dummy.getLocalizedName(context),
              subtitle: dummy.getLocalizedMuscle(context),
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
                  if (points.isEmpty) {
                    return _EmptyState(asset: asset, l10n: l10n);
                  }

                  final values = _metric == _Metric.oneRm
                      ? points.map((p) => p.estimatedOneRm).toList()
                      : points.map((p) => p.volume).toList();

                  final latest = values.last;
                  final previous = values.length > 1 ? values[values.length - 2] : latest;
                  final best = values.reduce(max);
                  final avg = values.reduce((a, b) => a + b) / values.length;
                  final delta = latest - previous;
                  final isPos = delta >= 0;
                  final deltaPct = previous != 0
                      ? ((delta / previous) * 100).toStringAsFixed(1)
                      : '0.0';

                  // PR index
                  final bestIdx = values.indexOf(best);
                  final prDate = points[bestIdx].date;

                  // Recent (last 5-6, reversed)
                  final recentCount = min(6, points.length);
                  final recentPoints = points.sublist(points.length - recentCount);
                  final recentValues = values.sublist(values.length - recentCount);
                  final recentMax = recentValues.reduce(max);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
                    children: [
                      _TopBar(asset: asset, dummy: dummy),
                      const SizedBox(height: 14),
                      _MetricToggle(
                        key: _metricToggleKey,
                        metric: _metric,
                        onChanged: (m) => setState(() => _metric = m),
                        l10n: l10n,
                      ),
                      const SizedBox(height: 18),
                      _MetricGrid(
                        latest: latest,
                        best: best,
                        avg: avg,
                        sessions: points.length,
                        delta: delta,
                        isPos: isPos,
                        deltaPct: deltaPct,
                        metric: _metric,
                        points: points,
                        prDate: prDate,
                      ),
                      const SizedBox(height: 20),
                      _ChartSection(
                        points: points,
                        values: values,
                        bestIdx: bestIdx,
                        metric: _metric,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 20),
                      _RecentSessions(
                        recentPoints: recentPoints,
                        recentValues: recentValues,
                        recentMax: recentMax,
                        metric: _metric,
                        l10n: l10n,
                      ),
                      if (_metric == _Metric.oneRm) ...[
                        const SizedBox(height: 16),
                        _FormulaChip(l10n: l10n),
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

// ═══════════════════════════════════════════════════════════════
// Top Bar (muscle image + exercise name + muscle label)
// ═══════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({required this.asset, required this.dummy});
  final String? asset;
  final Exercise dummy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: context.colors.accentTint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.accentSoft.withValues(alpha: 0.22),
              width: 0.5,
            ),
          ),
          child: asset != null
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(asset!, fit: BoxFit.contain),
                )
              : Icon(
                  Icons.fitness_center,
                  size: 24,
                  color: context.colors.accentDeep,
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dummy.getLocalizedName(context),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: context.colors.ink900,
                  letterSpacing: -0.02,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: context.colors.accentSoft,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dummy.getLocalizedMuscle(context),
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.ink500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Metric Toggle
// ═══════════════════════════════════════════════════════════════

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
    return GlassContainer(
      radius: 14,
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: metric == _Metric.oneRm
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.accentLight,
                      context.colors.accent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.accentDeep.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _ToggleBtn(
                label: l10n.estimatedOneRm,
                isActive: metric == _Metric.oneRm,
                onTap: () => onChanged(_Metric.oneRm),
              ),
              _ToggleBtn(
                label: l10n.volume,
                isActive: metric == _Metric.volume,
                onTap: () => onChanged(_Metric.volume),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PressableScale(
        onTap: onTap,
        child: SizedBox(
          height: 38,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : context.colors.ink500,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Metric Grid (2x2)
// ═══════════════════════════════════════════════════════════════

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.latest,
    required this.best,
    required this.avg,
    required this.sessions,
    required this.delta,
    required this.isPos,
    required this.deltaPct,
    required this.metric,
    required this.points,
    required this.prDate,
  });
  final double latest;
  final double best;
  final double avg;
  final int sessions;
  final double delta;
  final bool isPos;
  final String deltaPct;
  final _Metric metric;
  final List<ExerciseProgressPoint> points;
  final String prDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unit = metric == _Metric.oneRm ? 'kg' : 'kg';

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: [
        // ── Latest (accent) ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.accent.withValues(alpha: 0.18),
                context.colors.bgFrame.withValues(alpha: 0.35),
              ],
            ),
            border: Border.all(
              color: context.colors.accentSoft.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.last_label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.06,
                  color: context.colors.accentSoft,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _fmtValue(latest, metric),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: context.colors.ink900,
                  letterSpacing: -0.025,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 6),
              _DeltaPill(
                value: delta.abs(),
                pct: deltaPct,
                isPositive: isPos,
                metric: metric,
              ),
            ],
          ),
        ),

        // ── PR ──
        _MetricCard(
          label: Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 12,
                color: context.colors.accentSoft,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.recordLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.06,
                  color: context.colors.ink500,
                ),
              ),
            ],
          ),
          value: _fmtValue(best, metric),
          unit: unit,
          sub: _fmtDateShort(prDate),
        ),

        // ── Average ──
        _MetricCard(
          label: Text(
            l10n.averageLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.06,
              color: context.colors.ink500,
            ),
          ),
          value: _fmtValue(avg, metric),
          unit: '',
          extra: SizedBox(
            height: 18,
            child: _Sparkline(
              points: points,
              metric: metric,
              color: context.colors.accentSoft,
            ),
          ),
        ),

        // ── Sessions ──
        _MetricCard(
          label: Text(
            l10n.sessionsLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.06,
              color: context.colors.ink500,
            ),
          ),
          value: '$sessions',
          unit: '',
          sub: '${points.length} ${l10n.sessionsLabel.toLowerCase()}',
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    this.sub,
    this.extra,
  });
  final Widget label;
  final String value;
  final String unit;
  final String? sub;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: context.colors.ink900,
              letterSpacing: -0.025,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.ink500,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (sub != null) ...[
            const SizedBox(height: 6),
            Text(
              sub!,
              style: TextStyle(
                fontSize: 11,
                color: context.colors.ink400,
              ),
            ),
          ],
          if (extra case final w?) ...[w],
        ],
      ),
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
        borderRadius: BorderRadius.circular(8),
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

// ═══════════════════════════════════════════════════════════════
// Sparkline (mini)
// ═══════════════════════════════════════════════════════════════

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

    // Fill
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

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════
// Chart Section
// ═══════════════════════════════════════════════════════════════

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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.progressionLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: context.colors.ink400,
                ),
              ),
              _RangeMicro(),
            ],
          ),
        ),
        GlassContainer(
          strong: true,
          radius: 22,
          padding: const EdgeInsets.fromLTRB(2, 20, 20, 8),
          child: SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.colors.hairline,
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
                              color: context.colors.ink400,
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
                              color: context.colors.ink400,
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
                    color: context.colors.accent,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: n <= 15,
                      getDotPainter: (spot, percent, bar, index) {
                        final isPr = index == values.lastIndexOf(maxY);
                        if (isPr) {
                          return _PrDotPainter(
                            accent: context.colors.accent,
                            accentSoft: context.colors.accentSoft,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 3.5,
                          color: context.colors.accent,
                          strokeWidth: 2,
                          strokeColor: context.colors.bgApp,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          context.colors.accent.withValues(alpha: 0.18),
                          context.colors.accent.withValues(alpha: 0.0),
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
                        context.colors.bgFrame.withValues(alpha: 0.96),
                    tooltipRoundedRadius: 10,
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
                          color: context.colors.ink900,
                        ),
                        children: [
                          TextSpan(
                            text: date,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: context.colors.ink400,
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
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: context.colors.ink400,
              ),
              const SizedBox(width: 6),
              Text(
                metric == _Metric.oneRm
                    ? l10n.oneRmDescription
                    : l10n.volumeDescription,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.ink400,
                ),
              ),
            ],
          ),
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

    // glow
    final glowPaint = Paint()
      ..color = accent.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(c, 10, glowPaint);

    // filled circle
    canvas.drawCircle(
      c, 5,
      Paint()..color = accentSoft..style = PaintingStyle.fill,
    );

    // PR badge bg
    final badgeRect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(c.dx, c.dy - 19), width: 30, height: 16),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
      bottomLeft: const Radius.circular(4),
      bottomRight: const Radius.circular(4),
    );
    final badgePaint = Paint()
      ..shader = LinearGradient(
        colors: [accentSoft, accent],
      ).createShader(badgeRect.outerRect);
    canvas.drawRRect(badgeRect, badgePaint);

    // PR text
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
  @override
  Widget build(BuildContext context) {
    final ranges = const ['1M', '3M', '6M', '1A'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ranges.map((r) {
        final isActive = r == '3M';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isActive
                ? context.colors.accent.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            r,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.04,
              color: isActive
                  ? context.colors.accentSoft
                  : context.colors.ink400,
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

// ═══════════════════════════════════════════════════════════════
// Recent Sessions List
// ═══════════════════════════════════════════════════════════════

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentSessions.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08,
                  color: context.colors.ink400,
                ),
              ),
              Text(
                l10n.viewAll,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.ink400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: List.generate(reversedPoints.length, (i) {
            final p = reversedPoints[i];
            final v = reversedValues[i];
            final isPr = v == recentValues.reduce(max);
            final w = recentMax > 0 ? (v / recentMax) * 100 : 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: isPr
                    ? LinearGradient(
                        colors: [
                          context.colors.accentSoft.withValues(alpha: 0.10),
                          context.colors.accent.withValues(alpha: 0.05),
                        ],
                      )
                    : null,
                color: isPr ? null : context.colors.glassBg,
                border: Border.all(
                  color: isPr
                      ? context.colors.accentSoft.withValues(alpha: 0.25)
                      : context.colors.glassBorder,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(
                      _fmtDateShort(p.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.ink500,
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: context.colors.ink300.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: w.clamp(0.0, 1.0).toDouble(),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: isPr
                                  ? [
                                      context.colors.accentSoft,
                                      context.colors.accent,
                                    ]
                                  : [
                                      context.colors.accent.withValues(alpha: 0.7),
                                      context.colors.accentSoft.withValues(alpha: 0.7),
                                    ],
                            ),
                            boxShadow: isPr
                                ? [
                                    BoxShadow(
                                      color: context.colors.accentSoft.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 72,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isPr)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              size: 12,
                              color: context.colors.accentSoft,
                            ),
                          ),
                        Text(
                          _fmtValue(v, metric),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: context.colors.ink900,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'kg',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.ink400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Formula Chip
// ═══════════════════════════════════════════════════════════════

class _FormulaChip extends StatelessWidget {
  const _FormulaChip({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.accentTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.accent.withValues(alpha: 0.18),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.formulaEpley.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.06,
              color: context.colors.accentSoft,
            ),
          ),
          Text(
            '1RM ≈ kg × (1 + reps / 30)',
            style: TextStyle(
              fontSize: 12,
              color: context.colors.ink700,
              fontFamily: 'monospace',
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Empty State
// ═══════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.asset, required this.l10n});
  final String? asset;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
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
                color: context.colors.ink300,
              ),
            const SizedBox(height: 20),
            Text(
              l10n.noProgressYet,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.colors.ink400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
