// lib/core/mock/domain_mock_data.dart

import '../models/interaction_severity.dart';
import '../models/interaction_warning_model.dart';
import '../models/refill_alert_model.dart';

/// Realistic Phase 2 domain samples for mocks and unit tests.
class DomainMockData {
  DomainMockData._();

  static InteractionWarning pantoprazoleClopidogrelWarning({
    String profileId = 'profile_seed',
    List<String> medicineIds = const ['seed_m2', 'seed_m4'],
    bool acknowledged = false,
  }) {
    return InteractionWarning(
      id: 'warn_seed_pantop_clopi',
      profileId: profileId,
      medicineIds: medicineIds,
      drugA: 'Pan-D 40',
      drugB: 'Clopitab 75',
      severity: InteractionSeverity.moderate,
      title: 'Pan-D 40 + Clopitab 75',
      message:
          'Pantoprazole (Pan-D) may slightly reduce clopidogrel anti-clotting effect.',
      recommendation:
          'Ask your doctor if you need both — do not stop either medicine on your own.',
      source: 'Medha on-device guide',
      detectedAt: DateTime.now().subtract(const Duration(hours: 6)),
      interactionId: 'int_pantoprazole_clopidogrel',
      acknowledged: acknowledged,
    );
  }

  static InteractionWarning telmaPotassiumWarning({
    String profileId = 'profile_seed',
    List<String> medicineIds = const ['seed_m3'],
    bool acknowledged = false,
  }) {
    return InteractionWarning(
      id: 'warn_seed_telma_k',
      profileId: profileId,
      medicineIds: medicineIds,
      drugA: 'Telma 40',
      drugB: 'Potassium supplement',
      severity: InteractionSeverity.major,
      title: 'Telma 40 + Potassium',
      message:
          'Telmisartan (Telma) with potassium supplements may cause dangerously high potassium.',
      recommendation:
          'Avoid potassium supplements unless prescribed. Call your doctor if you feel weak or have an irregular heartbeat.',
      source: 'Medha on-device guide',
      detectedAt: DateTime.now().subtract(const Duration(days: 1)),
      interactionId: 'int_telmisartan_potassium',
      acknowledged: acknowledged,
    );
  }

  static RefillAlert crocinRefillDue({
    String profileId = 'profile_seed',
    String medicineId = 'seed_m1',
  }) {
    final scanDate = DateTime.now().subtract(const Duration(days: 3));
    return RefillAlert(
      id: 'refill_$medicineId',
      profileId: profileId,
      medicineId: medicineId,
      medicineName: 'Crocin 500',
      remainingDays: 2,
      remainingDoses: 4,
      status: RefillAlertStatus.dueSoon,
      scanDate: scanDate,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  static RefillAlert metforminRefillNotified({
    String profileId = 'profile_seed',
    String medicineId = 'seed_m5',
  }) {
    final scanDate = DateTime.now().subtract(const Duration(days: 28));
    return RefillAlert(
      id: 'refill_$medicineId',
      profileId: profileId,
      medicineId: medicineId,
      medicineName: 'Metformin 500',
      remainingDays: 1,
      remainingDoses: 2,
      status: RefillAlertStatus.notified,
      scanDate: scanDate,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      notifiedAt: DateTime.now().subtract(const Duration(hours: 10)),
    );
  }

  static List<InteractionWarning> seedInteractionWarnings({
    String profileId = 'profile_seed',
  }) =>
      [
        pantoprazoleClopidogrelWarning(profileId: profileId),
      ];

  static List<RefillAlert> seedRefillAlerts({
    String profileId = 'profile_seed',
  }) =>
      [
        crocinRefillDue(profileId: profileId),
      ];
}
