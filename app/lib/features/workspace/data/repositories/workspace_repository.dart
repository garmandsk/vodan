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
}

@riverpod
WorkspaceRepository workspaceRepository(Ref ref) {
  return WorkspaceRepository(ref.watch(supabaseClientProvider));
}