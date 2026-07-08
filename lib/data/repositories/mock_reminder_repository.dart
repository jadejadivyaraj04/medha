// lib/data/repositories/mock_reminder_repository.dart

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../core/mock/domain_mock_data.dart';
import '../../core/mock/mock_constants.dart';
import '../../core/models/dose_model.dart';
import '../../core/models/medicine_model.dart';
import '../../core/models/refill_alert_model.dart';
import '../../core/models/reminder_log_model.dart';
import '../../core/network/error_detail_wrapper.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/notifications/refill_notification_sync.dart';
import '../../core/models/refill_info_model.dart';
import '../../core/utils/refill_calculator.dart';
import '../../core/storage/storage_manager.dart';
import '../../core/utils/dose_schedule_helper.dart';
import 'medicine_repository.dart';
import 'reminder_repository.dart';

class MockReminderRepository implements ReminderRepository {
  MockReminderRepository({required MedicineRepository medicineRepository})
      : _medicineRepository = medicineRepository;

  final MedicineRepository _medicineRepository;

  static final Set<String> _dismissedRefillAlerts = {};

  @override
  Future<Either<ErrorDetailWrapper, List<DoseModel>>> getAllDoseLogs({
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return const Right([]);
    }
    final logs =
        StorageManager.getDoseLogsForProfile(id).map(DoseModel.fromJson).toList();
    return Right(logs);
  }

  @override
  Future<Either<ErrorDetailWrapper, List<DoseModel>>> getTodayDoses({
    String? profileId,
    DateTime? date,
  }) {
    return getDosesForDay(date ?? DateTime.now(), profileId: profileId);
  }

  @override
  Future<Either<ErrorDetailWrapper, List<DoseModel>>> getDosesForDay(
    DateTime date, {
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);

    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return const Right([]);
    }

    final medicinesResult = await _medicineRepository.getAll(profileId: id);
    return medicinesResult.fold(
      (error) async => Left(error),
      (medicines) async {
        final dateKey = DoseScheduleHelper.dateKeyFor(date);
        final generated = DoseScheduleHelper.generateForDay(medicines, date);
        if (generated.isEmpty) {
          return const Right(<DoseModel>[]);
        }

        final stored = StorageManager.getDoseLogsForProfile(id)
            .map(DoseModel.fromJson)
            .where((dose) => dose.dateKey == dateKey)
            .toList();

        final storedById = {for (final dose in stored) dose.id: dose};
        final now = DateTime.now();
        final isToday = DoseScheduleHelper.dateKeyFor(now) == dateKey;
        final userScheduled = StorageManager.areRemindersScheduled(id);

        final merged = generated.map((dose) {
          final saved = storedById[dose.id];
          if (saved != null) {
            return saved;
          }
          if (isToday && !userScheduled) {
            return _seedDemoStatus(dose, now);
          }
          if (isToday) {
            return DoseScheduleHelper.applyTimeBasedStatus(dose, now);
          }
          return dose;
        }).toList();

        await _persistDoses(id, merged, dateKey);
        return Right(merged);
      },
    );
  }

  @override
  Future<Either<ErrorDetailWrapper, int>> scheduleConfirmedMedicines(
    List<MedicineModel> medicines, {
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);

    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return Left(ErrorDetailWrapper.unknown('No active profile found.'));
    }
    if (medicines.isEmpty) {
      return Left(ErrorDetailWrapper.unknown('No medicines to schedule.'));
    }

    final active = medicines.where((medicine) => medicine.isActive).toList();
    final allDoses = DoseScheduleHelper.generateForCourse(active);
    if (allDoses.isEmpty) {
      return Left(ErrorDetailWrapper.unknown('Could not build a dose schedule.'));
    }

    final existing = StorageManager.getDoseLogsForProfile(id)
        .map(DoseModel.fromJson)
        .where((dose) {
          final medicineIds = active.map((m) => m.id).toSet();
          return !medicineIds.contains(dose.medicineId);
        })
        .toList();

    final merged = [...existing, ...allDoses];
    await StorageManager.saveDoseLogsForProfile(
      id,
      merged.map((dose) => dose.toJson()).toList(),
    );
    await StorageManager.setRemindersScheduled(id, value: true);

    if (Get.isRegistered<NotificationService>()) {
      final notifications = Get.find<NotificationService>();
      await notifications.requestPermissions();
      await notifications.cancelAll();
      await notifications.scheduleDoses(allDoses);
    }

    await _syncRefillNotifications(id, active);

    return Right(allDoses.length);
  }

  DoseModel _seedDemoStatus(DoseModel dose, DateTime now) {
    final withTime = DoseScheduleHelper.applyTimeBasedStatus(dose, now);
    if (withTime.status != 'upcoming') {
      return withTime;
    }

    return switch (dose.slot) {
      'morning' when dose.medicineName.contains('Crocin') =>
        dose.copyWith(status: 'taken'),
      'morning' => dose.copyWith(status: 'taken'),
      'afternoon' => withTime,
      'night' => dose.copyWith(status: 'upcoming'),
      _ => withTime,
    };
  }

  @override
  Future<Either<ErrorDetailWrapper, DoseModel>> updateDoseStatus(
    String doseId,
    String status, {
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return Left(ErrorDetailWrapper.unknown('No active profile found.'));
    }

    final logs = StorageManager.getDoseLogsForProfile(id).map(DoseModel.fromJson).toList();
    final index = logs.indexWhere((dose) => dose.id == doseId);
    if (index < 0) {
      return Left(ErrorDetailWrapper.unknown('Dose not found.'));
    }

    final current = logs[index];
    final updated = current.copyWith(status: status);
    logs[index] = updated;
    await StorageManager.saveDoseLogsForProfile(
      id,
      logs.map((dose) => dose.toJson()).toList(),
    );

    await _writeReminderLog(
      profileId: id,
      dose: updated,
      action: status,
    );

    if (Get.isRegistered<NotificationService>()) {
      await Get.find<NotificationService>().cancelDose(doseId);
    }

    await _syncRefillNotifications(id);

    return Right(updated);
  }

  @override
  Future<Either<ErrorDetailWrapper, DoseModel>> snoozeDose(
    String doseId, {
    int minutes = 10,
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return Left(ErrorDetailWrapper.unknown('No active profile found.'));
    }

    final logs = StorageManager.getDoseLogsForProfile(id).map(DoseModel.fromJson).toList();
    final index = logs.indexWhere((dose) => dose.id == doseId);
    if (index < 0) {
      return Left(ErrorDetailWrapper.unknown('Dose not found.'));
    }

    final current = logs[index];
    final snoozedTime = DateTime.now().add(Duration(minutes: minutes));
    final updated = current.copyWith(
      scheduledAt: snoozedTime.toIso8601String(),
      status: 'due_soon',
    );
    logs[index] = updated;
    await StorageManager.saveDoseLogsForProfile(
      id,
      logs.map((dose) => dose.toJson()).toList(),
    );

    await _writeReminderLog(
      profileId: id,
      dose: updated,
      action: 'snoozed',
    );

    if (Get.isRegistered<NotificationService>()) {
      await Get.find<NotificationService>().rescheduleDose(updated);
    }

    await _syncRefillNotifications(id);

    return Right(updated);
  }

  @override
  Future<Either<ErrorDetailWrapper, List<AdherenceDaySummary>>> getAdherenceMonth(
    int year,
    int month, {
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return const Right([]);
    }

    final medicinesResult = await _medicineRepository.getAll(profileId: id);
    return medicinesResult.fold(
      Left.new,
      (medicines) async {
        final active =
            medicines.where((medicine) => medicine.isActive).toList();
        if (active.isEmpty) {
          return const Right([]);
        }

        final storedByDateKey = <String, Map<String, DoseModel>>{};
        for (final raw in StorageManager.getDoseLogsForProfile(id)) {
          final dose = DoseModel.fromJson(raw);
          storedByDateKey
              .putIfAbsent(dose.dateKey, () => {})
              [dose.id] = dose;
        }

        final userScheduled = StorageManager.areRemindersScheduled(id);
        final now = DateTime.now();
        final daysInMonth = DateTime(year, month + 1, 0).day;
        final summaries = <AdherenceDaySummary>[];

        for (var day = 1; day <= daysInMonth; day++) {
          final date = DateTime(year, month, day);
          final dateKey = DoseScheduleHelper.dateKeyFor(date);
          final generated = DoseScheduleHelper.generateForDay(active, date);
          if (generated.isEmpty) {
            continue;
          }

          final storedById = storedByDateKey[dateKey] ?? {};
          final isToday = DoseScheduleHelper.dateKeyFor(now) == dateKey;
          final merged = generated.map((dose) {
            final saved = storedById[dose.id];
            if (saved != null) {
              return saved;
            }
            if (isToday && !userScheduled) {
              return _seedDemoStatus(dose, now);
            }
            if (isToday) {
              return DoseScheduleHelper.applyTimeBasedStatus(dose, now);
            }
            return dose;
          }).toList();

          summaries.add(
            AdherenceDaySummary(
              dateKey: dateKey,
              takenCount: merged.where((dose) => dose.isTaken).length,
              totalCount: merged.length,
              missedCount: merged.where((dose) => dose.isMissed).length,
              skippedCount: merged.where((dose) => dose.isSkipped).length,
            ),
          );
        }

        return Right(summaries);
      },
    );
  }

  @override
  Future<Either<ErrorDetailWrapper, List<RefillAlert>>> getRefillAlerts({
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);

    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return const Right([]);
    }

    final medicinesResult = await _medicineRepository.getAll(profileId: id);
    final logsResult = await getAllDoseLogs(profileId: id);

    return await medicinesResult.fold(
      (error) async => Left(error),
      (medicines) async {
        final logs = logsResult.getOrElse(() => <DoseModel>[]);
        final alerts = <RefillAlert>[];

        for (final medicine in medicines.where((m) => m.isActive)) {
          final info = RefillCalculator.compute(
            medicine: medicine,
            doseLogs: logs,
          );
          if (info == null || !info.isRefillDue) {
            continue;
          }
          final alertId = 'refill_${medicine.id}';
          if (_dismissedRefillAlerts.contains(alertId)) {
            continue;
          }
          alerts.add(
            RefillAlert.fromRefillInfo(
              info: info,
              profileId: id,
              status: RefillAlertStatus.dueSoon,
            ),
          );
        }

        alerts.sort((a, b) => a.remainingDays.compareTo(b.remainingDays));

        if (alerts.isEmpty) {
          return Right(
            DomainMockData.seedRefillAlerts(profileId: id)
                .where((alert) => !_dismissedRefillAlerts.contains(alert.id))
                .toList(),
          );
        }

        return Right(alerts);
      },
    );
  }

  @override
  Future<Either<ErrorDetailWrapper, RefillAlert>> dismissRefillAlert(
    String alertId, {
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return Left(ErrorDetailWrapper.unknown('No active profile found.'));
    }

    final alertsResult = await getRefillAlerts(profileId: id);
    return alertsResult.fold(
      Left.new,
      (alerts) {
        for (final alert in alerts) {
          if (alert.id == alertId) {
            _dismissedRefillAlerts.add(alertId);
            return Right(alert.copyWith(status: RefillAlertStatus.dismissed));
          }
        }
        return Left(ErrorDetailWrapper.unknown('Refill alert not found.'));
      },
    );
  }

  Future<void> _persistDoses(
    String profileId,
    List<DoseModel> dayDoses,
    String dateKey,
  ) async {
    final existing = StorageManager.getDoseLogsForProfile(profileId)
        .map(DoseModel.fromJson)
        .where((dose) => dose.dateKey != dateKey)
        .toList();
    final merged = [...existing, ...dayDoses];
    await StorageManager.saveDoseLogsForProfile(
      profileId,
      merged.map((dose) => dose.toJson()).toList(),
    );
  }

  Future<void> _syncRefillNotifications(
    String profileId, [
    List<MedicineModel>? medicines,
  ]) async {
    final medsResult = medicines != null
        ? Right<ErrorDetailWrapper, List<MedicineModel>>(medicines)
        : await _medicineRepository.getAll(profileId: profileId);
    final logs = StorageManager.getDoseLogsForProfile(profileId)
        .map(DoseModel.fromJson)
        .toList();

    await medsResult.fold(
      (_) async {},
      (meds) async {
        final refillInfos = <RefillInfo>[];
        for (final medicine in meds) {
          final info = RefillCalculator.compute(
            medicine: medicine,
            doseLogs: logs,
          );
          if (info != null) {
            refillInfos.add(info);
          }
        }
        await RefillNotificationSync.sync(
          medicines: meds,
          refillInfos: refillInfos,
        );
      },
    );
  }

  Future<void> _writeReminderLog({
    required String profileId,
    required DoseModel dose,
    required String action,
  }) async {
    final log = ReminderLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      doseId: dose.id,
      medicineId: dose.medicineId,
      medicineName: dose.medicineName,
      action: action,
      recordedAt: DateTime.now().toIso8601String(),
      dateKey: dose.dateKey,
    );
    await StorageManager.appendReminderLog(profileId, log.toJson());
  }
}
