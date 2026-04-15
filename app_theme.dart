import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const brandGreen = Color(0xFF00A082); // RuralGo green
    const softBg = Color(0xFFE9FBF6);     // soft light green background

    return ThemeData(
      useMaterial3: true,

      // ✅ Global background
      scaffoldBackgroundColor: softBg,

      // ✅ Proper Material 3 color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandGreen,
        primary: brandGreen,
        surface: softBg,
      ),

      // ✅ App bars everywhere
      appBarTheme: const AppBarTheme(
        backgroundColor: brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      // ✅ Primary buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      // ✅ Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandGreen,
          side: const BorderSide(color: brandGreen),
        ),
      ),

      // ✅ Typography
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w900),
        titleMedium: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}