// test/unit/core/models/domain_models_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:medha/core/mock/domain_mock_data.dart';
import 'package:medha/core/models/drug_interaction_model.dart';
import 'package:medha/core/models/interaction_severity.dart';
import 'package:medha/core/models/interaction_warning_model.dart';
import 'package:medha/core/models/refill_alert_model.dart';
import 'package:medha/core/models/refill_info_model.dart';
import '../../../helpers/mock_data.dart';

void main() {
  group('InteractionWarning', () {
    test('fromInteraction_maps_danger_fields', () {
      const interaction = DrugInteractionModel(
        id: 'int_test',
        drugA: 'Pan-D 40',
        drugB: 'Clopitab 75',
        severity: InteractionSeverity.major,
        description: 'May reduce anti-clotting effect.',
        recommendation: 'Ask your doctor.',
        source: 'Medha on-device guide',
      );

      final warning = InteractionWarning.fromInteraction(
        interaction: interaction,
        profileId: 'p1',
        medicineIds: const ['m2', 'm5'],
      );

      expect(warning.isDanger, isTrue);
      expect(warning.requiresAcknowledgement, isTrue);
      expect(warning.medicineIds, ['m2', 'm5']);
    });

    test('domain_mock_data_has_realistic_warning', () {
      final warning = DomainMockData.pantoprazoleClopidogrelWarning();
      expect(warning.drugA, contains('Pan-D'));
      expect(warning.source, isNotEmpty);
    });
  });

  group('RefillAlert', () {
    test('fromRefillInfo_maps_supply_fields', () {
      final alert = RefillAlert.fromRefillInfo(
        info: RefillInfo(
          medicine: MockData.crocin,
          remainingDays: 2,
          totalDoses: 10,
          takenDoses: 6,
          dosesPerDay: 2,
          scanDate: DateTime.now().subtract(const Duration(days: 3)),
        ),
        profileId: 'p1',
      );

      expect(alert.isDueSoon, isTrue);
      expect(alert.remainingDoses, 4);
      expect(alert.medicineName, 'Crocin 500');
    });

    test('domain_mock_data_has_crocin_refill', () {
      final alert = DomainMockData.crocinRefillDue();
      expect(alert.remainingDays, lessThanOrEqualTo(2));
      expect(alert.status, RefillAlertStatus.dueSoon);
    });
  });
}
