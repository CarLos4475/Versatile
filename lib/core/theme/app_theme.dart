import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../navigation/app_page_transitions.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const lightColors = AppColors(
    bone50: Color(0xFFFAF7F2),
    bone100: Color(0xFFF5F1EB),
    bone200: Color(0xFFECE6DC),
    bone300: Color(0xFFDFD7C9),
    bone400: Color(0xFFC7BCA9),
    ink900: Color(0xFF1F1B14),
    ink700: Color(0xFF3A3326),
    ink500: Color(0xFF6B6353),
    ink400: Color(0xFF8A8170),
    ink300: Color(0xFFADA593),
    accent: Color(0xFFD97757),
    accentSoft: Color(0xFFE89A7E),
    accentDeep: Color(0xFFB85432),
    accentLight: Color(0xFFE08866),
    accentTint: Color(0x1FD97757),
    bgApp: Color(0xFFE4DCCB),
    bgFrame: Color(0xFFF5F0E6),
    glassBg: Color(0xC7FFFBF4),
    glassBgStrong: Color(0xEBFFFBF4),
    glassBorder: Color(0xB3FFFFFF),
    glassShadow: [
      BoxShadow(
        color: Color(0x14000000), // rgba(0,0,0,0.08)
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
    hairline: Color(0x1F000000), // rgba(0,0,0,0.12)
    press: Color(0x0A000000),
    pressStrong: Color(0x14000000),
    fieldBg: Color(0x0A000000),
    green700: Color(0xFF3A6E48),
    green500: Color(0xFF4A8A5A),
    doneTint: Color(0x143A6E48),
    doneStrong: Color(0xFF3A6E48),
    doneIconBg: Color(0x1F3A6E48),
  );

  static const darkColors = AppColors(
    bone50: Color(0xFF2A241C),
    bone100: Color(0xFF352F25),
    bone200: Color(0xFF423C32),
    bone300: Color(0xFF564E42),
    bone400: Color(0xFF75695A),
    ink900: Color(0xFFF5EFE2),
    ink700: Color(0xFFDCD4C2),
    ink500: Color(0xFF9A9079),
    ink400: Color(0xFF75695A),
    ink300: Color(0xFF564E42),
    accent: Color(0xFFD97757),
    accentSoft: Color(0xFFE89A7E),
    accentDeep: Color(0xFFB85432),
    accentLight: Color(0xFFE08866),
    accentTint: Color(0x26D97757),
    bgApp: Color(0xFF0C0907),
    bgFrame: Color(0xFF1A1612),
    glassBg: Color(0x8C1A1612),
    glassBgStrong: Color(0xC71A1612),
    glassBorder: Color(0x14FFF0DC),
    glassShadow: [
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
    hairline: Color(0x11FFF0DC),
    press: Color(0x1AFFF0DC),
    pressStrong: Color(0x26FFF0DC),
    fieldBg: Color(0x66000000), // Darker field background
    green700: Color(0xFF9CC9A8),
    green500: Color(0xFF8CC896),
    doneTint: Color(0x1A8CC896),
    doneStrong: Color(0xFF9CC9A8),
    doneIconBg: Color(0x2E8CC896),
  );

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: lightColors.bgApp,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightColors.accent,
        brightness: Brightness.light,
        surface: lightColors.bgApp,
        onSurface: lightColors.ink900,
      ),
      extensions: <ThemeExtension<dynamic>>[lightColors],
      textTheme: GoogleFonts.nunitoTextTheme(
        base.textTheme,
      ).apply(bodyColor: lightColors.ink900, displayColor: lightColors.ink900),
      appBarTheme: AppBarTheme(
        backgroundColor: lightColors.bgApp,
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

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: darkColors.bgApp,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkColors.accent,
        brightness: Brightness.dark,
        surface: darkColors.bgApp,
        onSurface: darkColors.ink900,
      ),
      extensions: <ThemeExtension<dynamic>>[darkColors],
      textTheme: GoogleFonts.nunitoTextTheme(
        base.textTheme,
      ).apply(bodyColor: darkColors.ink900, displayColor: darkColors.ink900),
      appBarTheme: AppBarTheme(
        backgroundColor: darkColors.bgApp,
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
