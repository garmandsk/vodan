import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/transaction_model.dart';

part 'transaction_repository.g.dart';

class TransactionRepository {
  TransactionRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<void> saveTransaction(TransactionModel transaction) async {
    try {
      await _supabase.from('transaction').insert(transaction.toJson());
    } catch (e) {
      throw Exception('Gagal menyimpan transaksi: $e');
    }
  }

  Future<void> rejectTransaction(String transactionId) async {
    try {
      await _supabase
          .from('transactions')
          .update({'status': TransactionStatus.rejected.name})
          .eq('id', transactionId);
    } catch (e) {
      throw Exception('Gagal membatalkan transaksi: $e');
    }
  }
}

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepository(Supabase.instance.client);
}