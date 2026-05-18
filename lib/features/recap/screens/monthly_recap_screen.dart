import 'dart:io';
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
    try {
      final boundary = key!.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
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
      if (mounted) setState(() => _sharing = false);
    }
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

    return [
      CoverSlide(recap: recap),
      SessionsSlide(recap: recap),
      if (hasVolume) VolumeSlide(recap: recap),
      CalendarSlide(recap: recap),
      if (recap.topLift != null) TopLiftSlide(recap: recap),
      if (hasMuscleData) MuscleBalanceSlide(recap: recap),
      OutroSlide(recap: recap, onClose: _markSeenAndClose),
    ];
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
      backgroundColor: const Color(0xFF0E0B07),
      // The Stories layout is a takeover — force a bone DefaultTextStyle so
      // child Text widgets without an explicit color don't inherit the
      // ambient theme's dark text color (the Scaffold sits inside a Material
      // whose textTheme follows the app theme, which is dark text in light
      // mode and would render invisible on this warm-dark backdrop).
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RecapBackdrop(),
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
                  color: Color(0xFFF5EFE2),
                  decoration: TextDecoration.none,
                ),
                child: KeyedSubtree(
                  key: ValueKey(clamped),
                  child: RepaintBoundary(
                    key: _keyForSlide(clamped),
                    child: slides[clamped],
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
              height: 2.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.white.withValues(alpha: 0.16)),
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
                            child: Container(color: const Color(0xFFF5EFE2)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.close_rounded,
          size: 16,
          color: Color(0xFFF5EFE2),
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFF5EFE2),
                  ),
                ),
              )
            : const Icon(
                Icons.ios_share_rounded,
                size: 16,
                color: Color(0xFFF5EFE2),
              ),
      ),
    );
  }
}
