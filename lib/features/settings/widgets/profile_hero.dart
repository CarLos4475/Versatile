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

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.glassBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.glassBorder, width: 0.5),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 168),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OrangeBand(initial: initial),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    profileLabel.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: colors.accentDeep,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.6,
                                      height: 1.1,
                                      color: colors.ink900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            _EditButton(onTap: onEdit),
                          ],
                        ),
                        if (showStats) ...[
                          const Spacer(),
                          const SizedBox(height: 12),
                          _StatTriplet(
                            sessions: sessionCount!.toString(),
                            time: '${totalHours}h',
                            prs: prCount!.toString(),
                            sessionsLabel: sessionsLabel,
                            timeLabel: timeLabel,
                            prsLabel: prsLabel,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrangeBand extends StatelessWidget {
  const _OrangeBand({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 108,
      child: ClipRect(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(0.34, -1),
              end: const Alignment(-0.34, 1),
              colors: [colors.accentLight, colors.accent, colors.accentDeep],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.40],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -20,
                left: -16,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 160,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -9.6,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1.68,
                    color: Colors.white,
                    height: 1,
                    shadows: [
                      Shadow(
                        color: Color(0x38000000),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: colors.ink900.withValues(alpha: 0.05),
          border: Border.all(
            color: colors.ink900.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.edit_outlined,
          size: 13,
          color: colors.ink500,
        ),
      ),
    );
  }
}

class _StatTriplet extends StatelessWidget {
  const _StatTriplet({
    required this.sessions,
    required this.time,
    required this.prs,
    required this.sessionsLabel,
    required this.timeLabel,
    required this.prsLabel,
  });

  final String sessions;
  final String time;
  final String prs;
  final String sessionsLabel;
  final String timeLabel;
  final String prsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final divider = colors.hairline.withValues(alpha: 0.5);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: divider, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatCell(value: sessions, label: sessionsLabel),
            ),
            Container(width: 0.5, height: 36, color: divider),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _StatCell(value: time, label: timeLabel),
              ),
            ),
            Container(width: 0.5, height: 36, color: divider),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _StatCell(value: prs, label: prsLabel),
              ),
            ),
          ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.55,
            height: 1,
            color: colors.ink900,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.14,
            color: colors.ink500,
          ),
        ),
      ],
    );
  }
}
