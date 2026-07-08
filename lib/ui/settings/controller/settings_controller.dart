// lib/ui/settings/controller/settings_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_controller.dart';
import '../../../app/routes.dart';
import '../../../core/ai/gemma_service.dart';
import '../../../core/ai/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/app_settings_model.dart';
import '../../../data/repositories/profile_repository.dart';

class SettingsController extends GetxController {
  SettingsController({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;
  final _appController = Get.find<AppController>();
  final _tts = Get.find<TtsService>();
  final _gemma = Get.find<GemmaService>();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  final settings = AppSettingsModel.defaults().obs;
  final modelReady = false.obs;
  final modelDownloading = false.obs;
  final modelProgress = 0.0.obs;

  static const languageOptions = ['en', 'gu', 'hi'];

  @override
  void onInit() {
    super.onInit();
    load();
    ever(_gemma.isModelReady, (ready) => modelReady.value = ready);
    ever(_gemma.isDownloading, (downloading) => modelDownloading.value = downloading);
    ever(_gemma.downloadProgress, (progress) => modelProgress.value = progress);
    modelReady.value = _gemma.isModelReady.value;
    modelDownloading.value = _gemma.isDownloading.value;
    modelProgress.value = _gemma.downloadProgress.value;
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _repository.getSettings();
    result.fold(
      (error) => errorMessage.value = error.message,
      (data) {
        settings.value = data;
        _tts.isEnabled.value = data.voiceEnabled;
        _appController.textScaleFactor.value = data.textScale;
      },
    );

    isLoading.value = false;
  }

  Future<void> setLanguage(String code) async {
    settings.value = settings.value.copyWith(languageCode: code);
    await _persistSettings();
    await _appController.updateLocale(code);
    await _tts.setLocale(code);
  }

  Future<void> setTextScale(double scale) async {
    final clamped = scale.clamp(1.3, 1.5);
    settings.value = settings.value.copyWith(textScale: clamped);
    _appController.textScaleFactor.value = clamped;
    await _persistSettings();
  }

  Future<void> toggleVoice(bool enabled) async {
    settings.value = settings.value.copyWith(voiceEnabled: enabled);
    _tts.isEnabled.value = enabled;
    await _persistSettings();
  }

  Future<void> _persistSettings() async {
    isSaving.value = true;
    final result = await _repository.saveSettings(settings.value);
    result.fold(
      (error) => errorMessage.value = error.message,
      (saved) => settings.value = saved,
    );
    isSaving.value = false;
  }

  void openPermissions() {
    Get.toNamed(
      Routes.PERMISSION_SUMMARY,
      arguments: {'fromSettings': true},
    );
  }

  Future<void> redownloadModel() async {
    if (modelDownloading.value) {
      return;
    }
    final result = await _gemma.installModel();
    result.fold(
      (error) {
        Get.snackbar(
          'settings.model_error_title'.tr,
          error.message,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.surfaceElevated,
          colorText: AppColors.textPrimary,
        );
      },
      (_) {
        Get.snackbar(
          'settings.model_ready_title'.tr,
          'settings.model_ready_body'.tr,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.surfaceElevated,
          colorText: AppColors.textPrimary,
        );
      },
    );
  }

  String languageLabel(String code) {
    return switch (code) {
      'gu' => 'settings.language.gu'.tr,
      'hi' => 'settings.language.hi'.tr,
      _ => 'settings.language.en'.tr,
    };
  }

  String get modelStatusLabel {
    if (modelDownloading.value) {
      return 'settings.model_downloading'.trParams({
        'percent': '${(modelProgress.value * 100).round()}',
      });
    }
    if (modelReady.value) {
      return 'settings.model_ready'.tr;
    }
    return 'settings.model_not_ready'.tr;
  }
}
