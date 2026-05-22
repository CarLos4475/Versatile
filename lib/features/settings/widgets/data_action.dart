import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/motion.dart';

class DataAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback? onTap;

  const DataAction({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        color: colors.bgFrame,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.ink900.withValues(alpha: 0.04),
                border: Border.all(color: colors.hairline, width: 0.6),
              ),
              child: Icon(icon, size: 16, color: colors.ink700),
            ),
            const SizedBox(height: 12),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.18,
                color: colors.ink500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 12,
                color: colors.ink700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DestructiveDataAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback? onTap;

  const DestructiveDataAction({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const danger = Color(0xFFD93B3B);
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: danger.withValues(alpha: 0.35),
            width: 0.6,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: danger.withValues(alpha: 0.10),
                border: Border.all(
                  color: danger.withValues(alpha: 0.35),
                  width: 0.6,
                ),
              ),
              child: Icon(icon, size: 16, color: danger),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.18,
                      color: danger,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sublabel,
                    style: TextStyle(fontSize: 11, color: colors.ink500),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: danger.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
