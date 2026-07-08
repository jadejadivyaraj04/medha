// lib/ui/onboarding/language/controller/language_controller.dart

import 'package:get/get.dart';

import '../../../../app/app_controller.dart';
import '../../../../app/routes.dart';
import '../../../../core/ai/tts_service.dart';
import '../../permissions/model/onboarding_permission.dart';

class LanguageController extends GetxController {
  final selectedCode = ''.obs;

  final _appController = Get.find<AppController>();
  final _ttsService = Get.find<TtsService>();

  final languages = const [
    LanguageOption(code: 'gu', labelKey: 'onboarding.language.gujarati'),
    LanguageOption(code: 'hi', labelKey: 'onboarding.language.hindi'),
    LanguageOption(code: 'en', labelKey: 'onboarding.language.english'),
  ];

  bool get canContinue => selectedCode.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    final saved = _appController.localeCode.value;
    if (saved.isNotEmpty) {
      selectedCode.value = saved;
    }
  }

  void selectLanguage(String code) {
    selectedCode.value = code;
    _appController.updateLocale(code);
    _ttsService.setLocale(code);
  }

  void continueNext() {
    if (!canContinue) {
      return;
    }
    Get.offNamed(
      Routes.PERMISSION_SLIDE,
      arguments: {OnboardingPermission.routeArgKey: OnboardingPermission.camera.id},
    );
  }
}

class LanguageOption {
  const LanguageOption({required this.code, required this.labelKey});

  final String code;
  final String labelKey;
}
