import 'package:flutter/material.dart';
import 'package:vodan/core/theme/transition_builder.dart';

class AppTheme {
  // 1. PALET WARNA (Color Scheme)
  // Kita gunakan warna primer yang membangkitkan selera & energi (misal: Deep Orange/Indigo)
  static const Color primaryColor = Color.fromRGBO(230, 81, 0, 1); // Oranye Gelap
  static const Color secondaryColor = Color(0xFF2E7D32); // Hijau untuk sukses/uang
  static const Color surfaceColor = Color(0xFFF5F7FA);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  // 2. TEMA UTAMA (Light Theme)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: EaseInOutFadePageTransationBuilder(),
          TargetPlatform.iOS: EaseInOutFadePageTransationBuilder(),
          TargetPlatform.windows: EaseInOutFadePageTransationBuilder(),
          TargetPlatform.macOS: EaseInOutFadePageTransationBuilder(),
          TargetPlatform.linux: EaseInOutFadePageTransationBuilder(),
        }
      ),

      // 3. TIPOGRAFI (Text Theme)
      // Mengatur ukuran font standar agar konsisten di seluruh aplikasi
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Untuk teks tombol
      ),

      // 4. TEMA TOMBOL (Button Theme)
      // Tombol di aplikasi POS HAMPIR SEMUANYA harus besar agar mudah ditekan!
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 56), // Tinggi 56px sangat ideal untuk sentuhan jari (Touch Target)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Tidak terlalu bulat, terkesan profesional
          ),
          elevation: 2,
        ),
      ),

      // 5. TEMA KARTU (Card Theme)
      // Untuk membungkus daftar menu atau item keranjang
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 6. TEMA INPUT TEXT (TextFormField)
      // Untuk kotak pencarian atau form input manual
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}