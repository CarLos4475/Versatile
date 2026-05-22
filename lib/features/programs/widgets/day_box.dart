import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/motion.dart';

class DayBox extends StatelessWidget {
  final String dayLabel;
  final String? routineLabel;
  final Color? routineColor;
  final bool isRest;
  final VoidCallback onTap;
  final String restShortLabel;

  const DayBox({
    super.key,
    required this.dayLabel,
    required this.routineLabel,
    required this.routineColor,
    required this.isRest,
    required this.onTap,
    required this.restShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayLabel,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.18,
            color: colors.ink500,
          ),
        ),
        const SizedBox(height: 6),
        PressableScale(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 0.78,
            child: Container(
              decoration: BoxDecoration(
                color: isRest ? Colors.transparent : routineColor,
                border: Border.all(
                  color: isRest
                      ? colors.hairline
                      : routineColor!.withValues(alpha: 0.85),
                  width: 0.6,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: isRest
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bedtime_outlined,
                            size: 14,
                            color: colors.ink400,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            restShortLabel,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.18,
                              color: colors.ink400,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            routineLabel!.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            routineLabel!.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.18,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
