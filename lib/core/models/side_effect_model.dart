// lib/core/models/side_effect_model.dart

class SideEffectModel {
  const SideEffectModel({
    required this.medicineName,
    required this.effects,
    required this.source,
  });

  final String medicineName;
  final List<String> effects;
  final String source;

  bool get hasEffects => effects.isNotEmpty;

  factory SideEffectModel.fromJson(Map<String, dynamic> json) {
    final rawEffects = json['effects'];
    final effects = <String>[];
    if (rawEffects is List) {
      for (final effect in rawEffects) {
        final text = effect.toString().trim();
        if (text.isNotEmpty) {
          effects.add(text);
        }
      }
    }

    return SideEffectModel(
      medicineName: json['medicine_name']?.toString() ?? '',
      effects: effects,
      source: json['source']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'medicine_name': medicineName,
        'effects': effects,
        'source': source,
      };
}
