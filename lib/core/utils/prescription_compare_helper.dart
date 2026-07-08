// lib/core/utils/prescription_compare_helper.dart

import '../models/medicine_model.dart';
import '../models/prescription_compare_model.dart';

class PrescriptionCompareHelper {
  PrescriptionCompareHelper._();

  static PrescriptionCompareResult? comparePrescriptions({
    required String currentPrescriptionId,
    required List<MedicineModel> currentMeds,
    required String otherPrescriptionId,
    required List<MedicineModel> otherMeds,
    required String otherLabel,
  }) {
    if (currentPrescriptionId == otherPrescriptionId) {
      return null;
    }

    final currentByKey = <String, MedicineModel>{};
    for (final med in currentMeds) {
      currentByKey[_normalizeName(med.name)] = med;
    }

    final otherByKey = <String, MedicineModel>{};
    for (final med in otherMeds) {
      otherByKey[_normalizeName(med.name)] = med;
    }

    final allKeys = {...currentByKey.keys, ...otherByKey.keys};
    final items = <PrescriptionDiffItem>[];

    for (final key in allKeys) {
      final current = currentByKey[key];
      final other = otherByKey[key];

      if (current != null && other == null) {
        items.add(
          PrescriptionDiffItem(
            type: PrescriptionDiffType.added,
            current: current,
          ),
        );
        continue;
      }

      if (current == null && other != null) {
        items.add(
          PrescriptionDiffItem(
            type: PrescriptionDiffType.removed,
            other: other,
          ),
        );
        continue;
      }

      if (current != null && other != null) {
        final changedFields = _changedFields(current, other);
        items.add(
          PrescriptionDiffItem(
            type: changedFields.isEmpty
                ? PrescriptionDiffType.unchanged
                : PrescriptionDiffType.changed,
            current: current,
            other: other,
            changedFields: changedFields,
          ),
        );
      }
    }

    items.sort((a, b) {
      final order = {
        PrescriptionDiffType.added: 0,
        PrescriptionDiffType.changed: 1,
        PrescriptionDiffType.removed: 2,
        PrescriptionDiffType.unchanged: 3,
      };
      return order[a.type]!.compareTo(order[b.type]!);
    });

    return PrescriptionCompareResult(
      currentPrescriptionId: currentPrescriptionId,
      otherPrescriptionId: otherPrescriptionId,
      otherLabel: otherLabel,
      items: items,
    );
  }

  static String prescriptionLabel(String prescriptionId, DateTime? addedAt) {
    if (addedAt != null) {
      return '${addedAt.day}/${addedAt.month}/${addedAt.year}';
    }
    return prescriptionId;
  }

  static List<String> _changedFields(MedicineModel a, MedicineModel b) {
    final fields = <String>[];
    if (a.dosageMg != b.dosageMg) {
      fields.add('dosageMg');
    }
    if (a.frequency != b.frequency) {
      fields.add('frequency');
    }
    if (a.withFood != b.withFood) {
      fields.add('withFood');
    }
    if (a.durationDays != b.durationDays) {
      fields.add('durationDays');
    }
    return fields;
  }

  static String _normalizeName(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
