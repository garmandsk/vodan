import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/features/workspace/data/models/voice_transaction_response_model.dart';

part 'voice_transaction_repository.g.dart';

class VoiceTransactionRepository {
  VoiceTransactionRepository(this._supabase);
  
  final SupabaseClient _supabase;

  Future<VoiceTransactionResponseModel> createVoiceTransaction(String workspaceId, String voiceText, List<String> availableLanguages) async {
    try {
      final response = await _supabase.functions.invoke(
        'voice_transaction',
        body: {
          'workspace_id': workspaceId,
          'voice_text': voiceText,
          'available_languages': availableLanguages
        }
      );

      if (response.status != 200) {
        throw Exception('Error dari server: ${response.data}');
      }

      final responseData = response.data as Map<String, dynamic>;
      final responseModel = VoiceTransactionResponseModel.fromJson(responseData);

      // print(responseModel);
      return responseModel;
    } catch (e) {
      throw Exception('Gagal memproses pesanan suara: $e');
    }
  }
}

@Riverpod(keepAlive: true)
VoiceTransactionRepository voiceTransactionRepository(Ref ref) {
  return VoiceTransactionRepository(ref.watch(supabaseClientProvider));
}