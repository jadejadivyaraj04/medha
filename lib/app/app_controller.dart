// lib/app/app_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/notifications/notification_service.dart';
import '../core/storage/storage_manager.dart';
import '../data/models/app_settings_model.dart';

class AppController extends GetxController {
  final isBootstrapped = false.obs;
  final localeCode = 'en'.obs;
  final textScaleFactor = 1.3.obs;

  @override
  void onInit() {
    super.onInit();
    bootstrap();
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.isRegistered<NotificationService>()) {
      Get.find<NotificationService>().processPendingNavigation();
    }
  }

  Future<void> bootstrap() async {
    final savedLocale = StorageManager.getLocale();
    if (savedLocale != null && savedLocale.isNotEmpty) {
      localeCode.value = savedLocale;
      Get.updateLocale(Locale(savedLocale));
    }

    final settingsRaw = StorageManager.getAppSettings();
    if (settingsRaw.isNotEmpty) {
      final settings = AppSettingsModel.fromJson(settingsRaw);
      textScaleFactor.value = settings.textScale;
      if (savedLocale == null || savedLocale.isEmpty) {
        localeCode.value = settings.languageCode;
        Get.updateLocale(Locale(settings.languageCode));
      }
    }

    isBootstrapped.value = true;
  }

  Future<void> updateLocale(String code) async {
    localeCode.value = code;
    await StorageManager.saveLocale(code);
    Get.updateLocale(Locale(code));
    update();
  }
}
