import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../share/screens/share_session_screen.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  const WorkoutCompleteScreen({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final totalSets =
        session.exercises?.fold<int>(0, (s, e) => s + e.sets.length) ?? 0;
    final totalExercises = session.exercises?.length ?? 0;

    return Scaffold(
      backgroundColor: colors.bgApp,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      colors.accentTint,
                      colors.bgApp.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.accentLight,
                              colors.accent,
                              colors.accentDeep,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.accentDeep.withValues(alpha: 0.35),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: Text(
                      l10n.sessionComplete,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colors.ink900,
                        letterSpacing: -0.6,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 260),
                    child: Text(
                      l10n.greatJob,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.ink500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 360),
                    child: _HeroStatCard(
                      routineName: session.routineName,
                      routineColor: Color(session.colorValue),
                      iconCode: session.iconCode,
                      volumeLabel: FormatUtils.volume(session.volumeKg),
                      volumeCaption: l10n.volumeTotal.toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 460),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.timer_outlined,
                            value: '${session.durationMin}',
                            unit: 'min',
                            label: l10n.duration.toUpperCase(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.repeat_rounded,
                            value: '$totalSets',
                            label: l10n.sets.toUpperCase(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.list_alt_rounded,
                            value: '$totalExercises',
                            label: l10n.exercisesLabel.toUpperCase(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 580),
                    child: Row(
                      children: [
                        PressableScale(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ShareSessionScreen(session: session),
                            ),
                          ),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: colors.glassBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colors.glassBorder,
                                width: 0.5,
                              ),
                              boxShadow: colors.glassShadow,
                            ),
                            child: Tooltip(
                              message: l10n.share,
                              child: Icon(
                                Icons.ios_share_rounded,
                                color: colors.ink900,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GlassButton(
                            label: l10n.backToHome,
                            variant: GlassButtonVariant.primary,
                            size: GlassButtonSize.lg,
                            expand: true,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
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

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({
    required this.routineName,
    required this.routineColor,
    required this.iconCode,
    required this.volumeLabel,
    required this.volumeCaption,
  });

  final String routineName;
  final Color routineColor;
  final int iconCode;
  final String volumeLabel;
  final String volumeCaption;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassContainer(
      strong: true,
      radius: 24,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      routineColor.withValues(alpha: 0.9),
                      routineColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  IconData(iconCode, fontFamily: 'MaterialIcons'),
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  routineName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.ink900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              volumeLabel,
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: colors.ink900,
                letterSpacing: -1.5,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            volumeCaption,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.12,
              color: colors.accentDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    this.unit,
  });

  final IconData icon;
  final String value;
  final String? unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassContainer(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colors.accentDeep),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.ink900,
                      height: 1.0,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.ink500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: colors.ink400,
            ),
          ),
        ],
      ),
    );
  }
}
