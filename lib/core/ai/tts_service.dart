// lib/core/ai/tts_service.dart

import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import 'tts_speech_builder.dart';

/// Offline text-to-speech readout (gu / hi / en).
class TtsService extends GetxService {
  final FlutterTts _tts = FlutterTts();

  final isSpeaking = false.obs;
  final isEnabled = true.obs;
  final localeCode = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _configureTts();
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }

  Future<void> _configureTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.02);
    await _tts.setSpeechRate(0.53);
    await setLocale(localeCode.value);

    _tts.setStartHandler(() => isSpeaking.value = true);
    _tts.setCompletionHandler(() => isSpeaking.value = false);
    _tts.setCancelHandler(() => isSpeaking.value = false);
    _tts.setErrorHandler((_) => isSpeaking.value = false);
  }

  Future<void> setLocale(String code) async {
    localeCode.value = code;
    final languageTag = _mapLocale(code);
    await _tts.setLanguage(languageTag);
    await _selectBestVoice(languageTag);
  }

  Future<void> speak(String text) async {
    if (!isEnabled.value || text.trim().isEmpty) {
      return;
    }
    final script = TtsSpeechBuilder.sanitize(text.trim());
    await stop();
    await _tts.speak(script);
  }

  Future<void> stop() async {
    await _tts.stop();
    isSpeaking.value = false;
  }

  String _mapLocale(String code) {
    return switch (code) {
      'gu' => 'gu-IN',
      'hi' => 'hi-IN',
      _ => 'en-IN',
    };
  }

  Future<void> _selectBestVoice(String languageTag) async {
    try {
      final voices = await _tts.getVoices;
      if (voices == null || voices.isEmpty) {
        return;
      }

      final langPrefix = languageTag.split('-').first.toLowerCase();
      final matching = voices
          .whereType<Map>()
          .map((voice) => voice.map((key, value) => MapEntry(key.toString(), value)))
          .where((voice) {
        final locale = voice['locale']?.toString().toLowerCase() ?? '';
        return locale.startsWith(langPrefix);
      }).toList();

      if (matching.isEmpty) {
        return;
      }

      matching.sort((a, b) => _voiceRank(b).compareTo(_voiceRank(a)));
      final best = matching.first;
      final identifier = best['identifier']?.toString();
      if (identifier != null && identifier.isNotEmpty) {
        await _tts.setVoice({'identifier': identifier});
        return;
      }

      final name = best['name']?.toString();
      final locale = best['locale']?.toString();
      if (name != null && locale != null) {
        await _tts.setVoice({'name': name, 'locale': locale});
      }
    } catch (_) {
      // Keep platform default voice if selection fails.
    }
  }

  int _voiceRank(Map<String, dynamic> voice) {
    final quality = voice['quality']?.toString().toLowerCase() ?? '';
    final name = voice['name']?.toString().toLowerCase() ?? '';
    if (quality.contains('premium')) {
      return 4;
    }
    if (quality.contains('enhanced')) {
      return 3;
    }
    if (name.contains('premium') || name.contains('enhanced')) {
      return 3;
    }
    if (name.contains('neural') || name.contains('natural')) {
      return 2;
    }
    return 1;
  }
}
