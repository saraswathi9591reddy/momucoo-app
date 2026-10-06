import 'package:flutter/material.dart';

/// Colors taken from frontend/src/App.css.
class AppColors {
  static const primary = Color(0xFFD52F68); // .primary-btn
  static const primaryDark = Color(0xFFB92355);
  static const ink = Color(0xFF243F3B); // headings / dark text
  static const inkSoft = Color(0xFF354340);
  static const muted = Color(0xFF59625F);
  static const grey = Color(0xFF777777);
  static const accent = Color(0xFFD87854); // terracotta
  static const accentDark = Color(0xFFC96443);
  static const peach = Color(0xFFFFB58D);
  static const peachBg = Color(0xFFFFF1E9);
  static const cream = Color(0xFFFFFAF6);
  static const border = Color(0xFFEADED7);
  static const borderAlt = Color(0xFFDFD4CE);
  static const success = Color(0xFF278052);
  static const successBg = Color(0xFFE4F0EB);
  static const warning = Color(0xFFB16F16);
}

class AppTheme {
  /// Web uses Arial for body text and Georgia for display headings.
  static const bodyFont = 'Arial';
  static const displayFont = 'Georgia';

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: bodyFont,
    );
    final radius = BorderRadius.circular(10);
    return base.copyWith(
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink)
          .copyWith(
            headlineLarge: const TextStyle(fontFamily: displayFont, fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.ink),
            headlineMedium: const TextStyle(fontFamily: displayFont, fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.ink),
            titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: AppColors.ink, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(15),
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: AppColors.border)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
      ),
    );
  }
}
