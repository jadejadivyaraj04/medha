// lib/core/models/doctor_export_report.dart

import '../../data/models/caregiver_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/reminder_repository.dart';
import 'adherence_month_stats.dart';
import 'medicine_model.dart';

class DoctorExportReport {
  const DoctorExportReport({
    required this.profile,
    required this.medicines,
    required this.monthStats,
    required this.daySummaries,
    required this.generatedAt,
    this.caregiver,
  });

  final ProfileModel profile;
  final List<MedicineModel> medicines;
  final AdherenceMonthStats monthStats;
  final List<AdherenceDaySummary> daySummaries;
  final DateTime generatedAt;
  final CaregiverModel? caregiver;

  List<MedicineModel> get activeMedicines =>
      medicines.where((medicine) => medicine.isActive).toList();

  bool get hasMedicines => activeMedicines.isNotEmpty;

  bool get hasAdherenceData => monthStats.totalDoses > 0;

  bool get hasCaregiver => caregiver != null && caregiver!.hasContact;

  bool get includeAdherenceForCaregiver =>
      caregiver?.shareAdherence == true && hasAdherenceData;
}
