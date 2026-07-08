// lib/ui/onboarding/permissions/bindings/permission_slide_binding.dart

import 'package:get/get.dart';

import '../controller/permission_slide_controller.dart';

class PermissionSlideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(PermissionSlideController.new, fenix: true);
  }
}
