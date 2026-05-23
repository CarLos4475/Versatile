import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../domain/entities/session.dart';
import '../../../l10n/app_localizations.dart';

/// Editorial magazine-style share card. Fixed bone background regardless of
/// app theme — the design is intentional, not user-themed, so it looks the
/// same when posted regardless of whether the user shares from light/dark.
/// Routine color is the only personalized accent.
///
/// Optional [userPhotoPath] and [userQuote] let the user enrich their share.
/// The photo slots between the workout content and the VERSATILE wordmark
/// footer; the quote sits right below the photo as a caption (or stands
/// alone in that slot when there's no photo). Both extras grow the card
/// vertically rather than compressing the workout content above.
class ShareableSessionCard extends StatelessWidget {
  const ShareableSessionCard({
    super.key,
    required this.session,
    this.pr,
    this.userPhotoPath,
    this.userQuote,
    this.photoAlignX = 0.0,
    this.photoAlignY = 0.0,
    this.photoScale = 1.0,
  });

  final Session session;
  final RecapPersonalRecord? pr;
  final String? userPhotoPath;
  final String? userQuote;
  final double photoAlignX;
  final double photoAlignY;
  final double photoScale;

  /// Width of the card in logical pixels. Height grows dynamically via
  /// [logicalHeightFor] when a photo or quote is added.
  static const double logicalWidth = 360;
  static const double _photoSectionHeight = 180;
  static const double _quoteExtraHeight = 36;
  static const double _baseHeight = 360;

  /// Computes the card's logical height for the given extras. The screen
  /// uses the same formula to size the preview container so the FittedBox
  /// can scale the card without distortion.
  static double logicalHeightFor({
    required bool hasPhoto,
    required bool hasQuote,
  }) {
    var h = _baseHeight;
    if (hasQuote) h += _quoteExtraHeight;
    if (hasPhoto) h += _photoSectionHeight;
    return h;
  }

  // Fixed palette — does not follow theme.
  static const _bg = Color(0xFFEBE3D2);
  static const _ink = Color(0xFF1A1A1F);
  static const _mute = Color(0x8A1A1A1F);
  static const _hairlineStrong = Color(0x551A1A1F);
  static const _hairlineSoft = Color(0x331A1A1F);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final routineColor = Color(session.colorValue);
    final totalSets =
        session.exercises?.fold<int>(0, (s, e) => s + e.sets.length) ?? 0;
    final totalExercises = session.exercises?.length ?? 0;

    final dateFormatted = _formatDate(session.date, locale);
    final hasPR = pr != null;
    final hasPhoto = userPhotoPath != null &&
        userPhotoPath!.isNotEmpty &&
        File(userPhotoPath!).existsSync();
    final hasQuote = userQuote != null && userQuote!.trim().isNotEmpty;
    final height =
        logicalHeightFor(hasPhoto: hasPhoto, hasQuote: hasQuote);

    return SizedBox(
      width: logicalWidth,
      height: height,
      child: Container(
        color: _bg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                dateLabel: dateFormatted,
                routineColor: routineColor,
                iconCode: session.iconCode,
                issueAbbrev: l10n.shareIssueAbbrev,
                journalLabel: l10n.shareTrainingJournal,
              ),
              const SizedBox(height: 12),
              const _Hairline(color: _hairlineStrong, height: 0.8),
              const SizedBox(height: 16),
              _Headline(routineName: session.routineName),
              const SizedBox(height: 14),
              Expanded(
                child: _HeroVolume(
                  volumeKg: session.volumeKg,
                  label: l10n.volumeTotal.toUpperCase(),
                ),
              ),
              _StatsBar(
                durationMin: session.durationMin,
                totalSets: totalSets,
                totalExercises: totalExercises,
                timeLabel: l10n.duration.toUpperCase(),
                setsLabel: l10n.sets.toUpperCase(),
                exercisesLabel: l10n.exercisesLabel.toUpperCase(),
              ),
              if (hasPR) ...[
                const SizedBox(height: 10),
                _PrRow(
                  pr: pr!,
                  routineColor: routineColor,
                  badgeLabel: l10n.sharePRBadge,
                ),
              ],
              if (hasPhoto) ...[
                const SizedBox(height: 14),
                _UserPhoto(
                  path: userPhotoPath!,
                  alignX: photoAlignX,
                  alignY: photoAlignY,
                  scale: photoScale,
                ),
              ],
              if (hasQuote) ...[
                SizedBox(height: hasPhoto ? 8 : 14),
                _UserQuote(text: userQuote!.trim()),
              ],
              const SizedBox(height: 14),
              const _Hairline(color: _hairlineSoft),
              const SizedBox(height: 10),
              _Wordmark(tagline: l10n.shareTrainingJournal),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(String iso, String locale) {
    try {
      final dt = DateTime.parse(iso);
      final wd = DateFormat.E(locale).format(dt).toUpperCase();
      final mon = DateFormat.MMM(locale).format(dt).toUpperCase();
      return '$wd · $mon ${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.toUpperCase();
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.dateLabel,
    required this.routineColor,
    required this.iconCode,
    required this.issueAbbrev,
    required this.journalLabel,
  });

  final String dateLabel;
  final Color routineColor;
  final int iconCode;
  final String issueAbbrev;
  final String journalLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          color: routineColor,
          child: Icon(
            IconData(iconCode, fontFamily: 'MaterialIcons'),
            color: Colors.white,
            size: 12,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          dateLabel,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: ShareableSessionCard._ink,
          ),
        ),
        const Spacer(),
        Text(
          '$issueAbbrev ${_issueNumber()}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            color: ShareableSessionCard._mute,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  String _issueNumber() {
    // Stable per-session 3-digit "issue" derived from the date label hash.
    final h = dateLabel.codeUnits.fold<int>(0, (a, b) => a + b);
    final n = (h % 999) + 1;
    return n.toString().padLeft(3, '0');
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.routineName});

  final String routineName;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: routineName,
            style: GoogleFonts.playfairDisplay(
              fontSize: 38,
              fontWeight: FontWeight.w500,
              height: 1.02,
              letterSpacing: -0.6,
              color: ShareableSessionCard._ink,
            ),
          ),
          TextSpan(
            text: '.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 38,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: ShareableSessionCard._ink,
            ),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _HeroVolume extends StatelessWidget {
  const _HeroVolume({required this.volumeKg, required this.label});

  final double volumeKg;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 1,
              color: ShareableSessionCard._ink,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: ShareableSessionCard._ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: FormatUtils.volume(volumeKg),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 58,
                        fontWeight: FontWeight.w500,
                        height: 0.95,
                        letterSpacing: -1.6,
                        color: ShareableSessionCard._ink,
                      ),
                    ),
                    TextSpan(
                      text: ' kg',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color: ShareableSessionCard._mute,
                      ),
                    ),
                  ],
                ),
              ),
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
    required this.timeLabel,
    required this.setsLabel,
    required this.exercisesLabel,
  });

  final int durationMin;
  final int totalSets;
  final int totalExercises;
  final String timeLabel;
  final String setsLabel;
  final String exercisesLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ShareableSessionCard._hairlineStrong,
            width: 0.8,
          ),
          bottom: BorderSide(
            color: ShareableSessionCard._hairlineStrong,
            width: 0.8,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                value: FormatUtils.duration(durationMin),
                label: timeLabel,
              ),
            ),
            Container(
              width: 0.8,
              color: ShareableSessionCard._hairlineSoft,
            ),
            Expanded(
              child: _StatCell(value: '$totalSets', label: setsLabel),
            ),
            Container(
              width: 0.8,
              color: ShareableSessionCard._hairlineSoft,
            ),
            Expanded(
              child:
                  _StatCell(value: '$totalExercises', label: exercisesLabel),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                height: 1.0,
                letterSpacing: -0.4,
                color: ShareableSessionCard._ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: ShareableSessionCard._mute,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrRow extends StatelessWidget {
  const _PrRow({
    required this.pr,
    required this.routineColor,
    required this.badgeLabel,
  });

  final RecapPersonalRecord pr;
  final Color routineColor;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          color: ShareableSessionCard._ink,
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: ShareableSessionCard._bg,
            size: 11,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          badgeLabel,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: ShareableSessionCard._ink,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: pr.exerciseName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: ShareableSessionCard._ink,
                  ),
                ),
                TextSpan(
                  text: ' — ${FormatUtils.weight(pr.weightKg)} kg × ${pr.reps}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ShareableSessionCard._ink,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.tagline});

  final String tagline;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'VERSATILE',
          style: GoogleFonts.playfairDisplay(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 4.5,
            color: ShareableSessionCard._ink,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          color: ShareableSessionCard._ink,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            tagline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: ShareableSessionCard._mute,
            ),
          ),
        ),
      ],
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.color, this.height = 0.6});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(height: height, color: color);
  }
}

class _UserPhoto extends StatelessWidget {
  const _UserPhoto({
    required this.path,
    required this.alignX,
    required this.alignY,
    required this.scale,
  });

  final String path;
  final double alignX;
  final double alignY;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRect(
        child: Transform.scale(
          scale: scale,
          alignment: Alignment(alignX, alignY),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            alignment: Alignment(alignX, alignY),
          ),
        ),
      ),
    );
  }
}

class _UserQuote extends StatelessWidget {
  const _UserQuote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '“',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                height: 0.6,
                color: ShareableSessionCard._mute,
              ),
            ),
            TextSpan(
              text: text,
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: ShareableSessionCard._ink,
              ),
            ),
            TextSpan(
              text: '”',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                height: 0.6,
                color: ShareableSessionCard._mute,
              ),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
