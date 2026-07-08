// lib/ui/schedule_summary/bindings/schedule_summary_binding.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../core/scan/scan_flow_binding.dart';
import '../../../data/repositories/interaction_repository.dart';
import '../../../data/repositories/interaction_repository_provider.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/mock_medicine_repository.dart';
import '../../../data/repositories/mock_reminder_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../controller/schedule_summary_controller.dart';

class ScheduleSummaryBinding extends Bindings {
  @override
  void dependencies() {
    ensureScanSession();
    Get.lazyPut<MedicineRepository>(
      () => AppConfig.isMock
          ? MockMedicineRepository()
          : MockMedicineRepository(),
    );
    ensureInteractionRepository();
    Get.lazyPut<ReminderRepository>(
      () => MockReminderRepository(
        medicineRepository: Get.find<MedicineRepository>(),
      ),
    );
    Get.lazyPut(
      () => ScheduleSummaryController(
        repository: Get.find<MedicineRepository>(),
        reminderRepository: Get.find<ReminderRepository>(),
        interactionRepository: Get.find<InteractionRepository>(),
      ),
    );
  }
}
