import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_button.dart';
import 'package:vodan/core/presentation/widgets/vodan_action_card.dart';
import 'package:vodan/core/presentation/widgets/vodan_header.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/features/workspace/data/models/workspace_response_model.dart';
import 'package:vodan/features/workspace/presentation/controllers/workspace_controller.dart';

class WorkspaceListScreen extends ConsumerWidget {
  const WorkspaceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaces = ref.watch(workspaceControllerProvider);

    return VodanScaffold(
      title: 'Pilih lapak',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            VodanHeader(
              icon: Icons.store_mall_directory_rounded, 
              title: 'Lapak Saya',
              subtitle: 'Gasken',
            ),
        
            Expanded(
              child: workspaces.when(
                data: (workspaces) {
                  if (workspaces.isEmpty) {
                    return _buildEmptyState(context); // Jika belum ada lapak
                  }
                  return _buildWorkspaceList(workspaces); // Jika ada lapak
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text(
                    'Ups, terjadi kesalahan: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      // color: Colors.red.withOpacity(0.1),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VodanHeader(
            icon: Icons.storefront_outlined,
            iconSize: 100,
            iconColor: Colors.grey.shade400, 
            title: 'Belum ada lapak',
            titleStyle: Theme.of(context).textTheme.headlineMedium,
            subtitle: 'Buat lapak pertamamu sekarang untuk mulai mengelola transaksi.',
          ),
          const SizedBox(height: 16),
      
          VodanActionButton(
            text: 'Buka Lapak Sekarang',
            onPressed: () => CreateWorkspaceRoute().go(context)
          ),
        ],
      ),
    );
  }

  // --- 🌟 DAFTAR LAPAK (LIST VIEW) ---
  Widget _buildWorkspaceList(List<WorkspaceResponseModel> workspaces) {
    // Wajib pakai ListView.builder agar aman dari lag saat lapaknya banyak
    return ListView.separated(
      // padding: const EdgeInsets.all(16.0),
      itemCount: workspaces.length,
      separatorBuilder: (content, index) => const SizedBox(height: 16,),
      itemBuilder: (context, index) {
        final workspace = workspaces[index];
        
        return 
        VodanActionCard(
          title: 'Lapak ${workspace.name}',
          subtitle: workspace.id,
          prefixIcon: Icons.store_rounded,
          color: Theme.of(context).colorScheme.primary,
          onTap: () => WorkspaceRoute(workspaceId: workspace.id).go(context),
        );
      },
    );
  }
}