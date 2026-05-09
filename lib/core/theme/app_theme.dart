import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../navigation/app_page_transitions.dart';
import 'accent_colors.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static AppColors _buildColors(Color accent, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final accentSoft = AccentColors.soften(accent);
    final accentDeep = AccentColors.deepen(accent);
    final accentLight = AccentColors.lighten(accent);
    final accentTint = accent.withValues(alpha: isLight ? 0.20 : 0.15);

    if (isLight) {
      return AppColors(
        bone50: const Color(0xFFFAF7F2),
        bone100: const Color(0xFFF5F1EB),
        bone200: const Color(0xFFECE6DC),
        bone300: const Color(0xFFDFD7C9),
        bone400: const Color(0xFFC7BCA9),
        ink900: const Color(0xFF1F1B14),
        ink700: const Color(0xFF3A3326),
        ink500: const Color(0xFF6B6353),
        ink400: const Color(0xFF8A8170),
        ink300: const Color(0xFFADA593),
        accent: accent,
        accentSoft: accentSoft,
        accentDeep: accentDeep,
        accentLight: accentLight,
        accentTint: accentTint,
        bgApp: const Color(0xFFE4DCCB),
        bgFrame: const Color(0xFFF5F0E6),
        glassBg: const Color(0xC7FFFBF4),
        glassBgStrong: const Color(0xEBFFFBF4),
        glassBorder: const Color(0xB3FFFFFF),
        glassShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        hairline: const Color(0x1F000000),
        press: const Color(0x0A000000),
        pressStrong: const Color(0x14000000),
        fieldBg: const Color(0x0A000000),
        green700: const Color(0xFF3A6E48),
        green500: const Color(0xFF4A8A5A),
        doneTint: const Color(0x143A6E48),
        doneStrong: const Color(0xFF3A6E48),
        doneIconBg: const Color(0x1F3A6E48),
      );
    }

    return AppColors(
      bone50: const Color(0xFF2A241C),
      bone100: const Color(0xFF352F25),
      bone200: const Color(0xFF423C32),
      bone300: const Color(0xFF564E42),
      bone400: const Color(0xFF75695A),
      ink900: const Color(0xFFF5EFE2),
      ink700: const Color(0xFFDCD4C2),
      ink500: const Color(0xFF9A9079),
      ink400: const Color(0xFF75695A),
      ink300: const Color(0xFF564E42),
      accent: accent,
      accentSoft: accentSoft,
      accentDeep: accentDeep,
      accentLight: accentLight,
      accentTint: accentTint,
      bgApp: const Color(0xFF0C0907),
      bgFrame: const Color(0xFF1A1612),
      glassBg: const Color(0x8C1A1612),
      glassBgStrong: const Color(0xC71A1612),
      glassBorder: const Color(0x14FFF0DC),
      glassShadow: const [
        BoxShadow(
          color: Color(0x73000000),
          blurRadius: 22,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
      hairline: const Color(0x11FFF0DC),
      press: const Color(0x1AFFF0DC),
      pressStrong: const Color(0x26FFF0DC),
      fieldBg: const Color(0x66000000),
      green700: const Color(0xFF9CC9A8),
      green500: const Color(0xFF8CC896),
      doneTint: const Color(0x1A8CC896),
      doneStrong: const Color(0xFF9CC9A8),
      doneIconBg: const Color(0x2E8CC896),
    );
  }

  static ThemeData light(Color accent) {
    final colors = _buildColors(accent, Brightness.light);
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: colors.bgApp,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
        surface: colors.bgApp,
        onSurface: colors.ink900,
      ),
      extensions: <ThemeExtension<dynamic>>[colors],
      textTheme: GoogleFonts.nunitoTextTheme(
        base.textTheme,
      ).apply(bodyColor: colors.ink900, displayColor: colors.ink900),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgApp,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
          TargetPlatform.windows: AppPageTransitionsBuilder(),
          TargetPlatform.linux: AppPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData dark(Color accent) {
    final colors = _buildColors(accent, Brightness.dark);
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: colors.bgApp,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
        surface: colors.bgApp,
        onSurface: colors.ink900,
      ),
      extensions: <ThemeExtension<dynamic>>[colors],
      textTheme: GoogleFonts.nunitoTextTheme(
        base.textTheme,
      ).apply(bodyColor: colors.ink900, displayColor: colors.ink900),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgApp,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
          TargetPlatform.windows: AppPageTransitionsBuilder(),
          TargetPlatform.linux: AppPageTransitionsBuilder(),
        },
      ),
    );
  }
}
