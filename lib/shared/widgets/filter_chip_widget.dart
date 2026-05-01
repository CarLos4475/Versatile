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
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0x2ED97757), Color(0x14D97757)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: isActive ? null : const Color(0x8DFFFCF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? AppColors.accent.withOpacity(0.4)
                  : const Color(0x99FFFFFF),
              width: 0.5,
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
                  color: isActive ? AppColors.accentDeep : AppColors.ink700,
                  letterSpacing: -0.005,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
