import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/features/workspace_auth/data/models/cashier_session_model.dart';

part 'access_repository.g.dart';

class AccessRepository {
  AccessRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<CashierSessionModel>> getPendingUsers(String workspaceId) async {
    try {
      final response = await _supabase
          .from('cashier_queue')
          .select('id, cashier_name, created_at')
          .eq('workspace_id', workspaceId)
          .eq('status', QueueStatus.pending.name)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => CashierSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat antrean akses: $e');
    }
  }

  Future<List<CashierSessionModel>> getApprovedUsers(String workspaceId) async {
    try {
      final response = await _supabase
          .from('cashier_queue')
          .select('id, cashier_name, created_at')
          .eq('workspace_id', workspaceId)
          .eq('status', QueueStatus.approved.name)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => CashierSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar kasir aktif: $e');
    }
  }

  Future<void> setAccessStatus(String workspaceId, String sessionId, QueueStatus status) async {
    try {
      await _supabase
          .from('cashier_queue')
          .update({'status': status.name})
          .eq('workspace_id', workspaceId)
          .eq('id', sessionId);
    } catch (e) {
      throw Exception('Gagal update status antrean: $e');
    }
  }

  Future<void> setBulkAccessStatus(String workspaceId, List<String> sessionIds, QueueStatus status) async {
    if (sessionIds.isEmpty) return;

    try {
      await _supabase
          .from('cashier_queue')
          .update({'status': status.name})
          .eq('workspace_id', workspaceId)
          .inFilter('id', sessionIds);
    } catch (e) {
      throw Exception('Gagal update status massal: $e');
    }
  }
}

@Riverpod(keepAlive: true)
AccessRepository accessRepository(Ref ref) {
  return AccessRepository(ref.watch(supabaseClientProvider));
}