// lib/ui/doubt_query/bindings/doubt_query_binding.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../core/ai/audio_recorder_service.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/mock_medicine_repository.dart';
import '../controller/doubt_query_controller.dart';

class DoubtQueryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AudioRecorderService>()) {
      Get.lazyPut(AudioRecorderService.new, fenix: true);
    }
    Get.lazyPut<MedicineRepository>(
      () => AppConfig.isMock
          ? MockMedicineRepository()
          : MockMedicineRepository(),
    );
    Get.lazyPut(
      () => DoubtQueryController(
        medicineRepository: Get.find<MedicineRepository>(),
      ),
    );
  }
}
