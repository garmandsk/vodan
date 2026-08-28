import 'package:flutter/material.dart';

// Extension ini menyuntikkan kemampuan baru ke dalam "BuildContext"
extension ResponsiveContext on BuildContext {
  
  // 1. Ambil Lebar & Tinggi Layar
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // 2. Tipe Layar (Breakpoint)
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;
  bool get isDesktop => screenWidth >= 900;

  // 3. Khusus Grid POS: Kalkulator Kolom Otomatis
  int get posGridColumns {
    if (screenWidth >= 1200) return 5; // Monitor Ultra Lebar
    if (screenWidth >= 900) return 4;  // Laptop
    if (screenWidth >= 600) return 3;  // Tablet
    return 2;                          // HP
  }

  // 4. Pengatur Padding Otomatis (Lebih lebar di Desktop, lebih sempit di HP)
  double get defaultPadding => isMobile ? 16.0 : 24.0;
}