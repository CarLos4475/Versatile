import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../domain/entities/session.dart';
import '../../../l10n/app_localizations.dart';

/// Portrait "magazine cover" share variant. The user's photo fills the
/// 3:4 canvas; routine name reads bottom-to-top along the left edge; a
/// magazine masthead caps the top and a stats caption sits in the bottom
/// right. When no photo is supplied the card renders an editorial empty
/// state so the variant is still browsable in the share preview, just
/// non-shareable until a photo is added.
class MagazineCoverShareCard extends StatelessWidget {
  const MagazineCoverShareCard({
    super.key,
    required this.session,
    required this.accentColor,
    this.pr,
    this.userPhotoPath,
    this.photoAlignX = 0.0,
    this.photoAlignY = 0.0,
    this.photoScale = 1.0,
  });

  final Session session;
  final Color accentColor;
  final RecapPersonalRecord? pr;
  final String? userPhotoPath;
  final double photoAlignX;
  final double photoAlignY;
  final double photoScale;

  static const double logicalWidth = 360;
  static const double logicalHeight = 540;

  static const Color _bg = Color(0xFFEBE3D2);
  static const Color _ink = Color(0xFF1A1A1F);
  static const Color _mute = Color(0x8C1A1A1F);

  static bool hasUsablePhoto(String? path) =>
      path != null && path.isNotEmpty && File(path).existsSync();

  static String issueNumberFor(Session session) {
    final h = session.date.codeUnits.fold<int>(0, (a, b) => a + b);
    final n = (h % 999) + 1;
    return n.toString().padLeft(3, '0');
  }

  static String _monthYear(String iso, String locale) {
    try {
      final dt = DateTime.parse(iso);
      final mon = DateFormat.MMM(locale).format(dt).toUpperCase();
      return '$mon ${dt.year}';
    } catch (_) {
      return iso.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final hasPhoto = hasUsablePhoto(userPhotoPath);
    final issue = issueNumberFor(session);
    final monthYear = _monthYear(session.date, locale);

    return SizedBox(
      width: logicalWidth,
      height: logicalHeight,
      child: ClipRect(
        child: hasPhoto
            ? _CoverWithPhoto(
                session: session,
                accentColor: accentColor,
                pr: pr,
                photoPath: userPhotoPath!,
                photoAlignX: photoAlignX,
                photoAlignY: photoAlignY,
                photoScale: photoScale,
                issueNumber: issue,
                monthYear: monthYear,
                journalLabel: l10n.shareTrainingJournal,
                volumeLabel: l10n.volume.toUpperCase(),
                durationLabel: l10n.duration.toUpperCase(),
                setsLabel: l10n.sets.toUpperCase(),
                prBadgeLabel: l10n.sharePRBadge,
              )
            : _CoverEmpty(
                issueNumber: issue,
                monthYear: monthYear,
                journalLabel: l10n.shareTrainingJournal,
                emptyTitle: l10n.shareMagazineEmptyTitle,
                emptyBody: l10n.shareMagazineEmptyBody,
              ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Photo variant
// ───────────────────────────────────────────────────────────────────────────

class _CoverWithPhoto extends StatelessWidget {
  const _CoverWithPhoto({
    required this.session,
    required this.accentColor,
    required this.pr,
    required this.photoPath,
    required this.photoAlignX,
    required this.photoAlignY,
    required this.photoScale,
    required this.issueNumber,
    required this.monthYear,
    required this.journalLabel,
    required this.volumeLabel,
    required this.durationLabel,
    required this.setsLabel,
    required this.prBadgeLabel,
  });

  final Session session;
  final Color accentColor;
  final RecapPersonalRecord? pr;
  final String photoPath;
  final double photoAlignX;
  final double photoAlignY;
  final double photoScale;
  final String issueNumber;
  final String monthYear;
  final String journalLabel;
  final String volumeLabel;
  final String durationLabel;
  final String setsLabel;
  final String prBadgeLabel;

  @override
  Widget build(BuildContext context) {
    final totalSets =
        session.exercises?.fold<int>(0, (s, e) => s + e.sets.length) ?? 0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Photo background
        Positioned.fill(
          child: ClipRect(
            child: Transform.scale(
              scale: photoScale,
              alignment: Alignment(photoAlignX, photoAlignY),
              child: Image.file(
                File(photoPath),
                fit: BoxFit.cover,
                alignment: Alignment(photoAlignX, photoAlignY),
              ),
            ),
          ),
        ),

        // 2. Top scrim — dark gradient for masthead legibility
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 110,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99000000), Color(0x00000000)],
              ),
            ),
          ),
        ),

        // 3. Bottom scrim — dark gradient for caption legibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 160,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xB3000000), Color(0x00000000)],
              ),
            ),
          ),
        ),

        // 4. Left scrim — subtle gradient so the rotated title pops
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          width: 110,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0x4D000000), Color(0x00000000)],
              ),
            ),
          ),
        ),

        // 5. Masthead
        Positioned(
          top: 22,
          left: 22,
          right: 22,
          child: _MagazineMasthead(
            issue: issueNumber,
            monthYear: monthYear,
            journalLabel: journalLabel,
            color: Colors.white,
            muted: Colors.white.withValues(alpha: 0.78),
          ),
        ),

        // 6. PR ribbon below the masthead (right-aligned)
        if (pr != null)
          Positioned(
            top: 96,
            right: 22,
            child: _PrRibbon(pr: pr!, label: prBadgeLabel),
          ),

        // 7. Rotated routine name — reads bottom-to-top on the left edge.
        // RotatedBox transposes its child's constraints, so the inner
        // FittedBox sees a (vertical span × narrow band) and shrinks the
        // big Playfair text as needed for long routine names.
        Positioned(
          top: 100,
          bottom: 130,
          left: 0,
          width: 96,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, top: 6, bottom: 6),
            child: RotatedBox(
              quarterTurns: 3,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  session.routineName.toUpperCase(),
                  maxLines: 1,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 96,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 0.88,
                    letterSpacing: -3.0,
                  ),
                ),
              ),
            ),
          ),
        ),

        // 8. Bottom-right caption with hero volume + stats + accent dot
        Positioned(
          bottom: 22,
          right: 22,
          left: 110,
          child: _CornerCaption(
            volumeKg: session.volumeKg,
            durationMin: session.durationMin,
            totalSets: totalSets,
            issueNumber: issueNumber,
            routineColor: accentColor,
            volumeLabel: volumeLabel,
            durationLabel: durationLabel,
            setsLabel: setsLabel,
          ),
        ),
      ],
    );
  }
}

class _MagazineMasthead extends StatelessWidget {
  const _MagazineMasthead({
    required this.issue,
    required this.monthYear,
    required this.journalLabel,
    required this.color,
    required this.muted,
  });

  final String issue;
  final String monthYear;
  final String journalLabel;
  final Color color;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'VERSATILE',
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.36,
                color: color,
                height: 1.0,
              ),
            ),
            const Spacer(),
            Text(
              monthYear,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              journalLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
                color: muted,
              ),
            ),
            const Spacer(),
            Text(
              'ISSUE $issue',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
                color: muted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 0.8, color: color.withValues(alpha: 0.55)),
      ],
    );
  }
}

class _PrRibbon extends StatelessWidget {
  const _PrRibbon({required this.pr, required this.label});

  final RecapPersonalRecord pr;
  final String label;

  static const _cream = Color(0xFFEBE3D2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 7),
      constraints: const BoxConstraints(maxWidth: 220),
      decoration: const BoxDecoration(color: Color(0xFF1A1A1F)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            size: 12,
            color: _cream,
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: _cream,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${pr.exerciseName} · ${FormatUtils.weight(pr.weightKg)} × ${pr.reps}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: _cream,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerCaption extends StatelessWidget {
  const _CornerCaption({
    required this.volumeKg,
    required this.durationMin,
    required this.totalSets,
    required this.issueNumber,
    required this.routineColor,
    required this.volumeLabel,
    required this.durationLabel,
    required this.setsLabel,
  });

  final double volumeKg;
  final int durationMin;
  final int totalSets;
  final String issueNumber;
  final Color routineColor;
  final String volumeLabel;
  final String durationLabel;
  final String setsLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Volume eyebrow
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              volumeLabel,
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 22, height: 1, color: Colors.white),
          ],
        ),
        const SizedBox(height: 4),
        // Hero volume in Playfair, right-aligned
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: FormatUtils.volume(volumeKg),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 56,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 0.92,
                    letterSpacing: -1.6,
                  ),
                ),
                TextSpan(
                  text: ' kg',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 8),
        // Stats line: duration · sets
        Text(
          '${FormatUtils.duration(durationMin)} $durationLabel  ·  $totalSets $setsLabel',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 10),
        // Folio + accent swatch
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, color: routineColor),
            const SizedBox(width: 6),
            Text(
              'VOL $issueNumber / 999',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: Colors.white.withValues(alpha: 0.85),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Empty state (no photo)
// ───────────────────────────────────────────────────────────────────────────

class _CoverEmpty extends StatelessWidget {
  const _CoverEmpty({
    required this.issueNumber,
    required this.monthYear,
    required this.journalLabel,
    required this.emptyTitle,
    required this.emptyBody,
  });

  final String issueNumber;
  final String monthYear;
  final String journalLabel;
  final String emptyTitle;
  final String emptyBody;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MagazineCoverShareCard._bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 22,
            left: 22,
            right: 22,
            child: _MagazineMasthead(
              issue: issueNumber,
              monthYear: monthYear,
              journalLabel: journalLabel,
              color: MagazineCoverShareCard._ink,
              muted: MagazineCoverShareCard._mute,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '!',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 140,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: MagazineCoverShareCard._ink,
                      height: 1.0,
                      letterSpacing: -2.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 44,
                    height: 1,
                    color: MagazineCoverShareCard._ink,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptyTitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: MagazineCoverShareCard._ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    emptyBody,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: MagazineCoverShareCard._mute,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom: subtle folio so the empty state still feels like a page
          Positioned(
            bottom: 22,
            left: 22,
            right: 22,
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 1,
                  color: MagazineCoverShareCard._mute,
                ),
                const SizedBox(width: 8),
                Text(
                  'COVER · MAGAZINE',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: MagazineCoverShareCard._mute,
                  ),
                ),
                const Spacer(),
                Text(
                  'VOL $issueNumber / 999',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: MagazineCoverShareCard._mute,
                    fontFeatures: const [FontFeature.tabularFigures()],
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
