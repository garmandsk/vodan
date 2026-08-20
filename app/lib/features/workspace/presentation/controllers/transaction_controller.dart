import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/features/workspace/data/models/cart_item_model.dart';
import 'package:vodan/features/workspace/data/models/transaction_request_model.dart';
import 'package:vodan/features/workspace/data/models/transaction_response_model.dart';
import 'package:vodan/features/workspace/data/repositories/transaction_repository.dart';
import 'package:vodan/features/workspace/presentation/controllers/cart_controller.dart';

part 'transaction_controller.g.dart';

@riverpod
class TransactionController extends _$TransactionController {
  @override
  FutureOr<void> build() {
    
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
      final workspaceId = ref.read(currentWorkspaceIdProvider) ?? 'unknown_workspace';
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

      // 3. KOSONGKAN KERANJANG KARENA TRANSAKSI SUKSES!
      ref.read(cartControllerProvider.notifier).clearCart();

      // Kembalikan state menjadi sukses
      state = const AsyncValue.data(null);
      return true; // Berhasil
      
    } catch (e, st) {
      // Jika terjadi error (misal internet putus / gagal insert)
      state = AsyncValue.error(e, st);
      return false; // Gagal
    }
  }
}