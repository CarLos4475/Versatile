import 'package:flutter/material.dart';

class AccentOption {
  final String id;
  final String l10nKey;
  final Color color;

  const AccentOption({
    required this.id,
    required this.l10nKey,
    required this.color,
  });
}

class AccentColors {
  AccentColors._();

  static const options = [
    AccentOption(
      id: 'orange',
      l10nKey: 'colorOrange',
      color: Color(0xFFD97757),
    ),
    AccentOption(id: 'blue', l10nKey: 'colorBlue', color: Color(0xFF4A8FCF)),
    AccentOption(id: 'green', l10nKey: 'colorGreen', color: Color(0xFF4C9B6D)),
    AccentOption(
      id: 'purple',
      l10nKey: 'colorPurple',
      color: Color(0xFF8B5CF6),
    ),
    AccentOption(id: 'red', l10nKey: 'colorRed', color: Color(0xFFD95B5B)),
    AccentOption(id: 'teal', l10nKey: 'colorTeal', color: Color(0xFF0EA5A0)),
    AccentOption(id: 'pink', l10nKey: 'colorPink', color: Color(0xFFD95B9C)),
    AccentOption(id: 'amber', l10nKey: 'colorAmber', color: Color(0xFFE6A817)),
  ];

  static AccentOption fromId(String id) {
    return options.firstWhere((o) => o.id == id, orElse: () => options.first);
  }

  static Color soften(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.14).clamp(0.0, 1.0)).toColor();
  }

  static Color deepen(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.10).clamp(0.0, 1.0)).toColor();
  }

  static Color lighten(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.07).clamp(0.0, 1.0)).toColor();
  }
}
