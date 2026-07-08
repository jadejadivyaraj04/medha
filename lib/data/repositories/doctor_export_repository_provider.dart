// lib/data/repositories/doctor_export_repository_provider.dart

import 'package:get/get.dart';

import '../../app/app_config.dart';
import 'adherence_repository.dart';
import 'caregiver_repository_provider.dart';
import 'doctor_export_repository.dart';
import 'doctor_export_repository_impl.dart';
import 'medicine_repository.dart';
import 'mock_adherence_repository.dart';
import 'mock_doctor_export_repository.dart';
import 'mock_medicine_repository.dart';
import 'mock_profile_repository.dart';
import 'mock_reminder_repository.dart';
import 'profile_repository.dart';
import 'reminder_repository.dart';

void ensureDoctorExportRepositories() {
  if (!Get.isRegistered<ProfileRepository>()) {
    Get.lazyPut<ProfileRepository>(() => MockProfileRepository());
  }
  if (!Get.isRegistered<MedicineRepository>()) {
    Get.lazyPut<MedicineRepository>(() => MockMedicineRepository());
  }
  if (!Get.isRegistered<ReminderRepository>()) {
    Get.lazyPut<ReminderRepository>(
      () => MockReminderRepository(
        medicineRepository: Get.find<MedicineRepository>(),
      ),
    );
  }
  if (!Get.isRegistered<AdherenceRepository>()) {
    Get.lazyPut<AdherenceRepository>(
      () => MockAdherenceRepository(
        reminderRepository: Get.find<ReminderRepository>(),
        medicineRepository: Get.find<MedicineRepository>(),
      ),
    );
  }
  ensureCaregiverRepositories();
  if (!Get.isRegistered<DoctorExportRepository>()) {
    Get.lazyPut<DoctorExportRepository>(
      () => AppConfig.isMock
          ? MockDoctorExportRepository()
          : DoctorExportRepositoryImpl(),
    );
  }
}
