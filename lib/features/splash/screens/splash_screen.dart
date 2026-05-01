import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app.dart';
import '../../onboarding/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final settings = ref.read(settingsRepositoryProvider);
    final onboarded = await settings.isOnboarded();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondary) =>
            onboarded ? const MainShell() : const OnboardingScreen(),
        transitionsBuilder: (context, anim, secondary, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
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
    return Scaffold(
      backgroundColor: AppColors.bgFrame,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [Color(0x80D97757), Colors.transparent],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE08866),
                            Color(0xFFD97757),
                            Color(0xFFB85432),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentDeep.withOpacity(0.4),
                            blurRadius: 48,
                            offset: const Offset(0, 24),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 0,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fade,
                  child: const Text(
                    'Versatile',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1.32,
                      color: AppColors.ink900,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FadeTransition(
                  opacity: _fade,
                  child: const Text(
                    'Your training, every rep.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.ink500,
                      letterSpacing: 0.01,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fade,
              child: const _PulseDots(),
            ),
          ),
        ],
      ),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
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
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
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
