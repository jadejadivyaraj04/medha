// lib/ui/adherence_history/bindings/adherence_history_binding.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../data/repositories/adherence_repository.dart';
import '../../../data/repositories/mock_adherence_repository.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/mock_medicine_repository.dart';
import '../../../data/repositories/mock_reminder_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../controller/adherence_history_controller.dart';

class AdherenceHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicineRepository>(
      () => AppConfig.isMock
          ? MockMedicineRepository()
          : MockMedicineRepository(),
    );
    Get.lazyPut<ReminderRepository>(
      () => MockReminderRepository(
        medicineRepository: Get.find<MedicineRepository>(),
      ),
    );
    Get.lazyPut<AdherenceRepository>(
      () => AppConfig.isMock
          ? MockAdherenceRepository(
              reminderRepository: Get.find<ReminderRepository>(),
              medicineRepository: Get.find<MedicineRepository>(),
            )
          : MockAdherenceRepository(
              reminderRepository: Get.find<ReminderRepository>(),
              medicineRepository: Get.find<MedicineRepository>(),
            ),
    );
    Get.lazyPut(
      () => AdherenceHistoryController(
        repository: Get.find<AdherenceRepository>(),
      ),
    );
  }
}
