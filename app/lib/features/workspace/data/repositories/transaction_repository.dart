import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/features/workspace/data/models/transaction_request_model.dart';
import 'package:vodan/features/workspace/data/models/transaction_update_request_model.dart';
import '../models/transaction_response_model.dart';

part 'transaction_repository.g.dart';

class TransactionRepository {
  TransactionRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<void> createTransaction(TransactionRequestModel transaction) async {
    try {
      await _supabase.from('transaction_log').insert(transaction.toJson());
    } catch (e) {
      throw Exception('Gagal menyimpan transaksi: $e');
    }
  }

  Future<List<TransactionResponseModel>> getTransactions({
    required String workspaceId,
    String query = '',
    String status = 'Semua',
    DateTime? startDate, 
    DateTime? endDate,  
  }) async {
    try {
      var request = _supabase
          .from('transaction_log')
          .select('*')
          .eq('workspace_id', workspaceId);

      if (status != 'Semua') {
        request = request.eq('status', status);
      }

      if (startDate != null) {
        request = request.gte('transaction_time', startDate.toIso8601String());
      }
      if (endDate != null) {
        final endOfDay = endDate.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        request = request.lte('transaction_time', endOfDay.toIso8601String());
      }

      final response = await request.order('transaction_time', ascending: false);
      
      var transactions = response.map((json) => TransactionResponseModel.fromJson(json)).toList();

      if (query.isNotEmpty) {
        final keyword = query.toLowerCase();
        
        transactions = transactions.where((trx) {
          // Cek nama kasir
          final matchCashier = trx.cashierName.toLowerCase().contains(keyword);
          
          // Cek ID Pesanan
          final matchId = trx.id.toLowerCase().contains(keyword);
          
          // Cek Nama Item di dalam keranjang (Looping ke dalam List<CartItemModel>)
          final matchItems = trx.items.any((item) => 
              item.product.name.toLowerCase().contains(keyword)
          );

          // Jika salah satu cocok, tampilkan transaksinya!
          return matchCashier || matchId || matchItems;
        }).toList();
      }

      return transactions;
    } catch (e) {
      throw Exception('Gagal ambil data transaksi: $e');
    }
  }

  Future<void> updateTransaction(String transactionId, TransactionUpdateRequestModel transactionUpdateModel) async {
    try {
      final updateData = transactionUpdateModel.toJson();
      if (updateData.isEmpty) return;

      await _supabase
          .from('transaction_log')
          .update(updateData)
          .eq('id', transactionId);
    } catch (e) {
      throw Exception('Gagal edit transaksi: $e');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _supabase.from('transaction_log').delete().eq('id', transactionId);
    } catch (e) {
      throw Exception('Gagal menghapus transaksi: $e');
    }
  }
}

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepository(Supabase.instance.client);
}