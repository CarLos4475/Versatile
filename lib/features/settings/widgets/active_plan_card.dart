import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/week_strip.dart';

class ActivePlanCard extends StatelessWidget {
  final Program program;
  final int currentWeekIndex;
  final int todayWeekday;
  final List<Routine> routines;
  final VoidCallback onTap;
  final String activeBadgeLabel;
  final String weekProgressLabel;

  const ActivePlanCard({
    super.key,
    required this.program,
    required this.currentWeekIndex,
    required this.todayWeekday,
    required this.routines,
    required this.onTap,
    required this.activeBadgeLabel,
    required this.weekProgressLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final routinesById = {for (final r in routines) r.id: r};
    final cells = List<WeekStripCell>.generate(7, (i) {
      final weekday = i + 1;
      final slot = program.slotAt(currentWeekIndex, weekday);
      if (slot == null) return const WeekStripCell.rest();
      if (slot.kind == SlotKind.routine) {
        final r = routinesById[slot.routineId];
        if (r == null) return const WeekStripCell.rest();
        return WeekStripCell.routine(label: r.name, color: Color(r.colorValue));
      }
      final label = slot.labelText ?? '';
      if (label.isEmpty || label.toLowerCase() == 'rest') {
        return const WeekStripCell.rest();
      }
      return WeekStripCell.label(
        label: label,
        color: Color(program.colorValue),
      );
    });

    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        radius: 16,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(program.colorValue),
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.ink900,
                          letterSpacing: -0.18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        weekProgressLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.ink500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accentTint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    activeBadgeLabel,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: colors.accentDeep,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            WeekStrip(
              cells: cells,
              todayIndex: todayWeekday - 1,
              variant: WeekStripVariant.compact,
              dayLabels: const ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivePlanCardEmpty extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subtitle;

  const ActivePlanCardEmpty({
    super.key,
    required this.onTap,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        radius: 16,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colors.accentTint,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: colors.accentDeep,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.ink900,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: colors.ink500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: colors.ink300),
          ],
        ),
      ),
    );
  }
}
