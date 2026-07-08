// test/helpers/mock_data.dart

import 'package:medha/core/mock/domain_mock_data.dart';
import 'package:medha/core/models/interaction_warning_model.dart';
import 'package:medha/core/models/medicine_model.dart';
import 'package:medha/core/models/refill_alert_model.dart';

class MockData {
  MockData._();

  static MedicineModel get crocin => const MedicineModel(
        id: 'm1',
        name: 'Crocin 500',
        dosageMg: 500,
        frequency: '1-0-1',
        withFood: 'after',
        durationDays: 5,
        status: 'active',
        prescriptionId: 'rx_1',
      );

  static MedicineModel get panD => const MedicineModel(
        id: 'm2',
        name: 'Pan-D 40',
        dosageMg: 40,
        frequency: '1-0-0',
        withFood: 'before',
        durationDays: 14,
        status: 'completed',
        prescriptionId: 'rx_1',
      );

  static MedicineModel get telma => const MedicineModel(
        id: 'm3',
        name: 'Telma 40',
        dosageMg: 40,
        frequency: '0-0-1',
        withFood: 'after',
        durationDays: 30,
        status: 'active',
        prescriptionId: 'rx_2',
      );

  static MedicineModel get metformin => const MedicineModel(
        id: 'm4',
        name: 'Metformin 500',
        dosageMg: 500,
        frequency: '1-0-1',
        withFood: 'after',
        durationDays: 30,
        status: 'active',
      );

  static MedicineModel get clopitab => const MedicineModel(
        id: 'm5',
        name: 'Clopitab 75',
        dosageMg: 75,
        frequency: '0-0-1',
        withFood: 'after',
        durationDays: 30,
        status: 'active',
        prescriptionId: 'rx_2',
      );

  static List<MedicineModel> get medicineList => [
        crocin,
        panD,
        telma,
        metformin,
        clopitab,
      ];

  static InteractionWarning get pantopClopiWarning =>
      DomainMockData.pantoprazoleClopidogrelWarning(
        profileId: 'test_profile',
        medicineIds: const ['m2', 'm5'],
      );

  static RefillAlert get crocinRefillAlert => DomainMockData.crocinRefillDue(
        profileId: 'test_profile',
        medicineId: 'm1',
      );
}
