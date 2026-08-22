import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_service_controller.g.dart';

class TtsConfig {
  const TtsConfig({
    this.isSpeaking = false,
    this.text = '',
    this.rate = 1.0, 
    this.pitch = 1.0,
    this.languageCode = 'id-ID'
  });

  final bool isSpeaking;
  final String text;
  final double rate;
  final double pitch;
  final String languageCode;

  TtsConfig copyWith({
    String? text,
    double? rate,
    double? pitch,
    String? languageCode,
    bool? isSpeaking,
  }) {
    return TtsConfig(
      text: text ?? this.text,
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
      languageCode: languageCode ?? this.languageCode,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

@Riverpod(keepAlive: true)
class TtsServiceController extends _$TtsServiceController { 
  final FlutterTts _flutterTts = FlutterTts();

  // Memori untuk replay
  String _aiText = 'halo';
  String _aiLanguageCode = 'id-ID';
  double _aiPitch = 1.0;
  double _aiRate = 0.5;

  @override 
  TtsConfig build() {
    _initTts();
    return const TtsConfig();
  }

  void setText(String text) {
    state = state.copyWith(text: text);
  }

  void setPitch(double pitch) {
    state = state.copyWith(pitch: pitch);
  }

  void setRate(double rate) {
    state = state.copyWith(rate: rate);
  }

  void setLanguageCode(String languageCode) {
    state = state.copyWith(languageCode: languageCode);
  }

  void setDefaultAiTts({
    String text = 'halo', 
    double pitch = 1.0, 
    double rate = 1.0, 
    String languageCode = 'id-ID'
  }) {
    _aiText = text;
    _aiPitch = pitch;
    _aiRate = rate;
    _aiLanguageCode = languageCode;

    state = state.copyWith(
      text: _aiText,
      pitch: _aiPitch,
      rate: _aiRate,
      languageCode: _aiLanguageCode,
    );
  }

  void defaultAiTts()  {
    setText(_aiText);
    setPitch(_aiPitch);
    setRate(_aiRate);
    setLanguageCode(_aiLanguageCode);
  }

  Future<void> _initTts() async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setVolume(1.0);

    final languages = await _flutterTts.getLanguages;
    print('🗣️ Bahasa yang tersedia di Perangkat ini: $languages');

    _flutterTts.setStartHandler(() {
      state = state.copyWith(isSpeaking: true);
    });

    _flutterTts.setCompletionHandler(() {
      state = state.copyWith(isSpeaking: false);
    });

    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      state = state.copyWith(isSpeaking: false);
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

  Future<void> speak({
    String? text,
    double? pitch,
    double? rate,
    String? languageCode
  }) async {
    print("Berbicara: $text");
    try {
      await stop();

      // if (text != null) _aiText = text;
      // if (pitch != null) _aiPitch = pitch;
      // if (rate != null) _aiRate = rate;
      // if (languageCode != null) _aiLanguageCode = languageCode;

      print('text: ${state.text}');

      bool isAvailable = await _flutterTts.isLanguageAvailable(state.languageCode);
      String finalLangCode = state.languageCode;

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

      await _flutterTts.setPitch(state.pitch);
      await _flutterTts.setSpeechRate(state.rate);
      await _flutterTts.speak(state.text, focus: true);
    } catch (e) {
      print('Gagal memutar suara: $e');
    }
  }

  Future<void> replay() async {

    if (state.text.isNotEmpty) {
      await speak();
    } else {
      print('Belum ada suara yang bisa diulang.');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    state = state.copyWith(isSpeaking: false);
  }
}