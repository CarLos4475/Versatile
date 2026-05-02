import 'package:flutter/material.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../view_models/active_workout_view_model.dart';

class RestTimerBar extends StatelessWidget {
  const RestTimerBar({
    super.key,
    required this.restTimer,
    required this.onSkip,
    required this.onAddTime,
  });

  final RestTimerState restTimer;
  final VoidCallback onSkip;
  final VoidCallback onAddTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FadeSlideIn(
      offset: const Offset(0, 0.1),
      child: GlassContainer(
        radius: 24,
        strong: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _CircularProgress(progress: restTimer.progress),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${FormatUtils.timer(restTimer.remaining)} ${l10n.rest}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.ink900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    restTimer.exerciseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: context.colors.ink500),
                  ),
                ],
              ),
            ),
            PressableScale(
              onTap: onAddTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.accentTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+15s',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.colors.accentDeep,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PressableScale(
              onTap: onSkip,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.fieldBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.skip,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.ink700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  const _CircularProgress({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    const double size = 38;
    const double stroke = 3;
    const double radius = (size - stroke) / 2;
    const double circumference = 2 * 3.14159 * radius;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          circumference: circumference,
          radius: radius,
          stroke: stroke,
          color: context.colors.accentSoft,
        ),
        child: Center(
          child: Icon(
            Icons.timer_outlined,
            size: 16,
            color: context.colors.accentSoft,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.circumference,
    required this.radius,
    required this.stroke,
    required this.color,
  });

  final double progress;
  final double circumference;
  final double radius;
  final double stroke;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
