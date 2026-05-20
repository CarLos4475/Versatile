import 'package:flutter/material.dart';

Color darkenColor(Color base, double amount) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(base);
  return hsl
      .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
      .toColor();
}

Color lightenColor(Color base, double amount) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(base);
  return hsl
      .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
      .toColor();
}

LinearGradient warmGradient(
  Color base, {
  AlignmentGeometry begin = Alignment.topCenter,
  AlignmentGeometry end = Alignment.bottomCenter,
  double lighten = 0.06,
  double darken = 0.12,
}) {
  return LinearGradient(
    begin: begin,
    end: end,
    colors: [lightenColor(base, lighten), darkenColor(base, darken)],
  );
}

/// High-contrast gradient for routine/program cells. Creates a clear vertical
/// transition with a bright top, base mid, and darker bottom for a glossy 3D
/// feel. Pair with [glossyOverlay] for an even stronger highlight.
LinearGradient cellGradient(Color base) {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      lightenColor(base, 0.18),
      base,
      darkenColor(base, 0.24),
    ],
    stops: const [0.0, 0.45, 1.0],
  );
}

/// White-to-transparent overlay that sits on top of a colored cell to
/// produce a glossy highlight band on the upper half. Wrap a cell's child
/// content in a Stack and add this as the bottom layer.
const glossyOverlay = DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x59FFFFFF), Color(0x00FFFFFF)],
      stops: [0.0, 0.50],
    ),
  ),
);
