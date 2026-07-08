// lib/ui/caregiver/bindings/caregiver_binding.dart

import 'package:get/get.dart';

import '../../../data/repositories/caregiver_repository.dart';
import '../../../data/repositories/caregiver_repository_provider.dart';
import '../../../data/repositories/profile_repository.dart';
import '../controller/caregiver_controller.dart';

class CaregiverBinding extends Bindings {
  @override
  void dependencies() {
    ensureCaregiverRepositories();
    Get.lazyPut(
      () => CaregiverController(
        caregiverRepository: Get.find<CaregiverRepository>(),
        profileRepository: Get.find<ProfileRepository>(),
      ),
    );
  }
}
