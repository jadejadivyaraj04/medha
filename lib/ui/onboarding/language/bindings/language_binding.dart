// lib/ui/onboarding/language/bindings/language_binding.dart

import 'package:get/get.dart';

import '../controller/language_controller.dart';

class LanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(LanguageController.new);
  }
}
