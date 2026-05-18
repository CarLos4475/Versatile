import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Static dark backdrop for the Stories-style recap. Two soft radial
/// accent glows (top-right + bottom-left) painted over a deep base, plus a
/// faint pixel-grid noise texture for tactile feel. Deliberately not
/// animated — the slides themselves carry all motion.
class RecapBackdrop extends StatelessWidget {
  const RecapBackdrop({super.key});

  static const Color _base = Color(0xFF0E0B07);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: _base),
        // Top-right warm glow.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.6, -0.7),
              radius: 0.85,
              colors: [
                colors.accent.withValues(alpha: 0.35),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        // Bottom-left deeper glow.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.7, 0.9),
              radius: 0.75,
              colors: [
                colors.accentDeep.withValues(alpha: 0.30),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        // Grain noise — painted once, isolated under RepaintBoundary.
        const RepaintBoundary(
          child: CustomPaint(painter: _GrainPainter()),
        ),
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x07FFFFFF); // ~2.5% white
    const step = 3.0;
    for (var y = 0.0; y < size.height; y += step) {
      for (var x = 0.0; x < size.width; x += step) {
        canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
