import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.accent = false,
  });

  final String label;
  final String value;
  final String unit;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: GlassContainer(
        radius: 18,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                color: context.colors.ink400,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.02,
              ),
            ),
            SizedBox(height: 2),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.14),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Row(
                key: ValueKey('$value-$unit-$accent'),
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.48,
                      color: accent ? context.colors.accentDeep : context.colors.ink900,
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.ink400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
