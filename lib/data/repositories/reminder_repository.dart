// lib/data/repositories/reminder_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/models/dose_model.dart';
import '../../core/models/medicine_model.dart';
import '../../core/models/refill_alert_model.dart';
import '../../core/network/error_detail_wrapper.dart';

class AdherenceDaySummary {
  const AdherenceDaySummary({
    required this.dateKey,
    required this.takenCount,
    required this.totalCount,
    this.missedCount = 0,
    this.skippedCount = 0,
  });

  final String dateKey;
  final int takenCount;
  final int totalCount;
  final int missedCount;
  final int skippedCount;

  double get ratio => totalCount == 0 ? 0 : takenCount / totalCount;
}

abstract class ReminderRepository {
  Future<Either<ErrorDetailWrapper, List<DoseModel>>> getTodayDoses({
    String? profileId,
    DateTime? date,
  });

  Future<Either<ErrorDetailWrapper, List<DoseModel>>> getAllDoseLogs({
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, List<DoseModel>>> getDosesForDay(
    DateTime date, {
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, DoseModel>> updateDoseStatus(
    String doseId,
    String status, {
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, DoseModel>> snoozeDose(
    String doseId, {
    int minutes = 10,
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, List<AdherenceDaySummary>>> getAdherenceMonth(
    int year,
    int month, {
    String? profileId,
  });

  /// Called only after user confirms medicines on the schedule summary screen.
  Future<Either<ErrorDetailWrapper, int>> scheduleConfirmedMedicines(
    List<MedicineModel> medicines, {
    String? profileId,
  });

  /// Active refill alerts (supply ≤ 2 days) for the patient profile.
  Future<Either<ErrorDetailWrapper, List<RefillAlert>>> getRefillAlerts({
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, RefillAlert>> dismissRefillAlert(
    String alertId, {
    String? profileId,
  });
}
