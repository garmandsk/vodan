import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

part 'stt_service_controller.g.dart';

enum SpeechStatus {
  listening('listening'),
  notListening('notListening'),
  done('done'),
  error('error'),
  unknown('');

  final String value;
  const SpeechStatus(this.value);

  // Fungsi pengubah String dari package menjadi Enum
  static SpeechStatus fromString(String val) {
    return SpeechStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => SpeechStatus.unknown,
    );
  }
}

class SpeechState {
  const SpeechState({
    this.isAvailable = false,
    this.isListening = false,
    this.recognizedText = '',
  });

  final bool isAvailable;
  final bool isListening;
  final String recognizedText;

  SpeechState copyWith({
    bool? isAvailable,
    bool? isListening,
    String? recognizedText
  }) {
    return SpeechState(
      isAvailable: isAvailable ?? this.isAvailable,
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText
    );
  }
}

// Menggunakan riverpod statefull
@Riverpod(keepAlive: true)
class SttServiceController extends _$SttServiceController {
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override 
  SpeechState build() {
    _initSpeech();
    return const SpeechState();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (statusString) {
          final status = SpeechStatus.fromString(statusString);
          if (status == SpeechStatus.notListening || status == SpeechStatus.done) {
            state = state.copyWith(isListening: false);
          }
        },
        onError: (errorNotification) {
          // print('STT Error: $errorNotification');
          state = state.copyWith(isListening: false);
        },
      );
      state = state.copyWith(isAvailable: available);
    } catch (e) {
      // print('Gagal inisialisasi STT: $e');
      state = state.copyWith(isAvailable: false);
    }
  }

  Future<void> startListening() async {
    if (state.isListening) {
      // print('ℹ️ Mikrofon sudah berjalan, abaikan spam klik.');
      return;
    }

    if (!state.isAvailable) await _initSpeech();

    if (state.isAvailable) {
      state = state.copyWith(isListening: true, recognizedText: '');
      
      await _speech.listen(
        onResult: (result) {
          // print('suara terdengar: ${result.recognizedWords}');
          state = state.copyWith(recognizedText: result.recognizedWords);
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: 'id-ID',
          cancelOnError: true,
          partialResults: true,
          pauseFor: const Duration(seconds: 10),
          listenFor: const Duration(seconds: 60),
        )
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    state = state.copyWith(isListening: false);
  }
}