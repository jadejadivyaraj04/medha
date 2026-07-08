// lib/core/models/prescription_compare_model.dart

import 'medicine_model.dart';

enum PrescriptionDiffType { added, removed, changed, unchanged }

class PrescriptionDiffItem {
  const PrescriptionDiffItem({
    required this.type,
    this.current,
    this.other,
    this.changedFields = const [],
  });

  final PrescriptionDiffType type;
  final MedicineModel? current;
  final MedicineModel? other;
  final List<String> changedFields;

  String get displayName => current?.name ?? other?.name ?? '';
}

class PrescriptionCompareResult {
  const PrescriptionCompareResult({
    required this.currentPrescriptionId,
    required this.otherPrescriptionId,
    required this.otherLabel,
    required this.items,
  });

  final String currentPrescriptionId;
  final String otherPrescriptionId;
  final String otherLabel;
  final List<PrescriptionDiffItem> items;

  bool get hasChanges =>
      items.any((item) => item.type != PrescriptionDiffType.unchanged);

  List<PrescriptionDiffItem> get significantItems => items
      .where((item) => item.type != PrescriptionDiffType.unchanged)
      .toList();
}
