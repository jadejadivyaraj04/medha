// lib/ui/onboarding/splash/controller/splash_controller.dart

import 'package:get/get.dart';

import '../../../../app/app_controller.dart';
import '../../../../app/routes.dart';
import '../../../../core/ai/gemma_service.dart';
import '../../../../core/storage/storage_manager.dart';

class SplashController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final _appController = Get.find<AppController>();
  final _gemmaService = Get.find<GemmaService>();

  @override
  void onReady() {
    super.onReady();
    _startFlow();
  }

  /// Set when onboarding is already done and only the model is missing
  /// (e.g. onboarding was completed while the app ran in mock mode).
  bool _resumeToHome = false;

  Future<void> _startFlow() async {
    while (!_appController.isBootstrapped.value) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    if (StorageManager.isOnboardingComplete && StorageManager.hasProfile) {
      if (await _gemmaService.isModelInstalled()) {
        Get.offAllNamed(Routes.HOME);
        return;
      }
      _resumeToHome = true;
    }

    await _downloadModel();
  }

  Future<void> _downloadModel() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _gemmaService.installModelForOnboarding();
    result.fold(
      (error) => errorMessage.value = error.message,
      (_) => _resumeToHome
          ? Get.offAllNamed(Routes.HOME)
          : Get.offNamed(Routes.VALUE_INTRO),
    );

    isLoading.value = false;
  }

  void retry() => _downloadModel();

  void cancelDownload() {
    _gemmaService.cancelModelDownload();
  }
}
