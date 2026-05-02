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
    this.accentBack = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool accentBack;

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
                            gradient: accentBack
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFE08866),
                                      Color(0xFFD97757),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                : null,
                            color: accentBack ? null : context.colors.glassBg,
                            borderRadius: BorderRadius.circular(12),
                            border: accentBack
                                ? null
                                : Border.all(
                                    color: context.colors.glassBorder,
                                    width: 0.5,
                                  ),
                            boxShadow: accentBack
                                ? [
                                    BoxShadow(
                                      color: context.colors.accentDeep
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : context.colors.glassShadow,
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: accentBack
                                ? Colors.white
                                : context.colors.ink700,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      SizedBox.shrink(),
                    if (trailing != null)
                      trailing!
                    else
                      SizedBox.shrink(),
                  ],
                ),
              ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.9,
                color: context.colors.ink900,
                height: 1.05,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.ink500,
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
