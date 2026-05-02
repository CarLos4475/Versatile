import 'package:flutter/material.dart';

class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return buildAppRouteTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class AppRoute<T> extends PageRouteBuilder<T> {
  AppRoute({
    required Widget page,
    super.settings,
    super.fullscreenDialog,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: const Duration(milliseconds: 420),
         reverseTransitionDuration: const Duration(milliseconds: 320),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return buildAppRouteTransition(
             animation: animation,
             secondaryAnimation: secondaryAnimation,
             child: child,
           );
         },
       );
}

Widget buildAppRouteTransition({
  required Animation<double> animation,
  required Animation<double> secondaryAnimation,
  required Widget child,
}) {
  final primary = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  final outgoing = CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.025, 0),
    ).animate(outgoing),
    child: FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(primary),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.06, 0.02),
          end: Offset.zero,
        ).animate(primary),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(primary),
          child: child,
        ),
      ),
    ),
  );
}
