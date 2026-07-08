// lib/data/repositories/mock_adherence_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/mock/mock_constants.dart';
import '../../core/models/adherence_month_stats.dart';
import '../../core/models/dose_model.dart';
import '../../core/models/medicine_model.dart';
import '../../core/network/error_detail_wrapper.dart';
import '../../core/storage/storage_manager.dart';
import '../../core/utils/adherence_stats_helper.dart';
import '../../core/utils/dose_schedule_helper.dart';
import 'adherence_repository.dart';
import 'medicine_repository.dart';
import 'reminder_repository.dart';

class MockAdherenceRepository implements AdherenceRepository {
  MockAdherenceRepository({
    required ReminderRepository reminderRepository,
    required MedicineRepository medicineRepository,
  })  : _reminderRepository = reminderRepository,
        _medicineRepository = medicineRepository;

  final ReminderRepository _reminderRepository;
  final MedicineRepository _medicineRepository;

  @override
  Future<Either<ErrorDetailWrapper, AdherenceMonthStats>> getMonthStats(
    int year,
    int month, {
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return Right(_emptyStats(year, month));
    }

    await _ensureSeedHistory(id);
    final summariesResult = await getDaySummaries(year, month, profileId: id);
    return summariesResult.fold(
      Left.new,
      (summaries) => Right(
        AdherenceStatsHelper.monthStatsFromSummaries(
          year: year,
          month: month,
          summaries: summaries,
        ),
      ),
    );
  }

  @override
  Future<Either<ErrorDetailWrapper, List<AdherenceDaySummary>>> getDaySummaries(
    int year,
    int month, {
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return const Right([]);
    }

    await _ensureSeedHistory(id);
    return _reminderRepository.getAdherenceMonth(year, month, profileId: id);
  }

  @override
  Future<Either<ErrorDetailWrapper, List<DoseModel>>> getDayDoses(
    DateTime date, {
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return const Right([]);
    }

    await _ensureSeedHistory(id);
    return _reminderRepository.getDosesForDay(date, profileId: id);
  }

  AdherenceMonthStats _emptyStats(int year, int month) {
    return AdherenceStatsHelper.monthStatsFromSummaries(
      year: year,
      month: month,
      summaries: const [],
    );
  }

  Future<void> _ensureSeedHistory(String profileId) async {
    final existing = StorageManager.getDoseLogsForProfile(profileId);
    if (existing.length > 24) {
      return;
    }

    final medicinesResult = await _medicineRepository.getAll(profileId: profileId);
    final medicines = medicinesResult.getOrElse(() => <MedicineModel>[]);
    final active = medicines.where((medicine) => medicine.isActive).toList();
    if (active.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final seeded = <DoseModel>[];

    for (var offset = 21; offset >= 0; offset--) {
      final day = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: offset),
      );
      final generated = DoseScheduleHelper.generateForDay(active, day);
      for (final dose in generated) {
        seeded.add(
          dose.copyWith(status: _demoStatusFor(day, dose, offset)),
        );
      }
    }

    if (seeded.isEmpty) {
      return;
    }

    await StorageManager.saveDoseLogsForProfile(
      profileId,
      seeded.map((dose) => dose.toJson()).toList(),
    );
    await StorageManager.setRemindersScheduled(profileId, value: true);
  }

  String _demoStatusFor(DateTime day, DoseModel dose, int daysAgo) {
    final today = DateTime.now();
    final isToday = DoseScheduleHelper.dateKeyFor(day) ==
        DoseScheduleHelper.dateKeyFor(today);

    if (day.isAfter(today)) {
      return 'upcoming';
    }

    if (isToday) {
      return DoseScheduleHelper.applyTimeBasedStatus(dose, today).status;
    }

    if (dose.slot == 'night' && daysAgo % 6 == 0) {
      return 'missed';
    }
    if (dose.slot == 'afternoon' && daysAgo % 9 == 0) {
      return 'skipped';
    }
    return 'taken';
  }
}
