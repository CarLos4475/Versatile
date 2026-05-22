import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/motion.dart';

class ProfileHero extends StatelessWidget {
  final String name;
  final int? sessionCount;
  final int? totalHours;
  final int? prCount;
  final VoidCallback onEdit;
  final String profileLabel;
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
    required this.profileLabel,
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
    final showStats =
        sessionCount != null && totalHours != null && prCount != null;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgFrame,
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InitialBlock(initial: initial),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profileLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.18,
                            color: colors.ink500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.55,
                                  height: 1.05,
                                  color: colors.ink900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _EditButton(onTap: onEdit),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showStats)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colors.hairline, width: 0.5),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCell(
                        value: sessionCount!.toString(),
                        label: sessionsLabel,
                      ),
                    ),
                    Container(width: 0.5, color: colors.hairline),
                    Expanded(
                      child: _StatCell(
                        value: '${totalHours}h',
                        label: timeLabel,
                      ),
                    ),
                    Container(width: 0.5, color: colors.hairline),
                    Expanded(
                      child: _StatCell(
                        value: prCount!.toString(),
                        label: prsLabel,
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

class _InitialBlock extends StatelessWidget {
  const _InitialBlock({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 92,
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.accent),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -22,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 150,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -9,
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -1.4,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.ink900.withValues(alpha: 0.04),
          border: Border.all(color: colors.hairline, width: 0.6),
        ),
        child: Icon(
          Icons.edit_outlined,
          size: 14,
          color: colors.ink700,
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.18,
              color: colors.ink500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.55,
              height: 1,
              color: colors.ink900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
