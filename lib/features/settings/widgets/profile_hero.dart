import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';

class ProfileHero extends StatelessWidget {
  final String name;
  final int? sessionCount;
  final int? totalHours;
  final int? prCount;
  final VoidCallback onEdit;
  final String sessionsLabel;
  final String timeLabel;
  final String prsLabel;

  const ProfileHero({
    super.key,
    required this.name,
    required this.sessionCount,
    required this.totalHours,
    required this.prCount,
    required this.onEdit,
    required this.sessionsLabel,
    required this.timeLabel,
    required this.prsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = name.trim().isEmpty
        ? '·'
        : name.trim().substring(0, 1).toUpperCase();

    return GlassContainer(
      radius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: colors.accent,
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: colors.ink900,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PressableScale(
                onTap: onEdit,
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: colors.ink900.withValues(alpha: 0.08),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: colors.ink700,
                  ),
                ),
              ),
            ],
          ),
          if (sessionCount != null && totalHours != null && prCount != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colors.hairline.withValues(alpha: 0.4),
                      width: 0.5,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(top: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCell(
                        value: sessionCount.toString(),
                        label: sessionsLabel,
                        leading: false,
                      ),
                    ),
                    Expanded(
                      child: _StatCell(
                        value: '${totalHours}h',
                        label: timeLabel,
                        leading: true,
                      ),
                    ),
                    Expanded(
                      child: _StatCell(
                        value: prCount.toString(),
                        label: prsLabel,
                        leading: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final bool leading;

  const _StatCell({
    required this.value,
    required this.label,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.only(left: leading ? 12 : 0),
      decoration: leading
          ? BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: colors.hairline.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colors.ink900,
              letterSpacing: -0.36,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: colors.ink500,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
