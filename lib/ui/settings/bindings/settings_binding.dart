// lib/ui/settings/bindings/settings_binding.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../data/repositories/mock_profile_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../controller/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(
      () => AppConfig.isMock
          ? MockProfileRepository()
          : MockProfileRepository(),
    );
    Get.lazyPut(
      () => SettingsController(repository: Get.find<ProfileRepository>()),
    );
  }
}
