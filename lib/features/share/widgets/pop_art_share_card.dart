import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../domain/entities/session.dart';
import '../../../l10n/app_localizations.dart';

class PopArtShareCard extends StatelessWidget {
  const PopArtShareCard({
    super.key,
    required this.session,
    required this.cardColor,
    this.pr,
    this.userPhotoPath,
    this.photoAlignX = 0.0,
    this.photoAlignY = 0.0,
    this.photoScale = 1.0,
  });

  final Session session;
  final Color cardColor;
  final RecapPersonalRecord? pr;
  final String? userPhotoPath;
  final double photoAlignX;
  final double photoAlignY;
  final double photoScale;

  static bool hasUsablePhoto(String? path) =>
      path != null && path.isNotEmpty && File(path).existsSync();

  static const double logicalWidth = 360;
  static const double _baseHeight = 540;
  static const double _photoExtraHeight = 90;

  static double logicalHeightFor({required bool hasPhoto}) {
    return hasPhoto ? _baseHeight + _photoExtraHeight : _baseHeight;
  }

  static const double logicalHeight = 540;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final totalSets =
        session.exercises?.fold<int>(0, (s, e) => s + e.sets.length) ?? 0;
    final totalExercises = session.exercises?.length ?? 0;
    final useDarkFg = cardColor.computeLuminance() > 0.4;
    final fg = useDarkFg ? const Color(0xFF1A1A1F) : Colors.white;
    final strokeColor = useDarkFg ? Colors.white : const Color(0xFF1A1A1F);

    final hasPhoto = hasUsablePhoto(userPhotoPath);
    final height = logicalHeightFor(hasPhoto: hasPhoto);

    return SizedBox(
      width: logicalWidth,
      height: height,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: cardColor),

            Positioned.fill(
              child: CustomPaint(
                painter: _HalftonePainter(
                  color: fg.withValues(alpha: 0.09),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PopMasthead(fg: fg, date: session.date, locale: locale),
                  const SizedBox(height: 12),
                  Transform.rotate(
                    angle: -0.07,
                    child: _PopTitle(
                      name: session.routineName,
                      fill: fg,
                      stroke: strokeColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SpeechBubble(
                    volumeKg: session.volumeKg,
                    label: l10n.volumeTotal.toUpperCase(),
                  ),
                  if (hasUsablePhoto(userPhotoPath)) ...[
                    const SizedBox(height: 14),
                    Transform.rotate(
                      angle: 0.07,
                      child: _PopPhoto(
                        path: userPhotoPath!,
                        alignX: photoAlignX,
                        alignY: photoAlignY,
                        scale: photoScale,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (pr != null) ...[
                    _PrBadge(pr: pr!, label: l10n.sharePRBadge),
                    const SizedBox(height: 12),
                  ],
                  _PopStats(
                    durationMin: session.durationMin,
                    totalSets: totalSets,
                    totalExercises: totalExercises,
                    durationLabel: l10n.duration.toUpperCase(),
                    setsLabel: l10n.sets.toUpperCase(),
                    exercisesLabel: l10n.exercisesLabel.toUpperCase(),
                  ),
                  const SizedBox(height: 14),
                  _PopFooter(
                    fg: fg,
                    journalLabel: l10n.shareTrainingJournal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Halftone dots
// ─────────────────────────────────────────────────────────────────────────────

class _HalftonePainter extends CustomPainter {
  _HalftonePainter({required this.color});
  final Color color;

  static const double _dotR = 3.2;
  static const double _spacing = 13;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    int row = 0;
    for (double y = _spacing / 2; y < size.height; y += _spacing, row++) {
      final offsetX = (row.isOdd) ? _spacing / 2 : 0.0;
      for (double x = offsetX; x < size.width; x += _spacing) {
        canvas.drawCircle(Offset(x, y), _dotR, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HalftonePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Masthead
// ─────────────────────────────────────────────────────────────────────────────

class _PopMasthead extends StatelessWidget {
  const _PopMasthead({
    required this.fg,
    required this.date,
    required this.locale,
  });

  final Color fg;
  final String date;
  final String locale;

  @override
  Widget build(BuildContext context) {
    String formatted;
    try {
      final dt = DateTime.parse(date);
      final mon = DateFormat.MMM(locale).format(dt).toUpperCase();
      formatted = '$mon ${dt.day.toString().padLeft(2, '0')} · ${dt.year}';
    } catch (_) {
      formatted = date.toUpperCase();
    }

    return Row(
      children: [
        Text(
          'VERSATILE',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: fg,
          ),
        ),
        const Spacer(),
        Text(
          formatted,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: fg.withValues(alpha: 0.7),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Title — outlined comic lettering
// ─────────────────────────────────────────────────────────────────────────────

class _PopTitle extends StatelessWidget {
  const _PopTitle({
    required this.name,
    required this.fill,
    required this.stroke,
  });

  final String name;
  final Color fill;
  final Color stroke;

  @override
  Widget build(BuildContext context) {
    final text = name.toUpperCase();
    const fontSize = 64.0;
    const height = 0.92;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 140),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: Stack(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                height: height,
                letterSpacing: -1.5,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 5
                  ..color = stroke,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                height: height,
                letterSpacing: -1.5,
                color: fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Speech bubble with volume
// ─────────────────────────────────────────────────────────────────────────────

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.volumeKg, required this.label});

  final double volumeKg;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: FormatUtils.volume(volumeKg),
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A1F),
                        height: 1.0,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const TextSpan(
                      text: ' kg',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A1F),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: const Color(0xFF1A1A1F).withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  static const double _tailH = 16;
  static const double _r = 18;
  static const double _bw = 3.5;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyH = size.height - _tailH;
    final path = Path();
    path.moveTo(_r, 0);
    path.lineTo(size.width - _r, 0);
    path.arcToPoint(Offset(size.width, _r),
        radius: const Radius.circular(_r));
    path.lineTo(size.width, bodyH - _r);
    path.arcToPoint(Offset(size.width - _r, bodyH),
        radius: const Radius.circular(_r));
    path.lineTo(65, bodyH);
    path.lineTo(32, bodyH + _tailH);
    path.lineTo(40, bodyH);
    path.lineTo(_r, bodyH);
    path.arcToPoint(Offset(0, bodyH - _r),
        radius: const Radius.circular(_r));
    path.lineTo(0, _r);
    path.arcToPoint(Offset(_r, 0), radius: const Radius.circular(_r));
    path.close();

    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1A1A1F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _bw
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row — thick comic borders
// ─────────────────────────────────────────────────────────────────────────────

class _PopStats extends StatelessWidget {
  const _PopStats({
    required this.durationMin,
    required this.totalSets,
    required this.totalExercises,
    required this.durationLabel,
    required this.setsLabel,
    required this.exercisesLabel,
  });

  final int durationMin;
  final int totalSets;
  final int totalExercises;
  final String durationLabel;
  final String setsLabel;
  final String exercisesLabel;

  static const _ink = Color(0xFF1A1A1F);
  static const _bw = 3.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _ink, width: _bw),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _PopStatCell(
                value: FormatUtils.duration(durationMin),
                label: durationLabel,
              ),
            ),
            Container(width: _bw, color: _ink),
            Expanded(
              child: _PopStatCell(
                value: '$totalSets',
                label: setsLabel,
              ),
            ),
            Container(width: _bw, color: _ink),
            Expanded(
              child: _PopStatCell(
                value: '$totalExercises',
                label: exercisesLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopStatCell extends StatelessWidget {
  const _PopStatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1F),
              height: 1.0,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: const Color(0xFF1A1A1F).withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PR badge — comic caption box
// ─────────────────────────────────────────────────────────────────────────────

class _PrBadge extends StatelessWidget {
  const _PrBadge({required this.pr, required this.label});

  final RecapPersonalRecord pr;
  final String label;

  static const _ink = Color(0xFF1A1A1F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _ink, width: 3.0),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            size: 18,
            color: _ink,
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: _ink,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${pr.exerciseName} · ${FormatUtils.weight(pr.weightKg)} × ${pr.reps}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _ink.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo — thick comic border
// ─────────────────────────────────────────────────────────────────────────────

class _PopPhoto extends StatelessWidget {
  const _PopPhoto({
    required this.path,
    required this.alignX,
    required this.alignY,
    required this.scale,
  });

  final String path;
  final double alignX;
  final double alignY;
  final double scale;

  static const _ink = Color(0xFF1A1A1F);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _ink, width: 3.5),
      ),
      child: AspectRatio(
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────────────────────

class _PopFooter extends StatelessWidget {
  const _PopFooter({required this.fg, required this.journalLabel});

  final Color fg;
  final String journalLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 22, height: 3, color: fg),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            journalLabel.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: fg.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
