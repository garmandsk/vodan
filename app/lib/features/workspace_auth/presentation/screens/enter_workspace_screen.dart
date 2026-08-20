import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/widgets/cashier_bottom_sheet.dart';
import 'package:vodan/features/workspace_auth/presentation/controllers/waiting_room_controller.dart';
// import 'package:vodan/core/routes/app_router.dart'; // Buka komentar ini nanti saat rutenya siap

class EnterWorkspaceScreen extends ConsumerStatefulWidget {
  const EnterWorkspaceScreen({super.key});

  @override
  ConsumerState<EnterWorkspaceScreen> createState() => _EnterWorkspaceScreenState();
}

class _EnterWorkspaceScreenState extends ConsumerState<EnterWorkspaceScreen> {
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
              title: 'Selamat Datang di VoDan',
              subtitle: 'Pilih peranmu untuk masuk ke dalam lapak.',
            ),
      
            VodanActionCard(
              title: 'Pengurus Lapak (Admin)',
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
              onTap: () => CashierBottomSheet.show(
                context: context,
                title: 'Masuk Lapak', 
                subtitle: 'Masukkan nama dan ID Lapak.', 
                submitButtonText: 'Masuk', 
                onSubmit: (workspaceId, cashierName) async {
                  await ref.read(waitingRoomControllerProvider.notifier).join(workspaceId, cashierName);

                  if (context.mounted) WorkspaceWaitingRoomRoute(workspaceId: workspaceId, cashierName: cashierName).go(context);
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}