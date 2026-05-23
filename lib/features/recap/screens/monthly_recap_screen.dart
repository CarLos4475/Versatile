import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../view_models/recap_view_model.dart';
import '../widgets/recap_backdrop.dart';
import '../widgets/recap_slides.dart';

class MonthlyRecapScreen extends ConsumerStatefulWidget {
  const MonthlyRecapScreen({
    super.key,
    required this.monthKey,
  });
  final MonthKey monthKey;

  @override
  ConsumerState<MonthlyRecapScreen> createState() =>
      _MonthlyRecapScreenState();
}

// Per-slide auto-advance duration. Kept proportional to how much info the
// slide carries: cover/outro are quick reads, data slides need longer for
// the counters and bars to finish playing.
const _slideDurations = <Duration>[
  Duration(milliseconds: 3500),
  Duration(milliseconds: 5000),
  Duration(milliseconds: 5500),
  Duration(milliseconds: 5500),
  Duration(milliseconds: 5500),
  Duration(milliseconds: 5500),
  Duration(milliseconds: 4500),
];

class _MonthlyRecapScreenState extends ConsumerState<MonthlyRecapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  int _current = 0;
  bool _paused = false;
  bool _sharing = false;
  final _slideKeys = <int, GlobalKey>{};

  GlobalKey _keyForSlide(int index) {
    return _slideKeys.putIfAbsent(index, () => GlobalKey());
  }

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _advance();
      });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSlide();
    });
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _shareCurrentSlide() async {
    if (_sharing) return;
    final slides = _slides();
    final clamped = _current.clamp(0, slides.length - 1);
    final key = _slideKeys[clamped];
    if (key?.currentContext == null) return;
    setState(() => _sharing = true);
    ui.Image? rawImage;
    ui.Image? trimmedImage;
    try {
      const pixelRatio = 3.0;
      final boundary = key!.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      rawImage = await boundary.toImage(pixelRatio: pixelRatio);
      final trimmed = await _autoTrimPaperMargins(
        rawImage,
        pixelRatio: pixelRatio,
      );
      trimmedImage = trimmed;
      final byteData =
          await trimmed.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/versatile_recap_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
      );
    } finally {
      rawImage?.dispose();
      trimmedImage?.dispose();
      if (mounted) setState(() => _sharing = false);
    }
  }

  /// Detects the bounding box of non-paper content (text, hairlines, ink fills)
  /// in a captured slide image and returns a fresh image cropped to those
  /// bounds plus a small magazine margin. Paper grain (4% ink on bone) and the
  /// pure paper background stay above the brightness threshold, so they don't
  /// pollute the detection.
  Future<ui.Image> _autoTrimPaperMargins(
    ui.Image source, {
    required double pixelRatio,
  }) async {
    final byteData =
        await source.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return source;
    final bytes = byteData.buffer.asUint8List();
    final w = source.width;
    final h = source.height;

    // RGB-sum threshold: paper ≈ 672, grain ≈ 649, hairlineSoft ≈ 554,
    // hairlineStrong ≈ 478, ink text ≈ 83. 600 separates real content from
    // paper + grain without missing soft hairlines.
    const sumThreshold = 600;
    const sampleStep = 4;
    const minDarkRatio = 0.004;

    bool rowHasContent(int y) {
      final rowStart = y * w * 4;
      var dark = 0;
      var sampled = 0;
      for (var x = 0; x < w; x += sampleStep) {
        sampled++;
        final i = rowStart + x * 4;
        final sum = bytes[i] + bytes[i + 1] + bytes[i + 2];
        if (sum < sumThreshold) dark++;
      }
      return sampled > 0 && dark / sampled > minDarkRatio;
    }

    var firstContent = -1;
    for (var y = 0; y < h; y++) {
      if (rowHasContent(y)) {
        firstContent = y;
        break;
      }
    }
    if (firstContent < 0) return source; // nothing detected, leave as-is

    var lastContent = h - 1;
    for (var y = h - 1; y >= firstContent; y--) {
      if (rowHasContent(y)) {
        lastContent = y;
        break;
      }
    }

    final marginPx = (44 * pixelRatio).round();
    final cropTop = math.max(0, firstContent - marginPx);
    final cropBottom = math.min(h - 1, lastContent + marginPx);
    final cropHeight = cropBottom - cropTop + 1;
    if (cropHeight <= 0 || cropHeight >= h) return source;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      source,
      Rect.fromLTWH(0, cropTop.toDouble(), w.toDouble(), cropHeight.toDouble()),
      Rect.fromLTWH(0, 0, w.toDouble(), cropHeight.toDouble()),
      Paint(),
    );
    final picture = recorder.endRecording();
    final cropped = await picture.toImage(w, cropHeight);
    picture.dispose();
    return cropped;
  }

  void _startSlide() {
    final slides = _slides();
    if (_current >= slides.length) return;
    final duration =
        _slideDurations[_current.clamp(0, _slideDurations.length - 1)];
    _progress
      ..stop()
      ..duration = duration
      ..forward(from: 0);
  }

  void _advance() {
    final slides = _slides();
    if (_current >= slides.length - 1) {
      _markSeenAndClose();
      return;
    }
    setState(() => _current += 1);
    _startSlide();
  }

  void _retreat() {
    if (_current <= 0) {
      _progress.forward(from: 0);
      return;
    }
    setState(() => _current -= 1);
    _startSlide();
  }

  void _pause() {
    if (_paused) return;
    setState(() => _paused = true);
    _progress.stop();
  }

  void _resume() {
    if (!_paused) return;
    setState(() => _paused = false);
    _progress.forward();
  }

  Future<void> _markSeenAndClose() async {
    final key =
        '${widget.monthKey.year.toString().padLeft(4, '0')}-'
        '${widget.monthKey.month.toString().padLeft(2, '0')}';
    await ref.read(settingsRepositoryProvider).setRecapSeen(key);
    ref.invalidate(unseenLastRecapProvider);
    if (mounted) Navigator.of(context).pop();
  }

  List<Widget> _slides() {
    final recap = ref.read(monthlyRecapProvider(widget.monthKey));
    if (recap == null) return const [];

    final hasMuscleData =
        recap.volumeByMuscle.values.fold<double>(0, (s, v) => s + v) > 0;
    final hasVolume = recap.weeklyVolumeKg.any((v) => v > 0);

    // Count interior pages (everything except cover + outro) so the masthead
    // can show "PAGE X / N" with N stable across the issue.
    var interiorTotal = 1; // sessions always
    if (hasVolume) interiorTotal += 1;
    interiorTotal += 1; // calendar
    if (recap.topLift != null) interiorTotal += 1;
    if (hasMuscleData) interiorTotal += 1;

    final pages = <Widget>[CoverSlide(recap: recap)];
    var p = 1;
    pages.add(SessionsSlide(recap: recap, page: p++, total: interiorTotal));
    if (hasVolume) {
      pages.add(VolumeSlide(recap: recap, page: p++, total: interiorTotal));
    }
    pages.add(CalendarSlide(recap: recap, page: p++, total: interiorTotal));
    if (recap.topLift != null) {
      pages.add(TopLiftSlide(recap: recap, page: p++, total: interiorTotal));
    }
    if (hasMuscleData) {
      pages.add(MuscleBalanceSlide(recap: recap, page: p++, total: interiorTotal));
    }
    pages.add(OutroSlide(recap: recap, onClose: _markSeenAndClose));
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final recap = ref.watch(monthlyRecapProvider(widget.monthKey));
    if (recap == null) {
      return Scaffold(
        backgroundColor: context.colors.bgApp,
        body: SafeArea(
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.recapPastRecapsEmpty,
              style: TextStyle(color: context.colors.ink500),
            ),
          ),
        ),
      );
    }

    final slides = _slides();
    if (slides.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _markSeenAndClose());
      return const SizedBox.shrink();
    }
    final clamped = _current.clamp(0, slides.length - 1);

    return Scaffold(
      backgroundColor: RecapBackdrop.paperBg,
      // Editorial magazine takeover — force an ink DefaultTextStyle so child
      // Text widgets without an explicit color render dark on the bone paper.
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Captured layer: paper + grain + slide live together inside the
          // boundary so the share PNG carries the magazine background. Buttons
          // and progress bars are positioned ABOVE this layer and stay out of
          // the capture.
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (d) {
              final w = MediaQuery.of(context).size.width;
              if (d.globalPosition.dx < w * 0.35) {
                _retreat();
              } else {
                _advance();
              }
            },
            onLongPressStart: (_) => _pause(),
            onLongPressEnd: (_) => _resume(),
            onLongPressCancel: _resume,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Color(0xFF1A1A1F),
                decoration: TextDecoration.none,
              ),
              child: KeyedSubtree(
                key: ValueKey(clamped),
                child: RepaintBoundary(
                  key: _keyForSlide(clamped),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const RecapBackdrop(),
                      slides[clamped],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _ProgressBars(
                        total: slides.length,
                        current: clamped,
                        controller: _progress,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (clamped > 0 && clamped < slides.length - 1)
                      _ShareButton(
                        onTap: _sharing ? null : _shareCurrentSlide,
                        loading: _sharing,
                      ),
                    if (clamped > 0 && clamped < slides.length - 1)
                      const SizedBox(width: 8),
                    _CloseButton(onTap: _markSeenAndClose),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBars extends StatelessWidget {
  const _ProgressBars({
    required this.total,
    required this.current,
    required this.controller,
  });
  final int total;
  final int current;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            child: SizedBox(
              height: 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0x331A1A1F)),
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      double fill;
                      if (i < current) {
                        fill = 1;
                      } else if (i == current) {
                        fill = controller.value;
                      } else {
                        fill = 0;
                      }
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: fill,
                          heightFactor: 1,
                          child: Container(color: const Color(0xFF1A1A1F)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0x111A1A1F),
          border: Border.all(color: const Color(0x331A1A1F), width: 0.6),
        ),
        child: const Icon(
          Icons.close_rounded,
          size: 14,
          color: Color(0xFF1A1A1F),
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onTap, this.loading = false});
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0x111A1A1F),
          border: Border.all(color: const Color(0x331A1A1F), width: 0.6),
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1A1A1F),
                  ),
                ),
              )
            : const Icon(
                Icons.ios_share_rounded,
                size: 14,
                color: Color(0xFF1A1A1F),
              ),
      ),
    );
  }
}
