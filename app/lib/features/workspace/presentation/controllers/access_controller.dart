import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/providers/admin_session.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/features/workspace/data/repositories/access_repository.dart';
import 'package:vodan/features/workspace_auth/data/models/cashier_session_model.dart';

part 'access_controller.g.dart';

class AccessState {
  AccessState({
    this.isLoading = false,
    this.searchQuery = '',
    this.pendingUsers = const [],
    this.approvedUsers = const [],
    this.selectedPendingUserIds = const {},
  });

  final bool isLoading;
  final String searchQuery;
  final List<CashierSessionModel> pendingUsers;
  final List<CashierSessionModel> approvedUsers;
  final Set<String> selectedPendingUserIds;

  AccessState copyWith({
    bool? isLoading,
    String? searchQuery,
    List<CashierSessionModel>? pendingUsers,
    List<CashierSessionModel>? approvedUsers,
    Set<String>? selectedPendingUserIds,
  }) {
    return AccessState(
        isLoading: isLoading ?? this.isLoading,
        searchQuery: searchQuery ?? this.searchQuery,
        pendingUsers: pendingUsers ?? this.pendingUsers,
        approvedUsers: approvedUsers ?? this.approvedUsers,
        selectedPendingUserIds:
            selectedPendingUserIds ?? this.selectedPendingUserIds);
  }
}

@riverpod
class AccessController extends _$AccessController {
  RealtimeChannel? _realtimeChannel;

  @override
  AccessState build() {
    ref.onDispose(() {
      _realtimeChannel?.unsubscribe();
    });

    final workspaceId = ref.watch(currentWorkspaceProvider)?.id;
    if (workspaceId != null && workspaceId.isNotEmpty) {
      // _refresh(workspaceId);

      _realtimeChannel = ref
          .read(supabaseClientProvider)
          .channel('public:cashier_queue:$workspaceId')
          .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'cashier_queue',
              filter: PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'workspace_id',
                  value: workspaceId),
              callback: (payload) {
                print(
                    '🔥 Terdeteksi perubahan dari Spreadsheet/Supabase: $payload');
                _refresh(workspaceId);
              })
          .subscribe((statuc, [error]) {
        // print('📡 Status Realtime: $status');
        if (error != null) {
          // print('❌ Error Realtime: $error');
        }
      });
    }

    return AccessState();
  }

  void _pingSession() =>
      ref.read(adminSessionProvider.notifier).refreshSession();

  Future<void> _refresh(String workspaceId) async {
    try {
      final accessRepo = ref.read(accessRepositoryProvider);
      final pending = await accessRepo.getPendingUsers(workspaceId);
      final approved = await accessRepo.getApprovedUsers(workspaceId);

      state = state.copyWith(pendingUsers: pending, approvedUsers: approved);
    } catch (e) {
      print('Gagal memuat ulang: $e');
    }
  }

  Future<String?> setAccessStatus(
      String workspaceId, String sessionId, QueueStatus status) async {
    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(accessRepositoryProvider);
      await repo.setAccessStatus(workspaceId, sessionId, status);

      state = state.copyWith(isLoading: false);

      _pingSession();

      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'Terjadi kesalahan koneksi server: $e';
    }
  }

  void toggleSelection(String sessionId) {
    final current = Set<String>.from(state.selectedPendingUserIds);
    if (current.contains(sessionId)) {
      current.remove(sessionId);
    } else {
      current.add(sessionId);
    }
    state = state.copyWith(selectedPendingUserIds: current);
    _pingSession();
  }

  void selectAllPending() {
    final allIds = state.pendingUsers.map((e) => e.sessionId).toSet();
    state = state.copyWith(selectedPendingUserIds: allIds);
    _pingSession();
  }

  void clearSelection() {
    state = state.copyWith(selectedPendingUserIds: {});
    _pingSession();
  }

  Future<String?> processBulkAction(
      String workspaceId, QueueStatus status) async {
    if (state.selectedPendingUserIds.isEmpty) return null;

    state = state.copyWith(isLoading: true);
    _pingSession();
    try {
      final repo = ref.read(accessRepositoryProvider);

      await repo.setBulkAccessStatus(
          workspaceId, state.selectedPendingUserIds.toList(), status);

      await _refresh(workspaceId);

      state = state.copyWith(
        isLoading: false,
        selectedPendingUserIds: {},
      );

      _pingSession();
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'Gagal memproses aksi massal: $e';
    }
  }

  // Update nilai pencarian secara real-time
  void updateQuery(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query.toLowerCase());
    _pingSession();
  }
}
