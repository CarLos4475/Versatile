import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'motion.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onBack != null || trailing != null)
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (onBack != null)
                      PressableScale(
                        onTap: onBack,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xA6FFFCF7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.glassBorder,
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF3C2814,
                                ).withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: AppColors.ink700,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (trailing != null)
                      trailing!
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.9,
                color: AppColors.ink900,
                height: 1.05,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.ink500,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
