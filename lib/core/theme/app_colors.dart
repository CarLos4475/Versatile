import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  // Bone whites
  final Color bone50;
  final Color bone100;
  final Color bone200;
  final Color bone300;
  final Color bone400;

  // Ink
  final Color ink900;
  final Color ink700;
  final Color ink500;
  final Color ink400;
  final Color ink300;

  // Accent — Claude orange
  final Color accent;
  final Color accentSoft;
  final Color accentDeep;
  final Color accentLight;
  final Color accentTint;

  // Surfaces
  final Color bgApp;
  final Color bgFrame;

  // Glass surfaces
  final Color glassBg;
  final Color glassBgStrong;
  final Color glassBorder;
  
  // Shadows & effects
  final List<BoxShadow> glassShadow;
  final Color hairline;
  final Color press;
  final Color pressStrong;
  final Color fieldBg;

  // Success (completed set)
  final Color green700;
  final Color green500;
  final Color doneTint;
  final Color doneStrong;
  final Color doneIconBg;

  const AppColors({
    required this.bone50,
    required this.bone100,
    required this.bone200,
    required this.bone300,
    required this.bone400,
    required this.ink900,
    required this.ink700,
    required this.ink500,
    required this.ink400,
    required this.ink300,
    required this.accent,
    required this.accentSoft,
    required this.accentDeep,
    required this.accentLight,
    required this.accentTint,
    required this.bgApp,
    required this.bgFrame,
    required this.glassBg,
    required this.glassBgStrong,
    required this.glassBorder,
    required this.glassShadow,
    required this.hairline,
    required this.press,
    required this.pressStrong,
    required this.fieldBg,
    required this.green700,
    required this.green500,
    required this.doneTint,
    required this.doneStrong,
    required this.doneIconBg,
  });

  @override
  AppColors copyWith({
    Color? bone50,
    Color? bone100,
    Color? bone200,
    Color? bone300,
    Color? bone400,
    Color? ink900,
    Color? ink700,
    Color? ink500,
    Color? ink400,
    Color? ink300,
    Color? accent,
    Color? accentSoft,
    Color? accentDeep,
    Color? accentLight,
    Color? accentTint,
    Color? bgApp,
    Color? bgFrame,
    Color? glassBg,
    Color? glassBgStrong,
    Color? glassBorder,
    List<BoxShadow>? glassShadow,
    Color? hairline,
    Color? press,
    Color? pressStrong,
    Color? fieldBg,
    Color? green700,
    Color? green500,
    Color? doneTint,
    Color? doneStrong,
    Color? doneIconBg,
  }) {
    return AppColors(
      bone50: bone50 ?? this.bone50,
      bone100: bone100 ?? this.bone100,
      bone200: bone200 ?? this.bone200,
      bone300: bone300 ?? this.bone300,
      bone400: bone400 ?? this.bone400,
      ink900: ink900 ?? this.ink900,
      ink700: ink700 ?? this.ink700,
      ink500: ink500 ?? this.ink500,
      ink400: ink400 ?? this.ink400,
      ink300: ink300 ?? this.ink300,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentDeep: accentDeep ?? this.accentDeep,
      accentLight: accentLight ?? this.accentLight,
      accentTint: accentTint ?? this.accentTint,
      bgApp: bgApp ?? this.bgApp,
      bgFrame: bgFrame ?? this.bgFrame,
      glassBg: glassBg ?? this.glassBg,
      glassBgStrong: glassBgStrong ?? this.glassBgStrong,
      glassBorder: glassBorder ?? this.glassBorder,
      glassShadow: glassShadow ?? this.glassShadow,
      hairline: hairline ?? this.hairline,
      press: press ?? this.press,
      pressStrong: pressStrong ?? this.pressStrong,
      fieldBg: fieldBg ?? this.fieldBg,
      green700: green700 ?? this.green700,
      green500: green500 ?? this.green500,
      doneTint: doneTint ?? this.doneTint,
      doneStrong: doneStrong ?? this.doneStrong,
      doneIconBg: doneIconBg ?? this.doneIconBg,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bone50: Color.lerp(bone50, other.bone50, t)!,
      bone100: Color.lerp(bone100, other.bone100, t)!,
      bone200: Color.lerp(bone200, other.bone200, t)!,
      bone300: Color.lerp(bone300, other.bone300, t)!,
      bone400: Color.lerp(bone400, other.bone400, t)!,
      ink900: Color.lerp(ink900, other.ink900, t)!,
      ink700: Color.lerp(ink700, other.ink700, t)!,
      ink500: Color.lerp(ink500, other.ink500, t)!,
      ink400: Color.lerp(ink400, other.ink400, t)!,
      ink300: Color.lerp(ink300, other.ink300, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      bgApp: Color.lerp(bgApp, other.bgApp, t)!,
      bgFrame: Color.lerp(bgFrame, other.bgFrame, t)!,
      glassBg: Color.lerp(glassBg, other.glassBg, t)!,
      glassBgStrong: Color.lerp(glassBgStrong, other.glassBgStrong, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassShadow: t < 0.5 ? glassShadow : other.glassShadow,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      press: Color.lerp(press, other.press, t)!,
      pressStrong: Color.lerp(pressStrong, other.pressStrong, t)!,
      fieldBg: Color.lerp(fieldBg, other.fieldBg, t)!,
      green700: Color.lerp(green700, other.green700, t)!,
      green500: Color.lerp(green500, other.green500, t)!,
      doneTint: Color.lerp(doneTint, other.doneTint, t)!,
      doneStrong: Color.lerp(doneStrong, other.doneStrong, t)!,
      doneIconBg: Color.lerp(doneIconBg, other.doneIconBg, t)!,
    );
  }
}

extension BuildContextColors on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
