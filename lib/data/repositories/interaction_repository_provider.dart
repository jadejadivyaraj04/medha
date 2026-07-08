// lib/data/repositories/interaction_repository_provider.dart

import 'package:get/get.dart';

import '../../app/app_config.dart';
import 'interaction_repository.dart';
import 'interaction_repository_impl.dart';
import 'medicine_repository.dart';
import 'mock_interaction_repository.dart';

void ensureInteractionRepository() {
  if (!Get.isRegistered<InteractionRepository>()) {
    Get.lazyPut<InteractionRepository>(
      () => AppConfig.isMock
          ? MockInteractionRepository()
          : InteractionRepositoryImpl(
              medicineRepository: Get.isRegistered<MedicineRepository>()
                  ? Get.find<MedicineRepository>()
                  : null,
            ),
      fenix: true,
    );
  }
}
