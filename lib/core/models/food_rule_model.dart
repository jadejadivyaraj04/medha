// lib/core/models/food_rule_model.dart

import '../ai/knowledge/knowledge_entry.dart';
import 'interaction_severity.dart';

class FoodRuleModel {
  const FoodRuleModel({
    required this.id,
    required this.medicine,
    required this.rule,
    required this.message,
    required this.severity,
    required this.source,
  });

  final String id;
  final String medicine;
  final String rule;
  final String message;
  final InteractionSeverity severity;
  final String source;

  factory FoodRuleModel.fromKnowledgeEntry(KnowledgeFoodRuleEntry entry) {
    return FoodRuleModel(
      id: entry.id,
      medicine: entry.medicine,
      rule: entry.rule,
      message: entry.message,
      severity: entry.severity,
      source: entry.source,
    );
  }

  factory FoodRuleModel.fromJson(Map<String, dynamic> json) {
    return FoodRuleModel(
      id: json['id']?.toString() ?? '',
      medicine: json['medicine']?.toString() ?? '',
      rule: json['rule']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      severity: InteractionSeverity.fromString(
        json['severity']?.toString() ?? 'minor',
      ),
      source: json['source']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicine': medicine,
        'rule': rule,
        'message': message,
        'severity': severity.storageValue,
        'source': source,
      };
}
