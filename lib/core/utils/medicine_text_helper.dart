// lib/core/utils/medicine_text_helper.dart

import 'package:get/get.dart';

import '../models/medicine_model.dart';

class MedicineTextHelper {
  MedicineTextHelper._();

  static String doseLabel(MedicineModel medicine) {
    if (medicine.dosageMg == null) {
      return 'medicines.dose_unknown'.tr;
    }
    return 'medicines.dose_mg'.trParams({'dose': '${medicine.dosageMg}'});
  }

  static String foodLabel(String value) {
    return switch (value) {
      'before' => 'scan.food.before'.tr,
      'after' => 'scan.food.after'.tr,
      _ => 'scan.food.any'.tr,
    };
  }

  static String frequencyLabel(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      return value;
    }
    final labels = <String>[];
    if (int.tryParse(parts[0]) != null && int.parse(parts[0]) > 0) {
      labels.add('scan.frequency.morning'.tr);
    }
    if (int.tryParse(parts[1]) != null && int.parse(parts[1]) > 0) {
      labels.add('scan.frequency.afternoon'.tr);
    }
    if (int.tryParse(parts[2]) != null && int.parse(parts[2]) > 0) {
      labels.add('scan.frequency.night'.tr);
    }
    return labels.isEmpty ? value : labels.join(', ');
  }

  static String timingLine(MedicineModel medicine) {
    return 'medicines.timing_line'.trParams({
      'frequency': frequencyLabel(medicine.frequency),
      'food': foodLabel(medicine.withFood),
    });
  }

  static String summaryLine(MedicineModel medicine) {
    final dose = medicine.dosageMg != null ? '${medicine.dosageMg} mg' : '—';
    final days = medicine.durationDays > 0 ? '${medicine.durationDays}' : '—';
    return 'scan.summary.line'.trParams({
      'name': medicine.name,
      'dose': dose,
      'frequency': frequencyLabel(medicine.frequency),
      'food': foodLabel(medicine.withFood),
      'days': days,
    });
  }

  static String statusLabel(String status) {
    return switch (status) {
      'completed' => 'medicines.status.completed'.tr,
      'refill_due' => 'medicines.status.refill_due'.tr,
      _ => 'medicines.status.active'.tr,
    };
  }
}
