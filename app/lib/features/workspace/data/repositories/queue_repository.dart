import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_repository.g.dart';

class QueueRepository {
  QueueRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<void> registerSession(Map<String, dynamic> queueData) async {
    try {
      await _supabase.from('cashier_queue').upsert(queueData);
    } catch (e) {
      throw Exception('Gagal mendaftar sesi: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> watchQueueStatus(String id) {
    return _supabase
        .from('cashier_queue')
        .stream(primaryKey: ['id'])
        .eq('id', id);
  }
}

@riverpod 
QueueRepository queueRepository(Ref ref) {
  return QueueRepository(Supabase.instance.client);
}