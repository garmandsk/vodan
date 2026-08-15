import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/features/workspace_auth/presentation/controllers/waiting_room_controller.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceId = ref.read(currentWorkspaceIdProvider) ?? 'Lapak tidak diketahui';

    return VodanScaffold(
      title: 'POS (Mesin Kasir)',
      body: Center(
        child: Text('Siap melayani pesanan di Lapak:\n$workspaceId', textAlign: TextAlign.center),
      ),
    );
  }
}