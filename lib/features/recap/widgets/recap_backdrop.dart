import 'package:flutter/material.dart';

/// Editorial bone backdrop for the recap — like reading a printed magazine.
/// Fixed bone color (not theme-aware) so each page reads as paper regardless
/// of the user's theme. A faint pixel-grid texture adds tactile paper feel.
class RecapBackdrop extends StatelessWidget {
  const RecapBackdrop({super.key});

  static const Color paperBg = Color(0xFFEBE3D2);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: const [
        DecoratedBox(decoration: BoxDecoration(color: paperBg)),
        // Subtle paper grain — painted once, isolated under RepaintBoundary.
        RepaintBoundary(
          child: CustomPaint(painter: _PaperGrainPainter()),
        ),
      ],
    );
  }
}

class _PaperGrainPainter extends CustomPainter {
  const _PaperGrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Two-tone grain: very faint dark specks for paper fiber feel.
    final dark = Paint()..color = const Color(0x0A1A1A1F); // ~4% ink
    const step = 4.0;
    for (var y = 0.0; y < size.height; y += step) {
      for (var x = (y / step).floor().isEven ? 0.0 : step / 2;
          x < size.width;
          x += step) {
        canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), dark);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
