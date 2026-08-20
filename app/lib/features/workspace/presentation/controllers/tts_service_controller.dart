import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_service_controller.g.dart';

@Riverpod(keepAlive: true)
class TtsServiceController extends _$TtsServiceController {
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

    final languages = await _flutterTts.getLanguages;
    print('🗣️ Bahasa yang tersedia di Perangkat ini: $languages');

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

  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      final langList = List<String>.from(languages);
      
      if (langList.isEmpty) return ['id-ID', 'en-US']; 
      return langList;
    } catch (e) {
      return ['id-ID', 'en-US'];
    }
  }

  Future<void> speak(
    String text, {
    String languageCode = 'id-ID',
    double pitch = 1.0,
    double rate = 1.0,
  }) async {
    // print("Berbicara: $text");
    try {
      await stop();

      _lastSpokenText = text;
      _lastLanguageCode = languageCode;
      _lastPitch = pitch;
      _lastRate = rate;

      bool isAvailable = await _flutterTts.isLanguageAvailable(languageCode);
      String finalLangCode = languageCode;

      if (!isAvailable) {
        List<dynamic> languages = await _flutterTts.getLanguages;
        List<String> availableLanguage = List<String>.from(languages);

        if (availableLanguage.isEmpty) {
          isAvailable = false;
        } else {
          final result = await _flutterTts.setLanguage(availableLanguage[0]);
          isAvailable = (result == 1 || result == true);
        }
      } 
      
      if (isAvailable) {
        await _flutterTts.setLanguage(finalLangCode);
      } else {
        print("Tidak ada bahasa yang didukung di Perangkat ini.");
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