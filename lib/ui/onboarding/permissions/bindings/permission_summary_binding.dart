// lib/ui/onboarding/permissions/bindings/permission_summary_binding.dart

import 'package:get/get.dart';

import '../controller/permission_summary_controller.dart';

class PermissionSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(PermissionSummaryController.new);
  }
}
