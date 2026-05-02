import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/glass_effect.dart';
import 'motion.dart';

class VersatileChip extends StatelessWidget {
  const VersatileChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: GlassEffect.wrap(
        sigma: 6,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isActive
                ? context.colors.accent.withValues(alpha: 0.08)
                : context.colors.glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? context.colors.accent
                  : context.colors.glassBorder,
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? context.colors.accent : context.colors.ink700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
