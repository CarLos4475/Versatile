import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../l10n/app_localizations.dart';
import '../view_models/active_workout_view_model.dart';

/// Top-anchored celebration banner that surfaces when [finishSet] detects a
/// new PR. Listens to [ActiveWorkoutState.lastPREvent] and re-plays the
/// animation each time the `eventId` changes — even when the same exercise
/// hits another PR in the same session.
class PRCelebrationBanner extends ConsumerStatefulWidget {
  const PRCelebrationBanner({super.key, required this.routineId});
  final String routineId;

  @override
  ConsumerState<PRCelebrationBanner> createState() =>
      _PRCelebrationBannerState();
}

class _PRCelebrationBannerState extends ConsumerState<PRCelebrationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  RecapPersonalRecord? _currentPR;
  int _lastSeenEventId = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PREvent?>(
      activeWorkoutProvider(widget.routineId).select((s) => s.lastPREvent),
      (prev, next) {
        if (next == null) return;
        if (next.eventId == _lastSeenEventId) return;
        _lastSeenEventId = next.eventId;
        setState(() => _currentPR = next.pr);
        _ctrl.forward(from: 0);
      },
    );

    final pr = _currentPR;
    if (pr == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          // Scale-in (0→0.18) with elastic-style overshoot, hold, fade-out (0.78→1.0).
          double scale;
          double opacity;
          if (t < 0.18) {
            final p = t / 0.18;
            // Ease-out scale from 0.7 to 1.0 with a slight overshoot.
            scale = 0.7 + 0.35 * Curves.easeOutBack.transform(p);
            opacity = p;
          } else if (t < 0.78) {
            scale = 1.0;
            opacity = 1.0;
          } else {
            final p = (t - 0.78) / 0.22;
            scale = 1.0 - 0.05 * p;
            opacity = (1 - p).clamp(0.0, 1.0);
          }

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: _PRBadgeWithSparkles(progress: t, pr: pr),
            ),
          );
        },
      ),
    );
  }
}

class _PRBadgeWithSparkles extends StatelessWidget {
  const _PRBadgeWithSparkles({required this.progress, required this.pr});
  final double progress;
  final RecapPersonalRecord pr;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _SparklesPainter(
              progress: progress,
              color: colors.accentLight,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.accentLight, colors.accent, colors.accentDeep],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.accentDeep.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recapPRTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pr.exerciseName} · ${FormatUtils.weight(pr.weightKg)} kg × ${pr.reps}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Lightweight, packageless confetti: 8 small circles emanating radially from
/// the badge centre while fading out. Driven by the same controller so the
/// timing is locked to the badge animation.
class _SparklesPainter extends CustomPainter {
  _SparklesPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  static const _count = 8;
  static const _seedAngles = [
    -math.pi / 2,
    -math.pi / 2 + math.pi / 4,
    0.0,
    math.pi / 4,
    math.pi / 2,
    math.pi - math.pi / 4,
    math.pi,
    -math.pi + math.pi / 4,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Particles only show during scale-in + hold. After 0.7 they're gone.
    if (progress >= 0.7) return;
    final localT = (progress / 0.7).clamp(0.0, 1.0);
    final eased = Curves.easeOutCubic.transform(localT);

    final centre = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.55;

    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _count; i++) {
      final angle = _seedAngles[i];
      final dist = eased * maxRadius * (0.85 + (i % 3) * 0.08);
      final pos = centre + Offset(math.cos(angle) * dist, math.sin(angle) * dist);
      final alpha = (1.0 - localT).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: alpha * 0.95);
      final r = 3.5 * (1.0 - localT * 0.4);
      canvas.drawCircle(pos, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter old) {
    return old.progress != progress || old.color != color;
  }
}
