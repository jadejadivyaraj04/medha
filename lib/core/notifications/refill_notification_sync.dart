// lib/core/notifications/refill_notification_sync.dart

import 'package:get/get.dart';

import '../models/medicine_model.dart';
import '../models/refill_info_model.dart';
import '../utils/refill_calculator.dart';
import 'notification_service.dart';

/// Schedules or cancels local refill nudges from current supply projections.
class RefillNotificationSync {
  RefillNotificationSync._();

  static Future<void> sync({
    required List<MedicineModel> medicines,
    required List<RefillInfo> refillInfos,
  }) async {
    if (!Get.isRegistered<NotificationService>()) {
      return;
    }

    final notifications = Get.find<NotificationService>();
    final infoById = {for (final info in refillInfos) info.medicine.id: info};

    for (final medicine in medicines) {
      if (!medicine.isActive) {
        await notifications.cancelRefill(medicine.id);
        continue;
      }

      final info = infoById[medicine.id];
      if (info == null || info.isExpired) {
        await notifications.cancelRefill(medicine.id);
        continue;
      }

      final scheduledAt = RefillCalculator.nextRefillNotificationAt(info: info);
      await notifications.cancelRefill(medicine.id);
      if (scheduledAt == null) {
        continue;
      }

      await notifications.scheduleRefillAlert(
        medicineId: medicine.id,
        medicineName: medicine.name,
        scheduledAt: scheduledAt,
        remainingDays: info.remainingDays,
      );
    }
  }
}
