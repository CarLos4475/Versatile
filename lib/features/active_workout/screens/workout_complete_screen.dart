import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  const WorkoutCompleteScreen({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgApp,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colors.accentTint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 38,
                      color: colors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 250),
                  child: Text(
                    l10n.congratulations,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: colors.ink900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 350),
                  child: Text(
                    l10n.sessionComplete,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.ink500,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 450),
                  child: GlassContainer(
                    strong: true,
                    radius: 20,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        _StatRow(
                          icon: Icons.fitness_center_rounded,
                          label: l10n.startThisWorkout,
                          value: session.routineName,
                          colors: colors,
                        ),
                        const Divider(height: 24, color: Color(0x0D000000)),
                        _StatRow(
                          icon: Icons.timer_outlined,
                          label: l10n.duration,
                          value: '${session.durationMin} min',
                          colors: colors,
                        ),
                        const Divider(height: 24, color: Color(0x0D000000)),
                        _StatRow(
                          icon: Icons.monitor_weight_outlined,
                          label: l10n.volumeTotal,
                          value: FormatUtils.volume(session.volumeKg),
                          colors: colors,
                        ),
                        const Divider(height: 24, color: Color(0x0D000000)),
                        _StatRow(
                          icon: Icons.repeat_rounded,
                          label: l10n.sets,
                          value: session.exercises
                              ?.fold(0, (s, e) => s + e.sets.length)
                              .toString() ?? '0',
                          colors: colors,
                        ),
                        const Divider(height: 24, color: Color(0x0D000000)),
                        _StatRow(
                          icon: Icons.list_alt_rounded,
                          label: l10n.exercisesPerformed,
                          value: (session.exercises?.length ?? 0).toString(),
                          colors: colors,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 650),
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
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.accentTint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colors.accentDeep),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.ink500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.ink900,
          ),
        ),
      ],
    );
  }
}
