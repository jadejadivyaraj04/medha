// lib/ui/profile/bindings/profile_binding.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../data/repositories/mock_profile_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(
      () => AppConfig.isMock
          ? MockProfileRepository()
          : MockProfileRepository(),
    );
    Get.lazyPut(
      () => ProfileController(repository: Get.find<ProfileRepository>()),
    );
  }
}
