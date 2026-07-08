// lib/core/ai/voice_doubt_delegate.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/medicine_model.dart';
import '../permissions/permission_service.dart';
import '../theme/app_colors.dart';
import '../utils/medicine_text_helper.dart';
import '../../ui/onboarding/permissions/model/onboarding_permission.dart';
import 'audio_recorder_service.dart';
import 'gemma_service.dart';
import 'tts_service.dart';

/// Shared listen → think → answer flow for offline voice medicine doubts.
class VoiceDoubtDelegate {
  VoiceDoubtDelegate({
    required AudioRecorderService audio,
    required GemmaService gemma,
    required TtsService tts,
  })  : _audio = audio,
        _gemma = gemma,
        _tts = tts;

  final AudioRecorderService _audio;
  final GemmaService _gemma;
  final TtsService _tts;

  final answer = ''.obs;
  final errorMessage = ''.obs;
  final isProcessing = false.obs;
  final medicineContext = ''.obs;

  bool get isRecording => _audio.isRecording.value;

  String get recordingDuration => _audio.formattedDuration;

  bool get isBusy => isProcessing.value || _gemma.isAnsweringDoubt.value;

  Future<void> dispose() => _audio.cancelRecording();

  void setMedicineContext(String context) {
    medicineContext.value = context;
  }

  static String contextForMedicine({
    required MedicineModel focus,
    List<MedicineModel> otherActive = const [],
  }) {
    final buffer = StringBuffer(
      'doubt.focus_medicine'.trParams({'name': focus.name}),
    );
    buffer.write('. ');
    buffer.write(MedicineTextHelper.summaryLine(focus));
    if (otherActive.isNotEmpty) {
      buffer
        ..write('. ')
        ..write('doubt.other_active'.tr)
        ..write(' ')
        ..write(
          otherActive.map(MedicineTextHelper.summaryLine).join('. '),
        );
    }
    return buffer.toString();
  }

  Future<void> toggleRecording() async {
    if (isBusy) {
      return;
    }

    if (_audio.isRecording.value) {
      await _stopAndAsk();
      return;
    }

    await _startRecording();
  }

  Future<void> _startRecording() async {
    errorMessage.value = '';
    answer.value = '';

    final granted = await PermissionService.isGranted(
      OnboardingPermission.microphone,
    );
    if (!granted) {
      final requested = await PermissionService.request(
        OnboardingPermission.microphone,
      );
      if (!requested) {
        errorMessage.value = 'doubt.error_mic_denied'.tr;
        return;
      }
    }

    try {
      await _audio.startRecording();
    } catch (_) {
      errorMessage.value = 'doubt.error_mic_denied'.tr;
    }
  }

  Future<void> _stopAndAsk() async {
    isProcessing.value = true;
    errorMessage.value = '';

    final audioBytes = await _audio.stopRecording();
    if (audioBytes == null || audioBytes.isEmpty) {
      errorMessage.value = 'doubt.error_empty_audio'.tr;
      isProcessing.value = false;
      return;
    }

    final result = await _gemma.answerAudioDoubt(
      audioBytes,
      medicineContext: medicineContext.value,
    );

    await result.fold(
      (error) async => errorMessage.value = error.message,
      (text) async {
        answer.value = text;
        await _tts.speak(text);
      },
    );

    isProcessing.value = false;
  }

  Future<void> speakAnswer() async {
    if (answer.value.trim().isEmpty) {
      return;
    }
    await _tts.speak(answer.value);
  }

  Future<void> cancelRecording() async {
    await _audio.cancelRecording();
    errorMessage.value = '';
  }

  void showMicDeniedSnack() {
    Get.snackbar(
      'doubt.error_mic_title'.tr,
      'doubt.error_mic_denied'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      backgroundColor: AppColors.surfaceElevated,
      colorText: AppColors.textPrimary,
    );
  }
}
