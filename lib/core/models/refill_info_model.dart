// lib/core/models/refill_info_model.dart

import 'medicine_model.dart';

/// Supply + calendar refill projection for one active medicine.
class RefillInfo {
  const RefillInfo({
    required this.medicine,
    required this.remainingDays,
    required this.totalDoses,
    required this.takenDoses,
    required this.dosesPerDay,
    required this.scanDate,
  });

  final MedicineModel medicine;
  final int remainingDays;
  final int totalDoses;
  final int takenDoses;
  final int dosesPerDay;
  final DateTime scanDate;

  int get remainingDoses => (totalDoses - takenDoses).clamp(0, totalDoses);

  bool get isRefillDue => remainingDays <= 2 && remainingDays >= 0;

  bool get isExpired => remainingDays < 0 || remainingDoses <= 0;
}
