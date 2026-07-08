// lib/ui/onboarding/permissions/controller/permission_summary_controller.dart

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/routes.dart';
import '../../../../core/permissions/permission_service.dart';
import '../model/onboarding_permission.dart';

class PermissionSummaryController extends GetxController with WidgetsBindingObserver {
  final isLoading = false.obs;
  final statuses = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onReady() {
    super.onReady();
    loadStatuses();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadStatuses();
    }
  }

  Future<void> loadStatuses() async {
    isLoading.value = true;
    statuses.assignAll(await PermissionService.syncAllStatuses());
    isLoading.value = false;
  }

  String statusFor(OnboardingPermission permission) {
    return statuses[permission.id] ?? 'pending';
  }

  Future<void> retryPermission(OnboardingPermission permission) async {
    isLoading.value = true;
    await PermissionService.request(permission);
    await loadStatuses();
  }

  Future<void> openSettings() async {
    await PermissionService.openSettings();
  }

  void continueNext() {
    final args = Get.arguments;
    if (args is Map && args['fromSettings'] == true) {
      Get.back<void>();
      return;
    }
    Get.offNamed(Routes.CREATE_PROFILE);
  }
}
