// lib/ui/onboarding/permissions/controller/permission_slide_controller.dart

import 'package:get/get.dart';

import '../../../../app/routes.dart';
import '../../../../core/permissions/permission_service.dart';
import '../model/onboarding_permission.dart';

class PermissionSlideController extends GetxController {
  final isRequesting = false.obs;
  final permission = OnboardingPermission.first.obs;

  @override
  void onInit() {
    super.onInit();
    _syncFromArguments();
  }

  void _syncFromArguments() {
    permission.value =
        OnboardingPermission.fromArguments(Get.arguments) ??
        OnboardingPermission.first;
    isRequesting.value = false;
  }

  Future<void> allow() async {
    if (isRequesting.value) {
      return;
    }
    isRequesting.value = true;
    await PermissionService.request(permission.value);
    isRequesting.value = false;
    _advance();
  }

  Future<void> skip() async {
    await PermissionService.markSkipped(permission.value);
    _advance();
  }

  void _advance() {
    final next = permission.value.next;
    if (next != null) {
      permission.value = next;
      return;
    }
    Get.offNamed(Routes.PERMISSION_SUMMARY);
  }
}
