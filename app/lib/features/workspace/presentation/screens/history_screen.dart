import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';
import 'package:vodan/features/workspace_auth/presentation/controllers/waiting_room_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceId = ref.read(currentWorkspaceIdProvider) ?? 'Lapak tidak diketahui';

    return VodanScaffold(
      title: 'Riwayat Transaksi',
      body: Center(
        child: Text('Daftar riwayat transaksi Lapak:\n$workspaceId', textAlign: TextAlign.center),
      ),
    );
  }
}