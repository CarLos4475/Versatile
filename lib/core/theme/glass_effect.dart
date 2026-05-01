import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlassEffect {
  const GlassEffect._();

  static bool get _useBackdropBlur {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => false,
      TargetPlatform.iOS => true,
      TargetPlatform.macOS => true,
      TargetPlatform.windows => true,
      TargetPlatform.linux => true,
      _ => false,
    };
  }

  static double sigma(double base) {
    if (!_useBackdropBlur) return 0;
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows => base * 0.75,
      TargetPlatform.linux => base * 0.75,
      _ => base,
    };
  }

  static Widget wrap({
    required Widget child,
    required double sigma,
    required BorderRadius borderRadius,
  }) {
    final effectiveSigma = GlassEffect.sigma(sigma);
    if (effectiveSigma <= 0.01) {
      return child;
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effectiveSigma,
          sigmaY: effectiveSigma,
        ),
        child: child,
      ),
    );
  }
}
