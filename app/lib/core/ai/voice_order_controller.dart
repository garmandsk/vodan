import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/features/workspace/presentation/controllers/cart_controller.dart';
import 'package:vodan/features/workspace/presentation/controllers/product_controller.dart';
import 'ai_service.dart';
import 'stt_service.dart';
import 'tts_service.dart';

part 'voice_order_controller.g.dart';

enum VoiceOrderState { idle, listening, processing, success, error }

@riverpod
class VoiceOrderController extends _$VoiceOrderController {
  @override
  VoiceOrderState build() {
    return VoiceOrderState.idle;
  }

  Future<void> startRecording() async {
    state = VoiceOrderState.listening;
    await ref.read(speechControllerProvider.notifier).startListening();
  }

  Future<void> stopAndProcess(String workspaceId) async {
    await ref.read(speechControllerProvider.notifier).stopListening();

    final speechState = ref.read(speechControllerProvider);
    final text = speechState.recognizedText;

    // Jika tombol kepencet
    if (text.trim().isEmpty) {
      state = VoiceOrderState.idle;
      return;
    }

    state = VoiceOrderState.processing;

    try {
      final aiService = ref.read(aiServiceProvider);
      final aiResult = await aiService.processVoiceOrder(workspaceId, text);
      final catalog = ref.read(productListControllerProvider(workspaceId)).value ?? [];
      final orders = aiResult['orders'] as List<dynamic>;

      print('🛒 [KERANJANG] Menambahkan: $orders');
      ref.read(cartControllerProvider.notifier).addAiOrders(orders, catalog);

      final ttsConfig = aiResult['tts_config'];
      await ref.read(ttsServiceProvider.notifier).speak(
          aiResult['voice_response'],
          languageCode: ttsConfig['language_code'],
          pitch: (ttsConfig['pitch'] as num).toDouble(),
          rate: (ttsConfig['rate'] as num).toDouble());

      state = VoiceOrderState.success;

      Future.delayed(const Duration(seconds: 2), () {
        if (state == VoiceOrderState.success) {
          state = VoiceOrderState.idle;
        }
      });
    } catch (e) {
      print('❌ AI Error: $e');
      state = VoiceOrderState.error;

      await ref
          .read(ttsServiceProvider.notifier)
          .speak('Maaf, sistem sedang sibuk. Tolong ulangi pesanan.');

      Future.delayed(const Duration(seconds: 3), () {
        if (state == VoiceOrderState.error) {
          state = VoiceOrderState.idle;
        }
      });
    }
  }
}
