import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vodan/core/presentation/widgets/vodan_badge.dart';
import 'package:vodan/core/utils/responsive_utils.dart';
import 'package:vodan/features/account/data/repositories/account_repository.dart';
import 'package:vodan/core/presentation/widgets/account_bottom_sheet.dart';

class VodanMainScaffold extends ConsumerWidget {
  const VodanMainScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  // Fungsi untuk berpindah tab
  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = context.isDesktop || context.isTablet;
    final theme = Theme.of(context);

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

    String currentTitle = 'POS';
    if (navigationShell.currentIndex == 1) currentTitle = 'Riwayat Transaksi';
    if (navigationShell.currentIndex == 2) currentTitle = 'Halaman Admin';

     // Ambil data user dari repository

    final user = ref.watch(accountRepositoryProvider).currentUser;

    final name = user?.userMetadata?['name'] ?? user?.email?.split('@')[0] ?? 'Anonim';

    return Scaffold(
      appBar: isDesktop
          ? null // Desktop tidak pakai AppBar bawaan, tapi Header manual di Body
          : AppBar(
              title: Text(currentTitle),
              automaticallyImplyLeading: false,
              actions: [
                if (!(name == 'Anonim'))
                VodanBadge(
                  text: name,
                  radius: 18,
                  onTap: () => AccountBottomSheet.show(context),
                ), // Avatar versi Mobile
              ],
            ),
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
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: navigationShell),
              ],
            )
          : navigationShell,

      bottomNavigationBar: isDesktop
          ? null 
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