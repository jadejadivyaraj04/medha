// lib/core/utils/dose_schedule_helper.dart

import '../models/dose_model.dart';
import '../models/medicine_model.dart';

class DoseScheduleHelper {
  DoseScheduleHelper._();

  static const slotTimes = {
    'morning': (8, 0),
    'afternoon': (13, 0),
    'night': (21, 0),
  };

  static String dateKeyFor(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static List<DoseModel> generateForDay(
    List<MedicineModel> medicines,
    DateTime day,
  ) {
    final dateKey = dateKeyFor(day);
    final doses = <DoseModel>[];

    for (final medicine in medicines) {
      if (!medicine.isActive) {
        continue;
      }

      final parts = medicine.frequency.split('-');
      if (parts.length != 3) {
        continue;
      }

      final slotFlags = [
        (int.tryParse(parts[0]) ?? 0) > 0,
        (int.tryParse(parts[1]) ?? 0) > 0,
        (int.tryParse(parts[2]) ?? 0) > 0,
      ];
      const slots = ['morning', 'afternoon', 'night'];

      for (var i = 0; i < slots.length; i++) {
        if (!slotFlags[i]) {
          continue;
        }
        final slot = slots[i];
        final time = slotTimes[slot]!;
        final scheduled = DateTime(day.year, day.month, day.day, time.$1, time.$2);

        doses.add(
          DoseModel(
            id: 'dose_${medicine.id}_${slot}_$dateKey',
            medicineId: medicine.id,
            medicineName: medicine.name,
            dosageMg: medicine.dosageMg,
            slot: slot,
            scheduledAt: scheduled.toIso8601String(),
            status: 'upcoming',
            withFood: medicine.withFood,
            dateKey: dateKey,
          ),
        );
      }
    }

    doses.sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
    return doses;
  }

  static List<DoseModel> generateForCourse(
    List<MedicineModel> medicines, {
    DateTime? startDay,
  }) {
    final start = startDay ?? DateTime.now();
    final normalized = DateTime(start.year, start.month, start.day);
    final all = <DoseModel>[];

    for (final medicine in medicines) {
      if (!medicine.isActive) {
        continue;
      }
      final days = medicine.durationDays > 0 ? medicine.durationDays : 1;
      for (var offset = 0; offset < days; offset++) {
        final day = normalized.add(Duration(days: offset));
        all.addAll(generateForDay([medicine], day));
      }
    }

    all.sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
    return all;
  }

  static DoseModel applyTimeBasedStatus(DoseModel dose, DateTime now) {
    if (dose.isTaken || dose.isSkipped) {
      return dose;
    }

    final scheduled = dose.scheduledDateTime;
    if (scheduled.isBefore(now.subtract(const Duration(hours: 2)))) {
      return dose.copyWith(status: 'missed');
    }
    if (scheduled.isBefore(now) || scheduled.difference(now).inMinutes <= 30) {
      return dose.copyWith(status: 'due_soon');
    }
    return dose;
  }
}
