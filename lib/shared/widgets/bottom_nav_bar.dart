import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/glass_effect.dart';
import 'motion.dart';

class VersatileBottomNav extends StatelessWidget {
  const VersatileBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.list_rounded, label: 'Routines'),
    (icon: Icons.fitness_center, label: 'Exercises'),
    (icon: Icons.history_rounded, label: 'History'),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassEffect.wrap(
      sigma: 10,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.glassBgStrong,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: context.colors.glassBorder, width: 0.5),
          boxShadow: context.colors.glassShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            final isActive = i == currentIndex;
            return Expanded(
              child: PressableScale(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isActive
                              ? context.colors.accent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 6),
                      AnimatedScale(
                        scale: isActive ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: isActive
                              ? context.colors.accent
                              : context.colors.ink400,
                        ),
                      ),
                      SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isActive
                              ? context.colors.accent
                              : context.colors.ink400,
                          letterSpacing: 0.01,
                        ),
                        child: Text(item.label),
                      ),
                      SizedBox(height: 2),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
