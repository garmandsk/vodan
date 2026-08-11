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

      final payload = data.toJson();
      payload['owner_id'] = userId;

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
}

@riverpod 
WorkspaceAuthRepository workspaceAuthRepository(Ref ref) {
  return WorkspaceAuthRepository(ref.watch(supabaseClientProvider));
}