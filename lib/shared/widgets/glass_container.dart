import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/glass_effect.dart';
import 'motion.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    this.child,
    this.radius = 16.0,
    this.strong = false,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.onTap,
  });

  final Widget? child;
  final double radius;
  final bool strong;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    Widget container = GlassEffect.wrap(
      sigma: strong ? 12 : 8,
      borderRadius: borderRadius,
      child: Container(
        width: width,
        height: height,
        constraints: constraints,
        padding: padding,
        decoration: BoxDecoration(
          color: strong ? context.colors.glassBgStrong : context.colors.glassBg,
          borderRadius: borderRadius,
          border: Border.all(color: context.colors.glassBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3C2814).withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFF3C2814).withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: child,
      ),
    );

    if (margin != null || onTap != null) {
      container = Container(
        margin: margin,
        child: onTap != null
            ? PressableScale(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: container,
              )
            : container,
      );
    }

    return container;
  }
}
