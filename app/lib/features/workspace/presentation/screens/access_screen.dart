import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vodan/core/presentation/widgets/pin_barrier.dart';
import 'package:vodan/core/presentation/widgets/vodan_text_form_field.dart';
import 'package:vodan/core/providers/admin_session.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/features/workspace/data/repositories/access_repository.dart';
import 'package:vodan/features/workspace/presentation/controllers/access_controller.dart';
import 'package:vodan/features/workspace_auth/data/models/cashier_session_model.dart';

class AccessScreen extends ConsumerStatefulWidget {
  const AccessScreen({super.key});

  @override
  ConsumerState<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends ConsumerState<AccessScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submitPin() async {
    final workspaceId = ref.read(currentWorkspaceProvider)?.id;
    if (workspaceId == null) return;

    final pin = _pinController.text;
    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN tidak boleh kosong!')));
      return;
    }

    final errorMessage = await ref.read(adminSessionProvider.notifier).verifyPin(workspaceId, pin);
    
    _pinController.clear();

    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  Future<void> _changeAccessStatus(String sessionId, QueueStatus newStatus) async {
    final workspaceId = ref.read(currentWorkspaceProvider)?.id;
    if (workspaceId == null) return;

    try {
      await ref.read(accessRepositoryProvider).setAccessStatus(workspaceId, sessionId, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == QueueStatus.approved ? 'Akses diberikan!' : 'Akses dicabut/ditolak.'),
            backgroundColor: newStatus == QueueStatus.approved ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _processBulkAction(QueueStatus newStatus) async {
    final workspaceId = ref.read(currentWorkspaceProvider)?.id;
    if (workspaceId == null) return;

    final errorMessage = await ref.read(accessControllerProvider.notifier).processBulkAction(workspaceId, newStatus);
    
    if (mounted) {
      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == QueueStatus.approved ? 'Sukses menerima kasir yang dipilih!' : 'Sukses menolak kasir yang dipilih.'),
            backgroundColor: newStatus == QueueStatus.approved ? Colors.green : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barrierState = ref.watch(adminSessionProvider);
    final state = ref.watch(accessControllerProvider);

    // Layar Terkunci
    if (!barrierState.isPinVerified) {
      return PinBarrier(
        tffController: _pinController,
        tffEnabled: !barrierState.isLoading,
        tffOnFieldSubmitted: (_) => _submitPin(),
        buttonText: barrierState.isLoading ? 'Memeriksa...' : 'Buka Kunci', 
        buttonOnPressed: barrierState.isLoading ? null : _submitPin,
      );
    }

    // Layar Terbuka
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Column(
          children: [
            TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Menunggu Akses'),
                Tab(text: 'Telah Diberikan'),
              ],
            ),

            // Pencarian
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: VodanTextFormField(
                controller: _searchController,
                hintText: 'Cari nama kasir...',
                prefixIcon: Icons.search_rounded,
                onChanged: (value) => ref.read(accessControllerProvider.notifier).updateQuery(value),
              ),
            ),
            
            // Tab View List
            Expanded(
              child: TabBarView(
                children: [
                  _buildUserList(state.pendingUsers, state.searchQuery, isPending: true, theme: theme),
                  _buildUserList(state.approvedUsers, state.searchQuery, isPending: false, theme: theme),
                ],
              ),
            ),
          ],
        ),
        // Tombol manual untuk Logout/Lock kembali
        floatingActionButton: FloatingActionButton.small(
          onPressed: () => ref.read(adminSessionProvider.notifier).lockScreen(),
          backgroundColor: theme.colorScheme.errorContainer,
          child: Icon(Icons.lock_outline_rounded, color: theme.colorScheme.onErrorContainer),
        ),
      ),
    );
  }

  // =======================================================================
  // WIDGET DAFTAR KASIR 
  // =======================================================================
  Widget _buildUserList(List<CashierSessionModel> users, String query, {required bool isPending, required ThemeData theme}) {
    final state = ref.watch(accessControllerProvider);
    
    final filteredUsers = users.where((user) {
      return user.cashierName.toLowerCase().contains(query);
    }).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Text(
          query.isEmpty ? 'Belum ada data' : 'Tidak ditemukan kasir bernama "$query"',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Column(
      children: [
        if (isPending) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Row(
              children: [
                Checkbox(
                  value: state.selectedPendingUserIds.length == filteredUsers.length 
                      ? true 
                      : (state.selectedPendingUserIds.isNotEmpty ? null : false),
                  tristate: true,
                  onChanged: (val) {
                    if (val == true) {
                      ref.read(accessControllerProvider.notifier).selectAllPending();
                    } else {
                      ref.read(accessControllerProvider.notifier).clearSelection();
                    }
                  },
                ),
                Text(
                  state.selectedPendingUserIds.isNotEmpty 
                      ? '${state.selectedPendingUserIds.length} Terpilih' 
                      : 'Pilih Semua',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                
                if (state.selectedPendingUserIds.isNotEmpty) ...[
                  TextButton.icon(
                    onPressed: () => _processBulkAction(QueueStatus.rejected),
                    icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                    label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton.icon(
                    onPressed: () => _processBulkAction(QueueStatus.approved),
                    icon: const Icon(Icons.check_rounded, color: Colors.green, size: 20),
                    label: const Text('Terima', style: TextStyle(color: Colors.green)),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
        ],

        // LIST KASIR
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredUsers.length,
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final isSelected = state.selectedPendingUserIds.contains(user.sessionId);
              
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                
                leading: isPending
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (_) => ref.read(accessControllerProvider.notifier).toggleSelection(user.sessionId),
                      )
                    : CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          user.cashierName.isNotEmpty ? user.cashierName[0].toUpperCase() : '?', 
                          style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                        ),
                      ),
                
                title: Text(user.cashierName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('ID: ${user.sessionId.substring(0, 8)}...', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                    if (user.createdAt != null)
                      Text(
                        'Waktu: ${user.createdAt!.toLocal().toString().split('.')[0]}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                isThreeLine: true,
                
                trailing: isPending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.red), 
                            tooltip: 'Tolak',
                            onPressed: () => _changeAccessStatus(user.sessionId, QueueStatus.rejected),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_rounded, color: Colors.green), 
                            tooltip: 'Terima',
                            onPressed: () => _changeAccessStatus(user.sessionId, QueueStatus.approved),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: const Icon(Icons.person_remove_rounded, color: Colors.red), 
                        tooltip: 'Cabut Akses',
                        onPressed: () => _changeAccessStatus(user.sessionId, QueueStatus.rejected),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}