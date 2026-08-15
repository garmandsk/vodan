import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/providers/supabase_provider.dart';

part 'waiting_room_repository.g.dart';

class WaitingRoomRepository {
  WaitingRoomRepository(this._supabase);

  final SupabaseClient _supabase;
  
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
        .neq('id', mySessionId)
        .handleError((error) {
          print('Stream error caught: $error');
        });
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
    print('passcode: $passCode');
    print('workspaceid: $workspaceId');

    try {
      final Map<String, dynamic>? response = await _supabase
          .from('shift_passes')
          .select()
          .eq('pass_code', passCode)
          .eq('workspace_id', workspaceId)
          // 🌟 Filter ini SUDAH membuang tiket yang kedaluwarsa secara otomatis!
          .gte('expires_at', DateTime.now().toIso8601String()) 
          .maybeSingle();

      print('📦 [DEBUG REPO] Hasil mentah dari Supabase: $response');

      // 🌟 1. CEK NULL DULUAN (Wajib paling atas!)
      if (response == null) {
        // Jika null, berarti tiketnya antara tidak ada, beda Lapak, atau sudah kedaluwarsa
        print('❌ [DEBUG REPO] Tiket GAGAL! Alasan: Tidak ditemukan / Beda Lapak / Kedaluwarsa.');
        return false;
      } 
      
      // 🌟 2. JIKA SAMPAI DI SINI, BERARTI TIKETNYA 100% VALID & AKTIF
      await _supabase.from('cashier_queue').update({'status': 'approved'}).eq('id', sessionId);
      print('✅ [DEBUG REPO] Tiket VALID! Status kasir diubah jadi approved.');
      return true;

    } catch (e) {
      print('🚨 [DEBUG REPO] ERROR FATAL: $e');
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
WaitingRoomRepository waitingRoomRepo(Ref ref) {
  return WaitingRoomRepository(ref.watch(supabaseClientProvider));
}