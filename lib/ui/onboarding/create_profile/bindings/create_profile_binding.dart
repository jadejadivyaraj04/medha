// lib/ui/onboarding/create_profile/bindings/create_profile_binding.dart

import 'package:get/get.dart';

import '../../../../app/app_config.dart';
import '../../../../data/repositories/mock_profile_repository.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../controller/create_profile_controller.dart';

class CreateProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(
      () => AppConfig.isMock
          ? MockProfileRepository()
          : MockProfileRepository(),
    );
    Get.lazyPut(
      () => CreateProfileController(repository: Get.find<ProfileRepository>()),
    );
  }
}
