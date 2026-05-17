import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/exercise_category.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/motion.dart';
import 'month_heatmap.dart';

class _SlideShell extends StatelessWidget {
  const _SlideShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 92, 28, 96),
        child: child,
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.18,
        color: context.colors.accentDeep,
      ),
    );
  }
}

class _BigNumber extends StatelessWidget {
  const _BigNumber(this.value);
  final String value;
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 80,
          fontWeight: FontWeight.w800,
          letterSpacing: -2.4,
          height: 0.95,
          color: context.colors.ink900,
        ),
      ),
    );
  }
}

class IntroSlide extends StatelessWidget {
  const IntroSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final monthLabel = FormatUtils.monthYear(
      '${recap.year.toString().padLeft(4, '0')}-${recap.month.toString().padLeft(2, '0')}-01',
    );

    return _SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: Container(
              width: 84,
              height: 84,
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
                    color: colors.accentDeep.withValues(alpha: 0.4),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 28),
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: _Eyebrow(l10n.recapTitle),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 340),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                monthLabel,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.8,
                  height: 1.0,
                  color: colors.ink900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            delay: const Duration(milliseconds: 460),
            child: Text(
              l10n.recapIntroSubtitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: colors.ink500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SessionsSlide extends StatelessWidget {
  const SessionsSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return _SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: _Eyebrow(l10n.recapSessionsTitle),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: _BigNumber('${recap.sessionsCount}'),
          ),
          const SizedBox(height: 4),
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: Text(
              l10n.recapSessionsBody(recap.sessionsCount),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.ink700,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 36),
          FadeSlideIn(
            delay: const Duration(milliseconds: 460),
            child: Center(
              child: MonthHeatmap(
                year: recap.year,
                month: recap.month,
                workoutDays: recap.workoutDays,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VolumeSlide extends StatelessWidget {
  const VolumeSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final delta = recap.volumeDeltaPctVsPrev;
    final prevLabel = recap.prevMonthLabel;
    String? deltaText;
    IconData? deltaIcon;
    Color? deltaColor;
    if (delta != null && prevLabel != null) {
      if (delta > 1) {
        deltaText = l10n.recapVolumeDeltaUp(delta.round(), prevLabel);
        deltaIcon = Icons.trending_up_rounded;
        deltaColor = colors.accentDeep;
      } else if (delta < -1) {
        deltaText =
            l10n.recapVolumeDeltaDown(delta.abs().round(), prevLabel);
        deltaIcon = Icons.trending_down_rounded;
        deltaColor = colors.ink500;
      } else {
        deltaText = l10n.recapVolumeDeltaSame(prevLabel);
        deltaIcon = Icons.trending_flat_rounded;
        deltaColor = colors.ink500;
      }
    }

    return _SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: _Eyebrow(l10n.recapVolumeTitle),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: _BigNumber(FormatUtils.volume(recap.totalVolumeKg)),
          ),
          const SizedBox(height: 18),
          if (deltaText != null)
            FadeSlideIn(
              delay: const Duration(milliseconds: 360),
              child: Row(
                children: [
                  Icon(deltaIcon, size: 18, color: deltaColor),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      deltaText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: deltaColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class BalanceSlide extends StatelessWidget {
  const BalanceSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final push = recap.volumeByCategory[ExerciseCategory.push.name] ?? 0;
    final pull = recap.volumeByCategory[ExerciseCategory.pull.name] ?? 0;
    final legs = recap.volumeByCategory[ExerciseCategory.legs.name] ?? 0;
    final tracked = push + pull + legs;
    // Percentages are computed against the tracked total (push + pull + legs).
    // "Other" volume is excluded so the three rows sum to 100%.
    final pushPct = tracked > 0 ? (push / tracked) * 100 : 0.0;
    final pullPct = tracked > 0 ? (pull / tracked) * 100 : 0.0;
    final legsPct = tracked > 0 ? (legs / tracked) * 100 : 0.0;

    return _SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: _Eyebrow(l10n.recapBalanceTitle),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Text(
              l10n.recapBalanceBody,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.ink900,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 28),
          FadeSlideIn(
            delay: const Duration(milliseconds: 320),
            child: _BalanceRow(
              label: l10n.categoryPush,
              percent: pushPct,
              color: colors.accent,
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 420),
            child: _BalanceRow(
              label: l10n.categoryPull,
              percent: pullPct,
              color: colors.accentDeep,
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 520),
            child: _BalanceRow(
              label: l10n.categoryLegs,
              percent: legsPct,
              color: colors.accentLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.label,
    required this.percent,
    required this.color,
  });
  final String label;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = (percent / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.ink900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Text(
              '${percent.round()}%',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.ink700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, c) {
            return Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors.glassBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.glassBorder,
                      width: 0.5,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  height: 10,
                  width: c.maxWidth * filled,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class TopRoutineSlide extends StatelessWidget {
  const TopRoutineSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final top = recap.topRoutine!;
    final routineColor = Color(top.colorValue);

    return _SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: _Eyebrow(l10n.recapTopRoutineTitle),
          ),
          const SizedBox(height: 24),
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    routineColor.withValues(alpha: 0.85),
                    routineColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: routineColor.withValues(alpha: 0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                IconData(top.iconCode, fontFamily: 'MaterialIcons'),
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeSlideIn(
            delay: const Duration(milliseconds: 340),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                top.name,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  height: 1.05,
                  color: colors.ink900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeSlideIn(
            delay: const Duration(milliseconds: 460),
            child: Text(
              l10n.recapTopRoutineBody(top.sessionsCount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.ink500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopExerciseSlide extends StatelessWidget {
  const TopExerciseSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final top = recap.topExercise!;

    return _SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: _Eyebrow(l10n.recapTopExerciseTitle),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                top.name,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.4,
                  height: 1.05,
                  color: colors.ink900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            delay: const Duration(milliseconds: 340),
            child: Text(
              l10n.recapTopExerciseBody(
                top.setsCount,
                FormatUtils.volume(top.totalVolumeKg),
              ),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colors.ink500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PRSlide extends StatelessWidget {
  const PRSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final pr = recap.newPR!;

    return _SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.accentDeep,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.recapPRTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: _BigNumber('${FormatUtils.weight(pr.weightKg)} kg'),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            delay: const Duration(milliseconds: 320),
            child: Text(
              '× ${pr.reps} reps',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.ink700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeSlideIn(
            delay: const Duration(milliseconds: 440),
            child: Text(
              l10n.recapPRBody(pr.exerciseName),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colors.ink500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OutroSlide extends StatelessWidget {
  const OutroSlide({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return _SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: Icon(
              Icons.favorite_rounded,
              size: 56,
              color: colors.accentDeep,
            ),
          ),
          const SizedBox(height: 22),
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: Text(
              l10n.recapOutroTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                height: 1.1,
                color: colors.ink900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeSlideIn(
            delay: const Duration(milliseconds: 340),
            child: Text(
              l10n.recapOutroBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.ink500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
