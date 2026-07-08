// lib/core/models/reminder_log_model.dart

class ReminderLog {
  const ReminderLog({
    required this.id,
    required this.doseId,
    required this.medicineId,
    required this.medicineName,
    required this.action,
    required this.recordedAt,
    this.dateKey,
  });

  final String id;
  final String doseId;
  final String medicineId;
  final String medicineName;
  final String action;
  final String recordedAt;
  final String? dateKey;

  factory ReminderLog.fromJson(Map<String, dynamic> json) {
    return ReminderLog(
      id: json['id']?.toString() ?? '',
      doseId: json['dose_id']?.toString() ?? '',
      medicineId: json['medicine_id']?.toString() ?? '',
      medicineName: json['medicine_name']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      recordedAt: json['recorded_at']?.toString() ?? '',
      dateKey: json['date_key']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dose_id': doseId,
        'medicine_id': medicineId,
        'medicine_name': medicineName,
        'action': action,
        'recorded_at': recordedAt,
        'date_key': dateKey,
      };
}
