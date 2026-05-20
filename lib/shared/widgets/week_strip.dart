import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/color_utils.dart';

class WeekStripCell {
  final String? label;
  final Color? color;
  final bool isRest;

  const WeekStripCell.rest() : label = null, color = null, isRest = true;
  const WeekStripCell.routine({required String this.label, required Color this.color})
      : isRest = false;
  const WeekStripCell.label({required String this.label, required Color this.color})
      : isRest = false;
}

class WeekStrip extends StatelessWidget {
  final List<WeekStripCell> cells;
  final int? todayIndex;
  final WeekStripVariant variant;
  final List<String>? dayLabels;

  const WeekStrip({
    super.key,
    required this.cells,
    this.todayIndex,
    this.variant = WeekStripVariant.large,
    this.dayLabels,
  }) : assert(cells.length == 7);

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case WeekStripVariant.large:
        return _buildLarge(context);
      case WeekStripVariant.compact:
        return _buildCompact(context);
      case WeekStripVariant.mini:
        return _buildMini(context);
    }
  }

  Widget _buildLarge(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 6 ? 0 : 6),
            child: _LargeCell(
              cell: cells[i],
              isToday: i == todayIndex,
              dayLabel: dayLabels?[i],
              accent: context.colors.accent,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 6 ? 0 : 4),
            child: AspectRatio(
              aspectRatio: 1,
              child: _CompactCell(
                cell: cells[i],
                isToday: i == todayIndex,
                dayLabel: dayLabels?[i],
                code: dayLabels == null ? null : _codeFor(cells[i]),
                accent: context.colors.accent,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMini(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 6 ? 0 : 3),
            child: SizedBox(
              height: 6,
              child: _MiniCell(cell: cells[i], hairline: context.colors.hairline),
            ),
          ),
        );
      }),
    );
  }

  String _codeFor(WeekStripCell cell) {
    if (cell.isRest) return '·';
    final label = cell.label;
    if (label == null || label.isEmpty) return '·';
    return label.substring(0, 1).toUpperCase();
  }
}

enum WeekStripVariant { large, compact, mini }

class _LargeCell extends StatelessWidget {
  final WeekStripCell cell;
  final bool isToday;
  final String? dayLabel;
  final Color accent;

  const _LargeCell({
    required this.cell,
    required this.isToday,
    required this.dayLabel,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dayLabel != null) ...[
          Text(
            dayLabel!,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: isToday
                  ? lightenColor(accent, 0.20)
                  : context.colors.ink500,
            ),
          ),
          const SizedBox(height: 4),
        ],
        AspectRatio(
          aspectRatio: 1,
          child: _GlossyCell(
            cell: cell,
            radius: 12,
            isToday: isToday,
            todayAccent: accent,
            centerChild: cell.isRest
                ? Icon(
                    Icons.bedtime_outlined,
                    size: 14,
                    color: context.colors.ink400,
                  )
                : Text(
                    cell.label!.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _GlossyCell extends StatelessWidget {
  final WeekStripCell cell;
  final double radius;
  final bool isToday;
  final Color todayAccent;
  final Widget centerChild;

  const _GlossyCell({
    required this.cell,
    required this.radius,
    required this.isToday,
    required this.todayAccent,
    required this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    final isRest = cell.isRest;
    final base = cell.color;
    final r = radius + 2;
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        gradient: isRest ? null : cellGradient(base!),
        color: isRest ? colors.ink900.withValues(alpha: 0.06) : null,
        borderRadius: BorderRadius.circular(r),
        border: isRest
            ? Border.all(
                color: colors.hairline,
                width: 0.5,
              )
            : null,
      ),
      foregroundDecoration: isToday
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(r),
              border: Border.all(
                color: todayAccent.withValues(alpha: 0.7),
                width: 2,
              ),
            )
          : null,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
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
          Center(child: centerChild),
        ],
      ),
    );
  }
}

class _CompactCell extends StatelessWidget {
  final WeekStripCell cell;
  final bool isToday;
  final String? dayLabel;
  final String? code;
  final Color accent;

  const _CompactCell({
    required this.cell,
    required this.isToday,
    required this.dayLabel,
    required this.code,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return _GlossyCell(
      cell: cell,
      radius: 12,
      isToday: isToday,
      todayAccent: accent,
      centerChild: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dayLabel != null)
            Text(
              dayLabel!,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: cell.isRest
                    ? context.colors.ink400
                    : Colors.white.withValues(alpha: 0.80),
              ),
            ),
          Text(
            code ?? '',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cell.isRest
                  ? context.colors.ink500
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCell extends StatelessWidget {
  final WeekStripCell cell;
  final Color hairline;

  const _MiniCell({required this.cell, required this.hairline});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: cell.isRest
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lightenColor(cell.color!, 0.05),
                  darkenColor(cell.color!, 0.10),
                ],
              ),
        color: cell.isRest ? context.colors.ink900.withValues(alpha: 0.08) : null,
      ),
    );
  }
}
