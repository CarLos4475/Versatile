import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../domain/entities/session.dart';
import '../../../l10n/app_localizations.dart';

/// Two-photo collage variant where the routine's accent color is the
/// protagonist. A hero photo and a smaller secondary photo are laid out
/// asymmetrically on top of the accent field, with editorial typography in
/// the corners. Missing photos render as outlined placeholders so the
/// composition is still browsable in the share preview, gated by the
/// screen until both slots are filled.
class MagazineCollageShareCard extends StatelessWidget {
  const MagazineCollageShareCard({
    super.key,
    required this.session,
    required this.accentColor,
    this.pr,
    this.heroPhotoPath,
    this.heroAlignX = 0.0,
    this.heroAlignY = 0.0,
    this.heroScale = 1.0,
    this.secondaryPhotoPath,
    this.secondaryAlignX = 0.0,
    this.secondaryAlignY = 0.0,
    this.secondaryScale = 1.0,
  });

  final Session session;
  final Color accentColor;
  final RecapPersonalRecord? pr;

  final String? heroPhotoPath;
  final double heroAlignX;
  final double heroAlignY;
  final double heroScale;

  final String? secondaryPhotoPath;
  final double secondaryAlignX;
  final double secondaryAlignY;
  final double secondaryScale;

  static const double logicalWidth = 360;
  static const double logicalHeight = 540;

  // Hero photo occupies the upper-right quadrant; secondary overlaps the
  // hero's lower-left for visual tension. Coordinates are logical pixels
  // relative to the 360×540 canvas.
  static const Rect _heroRect = Rect.fromLTWH(118, 95, 230, 270);
  static const Rect _secondaryRect = Rect.fromLTWH(22, 270, 170, 218);

  static bool hasUsablePhoto(String? path) =>
      path != null && path.isNotEmpty && File(path).existsSync();

  static String _issueNumberFor(Session session) {
    final h = session.date.codeUnits.fold<int>(0, (a, b) => a + b);
    final n = (h % 999) + 1;
    return n.toString().padLeft(3, '0');
  }

  static String _monthLabel(String iso, String locale) {
    try {
      final dt = DateTime.parse(iso);
      final mon = DateFormat.MMM(locale).format(dt).toUpperCase();
      return '$mon ${dt.day.toString().padLeft(2, '0')} · ${dt.year}';
    } catch (_) {
      return iso.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final accent = accentColor;
    // Pick a foreground color that reads on the accent (bone for dark
    // accents, ink for light ones).
    final useLightInk = accent.computeLuminance() > 0.55;
    final fg = useLightInk ? const Color(0xFF1A1A1F) : const Color(0xFFEBE3D2);
    final fgMute = fg.withValues(alpha: 0.65);
    final issue = _issueNumberFor(session);
    final dateLabel = _monthLabel(session.date, locale);
    final totalSets =
        session.exercises?.fold<int>(0, (s, e) => s + e.sets.length) ?? 0;
    final isEs = locale == 'es';

    return SizedBox(
      width: logicalWidth,
      height: logicalHeight,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Accent field
            ColoredBox(color: accent),

            // 1.5. Floating accent-shade blocks
            Positioned(
              bottom: 44,
              right: 24,
              width: 200,
              height: 360,
              child: ColoredBox(
                color: Color.lerp(accent, Colors.black, 0.18) ?? accent,
              ),
            ),
            Positioned(
              top: 30,
              left: 18,
              width: 260,
              height: 200,
              child: ColoredBox(
                color: Color.lerp(accent, Colors.black, 0.18) ?? accent,
              ),
            ),

            // 2. Top-left editorial title
            Positioned(
              top: 22,
              left: 22,
              right: 26,
              child: _CollageTitle(
                routineName: session.routineName,
                subtitle: isEs ? 'UN ESTUDIO VERSATILE' : 'A VERSATILE STUDY',
                dateLabel: dateLabel,
                ink: fg,
                mute: fgMute,
              ),
            ),

            // 3. Hero photo (top-right). Larger, anchors the composition.
            Positioned.fromRect(
              rect: _heroRect,
              child: _CollagePhoto(
                path: heroPhotoPath,
                alignX: heroAlignX,
                alignY: heroAlignY,
                scale: heroScale,
                ink: fg,
                mute: fgMute,
                accent: accent,
                slotLabel: isEs ? 'FOTO 1' : 'PHOTO 1',
                addLabel: isEs ? 'AÑADIR FOTO' : 'ADD PHOTO',
              ),
            ),

            // 4. Secondary photo overlapping the hero's bottom-left.
            Positioned.fromRect(
              rect: _secondaryRect,
              child: _CollagePhoto(
                path: secondaryPhotoPath,
                alignX: secondaryAlignX,
                alignY: secondaryAlignY,
                scale: secondaryScale,
                ink: fg,
                mute: fgMute,
                accent: accent,
                slotLabel: isEs ? 'FOTO 2' : 'PHOTO 2',
                addLabel: isEs ? 'AÑADIR FOTO' : 'ADD PHOTO',
              ),
            ),

            // 5. PR ribbon (optional) — sits to the right of the title
            if (pr != null)
              Positioned(
                top: 22,
                right: 22,
                child: _CollagePrBadge(
                  pr: pr!,
                  label: l10n.sharePRBadge,
                  ink: fg,
                  accent: accent,
                ),
              ),

            // 6. Stats caption bottom-left, under the secondary photo
            Positioned(
              bottom: 64,
              left: 22,
              right: 22,
              child: _CollageStats(
                volumeKg: session.volumeKg,
                durationMin: session.durationMin,
                totalSets: totalSets,
                durationLabel: l10n.duration.toUpperCase(),
                setsLabel: l10n.sets.toUpperCase(),
                ink: fg,
                mute: fgMute,
              ),
            ),

            // 7. Folio at the very bottom
            Positioned(
              bottom: 22,
              left: 22,
              right: 22,
              child: _CollageFooter(
                issue: issue,
                journalLabel: l10n.shareTrainingJournal,
                ink: fg,
                mute: fgMute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Title (top-left)
// ───────────────────────────────────────────────────────────────────────────

class _CollageTitle extends StatelessWidget {
  const _CollageTitle({
    required this.routineName,
    required this.subtitle,
    required this.dateLabel,
    required this.ink,
    required this.mute,
  });

  final String routineName;
  final String subtitle;
  final String dateLabel;
  final Color ink;
  final Color mute;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
            color: mute,
          ),
        ),
        const SizedBox(height: 6),
        Container(width: 26, height: 1, color: ink),
        const SizedBox(height: 10),
        Text(
          routineName.toUpperCase(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.w600,
            color: ink,
            height: 0.94,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          dateLabel,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: mute,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Photo tile (filled or placeholder)
// ───────────────────────────────────────────────────────────────────────────

class _CollagePhoto extends StatelessWidget {
  const _CollagePhoto({
    required this.path,
    required this.alignX,
    required this.alignY,
    required this.scale,
    required this.ink,
    required this.mute,
    required this.accent,
    required this.slotLabel,
    required this.addLabel,
  });

  final String? path;
  final double alignX;
  final double alignY;
  final double scale;
  final Color ink;
  final Color mute;
  final Color accent;
  final String slotLabel;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        path != null && path!.isNotEmpty && File(path!).existsSync();

    return ClipRect(
      child: hasPhoto
          ? Transform.scale(
              scale: scale,
              alignment: Alignment(alignX, alignY),
              child: Image.file(
                File(path!),
                fit: BoxFit.cover,
                alignment: Alignment(alignX, alignY),
              ),
            )
          : _PhotoPlaceholder(
              slotLabel: slotLabel,
              addLabel: addLabel,
              ink: ink,
              mute: mute,
            ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({
    required this.slotLabel,
    required this.addLabel,
    required this.ink,
    required this.mute,
  });

  final String slotLabel;
  final String addLabel;
  final Color ink;
  final Color mute;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ink.withValues(alpha: 0.06),
        border: Border.all(color: ink.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 22,
              color: ink.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              slotLabel,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
                color: ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              addLabel,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// PR ribbon
// ───────────────────────────────────────────────────────────────────────────

class _CollagePrBadge extends StatelessWidget {
  const _CollagePrBadge({
    required this.pr,
    required this.label,
    required this.ink,
    required this.accent,
  });

  final RecapPersonalRecord pr;
  final String label;
  final Color ink;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 7),
      constraints: const BoxConstraints(maxWidth: 180),
      decoration: BoxDecoration(color: ink),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: 12,
                color: accent,
              ),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${pr.exerciseName} · ${FormatUtils.weight(pr.weightKg)} × ${pr.reps}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: accent.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Stats caption
// ───────────────────────────────────────────────────────────────────────────

class _CollageStats extends StatelessWidget {
  const _CollageStats({
    required this.volumeKg,
    required this.durationMin,
    required this.totalSets,
    required this.durationLabel,
    required this.setsLabel,
    required this.ink,
    required this.mute,
  });

  final double volumeKg;
  final int durationMin;
  final int totalSets;
  final String durationLabel;
  final String setsLabel;
  final Color ink;
  final Color mute;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: FormatUtils.volume(volumeKg),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 34,
                          fontWeight: FontWeight.w500,
                          color: ink,
                          height: 0.95,
                          letterSpacing: -0.8,
                        ),
                      ),
                      TextSpan(
                        text: ' kg',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: mute,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${FormatUtils.duration(durationMin)} $durationLabel  ·  $totalSets $setsLabel',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Footer
// ───────────────────────────────────────────────────────────────────────────

class _CollageFooter extends StatelessWidget {
  const _CollageFooter({
    required this.issue,
    required this.journalLabel,
    required this.ink,
    required this.mute,
  });

  final String issue;
  final String journalLabel;
  final Color ink;
  final Color mute;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'VERSATILE',
          style: GoogleFonts.playfairDisplay(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.36,
            color: ink,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 3, height: 3, color: mute),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            journalLabel.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: mute,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'VOL $issue / 999',
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: ink,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
