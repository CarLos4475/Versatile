import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/entities/routine.dart';
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
    final programColor = Color(program.colorValue);
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
      return WeekStripCell.label(label: label, color: programColor);
    });

    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.bgFrame,
          border: Border.all(color: colors.hairline, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 3, color: programColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: programColor),
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.ink900,
                                    letterSpacing: -0.18,
                                  ),
                                ),
                                const SizedBox(height: 2),
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
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(color: colors.accent),
                            child: Text(
                              activeBadgeLabel.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 0.5, color: colors.hairline),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: WeekStrip(
                cells: cells,
                todayIndex: todayWeekday - 1,
                variant: WeekStripVariant.compact,
                dayLabels: const ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
              ),
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
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          border: Border.all(color: colors.hairline, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: colors.accent),
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
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.ink900,
                      letterSpacing: -0.18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: colors.ink500),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: colors.ink900.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
