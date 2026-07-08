// lib/core/models/medicine_model.dart

class MedicineModel {
  const MedicineModel({
    required this.id,
    required this.name,
    this.dosageMg,
    required this.frequency,
    required this.withFood,
    required this.durationDays,
    this.confidence = 1.0,
    this.lowConfidenceFields = const {},
    this.status = 'active',
    this.prescriptionId,
    this.addedAt,
  });

  final String id;
  final String name;
  final int? dosageMg;
  final String frequency;
  final String withFood;
  final int durationDays;
  final double confidence;
  final Set<String> lowConfidenceFields;
  final String status;
  final String? prescriptionId;
  final String? addedAt;

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';

  bool get hasLowConfidence =>
      confidence < 0.7 || lowConfidenceFields.isNotEmpty;

  bool isFieldLowConfidence(String field) =>
      lowConfidenceFields.contains(field) || confidence < 0.7;

  MedicineModel copyWith({
    String? id,
    String? name,
    int? dosageMg,
    String? frequency,
    String? withFood,
    int? durationDays,
    double? confidence,
    Set<String>? lowConfidenceFields,
    String? status,
    String? prescriptionId,
    String? addedAt,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosageMg: dosageMg ?? this.dosageMg,
      frequency: frequency ?? this.frequency,
      withFood: withFood ?? this.withFood,
      durationDays: durationDays ?? this.durationDays,
      confidence: confidence ?? this.confidence,
      lowConfidenceFields: lowConfidenceFields ?? this.lowConfidenceFields,
      status: status ?? this.status,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    final rawLowFields = json['low_confidence_fields'];
    final lowFields = <String>{};
    if (rawLowFields is List) {
      for (final field in rawLowFields) {
        lowFields.add(_normalizeFieldKey(field.toString()));
      }
    }

    return MedicineModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString().trim() ?? '',
      dosageMg: _parseInt(json['dosage_mg']),
      frequency: json['frequency']?.toString().trim() ?? '',
      withFood: json['with_food']?.toString().trim() ?? 'any',
      durationDays: _parseInt(json['duration_days']) ?? 0,
      confidence: _parseDouble(json['confidence']) ?? 1.0,
      lowConfidenceFields: lowFields,
      status: json['status']?.toString() ?? 'active',
      prescriptionId: json['prescription_id']?.toString(),
      addedAt: json['added_at']?.toString(),
    );
  }

  factory MedicineModel.fromExtractionJson(
    Map<String, dynamic> json, {
    required String id,
  }) {
    final rawLowFields = json['low_confidence_fields'];
    final lowFields = <String>{};
    if (rawLowFields is List) {
      for (final field in rawLowFields) {
        lowFields.add(_normalizeFieldKey(field.toString()));
      }
    }

    return MedicineModel(
      id: id,
      name: json['name']?.toString().trim() ?? '',
      dosageMg: _parseDosageMg(json['dosage_mg']),
      frequency: normalizeFrequency(json['frequency']?.toString() ?? ''),
      withFood: normalizeWithFood(json['with_food']?.toString() ?? ''),
      durationDays: _parseInt(json['duration_days']) ?? 0,
      confidence: _parseDouble(json['confidence']) ?? 0.5,
      lowConfidenceFields: lowFields,
    );
  }

  static final _canonicalFrequency = RegExp(r'^\d+-\d+-\d+$');

  static bool isCanonicalFrequency(String value) =>
      _canonicalFrequency.hasMatch(value.trim());

  /// Maps common prescription shorthand to the app's morning-afternoon-night
  /// form; unrecognized values pass through and get flagged low-confidence.
  static String normalizeFrequency(String raw) {
    final compact = raw.trim().replaceAll(RegExp(r'\s*-\s*'), '-');
    if (isCanonicalFrequency(compact)) {
      return compact;
    }

    final lower = compact.toLowerCase();
    bool has(String pattern) => RegExp('\\b$pattern\\b').hasMatch(lower);

    if (has('od') || has('once')) {
      return '1-0-0';
    }
    if (has('bid') || has('bd') || has('twice')) {
      return '1-0-1';
    }
    if (has('tds') || has('tid') || has('thrice') || has('three times')) {
      return '1-1-1';
    }
    if (has('hs') || has('bedtime') || has('night')) {
      return '0-0-1';
    }
    if (has('morning')) {
      return '1-0-0';
    }
    return compact;
  }

  static String normalizeWithFood(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'before' || lower.contains('before') || lower.contains('empty')) {
      return 'before';
    }
    if (lower == 'after' || lower.contains('after') || lower.contains('with')) {
      return 'after';
    }
    return 'any';
  }

  /// Accepts 500, 500.0, "500", "500mg", "500 mg", "0.5g".
  static int? _parseDosageMg(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.round();
    }
    final text = value.toString().toLowerCase();
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*(mg|g)?').firstMatch(text);
    if (match == null) {
      return null;
    }
    final amount = double.tryParse(match.group(1)!);
    if (amount == null) {
      return null;
    }
    final isGrams = match.group(2) == 'g';
    return (isGrams ? amount * 1000 : amount).round();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage_mg': dosageMg,
        'frequency': frequency,
        'with_food': withFood,
        'duration_days': durationDays,
        'confidence': confidence,
        'low_confidence_fields': lowConfidenceFields.toList(),
        'status': status,
        'prescription_id': prescriptionId,
        'added_at': addedAt,
      };

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  static String _normalizeFieldKey(String raw) {
    return switch (raw) {
      'dosage_mg' => 'dosageMg',
      'with_food' => 'withFood',
      'duration_days' => 'durationDays',
      'low_confidence_fields' => 'lowConfidenceFields',
      _ => raw,
    };
  }
}
