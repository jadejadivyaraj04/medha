// lib/ui/medicines/bindings/medicines_binding.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../data/repositories/interaction_repository.dart';
import '../../../data/repositories/interaction_repository_provider.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/mock_medicine_repository.dart';
import '../../../data/repositories/mock_reminder_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../controller/medicines_controller.dart';

class MedicinesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MedicineRepository>()) {
      Get.lazyPut<MedicineRepository>(
        () => AppConfig.isMock
            ? MockMedicineRepository()
            : MockMedicineRepository(),
        fenix: true,
      );
    }
    ensureInteractionRepository();
    if (!Get.isRegistered<ReminderRepository>()) {
      Get.lazyPut<ReminderRepository>(
        () => MockReminderRepository(
          medicineRepository: Get.find<MedicineRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<MedicinesController>()) {
      Get.lazyPut(
        () => MedicinesController(
          repository: Get.find<MedicineRepository>(),
          interactionRepository: Get.find<InteractionRepository>(),
          reminderRepository: Get.find<ReminderRepository>(),
        ),
        fenix: true,
      );
    }
  }
}
