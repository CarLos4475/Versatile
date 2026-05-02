import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/session.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session, required this.onTap});

  final Session session;
  final VoidCallback onTap;

  Color get _accentColor => Color(session.colorValue);

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: GlassContainer(
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          session.routineName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.colors.ink900,
                            letterSpacing: -0.15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        FormatUtils.date(session.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.ink400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: context.colors.ink500,
                      ),
                      SizedBox(width: 4),
                      Text(
                        FormatUtils.duration(session.durationMin),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.ink500,
                        ),
                      ),
                      SizedBox(width: 14),
                      Icon(
                        Icons.fitness_center,
                        size: 13,
                        color: context.colors.ink500,
                      ),
                      SizedBox(width: 4),
                      Text(
                        FormatUtils.volume(session.volumeKg),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.ink500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: context.colors.ink900.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
