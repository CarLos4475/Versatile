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

enum _Metric { oneRm, volume }

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
  const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${m[int.parse(p[1]) - 1]} ${int.parse(p[2])}';
}

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
          // Wait for the MaterialPageRoute slide-in transition (~300 ms) to
          // finish before computing localToGlobal, otherwise the in-progress
          // SlideTransition offset shifts the spotlight out of position.
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
                error: (e, _) =>
                    Center(child: Text('$e')),
                data: (points) {
                  if (points.isEmpty) {
                    return _EmptyState(asset: asset, l10n: l10n);
                  }

                  final values = _metric == _Metric.oneRm
                      ? points.map((p) => p.estimatedOneRm).toList()
                      : points.map((p) => p.volume).toList();

                  final spots = values
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList();

                  final latest = values.last;
                  final best = values.reduce(max);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 40),
                    children: [
                      _HeaderCard(asset: asset, dummy: dummy),
                      const SizedBox(height: 16),
                      _MetricToggle(
                        key: _metricToggleKey,
                        metric: _metric,
                        onChanged: (m) => setState(() => _metric = m),
                        l10n: l10n,
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Column(
                          key: ValueKey(_metric),
                          children: [
                            Text(
                              _metric == _Metric.oneRm
                                  ? l10n.oneRmDescription
                                  : l10n.volumeDescription,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.colors.ink400,
                                height: 1.4,
                              ),
                            ),
                            if (_metric == _Metric.oneRm) ...[
                              const SizedBox(height: 4),
                              Text(
                                '1RM ≈ kg × (1 + reps / 30)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.accentDeep,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _StatsRow(
                        latest: latest,
                        best: best,
                        metric: _metric,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 14),
                      _ProgressChart(
                        spots: spots,
                        points: points,
                        metric: _metric,
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.asset, required this.dummy});
  final String? asset;
  final Exercise dummy;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.accentTint,
              borderRadius: BorderRadius.circular(16),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dummy.getLocalizedName(context),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.colors.ink900,
                  letterSpacing: -0.17,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dummy.getLocalizedMuscle(context),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.ink400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
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
    return GlassContainer(
      radius: 12,
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
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.accentLight,
                      context.colors.accent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
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
          height: 34,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.latest,
    required this.best,
    required this.metric,
    required this.l10n,
  });
  final double latest;
  final double best;
  final _Metric metric;
  final AppLocalizations l10n;

  String _fmt(double v) =>
      metric == _Metric.oneRm ? '${v.toStringAsFixed(1)} kg' : '${v.toStringAsFixed(0)} kg';

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _StatItem(
            label: l10n.last_label.toUpperCase(),
            value: _fmt(latest),
          ),
          Container(
            width: 0.5,
            height: 40,
            color: context.colors.hairline,
          ),
          _StatItem(
            label: l10n.best_label,
            value: _fmt(best),
            leftPad: 8,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, this.leftPad = 0});
  final String label;
  final String value;
  final double leftPad;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: leftPad),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: context.colors.ink400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.colors.ink900,
              letterSpacing: -0.44,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
        ),
      ),
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

class _ProgressChart extends StatelessWidget {
  const _ProgressChart({
    required this.spots,
    required this.points,
    required this.metric,
  });
  final List<FlSpot> spots;
  final List<ExerciseProgressPoint> points;
  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final n = spots.length;
    final interval = max(1.0, (n / 5).ceilToDouble());
    final maxY = spots.map((s) => s.y).reduce(max);
    final minY = spots.map((s) => s.y).reduce(min);
    final range = (maxY - minY).clamp(1.0, double.infinity);
    final paddedMin = (minY - range * 0.12).clamp(0.0, double.infinity);
    final paddedMax = maxY + range * 0.12;
    final yRange = paddedMax - paddedMin;
    final yInterval = max(1.0, (yRange / 4).roundToDouble());

    return GlassContainer(
      strong: true,
      radius: 20,
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
                    if (idx < 0 ||
                        idx >= points.length ||
                        value != idx.toDouble()) {
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
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                    radius: 3.5,
                    color: context.colors.accent,
                    strokeWidth: 2,
                    strokeColor: context.colors.bgApp,
                  ),
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
    );
  }
}

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
