import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/features/workspace_auth/data/models/cashier_session_model.dart';

part 'waiting_room_repository.g.dart';

class WaitingRoomRepository {
  WaitingRoomRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<String> joinAsOwner({
    required String workspaceId,
    required String deviceId,
    required String ownerName,
  }) async {
    try {
      final existingSession = await _supabase
          .from('cashier_queue')
          .select('id')
          .eq('workspace_id', workspaceId)
          .eq('device_id', deviceId)
          .maybeSingle();

      if (existingSession != null) {
        await _supabase
            .from('cashier_queue')
            .update({
              'cashier_name': ownerName,
              'status': QueueStatus.approved.name,
            })
            .eq('id', existingSession['id']);

        return existingSession['id'] as String;
      }

      final response = await _supabase
          .from('cashier_queue')
          .insert({
            'workspace_id': workspaceId,
            'cashier_name': ownerName,
            'device_id': deviceId,
            'status': QueueStatus.approved.name
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Gagal membuat sesi owner: $e');
    }
  }
  
  Future<String> joinWaitingRoom({
    required String workspaceId, 
    required String cashierName,
    required String deviceId
  }) async {
    try {
      final existingSession = await _supabase
          .from('cashier_queue')
          .select('id, status')
          .eq('workspace_id', workspaceId)
          .eq('device_id', deviceId)
          .maybeSingle();
      
      if (existingSession != null) {
        final currentStatus = QueueStatus.fromString(existingSession['status']);
        final updateData = {'cashier_name': cashierName};

        if (currentStatus == QueueStatus.rejected) {
          updateData['status'] = QueueStatus.pending.name;
        }

        await _supabase
            .from('cashier_queue')
            .update(updateData)
            .eq('id', existingSession['id']);

        return existingSession['id'] as String;
      }

      final response = await _supabase.from('cashier_queue').insert({
        'workspace_id': workspaceId,
        'cashier_name': cashierName,
        'device_id': deviceId,
        'status': QueueStatus.pending.name,
      }).select('id').single();

      return response['id'] as String; 
    } catch (e) {
      throw Exception('Gagal memproses masuk lapak: $e');
    }
  }
// terima semua tolak semua
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
        .eq('status', QueueStatus.pending.name)
        .handleError((error) {
          // print('Stream error caught: $error');
        })
        .map((otherCashiers) {
          return otherCashiers.where((cashier) => cashier['id'] != mySessionId).toList();
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
    // print('passcode: $passCode');
    // print('workspaceid: $workspaceId');

    try {
      final Map<String, dynamic>? response = await _supabase
          .from('shift_passes')
          .select()
          .eq('pass_code', passCode)
          .eq('workspace_id', workspaceId)
          .gte('expires_at', DateTime.now().toIso8601String()) 
          .maybeSingle();

      // print('📦 [DEBUG REPO] Hasil mentah dari Supabase: $response');

      if (response == null) {
        // Jika null, berarti tiketnya antara tidak ada, beda Lapak, atau sudah kedaluwarsa
        // print('❌ [DEBUG REPO] Tiket GAGAL! Alasan: Tidak ditemukan / Beda Lapak / Kedaluwarsa.');
        return false;
      } 
      
      await _supabase
          .from('cashier_queue')
          .update({'status': QueueStatus.approved.name})
          .eq('id', sessionId);
      // print('✅ [DEBUG REPO] Tiket VALID! Status kasir diubah jadi approved.');
      return true;

    } catch (e) {
      // print('🚨 [DEBUG REPO] ERROR FATAL: $e');
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
WaitingRoomRepository waitingRoomRepository(Ref ref) {
  return WaitingRoomRepository(ref.watch(supabaseClientProvider));
}