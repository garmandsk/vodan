import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/features/workspace/data/models/cart_item_model.dart';
import 'package:vodan/features/workspace/data/models/transaction_request_model.dart';
import 'package:vodan/features/workspace/data/models/transaction_response_model.dart';
import 'package:vodan/features/workspace/data/models/transaction_update_request_model.dart';
import 'package:vodan/features/workspace/data/repositories/transaction_repository.dart';
import 'package:vodan/features/workspace/presentation/controllers/cart_controller.dart';

part 'transaction_controller.g.dart';

@riverpod
class TransactionController extends _$TransactionController {
  Timer? _debounceTimer;
  RealtimeChannel? _realtimeChannel;

  String _currentQuery = '';
  String _currentStatus = 'Semua';

  DateTime? _startDate;
  DateTime? _endDate;

  String? get selectedStatus => _currentStatus;

  @override
  FutureOr<List<TransactionResponseModel>> build() async {
    ref.onDispose(() {
      _realtimeChannel?.unsubscribe();
    });

    final workspaceId = ref.watch(currentWorkspaceProvider)?.id;
    if (workspaceId != null && workspaceId.isNotEmpty) {
      _realtimeChannel = ref.read(supabaseClientProvider)
          .channel('public:transaction_log:$workspaceId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'transaction_log',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq, 
              column: 'workspace_id', 
              value: workspaceId
            ),
            callback: (payload) {
              print('🔥 Terdeteksi perubahan dari Spreadsheet/Supabase: $payload');
              ref.invalidateSelf();
            }
          )
          .subscribe((status, [error]) {
            // print('📡 Status Realtime: $status');
            if (error != null) {
              // print('❌ Error Realtime: $error');
            }
          });
    }

    return getTransactions();
  }

  Future<bool> createTransaction({
    required double totalPrice,
    required PaymentMethod paymentMethod,
    required TransactionStatus status,
    required List<CartItemModel> items,
  }) async {
    // Ubah state menjadi loading
    state = const AsyncValue.loading();

    try {
      final workspaceId = ref.read(currentWorkspaceProvider)?.id ?? 'unknown_workspace';
      final cashierName = ref.read(currentUserProvider)?.cashierName ?? 'Kasir-anonim';

      final transactionData = TransactionRequestModel(
        workspaceId: workspaceId, 
        items: items, 
        totalPrice: totalPrice, 
        paymentMethod: paymentMethod, 
        cashierName: cashierName, 
        status: status
      );

      final repo = ref.read(transactionRepositoryProvider);
      await repo.createTransaction(transactionData);

      ref.read(cartControllerProvider.notifier).clearCart();

      return true; // Berhasil
      
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false; // Gagal
    }
  }

  Future<List<TransactionResponseModel>> getTransactions() async {
    state = const AsyncValue.loading();

    try {
      final workspaceId = ref.read(currentWorkspaceProvider)?.id;
      if (workspaceId == null || workspaceId.isEmpty) {
        throw Exception('Lapak tidak ditemukan!');
      }
      final repo = ref.read(transactionRepositoryProvider);

      final transactions = await repo.getTransactions(
        workspaceId: workspaceId, 
        query: _currentQuery, 
        status: _currentStatus,
        startDate: _startDate,
        endDate: _endDate
      );

      state = AsyncValue.data(transactions);
      return transactions;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return [];
    }
  }

  Future<void> updateTransaction(String transactionId, TransactionUpdateRequestModel updateModel) async {
    state = const AsyncValue.loading();

    try {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.updateTransaction(transactionId, updateModel);

      await getTransactions();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    state = const AsyncValue.loading();

    try {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.deleteTransaction(transactionId);

      await getTransactions();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return;
    }
  }

  void updateSearch(String query) {
    if (_currentQuery == query) return;
    _currentQuery = query;
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => getTransactions());
    });
  }

  void updateStatus(TransactionStatus? status) {
    if (_currentStatus == status?.name) return;
    _currentStatus = status?.name ?? 'Semua';
    _debounceTimer?.cancel();
    state = const AsyncValue.loading();
    Future.microtask(() async {
      state = await AsyncValue.guard(() => getTransactions());
    });
  }

  void updateDateRange(DateTime? start, DateTime? end) {
    if (_startDate == start || _endDate == end) return;
    _startDate = start;
    _endDate = end;
    ref.invalidateSelf();
  }
}