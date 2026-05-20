import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/color_utils.dart';

class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;

  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 44,
    this.height = 26,
  });

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accent;
    final thumbSize = height - 4;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: value
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [lightenColor(accent, 0.04), darkenColor(accent, 0.10)],
                )
              : null,
          color: value ? null : context.colors.ink400.withValues(alpha: 0.22),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: darkenColor(accent, 0.10).withValues(alpha: 0.40),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              top: 2,
              left: value ? width - thumbSize - 2 : 2,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4D000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
