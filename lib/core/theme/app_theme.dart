import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../navigation/app_page_transitions.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgApp,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
        surface: AppColors.bgApp,
        onSurface: AppColors.ink900,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        base.textTheme,
      ).apply(bodyColor: AppColors.ink900, displayColor: AppColors.ink900),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgApp,
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
