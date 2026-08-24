import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/features/workspace/data/repositories/access_repository.dart';
import 'package:vodan/features/workspace/data/repositories/workspace_repository.dart';
import 'package:vodan/features/workspace_auth/data/models/cashier_session_model.dart';

part 'access_controller.g.dart';

class AccessState {
  final bool isPinVerified;
  final bool isLoading;
  final String searchQuery;
  final List<CashierSessionModel> pendingUsers;
  final List<CashierSessionModel> approvedUsers;
  final Set<String> selectedPendingUserIds;

  AccessState({
    this.isPinVerified = false,
    this.isLoading = false,
    this.searchQuery = '',
    this.pendingUsers = const [],
    this.approvedUsers = const [],
    this.selectedPendingUserIds = const {},
  });

  AccessState copyWith({
    bool? isPinVerified,
    bool? isLoading,
    String? searchQuery,
    List<CashierSessionModel>? pendingUsers,
    List<CashierSessionModel>? approvedUsers,
    Set<String>? selectedPendingUserIds,
  }) {
    return AccessState(
      isPinVerified: isPinVerified ?? this.isPinVerified,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      pendingUsers: pendingUsers ?? this.pendingUsers,
      approvedUsers: approvedUsers ?? this.approvedUsers,
      selectedPendingUserIds: selectedPendingUserIds ?? this.selectedPendingUserIds
    );
  }
}

@riverpod
class AccessController extends _$AccessController {
  Timer? _debounceTimer;
  Timer? _autoLockTimer;
  RealtimeChannel? _realtimeChannel;

  static const _timeoutDuration = Duration(minutes: 5);

  @override
  AccessState build() {
    ref.onDispose(() {
      _autoLockTimer?.cancel();
      _realtimeChannel?.unsubscribe();
    });

    final workspaceId = ref.watch(currentWorkspaceIdProvider);
    if (workspaceId != null && workspaceId.isNotEmpty) {
      _realtimeChannel = ref.read(supabaseClientProvider)
          .channel('public:cashier_queue:$workspaceId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'cashier_queue',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq, 
              column: 'workspace_id', 
              value: workspaceId
            ),
            callback: (payload) {
              print('🔥 Terdeteksi perubahan dari Spreadsheet/Supabase: $payload');
              _refresh(workspaceId);
            }
          )
          .subscribe((statuc, [error]) {
            // print('📡 Status Realtime: $status');
            if (error != null) {
              // print('❌ Error Realtime: $error');
            }
          });
    }

    return AccessState();
  }

  Future<void> _refresh(String workspaceId) async {
    try {
      final accessRepo = ref.read(accessRepositoryProvider);
      final pending = await accessRepo.getPendingUsers(workspaceId);
      final approved = await accessRepo.getApprovedUsers(workspaceId);

      state = state.copyWith(
        pendingUsers: pending,
        approvedUsers: approved
      );
    } catch (e) {
      print('Gagal memuat ulang: $e');
    }
  }

  Future<String?> openAccessScreen(String workspaceId, String pin) async {
    state = state.copyWith(isLoading: true);

    try {
      // print('pin: $pin');

      final workspaceRepo = ref.read(workspaceRepositoryProvider);

      final pinBytes = utf8.encode(pin);
      final clientHashedPin = sha256.convert(pinBytes).toString();
      final isMatch = await workspaceRepo.verifyPin(workspaceId, clientHashedPin);
      
      if (isMatch) {
        await _refresh(workspaceId);

        state = state.copyWith(
          isPinVerified: true,
          isLoading: false,
        );

        _startAutoLockTimer();
        
        return null; // Sukses (tidak ada error)
      } else {
        state = state.copyWith(isLoading: false);
        return 'PIN Salah! Silakan coba lagi.';
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'Terjadi kesalahan koneksi server: $e';
    }
  }

  Future<String?> setAccessStatus(String workspaceId, String sessionId,QueueStatus status) async {
    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(accessRepositoryProvider);
      await repo.setAccessStatus(workspaceId, sessionId, status);

      state = state.copyWith(isLoading: false);

      _startAutoLockTimer();

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
    _startAutoLockTimer();
  }

  void selectAllPending() {
    final allIds = state.pendingUsers.map((e) => e.sessionId).toSet();
    state = state.copyWith(selectedPendingUserIds: allIds);
    _startAutoLockTimer();
  }

  void clearSelection() {
    state = state.copyWith(selectedPendingUserIds: {});
    _startAutoLockTimer();
  }

  Future<String?> processBulkAction(String workspaceId, QueueStatus status) async {
    if (state.selectedPendingUserIds.isEmpty) return null;

    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(accessRepositoryProvider);
      
      await repo.setBulkAccessStatus(workspaceId, state.selectedPendingUserIds.toList(), status);

      await _refresh(workspaceId);
      
      state = state.copyWith(
        isLoading: false,
        selectedPendingUserIds: {}, 
      );
      
      _startAutoLockTimer();
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'Gagal memproses aksi massal: $e';
    }
  }

  void _startAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = Timer(_timeoutDuration, () {
      state = state.copyWith(isPinVerified: false);
      print("🔒 Auto-Lock Aktif: Sesi akses kadaluarsa.");
    });
  }

  void lockScreen() {
    _autoLockTimer?.cancel();
    state = state.copyWith(isPinVerified: false);
  }

  // Update nilai pencarian secara real-time
  void updateQuery(String query) {
    if (state.searchQuery == query) return;

    state = state.copyWith(isLoading: true);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      state = state.copyWith(isLoading: false);
      state = state.copyWith(searchQuery: query.toLowerCase());
    });
    _startAutoLockTimer();
  }
}