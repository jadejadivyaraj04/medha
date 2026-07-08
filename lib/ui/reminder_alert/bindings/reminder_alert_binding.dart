// lib/ui/reminder_alert/bindings/reminder_alert_binding.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/mock_medicine_repository.dart';
import '../../../data/repositories/mock_reminder_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../controller/reminder_alert_controller.dart';

class ReminderAlertBinding extends Bindings {
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
    Get.lazyPut(
      () => ReminderAlertController(repository: Get.find<ReminderRepository>()),
    );
  }
}
