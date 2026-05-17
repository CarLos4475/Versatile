import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MonthHeatmap extends StatelessWidget {
  const MonthHeatmap({
    super.key,
    required this.year,
    required this.month,
    required this.workoutDays,
    this.cellSize = 22,
    this.cellGap = 4,
  });

  final int year;
  final int month;
  final Set<String> workoutDays;
  final double cellSize;
  final double cellGap;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  String _fmt(int y, int m, int d) =>
      '${y.toString().padLeft(4, '0')}-'
      '${m.toString().padLeft(2, '0')}-'
      '${d.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final firstOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final weekStart =
        firstOfMonth.subtract(Duration(days: firstOfMonth.weekday - 1));
    final lastOfMonth = DateTime(year, month, daysInMonth);
    final lastWeekStart =
        lastOfMonth.subtract(Duration(days: lastOfMonth.weekday - 1));
    final numWeeks =
        (lastWeekStart.difference(weekStart).inDays / 7).round() + 1;

    final slot = cellSize + cellGap;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _dayLabels.map((label) {
            return SizedBox(
              width: slot,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: colors.ink400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate(numWeeks, (w) {
          final monday = weekStart.add(Duration(days: 7 * w));
          return Padding(
            padding: EdgeInsets.only(bottom: w < numWeeks - 1 ? cellGap : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (d) {
                final day = monday.add(Duration(days: d));
                final inMonth = day.month == month && day.year == year;
                final dateKey = _fmt(day.year, day.month, day.day);
                final trained = inMonth && workoutDays.contains(dateKey);
                return Padding(
                  padding: EdgeInsets.only(right: d < 6 ? cellGap : 0),
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      gradient: trained
                          ? LinearGradient(
                              colors: [colors.accentLight, colors.accentDeep],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: trained
                          ? null
                          : inMonth
                              ? colors.glassBg
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: !trained && inMonth
                          ? Border.all(color: colors.hairline, width: 0.5)
                          : null,
                      boxShadow: trained
                          ? [
                              BoxShadow(
                                color: colors.accentDeep.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}
