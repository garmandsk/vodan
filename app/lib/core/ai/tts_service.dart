import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_service.g.dart';

@Riverpod(keepAlive: true)
class TtsService extends _$TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  // Memori untuk replay
  String? _lastSpokenText;
  String _lastLanguageCode = 'id-ID';
  double _lastPitch = 1.0;
  double _lastRate = 0.5;

  @override 
  bool build() {
    _initTts();
    return false;
  }

  Future<void> _initTts() async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setVolume(1.0);

    _flutterTts.setStartHandler(() {
      state = true;
    });

    _flutterTts.setCompletionHandler(() {
      state = false;
    });

    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      state = false;
    });
  }

  Future<void> speak(
    String text, {
    String languageCode = 'id-ID',
    double pitch = 1.0,
    double rate = 0.5,
  }) async {
    try {
      await stop();

      _lastSpokenText = text;
      _lastLanguageCode = languageCode;
      _lastPitch = pitch;
      _lastRate = rate;

      final isAvailable = await _flutterTts.isLanguageAvailable(languageCode);

      if (isAvailable) {
        await _flutterTts.setLanguage(languageCode);
      } else {
        print("Bahasa $languageCode tidak didukung di HP ini. Fallback ke id-ID.");
        await _flutterTts.setLanguage('id-ID');
      }

      await _flutterTts.setPitch(pitch);
      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.speak(text, focus: true);
    } catch (e) {
      print('Gagal memutar suara: $e');
    }
  }

  Future<void> replay() async {

    if (_lastSpokenText != null && _lastSpokenText!.isNotEmpty) {
      await speak(
        _lastSpokenText!,
        languageCode: _lastLanguageCode,
        pitch: _lastPitch,
        rate: _lastRate,
      );
    } else {
      print('Belum ada suara yang bisa diulang.');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    state = false;
  }
}