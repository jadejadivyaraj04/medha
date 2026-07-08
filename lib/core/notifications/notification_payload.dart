// lib/core/notifications/notification_payload.dart

import 'dart:convert';

import '../models/dose_model.dart';

class NotificationPayload {
  NotificationPayload._();

  static String encodeDose(DoseModel dose) {
    return jsonEncode({
      'type': 'dose',
      'dose': dose.toJson(),
    });
  }

  static DoseModel? decodeDose(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      if (decoded['type']?.toString() == 'refill') {
        return null;
      }
      final doseJson = decoded['dose'];
      if (doseJson is! Map) {
        return null;
      }
      return DoseModel.fromJson(Map<String, dynamic>.from(doseJson));
    } catch (_) {
      return null;
    }
  }

  static String encodeRefill({
    required String medicineId,
    required String medicineName,
  }) {
    return jsonEncode({
      'type': 'refill',
      'medicine_id': medicineId,
      'medicine_name': medicineName,
    });
  }

  static Map<String, String>? decodeRefill(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      if (decoded['type']?.toString() != 'refill') {
        return null;
      }
      final id = decoded['medicine_id']?.toString() ?? '';
      final name = decoded['medicine_name']?.toString() ?? '';
      if (id.isEmpty) {
        return null;
      }
      return {'medicine_id': id, 'medicine_name': name};
    } catch (_) {
      return null;
    }
  }
}
