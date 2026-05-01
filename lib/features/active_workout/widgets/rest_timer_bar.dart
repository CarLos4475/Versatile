import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_effect.dart';
import '../../../core/utils/format_utils.dart';
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
    return GlassEffect.wrap(
        sigma: 10,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xEB281E16), Color(0xF51C1610)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              _CircularProgress(progress: restTimer.progress),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REST',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0x99FFFFFF),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.04,
                      ),
                    ),
                    Text(
                      FormatUtils.timer(restTimer.remaining),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: -0.48,
                        height: 1.1,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _ActionBtn(
                    label: '+15s',
                    onTap: onAddTime,
                    transparent: true,
                  ),
                  const SizedBox(width: 6),
                  _ActionBtn(label: 'Skip', onTap: onSkip, transparent: false),
                ],
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
    const size = 44.0;
    const stroke = 3.0;
    const radius = (size - stroke) / 2;
    final circumference = 2 * pi * radius;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          circumference: circumference,
          radius: radius,
          stroke: stroke,
        ),
        child: const Center(
          child: Icon(
            Icons.timer_outlined,
            size: 16,
            color: AppColors.accentSoft,
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
  });

  final double progress;
  final double circumference;
  final double radius;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final progressPaint = Paint()
      ..color = AppColors.accentSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.onTap,
    required this.transparent,
  });

  final String label;
  final VoidCallback onTap;
  final bool transparent;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: transparent
              ? Colors.white.withOpacity(0.1)
              : AppColors.accent.withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
