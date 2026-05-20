import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_utils.dart';
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
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: colors.ink500,
          ),
        ),
        const SizedBox(height: 4),
        PressableScale(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 0.75,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: isRest ? null : cellGradient(routineColor!),
                color: isRest
                    ? colors.ink900.withValues(alpha: 0.04)
                    : null,
                border: isRest
                    ? Border.all(
                        color: colors.hairline.withValues(alpha: 0.4),
                        width: 0.5,
                      )
                    : null,
                boxShadow: isRest
                    ? null
                    : [
                        BoxShadow(
                          color: routineColor!.withValues(alpha: 0.32),
                          blurRadius: 18,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: darkenColor(routineColor!, 0.22)
                              .withValues(alpha: 0.55),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (!isRest) const Positioned.fill(child: glossyOverlay),
                  if (!isRest)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  Padding(
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
                              const SizedBox(height: 2),
                              Text(
                                restShortLabel,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                routineLabel!.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color:
                                      Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
