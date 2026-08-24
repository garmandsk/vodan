import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/features/workspace/data/models/workspace_response_model.dart';

part 'workspace_repository.g.dart';

class WorkspaceRepository {
  WorkspaceRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<WorkspaceResponseModel>> getWorkspaceList() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Sesi telah habis, Silahkan login kembali');

      final response = await _supabase
          .from('workspaces')
          .select('id, name')
          .eq('owner_id', userId);
      
      final List<dynamic> data = response;
      return data.map((json) => WorkspaceResponseModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar lapak: $e');
    }
  }

  Future<bool> checkWorkspaceExists(String id) async {
    try {
      final response = await _supabase
          .from('workspaces')
          .select('id')
          .eq('id', id)
          .maybeSingle(); 
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteWorkspace(String id) async {
    try {
      await _supabase.from('workspaces').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus lapak: $e');
    }
  }

  Future<bool> verifyPin(String workspaceId, String pin) async {
    try {
      // print('pin: $pin');

      final response = await _supabase.rpc(
        'verify_workspace',
        params: {'p_workspace_id': workspaceId, 'p_pin': pin}
      );

      return response == true;
    } catch (e) {
      throw Exception('Gagal verifikasi pin lapak: $e');
    }
  }
}

@Riverpod(keepAlive: true)
WorkspaceRepository workspaceRepository(Ref ref) {
  return WorkspaceRepository(ref.watch(supabaseClientProvider));
}