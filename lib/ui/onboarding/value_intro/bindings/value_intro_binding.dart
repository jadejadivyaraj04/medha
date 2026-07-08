// lib/ui/onboarding/value_intro/bindings/value_intro_binding.dart

import 'package:get/get.dart';

import '../controller/value_intro_controller.dart';

class ValueIntroBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ValueIntroController.new);
  }
}
