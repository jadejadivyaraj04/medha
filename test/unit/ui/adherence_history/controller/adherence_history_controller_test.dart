// test/unit/ui/adherence_history/controller/adherence_history_controller_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medha/app/translations/app_translations.dart';
import 'package:medha/core/ai/tts_service.dart';
import 'package:medha/core/models/adherence_month_stats.dart';
import 'package:medha/core/models/dose_model.dart';
import 'package:medha/core/network/error_detail_wrapper.dart';
import 'package:medha/data/repositories/adherence_repository.dart';
import 'package:medha/data/repositories/reminder_repository.dart';
import 'package:medha/ui/adherence_history/controller/adherence_history_controller.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_tts_service.dart';
import '../../../../helpers/mock_repositories.dart';

void main() {
  late AdherenceHistoryController controller;
  late MockAdherenceRepository mockRepo;
  late FakeTtsService fakeTts;

  final sampleStats = AdherenceMonthStats(
    year: 2026,
    month: 6,
    totalDoses: 10,
    takenDoses: 8,
    missedDoses: 1,
    skippedDoses: 1,
    scheduledDays: 5,
    perfectDays: 3,
    streakDays: 2,
  );

  final sampleSummaries = [
    const AdherenceDaySummary(
      dateKey: '2026-06-01',
      takenCount: 2,
      totalCount: 2,
      missedCount: 0,
      skippedCount: 0,
    ),
    const AdherenceDaySummary(
      dateKey: '2026-06-02',
      takenCount: 1,
      totalCount: 2,
      missedCount: 1,
      skippedCount: 0,
    ),
  ];

  final sampleDoses = [
    const DoseModel(
      id: 'dose_1',
      medicineId: 'm1',
      medicineName: 'Crocin 500',
      dosageMg: 500,
      slot: 'morning',
      scheduledAt: '2026-06-01T08:00:00.000',
      status: 'taken',
      withFood: 'after',
      dateKey: '2026-06-01',
    ),
    const DoseModel(
      id: 'dose_2',
      medicineId: 'm3',
      medicineName: 'Telma 40',
      dosageMg: 40,
      slot: 'night',
      scheduledAt: '2026-06-01T21:00:00.000',
      status: 'missed',
      withFood: 'after',
      dateKey: '2026-06-01',
    ),
  ];

  AdherenceHistoryController buildController() =>
      AdherenceHistoryController(repository: mockRepo);

  void stubSuccessfulLoad() {
    when(() => mockRepo.getDaySummaries(any(), any()))
        .thenAnswer((_) async => Right(sampleSummaries));
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppTranslations.load();
  });

  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en');
    mockRepo = MockAdherenceRepository();
    fakeTts = FakeTtsService();
    Get.put<TtsService>(fakeTts);
    stubSuccessfulLoad();
    controller = buildController();
  });

  tearDown(() {
    Get.reset();
  });

  group('AdherenceHistoryController - load', () {
    test('load_success_populatesMonthStatsAndSummaries', () async {
      await controller.load();

      expect(controller.isLoading.value, false);
      expect(controller.monthStats.value?.takenDoses, 3);
      expect(controller.monthStats.value?.adherencePercent, 75);
      expect(controller.monthSummaries.length, 2);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('load_failure_setsErrorMessage', () async {
      when(() => mockRepo.getDaySummaries(any(), any())).thenAnswer(
        (_) async => const Left(ErrorDetailWrapper(message: 'Load failed')),
      );

      await controller.load();

      expect(controller.errorMessage.value, 'Load failed');
      expect(controller.monthSummaries, isEmpty);
    });

    test('load_isLoading_trueDuringThenFalseAfter', () async {
      when(() => mockRepo.getDaySummaries(any(), any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return Right(sampleSummaries);
      });

      final future = controller.load();
      expect(controller.isLoading.value, true);
      await future;
      expect(controller.isLoading.value, false);
    });

    test('load_clearsExpandedDaysAndLoadingKeys', () async {
      controller.expandedDayDoses['2026-06-01'] = sampleDoses;
      controller.loadingDayKeys.add('2026-06-02');

      await controller.load();

      expect(controller.expandedDayDoses, isEmpty);
      expect(controller.loadingDayKeys, isEmpty);
    });
  });

  group('AdherenceHistoryController - refresh', () {
    test('refresh_delegatesToLoad', () async {
      await controller.refresh();

      expect(controller.monthStats.value?.takenDoses, 3);
      verify(() => mockRepo.getDaySummaries(any(), any())).called(1);
    });
  });

  group('AdherenceHistoryController - month navigation', () {
    test('previousMonth_reloadsData', () async {
      await controller.load();
      clearInteractions(mockRepo);
      stubSuccessfulLoad();

      final before = controller.selectedMonth.value;
      controller.previousMonth();
      await pumpEventQueue();

      expect(
        controller.selectedMonth.value.month,
        before.month == 1 ? 12 : before.month - 1,
      );
      verify(() => mockRepo.getDaySummaries(any(), any())).called(1);
    });

    test('nextMonth_blockedOnCurrentMonth', () async {
      await controller.load();
      final current = controller.selectedMonth.value;

      expect(controller.isCurrentMonth, isTrue);
      controller.nextMonth();

      expect(controller.selectedMonth.value, current);
    });

    test('nextMonth_advancesWhenNotCurrentMonth', () async {
      controller.selectedMonth.value = DateTime(2026, 1);
      when(() => mockRepo.getMonthStats(2026, 1)).thenAnswer(
        (_) async => Right(
          AdherenceMonthStats(
            year: 2026,
            month: 1,
            totalDoses: 10,
            takenDoses: 8,
            missedDoses: 1,
            skippedDoses: 1,
            scheduledDays: 5,
            perfectDays: 3,
            streakDays: 2,
          ),
        ),
      );
      when(() => mockRepo.getDaySummaries(2026, 1))
          .thenAnswer((_) async => Right(sampleSummaries));

      controller.nextMonth();
      await pumpEventQueue();

      expect(controller.selectedMonth.value.month, 2);
    });
  });

  group('AdherenceHistoryController - toggleDayExpansion', () {
    test('toggleDayExpansion_loadsDosesOnExpand', () async {
      when(() => mockRepo.getDayDoses(any())).thenAnswer(
        (_) async => Right(sampleDoses),
      );

      await controller.toggleDayExpansion('2026-06-01');

      expect(controller.expandedDayDoses['2026-06-01'], sampleDoses);
      expect(controller.loadingDayKeys, isEmpty);
      verify(() => mockRepo.getDayDoses(any())).called(1);
    });

    test('toggleDayExpansion_collapsesWhenAlreadyExpanded', () async {
      controller.expandedDayDoses['2026-06-01'] = sampleDoses;

      await controller.toggleDayExpansion('2026-06-01');

      expect(controller.expandedDayDoses.containsKey('2026-06-01'), isFalse);
      verifyNever(() => mockRepo.getDayDoses(any()));
    });

    test('toggleDayExpansion_failure_setsErrorMessage', () async {
      when(() => mockRepo.getDayDoses(any())).thenAnswer(
        (_) async =>
            const Left(ErrorDetailWrapper(message: 'Could not load doses')),
      );

      await controller.toggleDayExpansion('2026-06-01');

      expect(controller.errorMessage.value, 'Could not load doses');
      expect(controller.expandedDayDoses.containsKey('2026-06-01'), isFalse);
    });

    test('toggleDayExpansion_invalidDateKey_doesNotCallRepository', () async {
      await controller.toggleDayExpansion('invalid');

      verifyNever(() => mockRepo.getDayDoses(any()));
    });
  });

  group('AdherenceHistoryController - labels', () {
    test('summaryByDate_mapsDateKeys', () async {
      await controller.load();

      final map = controller.summaryByDate;

      expect(map['2026-06-01']?.takenCount, 2);
      expect(map['2026-06-02']?.missedCount, 1);
    });

    test('statusLabel_mapsKnownStatuses', () {
      expect(controller.statusLabel('taken'), isNotEmpty);
      expect(controller.statusLabel('missed'), isNotEmpty);
      expect(controller.statusLabel('unknown'), isNotEmpty);
    });

    test('slotLabel_mapsKnownSlots', () {
      expect(controller.slotLabel('morning'), isNotEmpty);
      expect(controller.slotLabel('afternoon'), isNotEmpty);
      expect(controller.slotLabel('night'), isNotEmpty);
    });

    test('monthLabel_isNotEmpty', () async {
      await controller.load();
      expect(controller.monthLabel, isNotEmpty);
    });
  });

  group('AdherenceHistoryController - speakMonthSummary', () {
    test('speakMonthSummary_withStats_callsTts', () async {
      await controller.load();

      await controller.speakMonthSummary();

      expect(fakeTts.lastSpokenText, isNotNull);
      expect(fakeTts.lastSpokenText, contains('3'));
      expect(fakeTts.lastSpokenText, contains('4'));
    });

    test('speakMonthSummary_emptyStats_speaksEmptyReadout', () async {
      when(() => mockRepo.getDaySummaries(any(), any()))
          .thenAnswer((_) async => const Right(<AdherenceDaySummary>[]));
      await controller.load();

      await controller.speakMonthSummary();

      expect(fakeTts.lastSpokenText, isNotEmpty);
    });
  });

  group('AdherenceHistoryController - navigation', () {
    test('openDoctorExport_doesNotThrow', () {
      expect(controller.openDoctorExport, returnsNormally);
    });
  });
}
