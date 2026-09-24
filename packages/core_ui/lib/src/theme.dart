import 'package:flutter/material.dart';

class AuraColors {
  static const Color primary = Color(0xFFFF6B00);
  static const Color primaryDark = Color(0xFFD45A00);
  static const Color background = Color(0xFFFFF7F0);
}

class AuraTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AuraColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AuraColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AuraColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AuraColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AuraColors.primary,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AuraColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
