import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/features/workspace/data/models/voice_transaction_response_model.dart';

import 'package:vodan/features/workspace/presentation/controllers/cart_controller.dart';
import 'package:vodan/features/workspace/presentation/controllers/product_controller.dart';
import '../../data/repositories/voice_transaction_repository.dart';
import 'stt_service_controller.dart';
import 'tts_service_controller.dart';

part 'voice_transaction_controller.g.dart';

enum VoiceState { idle, listening, processing, successChat, successTransaction, error }

@riverpod
class VoiceTransactionController extends _$VoiceTransactionController {
  bool isLastStockAdjusted = false;

  @override
  VoiceState build() {
    return VoiceState.idle;
  }

  Future<void> startRecording() async {
    state = VoiceState.listening;
    await ref.read(sttServiceControllerProvider.notifier).startListening();
  }

  Future<void> stopAndProcess(String workspaceId) async {
    await ref.read(sttServiceControllerProvider.notifier).stopListening();

    final speechState = ref.read(sttServiceControllerProvider);
    final text = speechState.recognizedText;

    // Jika tombol kepencet
    if (text.trim().isEmpty) {
      state = VoiceState.idle;
      return;
    }

    state = VoiceState.processing;

    String fallbackText = 'Maaf, sistem sedang sibuk. Tolong ulangi pesanan.';
    String fallbackLangCode = 'id-ID';

    try {
      final aiService = ref.read(voiceTransactionRepositoryProvider);
      final availableLanguages = await ref.read(ttsServiceControllerProvider.notifier).getAvailableLanguages();

      final VoiceTransactionResponseModel aiResult = await aiService.createVoiceTransaction(workspaceId, text, availableLanguages);
      isLastStockAdjusted = aiResult.isStockAdjusted;

      fallbackText = aiResult.fallbackResponse;
      fallbackLangCode = aiResult.ttsConfig.languageCode;

      // print('aiResult response: ${aiResult.voiceResponse}');
      // print('aiResult: ${aiResult.ttsConfig}');

      final Intent intent = aiResult.intent;

      if (intent == Intent.transaction) {
        final catalog = ref.read(productControllerProvider).value ?? [];
        final orders = aiResult.orders;

        // print('🛒 [KERANJANG] Menambahkan: $orders');
        ref.read(cartControllerProvider.notifier).addAiOrders(orders, catalog);
      }

      final ttsConfig = aiResult.ttsConfig;
      await ref.read(ttsServiceControllerProvider.notifier).speak(
        aiResult.voiceResponse,
        languageCode: ttsConfig.languageCode,
        pitch: ttsConfig.pitch,
        rate: ttsConfig.rate
      );

      // for (var order in aiResult.orders) {
        // print('Menambahkan ${order.name} sebanyak ${order.qty} dengan total ${order.subTotal}');
      // }

      state = intent == Intent.transaction
          ? VoiceState.successTransaction
          : VoiceState.successChat;
    } catch (e) {
      print('❌ AI Error: $e');
      state = VoiceState.error;

      await ref
          .read(ttsServiceControllerProvider.notifier)
          .speak(
            fallbackText,
            languageCode: fallbackLangCode,
            pitch: 1.0,
            rate: 0.5
          );
    }
  }

  void resetToIdle() {
    if (state != VoiceState.idle) {
      state = VoiceState.idle;
    }
  }
}
