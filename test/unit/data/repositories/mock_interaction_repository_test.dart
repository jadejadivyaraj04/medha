// test/unit/data/repositories/mock_interaction_repository_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medha/app/translations/app_translations.dart';
import 'package:medha/core/models/medicine_model.dart';
import 'package:medha/data/repositories/mock_interaction_repository.dart';

void main() {
  late MockInteractionRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppTranslations.load();
  });

  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en');
    repository = MockInteractionRepository();
  });

  tearDown(() {
    Get.reset();
  });

  MedicineModel med(String name) {
    return MedicineModel(
      id: name,
      name: name,
      dosageMg: 500,
      frequency: '1-0-1',
      withFood: 'after',
      durationDays: 5,
      status: 'active',
    );
  }

  group('MockInteractionRepository', () {
    test('ensureReady_completes', () async {
      final result = await repository.ensureReady();
      expect(result.isRight(), true);
    });

    test('checkMedicines_finds_dangerous_pair', () async {
      final result = await repository.checkMedicines(
        activeMedicines: [med('Crocin 500'), med('Warfarin')],
      );

      result.fold(
        (_) => fail('expected success'),
        (interactions) {
          expect(interactions, isNotEmpty);
          expect(interactions.any((item) => item.isDanger), true);
        },
      );
    });

    test('getSideEffects_returns_crocin_profile', () async {
      final result = await repository.getSideEffects('Crocin 500');

      result.fold(
        (_) => fail('expected success'),
        (sideEffects) {
          expect(sideEffects, isNotNull);
          expect(sideEffects!.effects, isNotEmpty);
        },
      );
    });

    test('getFoodRules_returns_metformin_rule', () async {
      final result = await repository.getFoodRules('Glycomet');

      result.fold(
        (_) => fail('expected success'),
        (rules) {
          expect(rules, isNotEmpty);
          expect(rules.first.rule, 'after_food');
        },
      );
    });
  });
}
