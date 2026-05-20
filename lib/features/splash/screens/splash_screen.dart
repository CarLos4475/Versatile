import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app.dart';
import '../../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../../core/services/workout_notification_service.dart';
import '../../active_workout/view_models/active_workout_view_model.dart';
import '../../home/view_models/home_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();

    // Run cleanup and navigation concurrently with a minimum splash duration
    Future.wait([
      _runStartupTasks(),
      Future.delayed(const Duration(milliseconds: 2500)),
    ]).then((_) {
      if (mounted) _navigate();
    });
  }

  // Holds the results of async startup work so _navigate can use them
  bool _onboarded = false;
  ActiveWorkoutInfo? _activeInfo;

  Future<void> _runStartupTasks() async {
    _activeInfo = await WorkoutNotificationService.getActiveWorkout();
    _onboarded = await ref.read(settingsRepositoryProvider).isOnboarded();
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    if (_activeInfo != null) {
      // Store the workout info in a provider so MainNavigationShell can push
      // the workout screen from its own stable context — avoids the black-screen
      // bug that occurred when navigating from a SplashScreen context that was
      // already removed from the tree before the postFrameCallback fired.
      ref.read(pendingWorkoutRestoreProvider.notifier).state = _activeInfo;
      Navigator.of(
        context,
      ).pushReplacement(AppRoute(page: const MainNavigationShell()));
      return;
    }

    Navigator.of(context).pushReplacement(
      AppRoute(
        page: _onboarded
            ? const MainNavigationShell()
            : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final isCompact = MediaQuery.sizeOf(context).height < 760;

    return Scaffold(
      backgroundColor: colors.bgFrame,
      body: Stack(
        children: [
          const Positioned.fill(child: _SplashGlow()),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 10, 26, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      _VersionMeta(text: 'v1.0'),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Eyebrow(text: l10n.splashEyebrow),
                            const SizedBox(height: 18),
                            _Wordmark(compact: isCompact),
                            const SizedBox(height: 22),
                            _Tagline(
                              prefix: l10n.splashTaglinePrefix,
                              accent: l10n.splashTaglineAccent,
                            ),
                          ],
                        ),
                      ),
                      _Footer(loadingLabel: l10n.splashLoading),
                    ],
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

class _SplashGlow extends StatelessWidget {
  const _SplashGlow();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      children: [
        Positioned(
          top: -160,
          right: -140,
          child: _GlowOrb(
            size: 440,
            color: colors.accent.withValues(alpha: 0.40),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -100,
          child: _GlowOrb(
            size: 360,
            color: colors.accentLight.withValues(alpha: 0.18),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionMeta extends StatelessWidget {
  const _VersionMeta({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 18,
          height: 1,
          color: colors.ink400.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.32,
            color: colors.ink500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        _PulsingDot(color: colors.accentLight),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
              color: colors.accentLight,
            ),
          ),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.45 + 0.35 * t),
                blurRadius: 10 + 4 * t,
                spreadRadius: t,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = compact ? 92.0 : 108.0;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Versa-\ntile',
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w500,
              letterSpacing: -size * 0.055,
              height: 0.86,
              color: colors.ink900,
            ),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              letterSpacing: -size * 0.06,
              color: colors.accentLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline({required this.prefix, required this.accent});

  final String prefix;
  final String accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 17,
            height: 1.4,
            fontWeight: FontWeight.w400,
            color: colors.ink500,
          ),
          children: [
            TextSpan(text: '$prefix '),
            TextSpan(
              text: accent,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: colors.accentLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.loadingLabel});

  final String loadingLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          color: colors.hairline,
          margin: const EdgeInsets.only(bottom: 18),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _PulseDots(),
            Text(
              loadingLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
                color: colors.ink400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PulseDots extends StatefulWidget {
  const _PulseDots();

  @override
  State<_PulseDots> createState() => _PulseDotsState();
}

class _PulseDotsState extends State<_PulseDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              final delay = i * 0.2;
              final t = ((_ctrl.value - delay) % 1.0).abs();
              final opacity = 0.3 + 0.7 * (1 - (t * 2 - 1).abs());
              return Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: context.colors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
