import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Shared dialog that lets the user pan + pinch-zoom a photo to choose how
/// it crops within a given aspect ratio. Returns `{x, y, scale}` on save.
class PhotoRepositionDialog extends StatefulWidget {
  const PhotoRepositionDialog({
    super.key,
    required this.imagePath,
    required this.initialAlignX,
    required this.initialAlignY,
    required this.initialScale,
    required this.aspectRatio,
  });

  final String imagePath;
  final double initialAlignX;
  final double initialAlignY;
  final double initialScale;
  final double aspectRatio;

  @override
  State<PhotoRepositionDialog> createState() => _PhotoRepositionDialogState();
}

class _PhotoRepositionDialogState extends State<PhotoRepositionDialog> {
  static const double _minScale = 1.0;
  static const double _maxScale = 3.0;

  double? _imageWidth;
  double? _imageHeight;
  late double _alignX;
  late double _alignY;
  late double _scale;
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    _alignX = widget.initialAlignX;
    _alignY = widget.initialAlignY;
    _scale = widget.initialScale.clamp(_minScale, _maxScale);
    _loadImageDimensions();
  }

  void _loadImageDimensions() async {
    try {
      final file = File(widget.imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final decoded = await decodeImageFromList(bytes);
        if (mounted) {
          setState(() {
            _imageWidth = decoded.width.toDouble();
            _imageHeight = decoded.height.toDouble();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading image dimensions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    // AlertDialog uses IntrinsicWidth on its content, and LayoutBuilder can't
    // provide intrinsic dimensions. Compute width from MediaQuery instead.
    final screenWidth = MediaQuery.of(context).size.width;
    const dialogInset = 40.0;
    const contentInset = 20.0;
    final containerWidth =
        (screenWidth - (dialogInset * 2) - (contentInset * 2))
            .clamp(160.0, 400.0);
    final containerHeight = containerWidth / widget.aspectRatio;

    return AlertDialog(
      backgroundColor: colors.bgFrame,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: Text(
        l10n.editorialReposition.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: colors.ink900,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      content: SizedBox(
        width: containerWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onScaleStart: (_) {
                _baseScale = _scale;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scale = (_baseScale * details.scale)
                      .clamp(_minScale, _maxScale);

                  final dx = details.focalPointDelta.dx;
                  final dy = details.focalPointDelta.dy;

                  if (_imageWidth == null || _imageHeight == null) {
                    _alignX = (_alignX - dx / (150.0 * _scale))
                        .clamp(-1.0, 1.0);
                    _alignY = (_alignY - dy / (150.0 * _scale))
                        .clamp(-1.0, 1.0);
                    return;
                  }

                  final imageAR = _imageWidth! / _imageHeight!;
                  final containerAR = widget.aspectRatio;

                  double effW;
                  double effH;
                  if (imageAR > containerAR) {
                    final scaledWidth = containerHeight * imageAR;
                    effW = scaledWidth * _scale;
                    effH = containerHeight * _scale;
                  } else {
                    final scaledHeight = containerWidth / imageAR;
                    effW = containerWidth * _scale;
                    effH = scaledHeight * _scale;
                  }
                  final extraW = effW - containerWidth;
                  final extraH = effH - containerHeight;

                  if (extraW > 0) {
                    _alignX = (_alignX - (2.0 * dx) / extraW)
                        .clamp(-1.0, 1.0);
                  }
                  if (extraH > 0) {
                    _alignY = (_alignY - (2.0 * dy) / extraH)
                        .clamp(-1.0, 1.0);
                  }
                });
              },
              onDoubleTap: () {
                setState(() {
                  if (_scale > _minScale + 0.01) {
                    _scale = _minScale;
                    _alignX = 0.0;
                    _alignY = 0.0;
                  } else {
                    _scale = 2.0;
                  }
                });
              },
              child: Container(
                width: containerWidth,
                height: containerHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: colors.hairline, width: 0.5),
                ),
                clipBehavior: Clip.hardEdge,
                child: Transform.scale(
                  scale: _scale,
                  // Anchor the zoom at the chosen align point so X panning
                  // also works for photos that already fit the container's
                  // width at scale=1 (typical phone photos in a 16:9 strip).
                  alignment: Alignment(_alignX, _alignY),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                    alignment: Alignment(_alignX, _alignY),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.editorialDragInstructions,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: colors.ink400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.hairline, width: 0.5),
                  ),
                  child: Text(
                    l10n.cancel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: colors.ink500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(<String, double>{
                  'x': _alignX,
                  'y': _alignY,
                  'scale': _scale,
                }),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  color: colors.accent,
                  child: Text(
                    l10n.save.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
