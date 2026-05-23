import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../l10n/app_localizations.dart';

// Editorial palette — fixed bone paper + ink, never follows theme. Each
// slide reads like a printed magazine spread regardless of the user's
// chosen app theme.
const _paper = Color(0xFFEBE3D2);
const _ink = Color(0xFF1A1A1F);
const _inkSecondary = Color(0xB31A1A1F); // 70%
const _inkMuted = Color(0x8C1A1A1F); // 55%
const _inkFaint = Color(0x661A1A1F); // 40%
const _hairlineStrong = Color(0x551A1A1F);
const _hairlineSoft = Color(0x331A1A1F);

// ───────────────────────────────────────────────────────────────────────────
// Shared helpers
// ───────────────────────────────────────────────────────────────────────────

/// Big serif Playfair text in ink. Used for hero numbers and headlines.
class _SerifText extends StatelessWidget {
  const _SerifText(
    this.text, {
    required this.fontSize,
    this.fontWeight = FontWeight.w500,
    this.fontStyle = FontStyle.normal,
    this.letterSpacing = -0.04,
    this.height = 0.95,
    this.color = _ink,
    this.tabular = false,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final double letterSpacing;
  final double height;
  final Color color;
  final bool tabular;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
      style: GoogleFonts.playfairDisplay(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: fontSize * letterSpacing,
        height: height.clamp(1.0, double.infinity),
        fontFeatures: tabular
            ? const [FontFeature.tabularFigures()]
            : null,
      ),
    );
  }
}

/// Counts up from 0 to [target] on mount. Wraps the number in [_SerifText]
/// for the editorial typography.
class _CountUp extends StatelessWidget {
  const _CountUp({
    required this.target,
    required this.fontSize,
    this.delay = Duration.zero,
    this.fractionDigits = 0,
    this.useThousandsSeparator = false,
  });

  final double target;
  final double fontSize;
  final Duration delay;
  final int fractionDigits;
  final bool useThousandsSeparator;
  static const Duration duration = Duration(milliseconds: 1300);

  String _format(double v) {
    final rounded = fractionDigits == 0
        ? v.round().toString()
        : v.toStringAsFixed(fractionDigits);
    if (!useThousandsSeparator || fractionDigits != 0) return rounded;
    final buf = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      final fromEnd = rounded.length - i;
      buf.write(rounded[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target),
      duration: duration,
      curve: Interval(
        delay.inMilliseconds / (delay.inMilliseconds + duration.inMilliseconds),
        1,
        curve: Curves.easeOutCubic,
      ),
      builder: (context, value, _) {
        return _SerifText(
          _format(value),
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.04,
          tabular: true,
        );
      },
    );
  }
}

class _PullMark extends StatelessWidget {
  const _PullMark();

  @override
  Widget build(BuildContext context) {
    return Container(width: 22, height: 1, color: _ink);
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({this.color = _hairlineStrong, this.height = 0.8});
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(height: height, color: color);
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.text, this.icon = Icons.arrow_upward_rounded});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _ink,
        border: Border.all(color: _ink, width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _paper),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _paper,
              letterSpacing: 0.4,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Magazine-style masthead at the top of every interior slide: tiny wordmark
/// on the left, page number in the middle, issue date on the right. Hairline
/// rule beneath. Cover/outro slides skip this and use their own headers.
class _Masthead extends StatelessWidget {
  const _Masthead({
    required this.issue,
    required this.page,
    required this.total,
    required this.section,
  });

  final String issue;
  final int page;
  final int total;
  final String section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _SerifText(
              'VERSATILE',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.32,
              height: 1.0,
            ),
            const SizedBox(width: 8),
            Container(width: 3, height: 3, color: _ink),
            const SizedBox(width: 8),
            Text(
              section.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: _inkMuted,
              ),
            ),
            const Spacer(),
            Text(
              '${page.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _inkMuted,
                letterSpacing: 0.4,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              issue.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: _ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const _Hairline(),
      ],
    );
  }
}

class _PageFooter extends StatelessWidget {
  const _PageFooter({required this.byline});
  final String byline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Hairline(color: _hairlineSoft, height: 0.6),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              byline.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: _inkMuted,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward, size: 12, color: _inkMuted),
          ],
        ),
      ],
    );
  }
}

class _SlideShell extends StatelessWidget {
  const _SlideShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 56, 22, 22),
        child: Align(
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ),
    );
  }
}

/// Pages 2..N (skipping cover + outro) share the same chrome: masthead at
/// top, body in the middle, footer at the bottom. Body is centered
/// vertically by default.
class _MagazinePage extends StatelessWidget {
  const _MagazinePage({
    required this.section,
    required this.issue,
    required this.page,
    required this.total,
    required this.byline,
    required this.body,
  });

  final String section;
  final String issue;
  final int page;
  final int total;
  final String byline;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    // Top-anchored body so vertical dead space accumulates in a single region
    // (below the footer) instead of being split between masthead↔body and
    // body↔footer. Cleaner magazine flow live, and lets the share capture
    // crop the dead zone in one pass.
    return _SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Masthead(
            issue: issue,
            page: page,
            total: total,
            section: section,
          ),
          const SizedBox(height: 24),
          body,
          const SizedBox(height: 24),
          _PageFooter(byline: byline),
        ],
      ),
    );
  }
}

String _issueFor(MonthlyRecap recap, String locale) {
  try {
    final dt = DateTime(recap.year, recap.month, 1);
    final mon = DateFormat.MMM(locale).format(dt).toUpperCase();
    return '$mon ${recap.year.toString().substring(2)}'; // e.g. OCT 26
  } catch (_) {
    return '${recap.year}/${recap.month.toString().padLeft(2, '0')}';
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Slides
// ───────────────────────────────────────────────────────────────────────────

class CoverSlide extends StatelessWidget {
  const CoverSlide({super.key, required this.recap});
  final MonthlyRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final monthLabel = FormatUtils.monthYear(
      '${recap.year.toString().padLeft(4, '0')}-${recap.month.toString().padLeft(2, '0')}-01',
    );
    final volStr = recap.totalVolumeKg >= 1000
        ? '${(recap.totalVolumeKg / 1000).toStringAsFixed(1)}k'
        : recap.totalVolumeKg.round().toString();
    return _SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SerifText(
                'VERSATILE',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.32,
                height: 1.0,
              ),
              const SizedBox(width: 10),
              Container(width: 4, height: 4, color: _ink),
              const SizedBox(width: 10),
              Text(
                l10n.shareTrainingJournal.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: _inkMuted,
                ),
              ),
              const Spacer(),
              Text(
                _issueFor(recap, locale),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _Hairline(height: 1.2),
          const SizedBox(height: 32),
          Text(
            monthLabel.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.4,
              color: _inkMuted,
            ),
          ),
          const SizedBox(height: 22),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${l10n.recapHeadline.toUpperCase()}\n',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 64,
                    fontWeight: FontWeight.w500,
                    color: _ink,
                    height: 0.92,
                    letterSpacing: -2.0,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.left,
            maxLines: 3,
          ),
          const SizedBox(height: 22),
          Container(width: 60, height: 1, color: _ink),
          const SizedBox(height: 16),
          Text(
            l10n.recapCoverSubtitle,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: _inkSecondary,
              height: 1.4,
            ),
          ),
          const Spacer(),
          // Cover lines — magazine "Inside" teasers.
          _CoverLine(
            label: l10n.recapSessionsEyebrow,
            value: '${recap.sessionsCount}',
          ),
          const SizedBox(height: 6),
          _CoverLine(
            label: l10n.recapVolumeEyebrow,
            value: '$volStr kg',
          ),
          if (recap.topLift != null) ...[
            const SizedBox(height: 6),
            _CoverLine(
              label: l10n.recapTopLiftEyebrow,
              value: recap.topLift!.name,
            ),
          ],
          const SizedBox(height: 22),
          const _Hairline(color: _hairlineSoft),
          const SizedBox(height: 12),
          Center(child: _FloatingHint(text: l10n.recapTapToBegin)),
        ],
      ),
    );
  }
}

class _CoverLine extends StatelessWidget {
  const _CoverLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: _inkMuted,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: _DottedLine(color: _hairlineSoft),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _SerifText(
            value,
            fontSize: 14,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.04,
            color: _ink,
          ),
        ),
      ],
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final w = c.maxWidth;
        const dot = 2.0;
        const gap = 4.0;
        final count = (w / (dot + gap)).floor().clamp(0, 200);
        return Row(
          children: List.generate(count, (_) {
            return Padding(
              padding: const EdgeInsets.only(right: gap),
              child: Container(width: dot, height: 1, color: color),
            );
          }),
        );
      },
    );
  }
}

class _FloatingHint extends StatefulWidget {
  const _FloatingHint({required this.text});
  final String text;
  @override
  State<_FloatingHint> createState() => _FloatingHintState();
}

class _FloatingHintState extends State<_FloatingHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return Transform.translate(
          offset: Offset(0, -3 * t),
          child: Column(
            children: [
              Text(
                widget.text.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: _inkFaint,
                ),
              ),
              const SizedBox(height: 6),
              Container(width: 4, height: 4, color: _inkFaint),
            ],
          ),
        );
      },
    );
  }
}

class SessionsSlide extends StatelessWidget {
  const SessionsSlide({
    super.key,
    required this.recap,
    required this.page,
    required this.total,
  });
  final MonthlyRecap recap;
  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final delta = recap.sessionsCount - recap.prevSessionsCount;
    final perWeek = (recap.sessionsCount / 4.3).toStringAsFixed(1);
    return _MagazinePage(
      section: l10n.recapSessionsEyebrow,
      issue: _issueFor(recap, locale),
      page: page,
      total: total,
      byline: 'BY THE NUMBERS',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Row(
            children: const [
              _PullMark(),
              SizedBox(width: 8),
              Text(
                'COUNT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _CountUp(
            target: recap.sessionsCount.toDouble(),
            fontSize: 140,
            delay: const Duration(milliseconds: 200),
          ),
          const SizedBox(height: 6),
          _SerifText(
            l10n.recapSessionsLabel,
            fontSize: 22,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: _inkSecondary,
            letterSpacing: -0.04,
            height: 1.0,
          ),
          if (delta > 0 && recap.prevMonthLabel != null) ...[
            const SizedBox(height: 22),
            _DeltaPill(
              text: l10n.recapSessionsDelta(delta, recap.prevMonthLabel!),
            ),
          ],
          const SizedBox(height: 18),
          const _Hairline(color: _hairlineSoft),
          const SizedBox(height: 12),
          // Editorial pull paragraph with the per-week average.
          Text.rich(
            TextSpan(
              text: l10n.recapSessionsAvg(perWeek).split(perWeek).first,
              style: GoogleFonts.playfairDisplay(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: _inkSecondary,
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: perWeek,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    color: _ink,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text: l10n.recapSessionsAvg(perWeek).split(perWeek).last,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VolumeSlide extends StatelessWidget {
  const VolumeSlide({
    super.key,
    required this.recap,
    required this.page,
    required this.total,
  });
  final MonthlyRecap recap;
  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final pctDelta = recap.volumeDeltaPctVsPrev?.round();
    final maxWeek = recap.weeklyVolumeKg.isEmpty
        ? 1.0
        : recap.weeklyVolumeKg.reduce(math.max).clamp(1, double.infinity);

    return _MagazinePage(
      section: l10n.recapVolumeEyebrow,
      issue: _issueFor(recap, locale),
      page: page,
      total: total,
      byline: 'WEEKLY CHART',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Row(
            children: const [
              _PullMark(),
              SizedBox(width: 8),
              Text(
                'TOTAL VOLUME',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _CountUp(
                target: recap.totalVolumeKg,
                fontSize: 84,
                delay: const Duration(milliseconds: 200),
                useThousandsSeparator: true,
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SerifText(
                  'kg',
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  color: _inkSecondary,
                  letterSpacing: -0.04,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.recapVolumeLabel,
            style: GoogleFonts.playfairDisplay(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: _inkSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (recap.weeklyVolumeKg.isNotEmpty)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: _hairlineSoft, width: 0.6),
                  bottom: BorderSide(color: _hairlineSoft, width: 0.6),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(recap.weeklyVolumeKg.length, (i) {
                    final w = recap.weeklyVolumeKg[i];
                    final ratio = (w / maxWeek).clamp(0.0, 1.0);
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: i < recap.weeklyVolumeKg.length - 1 ? 8 : 0,
                        ),
                        child: _VolumeBar(
                          ratio: ratio,
                          labelTop: w >= 1000
                              ? '${(w / 1000).toStringAsFixed(1)}k'
                              : w.round().toString(),
                          labelBottom: l10n.recapWeekLabel(i + 1),
                          delay: Duration(milliseconds: 600 + i * 100),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          if (pctDelta != null && recap.prevMonthLabel != null) ...[
            const SizedBox(height: 20),
            _DeltaPill(
              text: l10n.recapVolumeDeltaPct(pctDelta, recap.prevMonthLabel!),
              icon: pctDelta >= 0
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _VolumeBar extends StatelessWidget {
  const _VolumeBar({
    required this.ratio,
    required this.labelTop,
    required this.labelBottom,
    required this.delay,
  });
  final double ratio;
  final String labelTop;
  final String labelBottom;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          labelTop,
          style: const TextStyle(
            fontSize: 9,
            color: _inkMuted,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Interval(
              delay.inMilliseconds / 1500,
              1,
              curve: Curves.easeOutCubic,
            ),
            builder: (context, t, _) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: ratio * 70 * t,
                  color: colors.accent,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          labelBottom.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            color: _inkMuted,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class CalendarSlide extends StatelessWidget {
  const CalendarSlide({
    super.key,
    required this.recap,
    required this.page,
    required this.total,
  });
  final MonthlyRecap recap;
  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final daysInMonth = DateTime(recap.year, recap.month + 1, 0).day;
    final firstDow = DateTime(recap.year, recap.month, 1).weekday % 7;
    final trained = <int>{};
    final monthKey =
        '${recap.year.toString().padLeft(4, '0')}-${recap.month.toString().padLeft(2, '0')}';
    for (final dayStr in recap.workoutDays) {
      if (!dayStr.startsWith(monthKey)) continue;
      final d = int.tryParse(dayStr.substring(8, 10));
      if (d != null) trained.add(d);
    }

    final cells = <int?>[];
    for (var i = 0; i < firstDow; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(d);
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return _MagazinePage(
      section: l10n.recapCalendarEyebrow,
      issue: _issueFor(recap, locale),
      page: page,
      total: total,
      byline: 'ATTENDANCE',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: const [
              _PullMark(),
              SizedBox(width: 8),
              Text(
                'TRAINING DAYS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _CountUp(
                target: trained.length.toDouble(),
                fontSize: 60,
                delay: const Duration(milliseconds: 200),
              ),
              _SerifText(
                ' / $daysInMonth',
                fontSize: 28,
                fontStyle: FontStyle.italic,
                color: _inkSecondary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.recapCalendarLabel,
            style: GoogleFonts.playfairDisplay(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: _inkSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: _inkMuted,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          const _Hairline(color: _hairlineSoft, height: 0.6),
          const SizedBox(height: 8),
          _CalendarGrid(cells: cells, trained: trained),
          const SizedBox(height: 16),
          if (recap.bestWeekSessions > 0)
            Row(
              children: [
                Container(width: 8, height: 8, color: context.colors.accent),
                const SizedBox(width: 8),
                Text(
                  l10n.recapBestWeek(recap.bestWeekSessions),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: _inkSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.cells, required this.trained});
  final List<int?> cells;
  final Set<int> trained;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: cells.length,
      itemBuilder: (context, idx) {
        final d = cells[idx];
        if (d == null) return const SizedBox.shrink();
        final did = trained.contains(d);
        final start = 350 + idx * 22;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: start + 500),
          curve: Interval(
            start / (start + 500),
            1,
            curve: Curves.easeOutBack,
          ),
          builder: (context, t, child) {
            return Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.3 + 0.7 * t, child: child),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: did ? colors.accent : Colors.transparent,
              border: Border.all(
                color: did ? colors.accent : _hairlineSoft,
                width: 0.6,
              ),
            ),
            child: Center(
              child: Text(
                d.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: did ? Colors.white : _inkMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TopLiftSlide extends StatelessWidget {
  const TopLiftSlide({
    super.key,
    required this.recap,
    required this.page,
    required this.total,
  });
  final MonthlyRecap recap;
  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final lift = recap.topLift!;
    final colors = context.colors;

    final displayName = () {
      if (lift.exerciseId.startsWith('c-') || lift.name.isEmpty) {
        return lift.name;
      }
      final dummy = Exercise(
        id: lift.exerciseId,
        name: lift.name,
        muscle: lift.muscle,
        equipment: '',
      );
      return dummy.getLocalizedName(context);
    }();
    final deltaStr = lift.deltaKgVsPrevMonth > 0
        ? FormatUtils.weight(lift.deltaKgVsPrevMonth)
        : null;

    return _MagazinePage(
      section: l10n.recapTopLiftEyebrow,
      issue: _issueFor(recap, locale),
      page: page,
      total: total,
      byline: 'FEATURE',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Row(
            children: const [
              _PullMark(),
              SizedBox(width: 8),
              Text(
                'LIFT OF THE MONTH',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SerifText(
            '$displayName.',
            fontSize: 38,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: _ink,
            letterSpacing: -0.04,
            height: 1.0,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _CountUp(
                target: lift.bestKg,
                fontSize: 92,
                delay: const Duration(milliseconds: 400),
                fractionDigits: lift.bestKg == lift.bestKg.roundToDouble()
                    ? 0
                    : 1,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 12),
                child: _SerifText(
                  'kg',
                  fontSize: 26,
                  fontStyle: FontStyle.italic,
                  color: _inkSecondary,
                ),
              ),
            ],
          ),
          if (deltaStr != null) ...[
            const SizedBox(height: 14),
            _DeltaPill(text: l10n.recapTopLiftDelta(deltaStr)),
          ],
          const SizedBox(height: 24),
          if (lift.weeklyBests.length >= 2)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: _hairlineStrong, width: 0.6),
                  bottom: BorderSide(color: _hairlineStrong, width: 0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recapWeeklyBestLabel.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: _inkMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 56,
                    child: _Sparkline(
                      values: lift.weeklyBests,
                      accent: colors.accent,
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

class _Sparkline extends StatefulWidget {
  const _Sparkline({required this.values, required this.accent});
  final List<double> values;
  final Color accent;

  @override
  State<_Sparkline> createState() => _SparklineState();
}

class _SparklineState extends State<_Sparkline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        size: const Size(double.infinity, 56),
        painter: _SparkPainter(
          values: widget.values,
          accent: widget.accent,
          progress: _ctrl.value,
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({
    required this.values,
    required this.accent,
    required this.progress,
  });
  final List<double> values;
  final Color accent;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final firstNonZero = values.indexWhere((v) => v > 0);
    final plot = firstNonZero < 0
        ? values
        : values.sublist(firstNonZero);
    if (plot.length < 2) return;

    final display = List<double>.filled(plot.length, 0);
    double? lastNonZero;
    for (var i = 0; i < plot.length; i++) {
      if (plot[i] > 0) {
        lastNonZero = plot[i];
        display[i] = plot[i];
      } else if (lastNonZero != null) {
        display[i] = lastNonZero;
      } else {
        display[i] = 0;
      }
    }

    final maxV = display.reduce(math.max);
    final minV = display.reduce(math.min);
    final span = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    const pad = 6.0;
    final usableHeight = size.height - pad * 2;

    final points = <Offset>[];
    for (var i = 0; i < display.length; i++) {
      final x = (i / (display.length - 1)) * size.width;
      final y = size.height - ((display[i] - minV) / span) * usableHeight - pad;
      points.add(Offset(x, y));
    }

    // Soft area under curve.
    final areaPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath
      ..lineTo(points.last.dx, size.height)
      ..close();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withValues(alpha: 0.25 * progress),
          accent.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    final metric = linePath.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);
    final linePaint = Paint()
      ..color = _ink
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(drawn, linePaint);

    final dotPaint = Paint()..color = accent;
    for (var i = 0; i < plot.length; i++) {
      if (plot[i] <= 0) continue;
      final showAt = i / (plot.length - 1);
      if (progress < showAt) continue;
      final localT = ((progress - showAt) / 0.15).clamp(0.0, 1.0);
      canvas.drawCircle(points[i], 2.5 * localT, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) {
    return old.progress != progress ||
        old.accent != accent ||
        old.values != values;
  }
}

class MuscleBalanceSlide extends StatelessWidget {
  const MuscleBalanceSlide({
    super.key,
    required this.recap,
    required this.page,
    required this.total,
  });
  final MonthlyRecap recap;
  final int page;
  final int total;

  static const _displayOrder = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final colors = context.colors;
    final totalVol = recap.volumeByMuscle.values.fold<double>(0, (s, v) => s + v);
    final ordered = _displayOrder
        .map((m) => (
              name: _localizedMuscle(context, m),
              pct: totalVol > 0
                  ? ((recap.volumeByMuscle[m] ?? 0) / totalVol) * 100
                  : 0.0,
            ))
        .toList()
      ..sort((a, b) => b.pct.compareTo(a.pct));
    final top = ordered.first;

    return _MagazinePage(
      section: l10n.recapMuscleBalanceEyebrow,
      issue: _issueFor(recap, locale),
      page: page,
      total: total,
      byline: 'BALANCE',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Row(
            children: const [
              _PullMark(),
              SizedBox(width: 8),
              Text(
                'MOST WORKED',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SerifText(
            '${top.name}.',
            fontSize: 56,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.04,
            color: _ink,
            height: 1.0,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.recapMuscleTopBody(top.pct.round()),
            style: GoogleFonts.playfairDisplay(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: _inkSecondary,
            ),
          ),
          const SizedBox(height: 22),
          const _Hairline(color: _hairlineSoft),
          const SizedBox(height: 12),
          ...List.generate(ordered.length, (i) {
            final m = ordered[i];
            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
              child: _MuscleRow(
                name: m.name,
                pct: m.pct,
                isTop: i == 0,
                delay: Duration(milliseconds: 600 + i * 100),
                accent: colors.accent,
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _localizedMuscle(BuildContext context, String key) {
    final dummy = Exercise(id: '', name: '', muscle: key, equipment: '');
    return dummy.getLocalizedMuscle(context);
  }
}

class _MuscleRow extends StatelessWidget {
  const _MuscleRow({
    required this.name,
    required this.pct,
    required this.isTop,
    required this.delay,
    required this.accent,
  });
  final String name;
  final double pct;
  final bool isTop;
  final Duration delay;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final fill = (pct / 100).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(
            name.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isTop ? _ink : _inkSecondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(color: _hairlineSoft),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fill),
                  duration: const Duration(milliseconds: 900),
                  curve: Interval(
                    delay.inMilliseconds / (delay.inMilliseconds + 900),
                    1,
                    curve: Curves.easeOutCubic,
                  ),
                  builder: (context, t, _) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: t,
                        heightFactor: 1,
                        child: Container(
                          color: isTop ? accent : accent.withValues(alpha: 0.55),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            '${pct.round()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isTop ? _ink : _inkSecondary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class OutroSlide extends StatelessWidget {
  const OutroSlide({super.key, required this.recap, required this.onClose});
  final MonthlyRecap recap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final monthLabel = FormatUtils.monthYear(
      '${recap.year.toString().padLeft(4, '0')}-${recap.month.toString().padLeft(2, '0')}-01',
    );
    final hours = (recap.totalDurationMin / 60).toStringAsFixed(1);

    return _SlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SerifText(
                'VERSATILE',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.32,
                height: 1.0,
              ),
              const SizedBox(width: 10),
              Container(width: 4, height: 4, color: _ink),
              const SizedBox(width: 10),
              Text(
                l10n.recapOutroEyebrow(monthLabel).toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: _inkMuted,
                ),
              ),
              const Spacer(),
              Text(
                _issueFor(recap, locale),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _Hairline(height: 1.2),
          const Spacer(),
          Center(
            child: _SerifText(
              'FIN.',
              fontSize: 96,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.04,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              l10n.recapOutroHeadline.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: _inkSecondary,
              ),
            ),
          ),
          const Spacer(),
          const _Hairline(color: _hairlineSoft),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _SummaryStat(
                    value: recap.sessionsCount.toString(),
                    label: l10n.recapStatSessions,
                  ),
                ),
                Container(width: 0.6, color: _hairlineSoft),
                Expanded(
                  child: _SummaryStat(
                    value: hours,
                    label: l10n.recapStatHours,
                  ),
                ),
                Container(width: 0.6, color: _hairlineSoft),
                Expanded(
                  child: _SummaryStat(
                    value: recap.newPRsCount.toString(),
                    label: l10n.recapStatNewPRs,
                    accent: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _Hairline(color: _hairlineSoft),
          const SizedBox(height: 18),
          Center(child: _OutroCta(label: l10n.recapOutroCta, onTap: onClose)),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.recapOutroFooter(monthLabel),
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: _inkMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    this.accent = false,
  });
  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: _SerifText(
              value,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.04,
              color: accent ? colors.accentDeep : _ink,
              tabular: true,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: _inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutroCta extends StatelessWidget {
  const _OutroCta({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        alignment: Alignment.center,
        color: colors.accent,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.8,
          ),
        ),
      ),
    );
  }
}
