// lib/core/models/dose_model.dart

class DoseModel {
  const DoseModel({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    this.dosageMg,
    required this.slot,
    required this.scheduledAt,
    required this.status,
    required this.withFood,
    required this.dateKey,
  });

  final String id;
  final String medicineId;
  final String medicineName;
  final int? dosageMg;
  final String slot;
  final String scheduledAt;
  final String status;
  final String withFood;
  final String dateKey;

  bool get isTaken => status == 'taken';
  bool get isMissed => status == 'missed';
  bool get isSkipped => status == 'skipped';
  bool get isUpcoming => status == 'upcoming' || status == 'due_soon';

  DateTime get scheduledDateTime => DateTime.parse(scheduledAt);

  DoseModel copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    int? dosageMg,
    String? slot,
    String? scheduledAt,
    String? status,
    String? withFood,
    String? dateKey,
  }) {
    return DoseModel(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      dosageMg: dosageMg ?? this.dosageMg,
      slot: slot ?? this.slot,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      withFood: withFood ?? this.withFood,
      dateKey: dateKey ?? this.dateKey,
    );
  }

  factory DoseModel.fromJson(Map<String, dynamic> json) {
    return DoseModel(
      id: json['id']?.toString() ?? '',
      medicineId: json['medicine_id']?.toString() ?? '',
      medicineName: json['medicine_name']?.toString() ?? '',
      dosageMg: _parseInt(json['dosage_mg']),
      slot: json['slot']?.toString() ?? 'morning',
      scheduledAt: json['scheduled_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'upcoming',
      withFood: json['with_food']?.toString() ?? 'any',
      dateKey: json['date_key']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicine_id': medicineId,
        'medicine_name': medicineName,
        'dosage_mg': dosageMg,
        'slot': slot,
        'scheduled_at': scheduledAt,
        'status': status,
        'with_food': withFood,
        'date_key': dateKey,
      };

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }
}
