import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VodanScaffoldNavbar extends StatelessWidget {
  const VodanScaffoldNavbar({
    super.key,
    required this.navigationShell,
  });

  // 🌟 Ini adalah objek sakti dari GoRouter yang menyimpan status (state) setiap tab
  final StatefulNavigationShell navigationShell;

  // Fungsi untuk berpindah tab
  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // A true boolean here ensures that if the user taps the active tab, 
      // it resets the routing stack of that branch to its root.
      // (Misal: Kasir sedang buka detail pesanan di tab Riwayat, 
      // lalu menekan tombol Riwayat lagi, maka akan kembali ke daftar awal)
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 1. Deteksi Ukuran Layar (Adaptive Layout)
    // Jika lebar layar >= 600 pixel, kita anggap ini Tablet / Web
    final isDesktop = MediaQuery.sizeOf(context).width >= 600;
    final theme = Theme.of(context);

    // 🌟 2. Daftar Menu (Konsisten antara Mobile & Web)
    final destinations = [
      const _NavigationDestination(
        icon: Icons.point_of_sale_outlined,
        selectedIcon: Icons.point_of_sale_rounded,
        label: 'POS',
      ),
      const _NavigationDestination(
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long_rounded,
        label: 'Riwayat',
      ),
      const _NavigationDestination(
        icon: Icons.admin_panel_settings_outlined,
        selectedIcon: Icons.admin_panel_settings_rounded,
        label: 'Admin',
      ),
    ];

    return Scaffold(
      // 🌟 TAMPILAN TABLET / WEB
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  extended: MediaQuery.sizeOf(context).width >= 900, // Expand menu jika layar sangat lebar
                  backgroundColor: theme.colorScheme.surface,
                  indicatorColor: theme.colorScheme.primaryContainer,
                  selectedLabelTextStyle: TextStyle(
                    color: theme.colorScheme.primary, 
                    fontWeight: FontWeight.bold
                  ),
                  destinations: destinations.map((dest) {
                    return NavigationRailDestination(
                      icon: Icon(dest.icon),
                      selectedIcon: Icon(dest.selectedIcon),
                      label: Text(dest.label),
                    );
                  }).toList(),
                ),
                // Garis pemisah tipis
                const VerticalDivider(thickness: 1, width: 1),
                // Konten Tab (POS / Riwayat / Admin)
                Expanded(child: navigationShell),
              ],
            )
          // 🌟 TAMPILAN MOBILE (HP)
          : navigationShell,

      // 🌟 BOTTOM BAR HANYA MUNCUL DI MOBILE
      bottomNavigationBar: isDesktop
          ? null // Sembunyikan bottom bar di Desktop/Tablet
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              backgroundColor: theme.colorScheme.surface,
              indicatorColor: theme.colorScheme.primaryContainer,
              destinations: destinations.map((dest) {
                return NavigationDestination(
                  icon: Icon(dest.icon),
                  selectedIcon: Icon(dest.selectedIcon, color: theme.colorScheme.onPrimaryContainer),
                  label: dest.label,
                );
              }).toList(),
            ),
    );
  }
}

// Class bantuan sederhana untuk merapikan ikon & label
class _NavigationDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}