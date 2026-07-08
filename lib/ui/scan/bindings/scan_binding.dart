// lib/ui/scan/bindings/scan_binding.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../core/scan/prescription_camera_service.dart';
import '../../../core/scan/scan_flow_binding.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/mock_medicine_repository.dart';
import '../controller/scan_controller.dart';

class ScanBinding extends Bindings {
  @override
  void dependencies() {
    ensureScanSession();
    Get.lazyPut(PrescriptionCameraService.new);
    Get.lazyPut<MedicineRepository>(
      () => AppConfig.isMock
          ? MockMedicineRepository()
          : MockMedicineRepository(),
    );
    Get.lazyPut(
      () => ScanController(cameraService: Get.find<PrescriptionCameraService>()),
    );
  }
}
