// lib/ui/medicine_detail/bindings/medicine_detail_binding.dart

import 'package:get/get.dart';

import '../../../core/ai/audio_recorder_service.dart';
import '../../../core/ai/rag_service.dart';
import '../../../app/app_config.dart';
import '../../../data/repositories/interaction_repository.dart';
import '../../../data/repositories/interaction_repository_provider.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/mock_medicine_repository.dart';
import '../../../data/repositories/mock_reminder_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../controller/medicine_detail_controller.dart';

class MedicineDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicineRepository>(
      () => AppConfig.isMock
          ? MockMedicineRepository()
          : MockMedicineRepository(),
    );
    ensureInteractionRepository();
    if (!Get.isRegistered<AudioRecorderService>()) {
      Get.lazyPut(AudioRecorderService.new, fenix: true);
    }
    Get.lazyPut<ReminderRepository>(
      () => MockReminderRepository(
        medicineRepository: Get.find<MedicineRepository>(),
      ),
    );
    Get.lazyPut(
      () => MedicineDetailController(
        repository: Get.find<MedicineRepository>(),
        interactionRepository: Get.find<InteractionRepository>(),
        reminderRepository: Get.find<ReminderRepository>(),
        ragService: Get.find<RagService>(),
      ),
    );
  }
}
