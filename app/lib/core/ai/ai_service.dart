import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_service.g.dart';

class AiService {
  AiService(this._supabase);
  
  final SupabaseClient _supabase;

  Future<Map<String, dynamic>> processVoiceOrder(String workspaceId, String voiceText) async {
    try {
      final response = await _supabase.functions.invoke(
        'voice_order',
        body: {
          'workspace_id': workspaceId,
          'voice_text': voiceText
        }
      );

      if (response.status != 200) {
        throw Exception('Error dari server: ${response.data}');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Gagal memproses pesanan suara: $e');
    }
  }
}

@riverpod
AiService aiService(Ref ref) {
  return AiService(Supabase.instance.client);
}