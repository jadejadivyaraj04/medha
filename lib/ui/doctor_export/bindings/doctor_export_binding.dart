// lib/ui/doctor_export/bindings/doctor_export_binding.dart

import 'package:get/get.dart';

import '../../../data/repositories/doctor_export_repository.dart';
import '../../../data/repositories/doctor_export_repository_provider.dart';
import '../controller/doctor_export_controller.dart';

class DoctorExportBinding extends Bindings {
  @override
  void dependencies() {
    ensureDoctorExportRepositories();
    Get.lazyPut(
      () => DoctorExportController(
        repository: Get.find<DoctorExportRepository>(),
      ),
    );
  }
}
