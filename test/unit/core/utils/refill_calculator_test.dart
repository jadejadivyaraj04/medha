// test/unit/core/utils/refill_calculator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:medha/core/models/dose_model.dart';
import 'package:medha/core/models/medicine_model.dart';
import 'package:medha/core/utils/refill_calculator.dart';

void main() {
  final referenceDay = DateTime(2026, 6, 27);

  MedicineModel activeMedicine({
    String id = 'm1',
    String frequency = '1-0-1',
    int durationDays = 5,
    DateTime? scanDate,
  }) {
    return MedicineModel(
      id: id,
      name: 'Crocin 500',
      dosageMg: 500,
      frequency: frequency,
      withFood: 'after',
      durationDays: durationDays,
      addedAt: (scanDate ?? referenceDay.subtract(const Duration(days: 3)))
          .toIso8601String(),
    );
  }

  DoseModel takenDose({
    required String id,
    required String medicineId,
  }) {
    return DoseModel(
      id: id,
      medicineId: medicineId,
      medicineName: 'Crocin 500',
      dosageMg: 500,
      slot: 'morning',
      scheduledAt: referenceDay.toIso8601String(),
      status: 'taken',
      withFood: 'after',
      dateKey: '2026-06-27',
    );
  }

  group('RefillCalculator.dosesPerDay', () {
    test('parses_frequency_pattern', () {
      expect(RefillCalculator.dosesPerDay('1-0-1'), 2);
      expect(RefillCalculator.dosesPerDay('1-0-0'), 1);
      expect(RefillCalculator.dosesPerDay('invalid'), 0);
    });
  });

  group('RefillCalculator.compute', () {
    test('returns_null_for_completed_or_zero_duration', () {
      final completed = activeMedicine().copyWith(status: 'completed');
      expect(
        RefillCalculator.compute(
          medicine: completed,
          doseLogs: const [],
          referenceDay: referenceDay,
        ),
        isNull,
      );

      final zeroDuration = activeMedicine(durationDays: 0);
      expect(
        RefillCalculator.compute(
          medicine: zeroDuration,
          doseLogs: const [],
          referenceDay: referenceDay,
        ),
        isNull,
      );
    });

    test('marks_refill_due_when_calendar_days_at_threshold', () {
      final medicine = activeMedicine(
        scanDate: referenceDay.subtract(const Duration(days: 3)),
      );

      final info = RefillCalculator.compute(
        medicine: medicine,
        doseLogs: const [],
        referenceDay: referenceDay,
      );

      expect(info, isNotNull);
      expect(info!.remainingDays, 2);
      expect(info.isRefillDue, isTrue);
    });

    test('marks_refill_due_when_supply_runs_low', () {
      final medicine = activeMedicine(
        scanDate: referenceDay.subtract(const Duration(days: 1)),
        durationDays: 5,
      );
      final logs = List.generate(
        9,
        (index) => takenDose(id: 'd$index', medicineId: medicine.id),
      );

      final info = RefillCalculator.compute(
        medicine: medicine,
        doseLogs: logs,
        referenceDay: referenceDay,
      );

      expect(info, isNotNull);
      expect(info!.remainingDoses, 1);
      expect(info.remainingDays, 1);
      expect(info.isRefillDue, isTrue);
    });

    test('refillDueMedicines_sorts_by_remaining_days', () {
      final soon = activeMedicine(
        id: 'soon',
        scanDate: referenceDay.subtract(const Duration(days: 4)),
      );
      final later = activeMedicine(
        id: 'later',
        scanDate: referenceDay.subtract(const Duration(days: 1)),
        durationDays: 10,
      );

      final due = RefillCalculator.refillDueMedicines(
        medicines: [later, soon],
        doseLogs: const [],
        referenceDay: referenceDay,
      );

      expect(due, isNotEmpty);
      expect(due.first.medicine.id, 'soon');
    });
  });

  group('RefillCalculator.nextRefillNotificationAt', () {
    test('schedules_today_at_9am_when_already_refill_due', () {
      final medicine = activeMedicine(
        scanDate: referenceDay.subtract(const Duration(days: 3)),
      );
      final info = RefillCalculator.compute(
        medicine: medicine,
        doseLogs: const [],
        referenceDay: referenceDay,
      );

      final at = RefillCalculator.nextRefillNotificationAt(
        info: info!,
        referenceDay: DateTime(2026, 6, 27, 8),
      );

      expect(at, DateTime(2026, 6, 27, 9));
    });
  });
}
