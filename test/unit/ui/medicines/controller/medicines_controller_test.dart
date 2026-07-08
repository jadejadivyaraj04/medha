// test/unit/ui/medicines/controller/medicines_controller_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:medha/app/translations/app_translations.dart';
import 'package:medha/core/ai/tts_service.dart';
import 'package:medha/core/network/error_detail_wrapper.dart';
import 'package:medha/ui/medicines/controller/medicines_controller.dart';
import 'package:medha/ui/shell/controller/shell_controller.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_tts_service.dart';
import '../../../../helpers/mock_data.dart';
import '../../../../helpers/mock_repositories.dart';

void main() {
  late MedicinesController controller;
  late MockMedicineRepository mockRepo;
  late MockInteractionRepository mockInteractionRepo;
  late MockReminderRepository mockReminderRepo;
  late FakeTtsService fakeTts;

  MedicinesController buildController() => MedicinesController(
        repository: mockRepo,
        interactionRepository: mockInteractionRepo,
        reminderRepository: mockReminderRepo,
      );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppTranslations.load();
  });

  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en');
    mockRepo = MockMedicineRepository();
    mockInteractionRepo = MockInteractionRepository();
    mockReminderRepo = MockReminderRepository();
    fakeTts = FakeTtsService();

    when(() => mockRepo.getAll(profileId: any(named: 'profileId')))
        .thenAnswer((_) async => Right(MockData.medicineList));
    when(() => mockReminderRepo.getAllDoseLogs())
        .thenAnswer((_) async => const Right([]));
    when(() => mockInteractionRepo.ensureReady())
        .thenAnswer((_) async => const Right(null));
    when(
      () => mockInteractionRepo.checkMedicines(
        activeMedicines: any(named: 'activeMedicines'),
        incomingMedicines: any(named: 'incomingMedicines'),
      ),
    ).thenAnswer((_) async => const Right([]));

    Get.put<TtsService>(fakeTts);
    controller = buildController();
  });

  tearDown(() {
    Get.reset();
  });

  group('MedicinesController - load', () {
    test('load_success_populatesItems', () async {
      await controller.load();

      expect(controller.isLoading.value, false);
      expect(controller.items, MockData.medicineList);
      expect(controller.errorMessage.value, isEmpty);
      verify(() => mockRepo.getAll(profileId: any(named: 'profileId'))).called(1);
    });

    test('load_failure_setsErrorMessage', () async {
      when(() => mockRepo.getAll(profileId: any(named: 'profileId'))).thenAnswer(
        (_) async => const Left(
          ErrorDetailWrapper(message: 'Could not load medicines'),
        ),
      );

      await controller.load();

      expect(controller.isLoading.value, false);
      expect(controller.items, isEmpty);
      expect(controller.errorMessage.value, 'Could not load medicines');
    });

    test('load_isLoading_trueDuringThenFalseAfter', () async {
      when(() => mockRepo.getAll(profileId: any(named: 'profileId'))).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return Right(MockData.medicineList);
        },
      );

      final future = controller.load();
      expect(controller.isLoading.value, true);

      await future;
      expect(controller.isLoading.value, false);
    });

    test('load_clearsPreviousErrorMessage', () async {
      controller.errorMessage.value = 'Old error';

      await controller.load();

      expect(controller.errorMessage.value, isEmpty);
    });
  });

  group('MedicinesController - refresh', () {
    test('refresh_delegatesToLoad', () async {
      await controller.refresh();

      expect(controller.items, MockData.medicineList);
      verify(() => mockRepo.getAll(profileId: any(named: 'profileId'))).called(1);
    });
  });

  group('MedicinesController - onInit', () {
    test('onInit_callsLoadWhenRegistered', () async {
      Get.put(buildController());

      await pumpEventQueue();

      final registered = Get.find<MedicinesController>();
      expect(registered.items, MockData.medicineList);
      verify(() => mockRepo.getAll(profileId: any(named: 'profileId'))).called(1);
    });

    test('onInit_reloadsWhenMedicinesTabSelected', () async {
      Get.put(ShellController(), permanent: true);
      Get.put(buildController());

      await pumpEventQueue();
      clearInteractions(mockRepo);

      when(() => mockRepo.getAll(profileId: any(named: 'profileId')))
          .thenAnswer((_) async => Right(MockData.medicineList));

      Get.find<ShellController>().selectTab(1);
      await pumpEventQueue();

      verify(() => mockRepo.getAll(profileId: any(named: 'profileId'))).called(1);
    });
  });

  group('MedicinesController - selectFilter', () {
    setUp(() async {
      await controller.load();
    });

    test('selectFilter_active_returnsOnlyActiveMedicines', () {
      controller.selectFilter(MedicineFilter.active);

      expect(controller.selectedFilter.value, MedicineFilter.active);
      expect(controller.filteredItems.every((item) => item.isActive), true);
      expect(controller.filteredItems.length, 3);
    });

    test('selectFilter_completed_returnsOnlyCompletedMedicines', () {
      controller.selectFilter(MedicineFilter.completed);

      expect(controller.selectedFilter.value, MedicineFilter.completed);
      expect(controller.filteredItems.every((item) => item.isCompleted), true);
      expect(controller.filteredItems, [MockData.panD]);
    });

    test('selectFilter_all_returnsAllMedicines', () {
      controller.selectFilter(MedicineFilter.completed);
      controller.selectFilter(MedicineFilter.all);

      expect(controller.selectedFilter.value, MedicineFilter.all);
      expect(controller.filteredItems, MockData.medicineList);
    });
  });

  group('MedicinesController - groupedItems', () {
    setUp(() async {
      await controller.load();
      controller.selectFilter(MedicineFilter.all);
    });

    test('groupedItems_groupsByPrescriptionId', () {
      final grouped = controller.groupedItems;

      expect(grouped['rx_1'], [MockData.crocin, MockData.panD]);
      expect(grouped['rx_2'], [MockData.telma]);
      expect(grouped['__other__'], [MockData.metformin]);
    });

    test('groupedItems_respectsActiveFilter', () {
      controller.selectFilter(MedicineFilter.active);

      final grouped = controller.groupedItems;

      expect(grouped['rx_1'], [MockData.crocin]);
      expect(grouped['rx_2'], [MockData.telma]);
      expect(grouped['__other__'], [MockData.metformin]);
      expect(grouped.values.expand((items) => items).length, 3);
    });
  });

  group('MedicinesController - groupTitle', () {
    test('groupTitle_otherKey_returnsLocalizedOtherTitle', () {
      expect(controller.groupTitle('__other__'), isNotEmpty);
    });

    test('groupTitle_prescriptionKey_returnsLocalizedPrescriptionTitle', () {
      expect(controller.groupTitle('rx_1'), isNotEmpty);
    });
  });

  group('MedicinesController - speakMedicine', () {
    test('speakMedicine_callsTtsWithSummaryLine', () async {
      await controller.speakMedicine(MockData.crocin);

      expect(fakeTts.lastSpokenText, isNotNull);
      expect(fakeTts.lastSpokenText, contains('Crocin 500'));
    });
  });

  group('MedicinesController - navigation', () {
    test('openScan_doesNotThrow', () {
      expect(controller.openScan, returnsNormally);
    });

    test('openDetail_doesNotThrow', () {
      expect(() => controller.openDetail(MockData.crocin), returnsNormally);
    });
  });
}
