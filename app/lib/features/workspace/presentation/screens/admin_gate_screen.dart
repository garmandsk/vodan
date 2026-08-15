import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/features/workspace_auth/presentation/controllers/waiting_room_controller.dart';

class AdminGateScreen extends ConsumerWidget {
  const AdminGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceId = ref.read(currentWorkspaceIdProvider) ?? 'Lapak tidak diketahui';

    return VodanScaffold(
      title: 'Akses Khusus Admin',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Gerbang Admin Lapak:\n$workspaceId', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Munculkan Numpad PIN di sini nanti
              }, 
              child: const Text('Masukkan PIN Lapak')
            )
          ],
        ),
      ),
    );
  }
}