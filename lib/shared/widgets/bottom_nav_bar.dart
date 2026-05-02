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
          color: const Color(0x9EFFFCF7),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xA6FFFFFF), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3C2814).withOpacity(0.14),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
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
                    color: isActive
                        ? AppColors.accentDeep.withOpacity(0.72)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: 28,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.bone50
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedScale(
                        scale: isActive ? 1.08 : 1,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: isActive
                              ? AppColors.bone50
                              : AppColors.ink900.withOpacity(0.45),
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isActive
                              ? AppColors.bone50
                              : AppColors.ink900.withOpacity(0.45),
                          letterSpacing: 0.01,
                        ),
                        child: Text(item.label),
                      ),
                      const SizedBox(height: 4),
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
