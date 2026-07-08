// lib/ui/home/bindings/home_binding.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../data/repositories/adherence_repository.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/mock_adherence_repository.dart';
import '../../../data/repositories/mock_medicine_repository.dart';
import '../../../data/repositories/mock_reminder_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../controller/home_controller.dart';

class HomeBinding extends Bindings {
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
    if (!Get.isRegistered<ReminderRepository>()) {
      Get.lazyPut<ReminderRepository>(
        () => MockReminderRepository(
          medicineRepository: Get.find<MedicineRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AdherenceRepository>()) {
      Get.lazyPut<AdherenceRepository>(
        () => MockAdherenceRepository(
          reminderRepository: Get.find<ReminderRepository>(),
          medicineRepository: Get.find<MedicineRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut(
        () => HomeController(
          reminderRepository: Get.find<ReminderRepository>(),
          adherenceRepository: Get.find<AdherenceRepository>(),
          medicineRepository: Get.find<MedicineRepository>(),
        ),
        fenix: true,
      );
    }
  }
}
