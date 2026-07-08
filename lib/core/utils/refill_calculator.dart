// lib/core/utils/refill_calculator.dart

import '../models/dose_model.dart';
import '../models/medicine_model.dart';
import '../models/refill_info_model.dart';

class RefillCalculator {
  RefillCalculator._();

  static const refillDueThresholdDays = 2;

  static int dosesPerDay(String frequency) {
    final parts = frequency.split('-');
    if (parts.length != 3) {
      return 0;
    }
    var count = 0;
    for (final part in parts) {
      if ((int.tryParse(part) ?? 0) > 0) {
        count++;
      }
    }
    return count;
  }

  static RefillInfo? compute({
    required MedicineModel medicine,
    required List<DoseModel> doseLogs,
    DateTime? referenceDay,
  }) {
    if (!medicine.isActive || medicine.durationDays <= 0) {
      return null;
    }

    final perDay = dosesPerDay(medicine.frequency);
    if (perDay <= 0) {
      return null;
    }

    final today = _normalizeDay(referenceDay ?? DateTime.now());
    final totalDoses = perDay * medicine.durationDays;
    final medicineDoses =
        doseLogs.where((dose) => dose.medicineId == medicine.id).toList();
    final takenDoses = medicineDoses.where((dose) => dose.isTaken).length;
    final remainingDoses = (totalDoses - takenDoses).clamp(0, totalDoses);

    final supplyDays =
        remainingDoses == 0 ? 0 : (remainingDoses / perDay).ceil();

    final scanDate = _resolveScanDate(medicine, medicineDoses, today);
    final courseEnd = scanDate.add(Duration(days: medicine.durationDays));
    final calendarDays = courseEnd.difference(today).inDays;

    final remainingDays = _combineRemaining(supplyDays, calendarDays);

    return RefillInfo(
      medicine: medicine,
      remainingDays: remainingDays,
      totalDoses: totalDoses,
      takenDoses: takenDoses,
      dosesPerDay: perDay,
      scanDate: scanDate,
    );
  }

  static List<RefillInfo> refillDueMedicines({
    required List<MedicineModel> medicines,
    required List<DoseModel> doseLogs,
    DateTime? referenceDay,
  }) {
    final results = <RefillInfo>[];
    for (final medicine in medicines) {
      final info = compute(
        medicine: medicine,
        doseLogs: doseLogs,
        referenceDay: referenceDay,
      );
      if (info != null && info.isRefillDue) {
        results.add(info);
      }
    }
    results.sort((a, b) => a.remainingDays.compareTo(b.remainingDays));
    return results;
  }

  static DateTime? nextRefillNotificationAt({
    required RefillInfo info,
    DateTime? referenceDay,
  }) {
    if (!info.isRefillDue && info.remainingDays > refillDueThresholdDays) {
      final today = _normalizeDay(referenceDay ?? DateTime.now());
      final daysUntilNudge = info.remainingDays - refillDueThresholdDays;
      final nudgeDay = today.add(Duration(days: daysUntilNudge));
      return DateTime(nudgeDay.year, nudgeDay.month, nudgeDay.day, 9);
    }

    if (info.isRefillDue) {
      final now = referenceDay ?? DateTime.now();
      final todayNine = DateTime(now.year, now.month, now.day, 9);
      if (now.isBefore(todayNine)) {
        return todayNine;
      }
      final tomorrow = todayNine.add(const Duration(days: 1));
      return tomorrow;
    }

    return null;
  }

  static DateTime _resolveScanDate(
    MedicineModel medicine,
    List<DoseModel> medicineDoses,
    DateTime today,
  ) {
    final addedRaw = medicine.addedAt;
    if (addedRaw != null && addedRaw.isNotEmpty) {
      final parsed = DateTime.tryParse(addedRaw);
      if (parsed != null) {
        return _normalizeDay(parsed);
      }
    }

    if (medicineDoses.isNotEmpty) {
      final keys = medicineDoses.map((dose) => dose.dateKey).toList()..sort();
      final earliest = keys.first;
      final parts = earliest.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }

    return today.subtract(Duration(days: medicine.durationDays));
  }

  static DateTime _normalizeDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static int _combineRemaining(int supplyDays, int calendarDays) {
    if (calendarDays < 0) {
      return supplyDays;
    }
    if (supplyDays <= 0) {
      return calendarDays < 0 ? 0 : calendarDays;
    }
    return supplyDays < calendarDays ? supplyDays : calendarDays;
  }
}
