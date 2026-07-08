// lib/data/repositories/caregiver_repository_provider.dart

import 'package:get/get.dart';

import '../../app/app_config.dart';
import 'caregiver_repository.dart';
import 'caregiver_repository_impl.dart';
import 'mock_caregiver_repository.dart';
import 'mock_profile_repository.dart';
import 'profile_repository.dart';

void ensureCaregiverRepositories() {
  if (!Get.isRegistered<ProfileRepository>()) {
    Get.lazyPut<ProfileRepository>(() => MockProfileRepository());
  }
  if (!Get.isRegistered<CaregiverRepository>()) {
    Get.lazyPut<CaregiverRepository>(
      () => AppConfig.isMock
          ? MockCaregiverRepository()
          : CaregiverRepositoryImpl(),
    );
  }
}
