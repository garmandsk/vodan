import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/features/workspace_auth/data/models/create_workspace_request_model.dart';

part 'workspace_auth_repository.g.dart';

class WorkspaceAuthRepository {
  WorkspaceAuthRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<String> createWorkspace({required CreateWorkspaceRequestModel data}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Sesi telah habis, silahkan login kembali.');
      }

      final pinBytes = utf8.encode(data.adminPin);
      final clientHashedPin = sha256.convert(pinBytes).toString();

      final payload = data.toJson();
      payload['owner_id'] = userId;
      payload['admin_pin'] = clientHashedPin;

      final response = await _supabase
          .from('workspaces')
          .insert(payload)
          .select('id')
          .single();

      return response['id'] as String;
      
    } catch (e) {
      throw Exception('Gagal membuat lapak: $e');
    }
  }

  Future<String> joinWaitingRoom({required String workspaceId, required String cashierName}) async {
    final response = await _supabase.from('cashier_queue').insert({
      'workspace_id': workspaceId,
      'cashier_name': cashierName,
      'status': 'pending',
    }).select('id').single();
    
    return response['id']; 
  }

  // Stream: Pantau Status Diri Sendiri (Apakah sudah di-ACC Owner?)
  Stream<Map<String, dynamic>> watchMyStatus(String sessionId) {
    return _supabase
        .from('cashier_queue')
        .stream(primaryKey: ['id'])
        .eq('id', sessionId)
        .map((event) => event.first); 
  }

  // Stream: Pantau Kasir Lain di Ruang Tunggu yang Sama (Status Pending)
  Stream<List<Map<String, dynamic>>> watchOtherCashiers(String workspaceId, String mySessionId) {
    return _supabase
        .from('cashier_queue')
        .stream(primaryKey: ['id'])
        .eq('workspace_id', workspaceId)
        .eq('status', 'pending')
        .neq('id', mySessionId);
  }

  // Update Nama / Workspace ID (Saat user menekan tombol Edit)
  Future<void> updateCredentials(String sessionId, String newName, String newWorkspaceId) async {
    await _supabase.from('cashier_queue').update({
      'cashier_name': newName,
      'workspace_id': newWorkspaceId,
    }).eq('id', sessionId);
  }

  // Validasi Tiket Akses Shift (QR Dinamis)
  Future<bool> validateShiftPass(String passCode, String workspaceId, String sessionId) async {
    final response = await _supabase
        .from('shift_passes')
        .select()
        .eq('pass_code', passCode)
        .eq('workspace_id', workspaceId)
        .gte('expires_at', DateTime.now().toIso8601String()) 
        .maybeSingle();

    if (response != null) {
      await _supabase.from('cashier_queue').update({'status': 'approved'}).eq('id', sessionId);
      return true;
    }
    return false; 
  }
}

@Riverpod(keepAlive: true)
WorkspaceAuthRepository workspaceAuthRepository(Ref ref) {
  return WorkspaceAuthRepository(ref.watch(supabaseClientProvider));
}