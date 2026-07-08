// test/helpers/fake_tts_service.dart

import 'package:get/get.dart';
import 'package:medha/core/ai/tts_service.dart';

/// Lightweight [TtsService] for unit tests — skips native TTS init.
class FakeTtsService extends TtsService {
  String? lastSpokenText;

  @override
  void onInit() {}

  @override
  void onClose() {}

  @override
  Future<void> speak(String text) async {
    if (!isEnabled.value || text.trim().isEmpty) {
      return;
    }
    lastSpokenText = text.trim();
  }
}
