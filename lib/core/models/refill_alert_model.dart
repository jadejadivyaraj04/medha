// lib/core/models/refill_alert_model.dart

import 'refill_info_model.dart';

enum RefillAlertStatus {
  dueSoon,
  notified,
  dismissed;

  static RefillAlertStatus fromString(String raw) {
    return switch (raw.toLowerCase().trim()) {
      'notified' => RefillAlertStatus.notified,
      'dismissed' => RefillAlertStatus.dismissed,
      _ => RefillAlertStatus.dueSoon,
    };
  }

  String get storageValue => switch (this) {
        RefillAlertStatus.dueSoon => 'due_soon',
        RefillAlertStatus.notified => 'notified',
        RefillAlertStatus.dismissed => 'dismissed',
      };
}

/// Persisted refill nudge for one medicine on a patient profile.
class RefillAlert {
  const RefillAlert({
    required this.id,
    required this.profileId,
    required this.medicineId,
    required this.medicineName,
    required this.remainingDays,
    required this.remainingDoses,
    required this.status,
    required this.scanDate,
    required this.createdAt,
    this.notifiedAt,
  });

  final String id;
  final String profileId;
  final String medicineId;
  final String medicineName;
  final int remainingDays;
  final int remainingDoses;
  final RefillAlertStatus status;
  final DateTime scanDate;
  final DateTime createdAt;
  final DateTime? notifiedAt;

  bool get isActive => status != RefillAlertStatus.dismissed;

  bool get isDueSoon => remainingDays <= 2 && remainingDays >= 0;

  RefillAlert copyWith({
    String? id,
    String? profileId,
    String? medicineId,
    String? medicineName,
    int? remainingDays,
    int? remainingDoses,
    RefillAlertStatus? status,
    DateTime? scanDate,
    DateTime? createdAt,
    DateTime? notifiedAt,
  }) {
    return RefillAlert(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      remainingDays: remainingDays ?? this.remainingDays,
      remainingDoses: remainingDoses ?? this.remainingDoses,
      status: status ?? this.status,
      scanDate: scanDate ?? this.scanDate,
      createdAt: createdAt ?? this.createdAt,
      notifiedAt: notifiedAt ?? this.notifiedAt,
    );
  }

  factory RefillAlert.fromRefillInfo({
    required RefillInfo info,
    required String profileId,
    RefillAlertStatus status = RefillAlertStatus.dueSoon,
    DateTime? notifiedAt,
    DateTime? createdAt,
  }) {
    final medicine = info.medicine;
    return RefillAlert(
      id: 'refill_${medicine.id}',
      profileId: profileId,
      medicineId: medicine.id,
      medicineName: medicine.name,
      remainingDays: info.remainingDays,
      remainingDoses: info.remainingDoses,
      status: status,
      scanDate: info.scanDate,
      createdAt: createdAt ?? DateTime.now(),
      notifiedAt: notifiedAt,
    );
  }

  factory RefillAlert.fromJson(Map<String, dynamic> json) {
    return RefillAlert(
      id: json['id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      medicineId: json['medicine_id']?.toString() ?? '',
      medicineName: json['medicine_name']?.toString() ?? '',
      remainingDays: int.tryParse(json['remaining_days']?.toString() ?? '') ?? 0,
      remainingDoses:
          int.tryParse(json['remaining_doses']?.toString() ?? '') ?? 0,
      status: RefillAlertStatus.fromString(
        json['status']?.toString() ?? 'due_soon',
      ),
      scanDate: DateTime.tryParse(json['scan_date']?.toString() ?? '') ??
          DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      notifiedAt: DateTime.tryParse(json['notified_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'profile_id': profileId,
        'medicine_id': medicineId,
        'medicine_name': medicineName,
        'remaining_days': remainingDays,
        'remaining_doses': remainingDoses,
        'status': status.storageValue,
        'scan_date': scanDate.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        if (notifiedAt != null) 'notified_at': notifiedAt!.toIso8601String(),
      };
}
