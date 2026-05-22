import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/motion.dart';

class RoutineSheetCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final int exerciseCount;
  final String exerciseCountLabel;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const RoutineSheetCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.exerciseCount,
    required this.exerciseCountLabel,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? color : colors.hairline,
            width: selected ? 1.0 : 0.5,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: color),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: color),
                      child: Icon(icon, size: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.ink900,
                          letterSpacing: -0.16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        (subtitle != null && subtitle!.isNotEmpty)
                            ? subtitle!
                            : exerciseCountLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.ink500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? color
                          : colors.hairline,
                      width: selected ? 0 : 1,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
