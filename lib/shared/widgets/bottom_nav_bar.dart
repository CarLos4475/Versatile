import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class VersatileBottomNav extends StatelessWidget {
  const VersatileBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const _items = [
    (icon: Icons.home_rounded,     label: 'Home'),
    (icon: Icons.list_rounded,     label: 'Routines'),
    (icon: Icons.fitness_center,   label: 'Exercises'),
    (icon: Icons.history_rounded,  label: 'History'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
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
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          if (isActive)
                            Positioned(
                              top: 0,
                              child: Container(
                                width: 28,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Icon(
                              item.icon,
                              size: 22,
                              color: isActive
                                  ? AppColors.accentDeep
                                  : AppColors.ink900.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive
                              ? AppColors.accentDeep
                              : AppColors.ink900.withOpacity(0.45),
                          letterSpacing: 0.01,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
