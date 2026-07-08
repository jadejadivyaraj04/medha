// lib/ui/verify_edit/bindings/verify_edit_binding.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../core/scan/scan_flow_binding.dart';
import '../../../data/repositories/interaction_repository.dart';
import '../../../data/repositories/interaction_repository_provider.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/mock_medicine_repository.dart';
import '../controller/verify_edit_controller.dart';

class VerifyEditBinding extends Bindings {
  @override
  void dependencies() {
    ensureScanSession();
    Get.lazyPut<MedicineRepository>(
      () => AppConfig.isMock
          ? MockMedicineRepository()
          : MockMedicineRepository(),
    );
    ensureInteractionRepository();
    Get.lazyPut(
      () => VerifyEditController(
        medicineRepository: Get.find<MedicineRepository>(),
        interactionRepository: Get.find<InteractionRepository>(),
      ),
    );
  }
}
