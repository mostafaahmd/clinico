import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistant {
  final stt.SpeechToText _stt = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _ready = false;

  Future<bool> init({String ttsLang = 'ar-SA'}) async {
    final ok = await _stt.initialize();
    await _tts.setLanguage(ttsLang);      // 'ar-SA' أو 'en-US'
    await _tts.setSpeechRate(0.5);        // سرعة مريحة
    _ready = ok;
    return ok;
  }

  Future<String?> listenOnce({String localeId = 'ar_SA'}) async {
    if (!_ready) {
      final ok = await init(ttsLang: localeId == 'ar_SA' ? 'ar-SA' : 'en-US');
      if (!ok) return null;
    }
    String? text;
    await _stt.listen(
      localeId: localeId,
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      onResult: (r) => text = r.recognizedWords,
      partialResults: false,
    );
    // انتظر لحد ما يوقف تلقائي
    await Future.delayed(const Duration(seconds: 9));
    await _stt.stop();
    return (text?.trim().isEmpty ?? true) ? null : text!.trim();
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }
}
