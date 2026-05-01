import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/session.dart';
import '../../../shared/widgets/glass_container.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
  });

  final Session session;
  final VoidCallback onTap;

  Color get _accentColor => Color(session.colorValue);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            const SizedBox(width: 14),
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink900,
                            letterSpacing: -0.15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        FormatUtils.date(session.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.ink400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 13, color: AppColors.ink500),
                      const SizedBox(width: 4),
                      Text(
                        FormatUtils.duration(session.durationMin),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.ink500),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.fitness_center,
                          size: 13, color: AppColors.ink500),
                      const SizedBox(width: 4),
                      Text(
                        FormatUtils.volume(session.volumeKg),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.ink500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,
                size: 16, color: AppColors.ink900.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
