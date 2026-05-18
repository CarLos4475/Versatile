import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../l10n/app_localizations.dart';

// Recap-specific palette intentionally diverges from the global theme: this
// is a Stories-style takeover that always reads as a warm dark canvas, so we
// hardcode the cover colours instead of going through context.colors.
const _bone = Color(0xFFF5EFE2);
const _boneSecondary = Color(0xB3F5EFE2); // 70% alpha
const _boneMuted = Color(0x8CF5EFE2); // 55% alpha
const _boneFaint = Color(0x73F5EFE2); // 45% alpha
const _pillText = Color(0xFFF4C2A9);

// ───────────────────────────────────────────────────────────────────────────
// Shared helpers
// ───────────────────────────────────────────────────────────────────────────

/// Big text with the recap's signature white→accent gradient applied via
/// [ShaderMask]. Always paints white internally; the shader colours the
/// pixels. Used for hero numbers and slide headlines.
class _GradientText extends StatelessWidget {
  const _GradientText(
    this.text, {
    required this.fontSize,
    this.fontWeight = FontWeight.w500,
    this.letterSpacing = -0.04,
    this.height = 0.95,
    this.tabular = false,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final double height;
  final bool tabular;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, colors.accentLight, colors.accent],
      ).createShader(rect),
      child: Text(
        text,
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: fontSize * letterSpacing,
          height: height.clamp(1.0, double.infinity),
          fontFeatures: tabular
              ? const [FontFeature.tabularFigures()]
              : null,
        ),
      ),
    );
  }
}

/// Counts up from 0 to [target] on mount, easing with cubic ease-out. Wraps
/// the resulting number in a [_GradientText] so it shares the signature
/// gradient. Optional [delay] lets us stagger the start.
class _CountUp extends StatelessWidget {
  const _CountUp({
    required this.target,
    required this.fontSize,
    this.delay = Duration.zero,
    this.fractionDigits = 0,
    this.useThousandsSeparator = false,
  });

  final double target;
  final double fontSize;
  final Duration delay;
  final int fractionDigits;
  final bool useThousandsSeparator;
  static const Duration duration = Duration(milliseconds: 1300);

  String _format(double v) {
    final rounded = fractionDigits == 0
        ? v.round().toString()
        : v.toStringAsFixed(fractionDigits);
    if (!useThousandsSeparator || fractionDigits != 0) return rounded;
    // Insert thousands separators on the integer part.
    final buf = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      final fromEnd = rounded.length - i;
      buf.write(rounded[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target),
      duration: duration,
      curve: Interval(
        delay.inMilliseconds / (delay.inMilliseconds + duration.inMilliseconds),
        1,
        curve: Curves.easeOutCubic,
      ),
      builder: (context, value, _) {
        return _GradientText(
          _format(value),
          fontSize: fontSize,
          tabular: true,
          height: 1.0,
        );
      },
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.6,
        color: _boneMuted,
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.text, this.icon = Icons.arrow_upward_rounded});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: colors.accentLight.withValues(alpha: 0.35),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _pillText),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _pillText,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideShell extends StatelessWidget {
  const _SlideShell({
    required this.child,
    this.centerHorizontally = false,
  });
  final Widget child;
  final bool centerHorizontally;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 92, 28, 28),
        child: Align(
          alignment: centerHorizontally
              ? Alignment.center
              : Alignment.centerLeft,
          child: child,
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Slides
// ───────────────────────────────────────────────────────────────────────────

class CoverSlide extends StatelessWidget {
  const CoverSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final monthLabel = FormatUtils.monthYear(
      '${recap.year.toString().padLeft(4, '0')}-${recap.month.toString().padLeft(2, '0')}-01',
    );
    return _SlideShell(
      centerHorizontally: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Eyebrow(monthLabel),
          const SizedBox(height: 22),
          _GradientText(
            l10n.recapHeadline,
            fontSize: 88,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.05,
            height: 0.95,
          ),
          const SizedBox(height: 22),
          Text(
            l10n.recapCoverSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: _boneSecondary,
              height: 1.4,
            ),
          ),
          const Spacer(),
          _FloatingHint(text: l10n.recapTapToBegin),
        ],
      ),
    );
  }
}

class _FloatingHint extends StatefulWidget {
  const _FloatingHint({required this.text});
  final String text;
  @override
  State<_FloatingHint> createState() => _FloatingHintState();
}

class _FloatingHintState extends State<_FloatingHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return Transform.translate(
          offset: Offset(0, -4 * t),
          child: Column(
            children: [
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                  color: _boneFaint,
                ),
              ),
              const SizedBox(height: 6),
              const _Dot(),
            ],
          ),
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(color: _boneFaint, shape: BoxShape.circle),
      );
}

class SessionsSlide extends StatelessWidget {
  const SessionsSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final delta = recap.sessionsCount - recap.prevSessionsCount;
    final perWeek = (recap.sessionsCount / 4.3).toStringAsFixed(1);
    return _SlideShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(l10n.recapSessionsEyebrow),
          const SizedBox(height: 18),
          _CountUp(
            target: recap.sessionsCount.toDouble(),
            fontSize: 150,
            delay: const Duration(milliseconds: 200),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.recapSessionsLabel,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: _bone,
              letterSpacing: -0.4,
            ),
          ),
          if (delta > 0 && recap.prevMonthLabel != null) ...[
            const SizedBox(height: 26),
            _DeltaPill(
              text: l10n.recapSessionsDelta(delta, recap.prevMonthLabel!),
            ),
          ],
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              text: l10n.recapSessionsAvg(perWeek).split(perWeek).first,
              style: const TextStyle(
                fontSize: 14,
                color: _boneMuted,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: perWeek,
                  style: const TextStyle(
                    color: _bone,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text: l10n.recapSessionsAvg(perWeek).split(perWeek).last,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VolumeSlide extends StatelessWidget {
  const VolumeSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pctDelta = recap.volumeDeltaPctVsPrev?.round();
    final maxWeek = recap.weeklyVolumeKg.isEmpty
        ? 1.0
        : recap.weeklyVolumeKg.reduce(math.max).clamp(1, double.infinity);

    return _SlideShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(l10n.recapVolumeEyebrow),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _CountUp(
                target: recap.totalVolumeKg,
                fontSize: 92,
                delay: const Duration(milliseconds: 200),
                useThousandsSeparator: true,
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'kg',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: _boneSecondary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.recapVolumeLabel,
            style: const TextStyle(fontSize: 16, color: _boneSecondary),
          ),
          const SizedBox(height: 32),
          if (recap.weeklyVolumeKg.isNotEmpty)
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(recap.weeklyVolumeKg.length, (i) {
                  final w = recap.weeklyVolumeKg[i];
                  final ratio = (w / maxWeek).clamp(0.0, 1.0);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i < recap.weeklyVolumeKg.length - 1 ? 10 : 0,
                      ),
                      child: _VolumeBar(
                        ratio: ratio,
                        labelTop: w >= 1000
                            ? '${(w / 1000).toStringAsFixed(1)}k'
                            : w.round().toString(),
                        labelBottom: l10n.recapWeekLabel(i + 1),
                        delay: Duration(milliseconds: 600 + i * 100),
                      ),
                    ),
                  );
                }),
              ),
            ),
          if (pctDelta != null && recap.prevMonthLabel != null) ...[
            const SizedBox(height: 26),
            _DeltaPill(
              text: l10n.recapVolumeDeltaPct(pctDelta, recap.prevMonthLabel!),
              icon: pctDelta >= 0
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _VolumeBar extends StatelessWidget {
  const _VolumeBar({
    required this.ratio,
    required this.labelTop,
    required this.labelBottom,
    required this.delay,
  });
  final double ratio;
  final String labelTop;
  final String labelBottom;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          labelTop,
          style: const TextStyle(
            fontSize: 10,
            color: _boneFaint,
            fontWeight: FontWeight.w500,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Interval(
              delay.inMilliseconds / 1500,
              1,
              curve: Curves.easeOutCubic,
            ),
            builder: (context, t, _) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  // Bar grows from the bottom edge.
                  height: ratio * 70 * t,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.accentLight,
                        colors.accent,
                        colors.accentDeep,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          labelBottom,
          style: const TextStyle(
            fontSize: 10,
            color: _boneFaint,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class CalendarSlide extends StatelessWidget {
  const CalendarSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final daysInMonth = DateTime(recap.year, recap.month + 1, 0).day;
    // Map weekday(1=Mon..7=Sun) to design's Sun-anchored layout where Sun=0.
    final firstDow = DateTime(recap.year, recap.month, 1).weekday % 7;
    final trained = <int>{};
    final monthKey =
        '${recap.year.toString().padLeft(4, '0')}-${recap.month.toString().padLeft(2, '0')}';
    for (final dayStr in recap.workoutDays) {
      if (!dayStr.startsWith(monthKey)) continue;
      final d = int.tryParse(dayStr.substring(8, 10));
      if (d != null) trained.add(d);
    }

    final cells = <int?>[];
    for (var i = 0; i < firstDow; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(d);
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return _SlideShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(l10n.recapCalendarEyebrow),
          const SizedBox(height: 12),
          _GradientText(
            '${trained.length}/$daysInMonth',
            fontSize: 60,
            letterSpacing: -0.04,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.recapCalendarLabel,
            style: const TextStyle(fontSize: 16, color: _boneSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: _boneFaint,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          _CalendarGrid(cells: cells, trained: trained),
          const SizedBox(height: 22),
          if (recap.bestWeekSessions > 0)
            Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 16,
                  color: context.colors.accentLight,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.recapBestWeek(recap.bestWeekSessions),
                  style: const TextStyle(
                    fontSize: 13,
                    color: _boneSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.cells, required this.trained});
  final List<int?> cells;
  final Set<int> trained;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: cells.length,
      itemBuilder: (context, idx) {
        final d = cells[idx];
        if (d == null) return const SizedBox.shrink();
        final did = trained.contains(d);
        final start = 350 + idx * 22;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: start + 500),
          curve: Interval(
            start / (start + 500),
            1,
            curve: Curves.easeOutBack,
          ),
          builder: (context, t, child) {
            return Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.3 + 0.7 * t, child: child),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              gradient: did
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.accentLight, colors.accent],
                    )
                  : null,
              color: did ? null : Colors.white.withValues(alpha: 0.06),
              border: did
                  ? null
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 0.5,
                    ),
              boxShadow: did
                  ? [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                d.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: did
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.35),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TopLiftSlide extends StatelessWidget {
  const TopLiftSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lift = recap.topLift!;
    final colors = context.colors;

    final displayName = () {
      if (lift.exerciseId.startsWith('c-') || lift.name.isEmpty) {
        return lift.name;
      }
      final dummy = Exercise(
        id: lift.exerciseId,
        name: lift.name,
        muscle: lift.muscle,
        equipment: '',
      );
      return dummy.getLocalizedName(context);
    }();
    final deltaStr = lift.deltaKgVsPrevMonth > 0
        ? FormatUtils.weight(lift.deltaKgVsPrevMonth)
        : null;

    return _SlideShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(l10n.recapTopLiftEyebrow),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w500,
              color: _bone,
              letterSpacing: -1.0,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _CountUp(
                target: lift.bestKg,
                fontSize: 100,
                delay: const Duration(milliseconds: 400),
                fractionDigits: lift.bestKg == lift.bestKg.roundToDouble()
                    ? 0
                    : 1,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 14),
                child: Text(
                  'kg',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: _boneSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (deltaStr != null) ...[
            const SizedBox(height: 18),
            _DeltaPill(text: l10n.recapTopLiftDelta(deltaStr)),
          ],
          const SizedBox(height: 28),
          if (lift.weeklyBests.length >= 2)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recapWeeklyBestLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                      color: _boneFaint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: _Sparkline(
                      values: lift.weeklyBests,
                      accent: colors.accentLight,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Sparkline extends StatefulWidget {
  const _Sparkline({required this.values, required this.accent});
  final List<double> values;
  final Color accent;

  @override
  State<_Sparkline> createState() => _SparklineState();
}

class _SparklineState extends State<_Sparkline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        size: const Size(double.infinity, 60),
        painter: _SparkPainter(
          values: widget.values,
          accent: widget.accent,
          progress: _ctrl.value,
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({
    required this.values,
    required this.accent,
    required this.progress,
  });
  final List<double> values;
  final Color accent;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    // Skip leading zeros (no data for those weeks). Use the trailing run.
    final firstNonZero = values.indexWhere((v) => v > 0);
    final plot = firstNonZero < 0
        ? values
        : values.sublist(firstNonZero);
    if (plot.length < 2) return;

    // Forward-fill internal zeros so the line stays within range instead of
    // dropping to the bottom edge. This preserves the single-path animation
    // while making gaps read as flat plateaus.
    final display = List<double>.filled(plot.length, 0);
    double? lastNonZero;
    for (var i = 0; i < plot.length; i++) {
      if (plot[i] > 0) {
        lastNonZero = plot[i];
        display[i] = plot[i];
      } else if (lastNonZero != null) {
        display[i] = lastNonZero;
      } else {
        display[i] = 0;
      }
    }

    final maxV = display.reduce(math.max);
    final minV = display.reduce(math.min);
    final span = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    const pad = 8.0;
    final usableHeight = size.height - pad * 2;

    final points = <Offset>[];
    for (var i = 0; i < display.length; i++) {
      final x = (i / (display.length - 1)) * size.width;
      final y = size.height - ((display[i] - minV) / span) * usableHeight - pad;
      points.add(Offset(x, y));
    }

    // Area under curve.
    final areaPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath
      ..lineTo(points.last.dx, size.height)
      ..close();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withValues(alpha: 0.4 * progress),
          accent.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    // Line, animated via trim.
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    final metric = linePath.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);
    final linePaint = Paint()
      ..color = accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(drawn, linePaint);

    // Dots — each appears once the line passes its position.
    // Only draw dots for the *real* non-zero original values.
    final dotPaint = Paint()..color = Colors.white;
    for (var i = 0; i < plot.length; i++) {
      if (plot[i] <= 0) continue;
      final showAt = i / (plot.length - 1);
      if (progress < showAt) continue;
      final localT = ((progress - showAt) / 0.15).clamp(0.0, 1.0);
      canvas.drawCircle(points[i], 3 * localT, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) {
    return old.progress != progress ||
        old.accent != accent ||
        old.values != values;
  }
}

class MuscleBalanceSlide extends StatelessWidget {
  const MuscleBalanceSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  static const _displayOrder = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final total = recap.volumeByMuscle.values.fold<double>(0, (s, v) => s + v);
    final ordered = _displayOrder
        .map((m) => (
              name: _localizedMuscle(context, m),
              pct: total > 0
                  ? ((recap.volumeByMuscle[m] ?? 0) / total) * 100
                  : 0.0,
            ))
        .toList()
      ..sort((a, b) => b.pct.compareTo(a.pct));
    final top = ordered.first;

    return _SlideShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(l10n.recapMuscleBalanceEyebrow),
          const SizedBox(height: 14),
          _GradientText(
            top.name,
            fontSize: 78,
            letterSpacing: -0.04,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.recapMuscleTopBody(top.pct.round()),
            style: const TextStyle(fontSize: 16, color: _boneSecondary),
          ),
          const SizedBox(height: 28),
          ...List.generate(ordered.length, (i) {
            final m = ordered[i];
            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
              child: _MuscleRow(
                name: m.name,
                pct: m.pct,
                isTop: i == 0,
                delay: Duration(milliseconds: 600 + i * 100),
                accentLight: colors.accentLight,
                accent: colors.accent,
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _localizedMuscle(BuildContext context, String key) {
    // Reuse the existing muscle localisation, but Legs/Arms are aggregates
    // not in the per-muscle map.
    if (key == 'Legs' || key == 'Arms' || key == 'Core') {
      final dummy = Exercise(id: '', name: '', muscle: key, equipment: '');
      return dummy.getLocalizedMuscle(context);
    }
    final dummy = Exercise(id: '', name: '', muscle: key, equipment: '');
    return dummy.getLocalizedMuscle(context);
  }
}

class _MuscleRow extends StatelessWidget {
  const _MuscleRow({
    required this.name,
    required this.pct,
    required this.isTop,
    required this.delay,
    required this.accentLight,
    required this.accent,
  });
  final String name;
  final double pct;
  final bool isTop;
  final Duration delay;
  final Color accentLight;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final fill = (pct / 100).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isTop ? _bone : _boneSecondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 10,
              color: Colors.white.withValues(alpha: 0.06),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fill),
                duration: const Duration(milliseconds: 900),
                curve: Interval(
                  delay.inMilliseconds / (delay.inMilliseconds + 900),
                  1,
                  curve: Curves.easeOutCubic,
                ),
                builder: (context, t, _) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: t,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: LinearGradient(
                            colors: isTop
                                ? [accentLight, accent]
                                : [
                                    accent.withValues(alpha: 0.5),
                                    accent.withValues(alpha: 0.7),
                                  ],
                          ),
                          boxShadow: isTop
                              ? [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.45),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          child: Text(
            '${pct.round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _boneSecondary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class OutroSlide extends StatelessWidget {
  const OutroSlide({super.key, required this.recap, required this.onClose});
  final MonthlyRecap recap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final monthLabel = FormatUtils.monthYear(
      '${recap.year.toString().padLeft(4, '0')}-${recap.month.toString().padLeft(2, '0')}-01',
    );
    final hours = (recap.totalDurationMin / 60).toStringAsFixed(1);

    return _SlideShell(
      centerHorizontally: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Eyebrow(l10n.recapOutroEyebrow(monthLabel)),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SummaryStat(value: recap.sessionsCount.toString(), label: l10n.recapStatSessions),
              const SizedBox(width: 12),
              _SummaryStat(value: hours, label: l10n.recapStatHours),
              const SizedBox(width: 12),
              _SummaryStat(
                value: recap.newPRsCount.toString(),
                label: l10n.recapStatNewPRs,
                accent: true,
              ),
            ],
          ),
          const SizedBox(height: 36),
          _GradientText(
            l10n.recapOutroHeadline,
            fontSize: 40,
            letterSpacing: -0.04,
            height: 1.05,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.recapOutroFooter(monthLabel),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: _boneSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
          _OutroCta(label: l10n.recapOutroCta, onTap: onClose),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    this.accent = false,
  });
  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: accent
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.accent.withValues(alpha: 0.25),
                  colors.accent.withValues(alpha: 0.10),
                ],
              )
            : null,
        color: accent ? null : Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: accent
              ? colors.accentLight.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: accent ? _pillText : _bone,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
              color: _boneMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutroCta extends StatelessWidget {
  const _OutroCta({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.accentLight, colors.accent],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.accentDeep.withValues(alpha: 0.5),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.15,
            ),
          ),
        ),
      ),
    );
  }
}
