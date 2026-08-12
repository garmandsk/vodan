import 'package:flutter/material.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/core/routes/app_router.dart';
// import 'package:vodan/core/routes/app_router.dart'; // Buka komentar ini nanti saat rutenya siap

class EnterWorkspaceScreen extends StatelessWidget {
  const EnterWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VodanScaffold(
      title: 'Masuk Lapak',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            VodanHeader(
              icon: Icons.storefront_rounded, 
              iconColor: Colors.orange,
              title: 'Selamat Datang di VoDan',
              subtitle: 'Pilih peranmu untuk masuk ke dalam lapak.',
            ),
      
            VodanActionCard(
              title: 'Pemilik Lapak (Admin)',
              subtitle: 'Kelola toko, lihat laporan, dan atur pegawai.',
              prefixIcon: Icons.admin_panel_settings_rounded,
              color: Theme.of(context).colorScheme.primary,
              onTap: () => const WorkspaceListRoute().go(context)
            ),
            
            VodanActionCard(
              title: 'Pegawai (Kasir)',
              subtitle: 'Mulai berjualan dan layani pelanggan.',
              prefixIcon: Icons.point_of_sale_rounded,
              color: Theme.of(context).colorScheme.tertiary,
              onTap: () => {}
            ),
          ],
        ),
      ),
    );
  }
}