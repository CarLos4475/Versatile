import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../domain/entities/session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/motion.dart';
import '../../share/screens/share_session_screen.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  const WorkoutCompleteScreen({
    super.key,
    required this.session,
    this.precomputedPRs = const [],
  });

  final Session session;

  /// PRs detected during the active workout. Pre-supplied to the share card so
  /// it doesn't re-iterate session history. Empty when this screen is reached
  /// without a realtime detection (e.g., legacy state).
  final List<RecapPersonalRecord> precomputedPRs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final totalSets =
        session.exercises?.fold<int>(0, (s, e) => s + e.sets.length) ?? 0;
    final totalExercises = session.exercises?.length ?? 0;

    return Scaffold(
      backgroundColor: colors.bgApp,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 60),
                      child: _IssueBar(date: session.date),
                    ),
                    const SizedBox(height: 12),
                    _Hairline(color: colors.ink900.withValues(alpha: 0.35)),
                    const SizedBox(height: 26),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 140),
                      child: _Headline(
                        rawTitle: l10n.sessionComplete,
                        accentColor: colors.accentLight,
                        ink: colors.ink900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 220),
                      child: Text(
                        l10n.greatJob,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                          color: colors.ink500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    _Hairline(color: colors.hairline),
                    const SizedBox(height: 22),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 320),
                      child: _HeroVolume(
                        volumeKg: session.volumeKg,
                        ink: colors.ink900,
                        mute: colors.ink500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 400),
                      child: _StatsBar(
                        durationMin: session.durationMin,
                        totalSets: totalSets,
                        totalExercises: totalExercises,
                        ink: colors.ink900,
                        mute: colors.ink500,
                        hairlineStrong:
                            colors.ink900.withValues(alpha: 0.35),
                        hairlineSoft: colors.hairline,
                        timeLabel: l10n.duration.toUpperCase(),
                        setsLabel: l10n.sets.toUpperCase(),
                        exercisesLabel: l10n.exercisesLabel.toUpperCase(),
                      ),
                    ),
                    for (var i = 0; i < precomputedPRs.length; i++) ...[
                      if (i == 0)
                        const SizedBox(height: 18)
                      else ...[
                        const SizedBox(height: 8),
                        _Hairline(
                          color: colors.ink900.withValues(alpha: 0.10),
                        ),
                        const SizedBox(height: 8),
                      ],
                      FadeSlideIn(
                        delay: Duration(milliseconds: 480 + i * 80),
                        child: _PrCallout(
                          pr: precomputedPRs[i],
                          ink: colors.ink900,
                          bg: colors.bgApp,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    _Hairline(color: colors.hairline),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 560),
                      child: _RoutineFooter(
                        routineName: session.routineName,
                        routineColor: Color(session.colorValue),
                        iconCode: session.iconCode,
                        ink: colors.ink900,
                        mute: colors.ink500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 640),
              child: _ActionBar(
                onShare: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShareSessionScreen(
                      session: session,
                      precomputedPRs: precomputedPRs,
                    ),
                  ),
                ),
                onBack: () => Navigator.of(context).pop(),
                shareLabel: l10n.share,
                backLabel: l10n.backToHome,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueBar extends StatelessWidget {
  const _IssueBar({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dt = _tryParse(date);
    final formatted = dt != null
        ? '${DateFormat.E('en').format(dt).toUpperCase()} · '
              '${DateFormat.MMM('en').format(dt).toUpperCase()} '
              '${dt.day.toString().padLeft(2, '0')}'
        : date.toUpperCase();
    final issue = _issueFor(date);
    return Row(
      children: [
        Text(
          'No. $issue',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            color: colors.ink500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 3,
          height: 3,
          color: colors.ink500.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 10),
        Text(
          formatted,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: colors.ink900,
          ),
        ),
        const Spacer(),
        Text(
          'TRAINING JOURNAL',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: colors.ink500,
          ),
        ),
      ],
    );
  }

  DateTime? _tryParse(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  String _issueFor(String s) {
    final h = s.codeUnits.fold<int>(0, (a, b) => a + b);
    final n = (h % 999) + 1;
    return n.toString().padLeft(3, '0');
  }
}

class _Headline extends StatelessWidget {
  const _Headline({
    required this.rawTitle,
    required this.accentColor,
    required this.ink,
  });

  final String rawTitle;
  final Color accentColor;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final clean = rawTitle.replaceAll('!', '').replaceAll('¡', '').trim();
    final parts = clean.split(' ');
    final prefix = parts.isNotEmpty ? parts.first : clean;
    final suffix = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final compact = MediaQuery.sizeOf(context).height < 780;
    final size = compact ? 46.0 : 54.0;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: suffix.isEmpty ? clean : '$prefix\n',
            style: GoogleFonts.playfairDisplay(
              fontSize: size,
              fontWeight: FontWeight.w500,
              height: 0.95,
              letterSpacing: -1.2,
              color: ink,
            ),
          ),
          if (suffix.isNotEmpty)
            TextSpan(
              text: '$suffix.',
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                height: 0.95,
                letterSpacing: -1.0,
                color: accentColor,
              ),
            ),
        ],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _HeroVolume extends StatelessWidget {
  const _HeroVolume({
    required this.volumeKg,
    required this.ink,
    required this.mute,
  });

  final double volumeKg;
  final Color ink;
  final Color mute;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 24, height: 1, color: ink),
            const SizedBox(width: 10),
            Text(
              'TOTAL VOLUME',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: FormatUtils.volume(volumeKg),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 76,
                    fontWeight: FontWeight.w500,
                    height: 0.95,
                    letterSpacing: -2.4,
                    color: ink,
                  ),
                ),
                TextSpan(
                  text: ' kg',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: mute,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.durationMin,
    required this.totalSets,
    required this.totalExercises,
    required this.ink,
    required this.mute,
    required this.hairlineStrong,
    required this.hairlineSoft,
    required this.timeLabel,
    required this.setsLabel,
    required this.exercisesLabel,
  });

  final int durationMin;
  final int totalSets;
  final int totalExercises;
  final Color ink;
  final Color mute;
  final Color hairlineStrong;
  final Color hairlineSoft;
  final String timeLabel;
  final String setsLabel;
  final String exercisesLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: hairlineStrong, width: 0.8),
          bottom: BorderSide(color: hairlineStrong, width: 0.8),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                value: FormatUtils.duration(durationMin),
                label: timeLabel,
                ink: ink,
                mute: mute,
              ),
            ),
            Container(width: 0.6, color: hairlineSoft),
            Expanded(
              child: _StatCell(
                value: '$totalSets',
                label: setsLabel,
                ink: ink,
                mute: mute,
              ),
            ),
            Container(width: 0.6, color: hairlineSoft),
            Expanded(
              child: _StatCell(
                value: '$totalExercises',
                label: exercisesLabel,
                ink: ink,
                mute: mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.ink,
    required this.mute,
  });

  final String value;
  final String label;
  final Color ink;
  final Color mute;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                height: 1.0,
                letterSpacing: -0.4,
                color: ink,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: mute,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrCallout extends StatelessWidget {
  const _PrCallout({
    required this.pr,
    required this.ink,
    required this.bg,
  });

  final RecapPersonalRecord pr;
  final Color ink;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          color: ink,
          child: Icon(
            Icons.workspace_premium_rounded,
            color: bg,
            size: 13,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NEW PERSONAL RECORD',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: ink,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: pr.exerciseName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        height: 1.2,
                        color: ink,
                      ),
                    ),
                    TextSpan(
                      text:
                          '   ${FormatUtils.weight(pr.weightKg)} kg × ${pr.reps}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: ink,
                      ),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoutineFooter extends StatelessWidget {
  const _RoutineFooter({
    required this.routineName,
    required this.routineColor,
    required this.iconCode,
    required this.ink,
    required this.mute,
  });

  final String routineName;
  final Color routineColor;
  final int iconCode;
  final Color ink;
  final Color mute;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          color: routineColor,
          child: Icon(
            IconData(iconCode, fontFamily: 'MaterialIcons'),
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            routineName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
              color: ink,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'ROUTINE',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: mute,
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.onShare,
    required this.onBack,
    required this.shareLabel,
    required this.backLabel,
  });

  final VoidCallback onShare;
  final VoidCallback onBack;
  final String shareLabel;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.bgApp,
        border: Border(
          top: BorderSide(color: colors.hairline, width: 0.6),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
      child: Row(
        children: [
          PressableScale(
            onTap: onShare,
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.bgFrame,
                border: Border.all(color: colors.hairline, width: 0.6),
              ),
              child: Tooltip(
                message: shareLabel,
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
            child: PressableScale(
              onTap: onBack,
              child: Container(
                height: 56,
                alignment: Alignment.center,
                color: colors.accent,
                child: Text(
                  backLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(height: 0.6, color: color);
  }
}
