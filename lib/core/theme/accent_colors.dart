import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class AccentOption {
  final String id;
  final String l10nKey;
  final Color color;

  const AccentOption({
    required this.id,
    required this.l10nKey,
    required this.color,
  });

  String displayName(AppLocalizations l10n) {
    switch (id) {
      case 'ember':
        return l10n.colorEmber;
      case 'pink':
        return l10n.colorPink;
      case 'wine':
        return l10n.colorWine;
      case 'brick':
        return l10n.colorBrick;
      case 'camel':
        return l10n.colorCamel;
      case 'olive':
        return l10n.colorOlive;
      case 'slate':
        return l10n.colorSlate;
      case 'plum':
        return l10n.colorPlum;
      default:
        return l10n.colorEmber;
    }
  }
}

class AccentColors {
  AccentColors._();

  static const options = [
    AccentOption(id: 'ember', l10nKey: 'colorEmber', color: Color(0xFFD97757)),
    AccentOption(id: 'pink', l10nKey: 'colorPink', color: Color(0xFFD9687E)),
    AccentOption(id: 'wine', l10nKey: 'colorWine', color: Color(0xFF9B3A4A)),
    AccentOption(id: 'brick', l10nKey: 'colorBrick', color: Color(0xFFB85432)),
    AccentOption(id: 'camel', l10nKey: 'colorCamel', color: Color(0xFF9E7B4E)),
    AccentOption(id: 'olive', l10nKey: 'colorOlive', color: Color(0xFF7A8C5B)),
    AccentOption(id: 'slate', l10nKey: 'colorSlate', color: Color(0xFF5B7A8C)),
    AccentOption(id: 'plum', l10nKey: 'colorPlum', color: Color(0xFF8C5B6E)),
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
