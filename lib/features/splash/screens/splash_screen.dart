import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app.dart';
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
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
    // Run cleanup silently in background — don't block navigation on it
    unawaited(ref.read(cleanupOldSessionsProvider.future).catchError((_) {}));
    // These must complete before navigation
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
    return Scaffold(
      backgroundColor: context.colors.bgFrame,
      body: Stack(
        children: [
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
                        gradient: LinearGradient(
                          colors: [
                            context.colors.accentLight,
                            context.colors.accent,
                            context.colors.accentDeep,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.accentDeep.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 48,
                            offset: const Offset(0, 24),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.4),
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
                  child: Text(
                    'Versatile',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1.32,
                      color: context.colors.ink900,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FadeTransition(
                  opacity: _fade,
                  child: Text(
                    'Your training, every rep.',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.ink500,
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
            child: FadeTransition(opacity: _fade, child: const _PulseDots()),
          ),
        ],
      ),
    );
  }
}

class _PulseDots extends StatefulWidget {
  const _PulseDots({super.key});

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
