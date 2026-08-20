import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/features/workspace/data/models/transaction_request_model.dart';
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

  Future<void> updateTransaction(String transactionId, TransactionStatus status) async {
    try {
      await _supabase
          .from('transaction_log')
          .update({'status': status.name})
          .eq('id', transactionId);
    } catch (e) {
      throw Exception('Gagal edit transaksi: $e');
    }
  }
}

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepository(Supabase.instance.client);
}