import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AnimatedAuroraBackground extends StatefulWidget {
  const AnimatedAuroraBackground({super.key});

  @override
  State<AnimatedAuroraBackground> createState() =>
      _AnimatedAuroraBackgroundState();
}

class _AnimatedAuroraBackgroundState extends State<AnimatedAuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = <Color>[
      colors.accent,
      colors.accentLight,
      colors.accentDeep,
      Color.lerp(colors.accent, colors.ink900, 0.55)!,
    ];
    final base = colors.bgApp;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => CustomPaint(
          painter: _AuroraPainter(
            t: _ctrl.value,
            palette: palette,
            base: base,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({
    required this.t,
    required this.palette,
    required this.base,
  });

  final double t;
  final List<Color> palette;
  final Color base;

  static const _tau = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = base);

    final center = Offset(size.width / 2, size.height / 2);
    // Quarter-turn per cycle — the rotation through the view the user asked for.
    final rotation = t * _tau * 0.25;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final blobRadius = math.max(size.width, size.height) * 0.55;

    for (var i = 0; i < palette.length; i++) {
      final phase = i * math.pi / 2;
      final px = size.width *
          (0.5 + 0.45 * math.sin(t * _tau + phase));
      final py = size.height *
          (0.5 + 0.40 * math.cos(t * _tau * 1.3 + phase));
      final pos = Offset(px, py);

      final mix = 0.5 + 0.5 * math.sin(t * _tau + i * math.pi / 3);
      final blobColor = Color.lerp(
        palette[i],
        palette[(i + 1) % palette.length],
        mix,
      )!
          .withValues(alpha: 0.65);

      final shader = RadialGradient(
        colors: [blobColor, blobColor.withValues(alpha: 0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: blobRadius));

      final paint = Paint()
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

      canvas.drawCircle(pos, blobRadius, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) {
    return old.t != t ||
        old.base != base ||
        !_listEquals(old.palette, palette);
  }

  static bool _listEquals(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
