import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'motion.dart';

class CoachmarkOverlay extends StatefulWidget {
  const CoachmarkOverlay({
    super.key,
    required this.targetRect,
    required this.title,
    required this.body,
    required this.gotItLabel,
    required this.skipLabel,
    required this.onGotIt,
    required this.onSkip,
  });

  final Rect targetRect;
  final String title;
  final String body;
  final String gotItLabel;
  final String skipLabel;
  final VoidCallback onGotIt;
  final VoidCallback onSkip;

  static void show({
    required BuildContext context,
    required GlobalKey targetKey,
    required String title,
    required String body,
    required String gotItLabel,
    required String skipLabel,
    required VoidCallback onDone,
  }) {
    final renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final rect = offset & renderBox.size;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => CoachmarkOverlay(
        targetRect: rect,
        title: title,
        body: body,
        gotItLabel: gotItLabel,
        skipLabel: skipLabel,
        onGotIt: () {
          entry.remove();
          onDone();
        },
        onSkip: () {
          entry.remove();
          onDone();
        },
      ),
    );
    Overlay.of(context).insert(entry);
  }

  @override
  State<CoachmarkOverlay> createState() => _CoachmarkOverlayState();
}

class _CoachmarkOverlayState extends State<CoachmarkOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _backdrop;
  late Animation<double> _spotlight;
  late Animation<double> _cardOpacity;
  late Animation<Offset> _cardSlide;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 580),
      vsync: this,
    );
    _backdrop = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _spotlight = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.08, 0.68, curve: Curves.easeOutBack),
    );
    _cardOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.42, 1.0, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.42, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _dismiss(VoidCallback action) {
    if (_dismissing) return;
    _dismissing = true;
    _ctrl
        .animateTo(0.0, duration: const Duration(milliseconds: 280),
            curve: Curves.easeIn)
        .then((_) => action());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screen = MediaQuery.of(context).size;
    final target = widget.targetRect;

    const cardPadding = 22.0;
    const cardEstimatedHeight = 180.0;
    const gap = 22.0;

    final spaceBelow = screen.height - target.bottom;
    final showBelow = spaceBelow >= cardEstimatedHeight + gap + 24;

    final cardTop = showBelow ? target.bottom + gap : null;
    final cardBottom =
        showBelow ? null : screen.height - target.top + gap;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                size: screen,
                painter: _SpotlightPainter(
                  targetRect: target,
                  spotlightProgress: _spotlight.value,
                  backdropProgress: _backdrop.value,
                  ringColor: colors.accent,
                ),
              ),
              GestureDetector(
                onTap: () => _dismiss(widget.onGotIt),
                behavior: HitTestBehavior.translucent,
              ),
              Positioned(
                left: cardPadding,
                right: cardPadding,
                top: cardTop,
                bottom: cardBottom,
                child: FadeTransition(
                  opacity: _cardOpacity,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: GestureDetector(
                      onTap: () {},
                      child: _TooltipCard(
                        title: widget.title,
                        body: widget.body,
                        gotItLabel: widget.gotItLabel,
                        skipLabel: widget.skipLabel,
                        onGotIt: () => _dismiss(widget.onGotIt),
                        onSkip: () => _dismiss(widget.onSkip),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.targetRect,
    required this.spotlightProgress,
    required this.backdropProgress,
    required this.ringColor,
  });

  final Rect targetRect;
  final double spotlightProgress;
  final double backdropProgress;
  final Color ringColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.72 * backdropProgress),
    );

    if (spotlightProgress > 0) {
      const padding = 16.0;
      final w = (targetRect.width + padding * 2) * spotlightProgress;
      final h = (targetRect.height + padding * 2) * spotlightProgress;
      final center = targetRect.center;
      final spotRect =
          Rect.fromCenter(center: center, width: w, height: h);
      const radius = Radius.circular(22.0);

      canvas.drawRRect(
        RRect.fromRectAndRadius(spotRect, radius),
        Paint()..blendMode = BlendMode.clear,
      );
      canvas.restore();

      canvas.drawRRect(
        RRect.fromRectAndRadius(spotRect.inflate(1.5), radius),
        Paint()
          ..color = ringColor.withValues(alpha: 0.55 * spotlightProgress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    } else {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.spotlightProgress != spotlightProgress ||
      old.backdropProgress != backdropProgress;
}

class _TooltipCard extends StatelessWidget {
  const _TooltipCard({
    required this.title,
    required this.body,
    required this.gotItLabel,
    required this.skipLabel,
    required this.onGotIt,
    required this.onSkip,
  });

  final String title;
  final String body;
  final String gotItLabel;
  final String skipLabel;
  final VoidCallback onGotIt;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: colors.bgFrame,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.glassBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: colors.ink900,
              letterSpacing: -0.38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              color: colors.ink500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              GestureDetector(
                onTap: onSkip,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 2),
                  child: Text(
                    skipLabel,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.ink400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              PressableScale(
                onTap: onGotIt,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.accentLight, colors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colors.accentDeep.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    gotItLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
