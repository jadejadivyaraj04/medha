// lib/core/models/drug_interaction_model.dart

import 'interaction_severity.dart';

class DrugInteractionModel {
  const DrugInteractionModel({
    required this.id,
    required this.drugA,
    required this.drugB,
    required this.severity,
    required this.description,
    required this.recommendation,
    required this.source,
  });

  final String id;
  final String drugA;
  final String drugB;
  final InteractionSeverity severity;
  final String description;
  final String recommendation;
  final String source;

  bool get isDanger => severity.isDanger;

  factory DrugInteractionModel.fromJson(Map<String, dynamic> json) {
    return DrugInteractionModel(
      id: json['id']?.toString() ?? '',
      drugA: json['drug_a']?.toString() ?? '',
      drugB: json['drug_b']?.toString() ?? '',
      severity: InteractionSeverity.fromString(
        json['severity']?.toString() ?? 'moderate',
      ),
      description: json['description']?.toString() ?? '',
      recommendation: json['recommendation']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'drug_a': drugA,
        'drug_b': drugB,
        'severity': severity.storageValue,
        'description': description,
        'recommendation': recommendation,
        'source': source,
      };
}
