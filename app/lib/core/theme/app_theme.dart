import 'package:flutter/material.dart';
import 'package:vodan/core/theme/transition_builder.dart';

class AppTheme {
  // ===========================================================================
  // 1. PALET WARNA (LIGHT THEME)
  // ===========================================================================
  static const Color _lightPrimary = Color.fromRGBO(230, 81, 0, 1); // Oranye Gelap
  static const Color _lightSecondary = Color(0xFF2E7D32); // Hijau
  static const Color _lightTertiary = Colors.blue;
  static const Color _lightSurface = Colors.white;
  static const Color _lightOnSurface = Colors.black;
  static const Color _lightBackground = Color(0xFFF5F7FA);
  static const Color _lightError = Color(0xFFD32F2F);
  static const Color _lightTextPrimary = Color(0xFF1E293B);
  static const Color _lightTextSecondary = Color(0xFF64748B);
  static const Color _lightBorder = Color(0xFFE2E8F0);

  // ===========================================================================
  // 2. PALET WARNA (DARK THEME)
  // ===========================================================================
  // Warna di Dark Mode biasanya lebih terang / pastel agar tidak menyilaukan mata
  static const Color _darkPrimary = Color.fromRGBO(255, 138, 101, 1); // Oranye lebih terang
  static const Color _darkSecondary = Color(0xFF81C784); // Hijau lebih terang
  static const Color _darkTertiary = Color(0xFF64B5F6);
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkError = Color(0xFFCF6679);
  static const Color _darkTextPrimary = Color(0xFFE3E3E3);
  static const Color _darkTextSecondary = Color(0xFFA0A0A0);
  static const Color _darkBorder = Color(0xFF333333);

  // ===========================================================================
  // 3. ANIMASI TRANSISI GLOBAL
  // Dibuat konstan di luar agar bisa dipakai oleh Light dan Dark Theme
  // ===========================================================================
  static const PageTransitionsTheme _pageTransitions = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: EaseInOutFadePageTransationBuilder(),
      TargetPlatform.iOS: EaseInOutFadePageTransationBuilder(),
      TargetPlatform.windows: EaseInOutFadePageTransationBuilder(),
      TargetPlatform.macOS: EaseInOutFadePageTransationBuilder(),
      TargetPlatform.linux: EaseInOutFadePageTransationBuilder(),
    },
  );

  // ===========================================================================
  // 4. TEMA UTAMA (LIGHT THEME)
  // ===========================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _lightBackground,
      brightness: Brightness.light,
      
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        onPrimary: Colors.white,
        secondary: _lightSecondary,
        tertiary: _lightTertiary,
        surface: _lightSurface,
        onSurface: _lightOnSurface,
        error: _lightError,
      ),
      
      pageTransitionsTheme: _pageTransitions,

      // TIPOGRAFI
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _lightTextPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _lightTextPrimary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _lightTextPrimary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: _lightTextPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: _lightTextSecondary),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), 
      ),

      // TOMBOL
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(88, 56), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),

      // KARTU
      cardTheme: CardThemeData(
        color: _lightBackground,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // FORM INPUT
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: _lightTextSecondary),
        floatingLabelStyle: const TextStyle(color: _lightPrimary),
        hintStyle: const TextStyle(color: _lightTextSecondary, fontWeight: FontWeight.normal),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightError, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightError, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder, width: 1.5),
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. TEMA GELAP (DARK THEME)
  // ===========================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _darkBackground,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        onPrimary: _darkBackground,
        secondary: _darkSecondary,
        tertiary: _darkTertiary,
        surface: _darkSurface,
        error: _darkError,
      ),
      
      pageTransitionsTheme: _pageTransitions,

      // TIPOGRAFI
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _darkTextPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _darkTextPrimary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _darkTextPrimary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: _darkTextPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: _darkTextSecondary),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _darkBackground), 
      ),

      // TOMBOL
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(88, 56), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),

      // KARTU
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // FORM INPUT
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        labelStyle: const TextStyle(color: _darkTextSecondary),
        floatingLabelStyle: const TextStyle(color: _darkPrimary),
        hintStyle: const TextStyle(color: _darkTextSecondary, fontWeight: FontWeight.normal),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkError, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkError, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder, width: 1.5),
        ),
      ),
    );
  }
}