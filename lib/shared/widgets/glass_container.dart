import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
    Widget container = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: width,
          height: height,
          constraints: constraints,
          padding: padding,
          decoration: BoxDecoration(
            color: strong ? AppColors.glassBgStrong : AppColors.glassBg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 0.5,
            ),
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
      ),
    );

    if (margin != null || onTap != null) {
      container = Container(
        margin: margin,
        child: onTap != null
            ? GestureDetector(onTap: onTap, child: container)
            : container,
      );
    }

    return container;
  }
}
