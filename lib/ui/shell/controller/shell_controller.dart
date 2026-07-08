// lib/ui/shell/controller/shell_controller.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../core/ai/rag_service.dart';
import '../../../app/routes.dart';

class ShellController extends GetxController {
  final currentIndex = 0.obs;

  static const tabRoutes = <String>[
    Routes.HOME,
    Routes.MEDICINES,
    Routes.REMINDERS,
    Routes.PROFILE,
  ];

  @override
  void onReady() {
    super.onReady();
    syncIndexFromRoute(Get.currentRoute);
    if (AppConfig.enableInteractionChecks) {
      _warmRagIndex();
    }
  }

  Future<void> _warmRagIndex() async {
    if (!Get.isRegistered<RagService>()) {
      return;
    }
    await Get.find<RagService>().initialize();
  }

  void syncIndexFromRoute(String? route) {
    final index = tabRoutes.indexOf(route ?? '');
    if (index >= 0) {
      currentIndex.value = index;
    }
  }

  void selectTab(int index) {
    if (index < 0 || index >= tabRoutes.length) {
      return;
    }
    if (currentIndex.value == index) {
      return;
    }
    currentIndex.value = index;
  }

  void openScan() {
    Get.toNamed(Routes.SCAN);
  }
}
