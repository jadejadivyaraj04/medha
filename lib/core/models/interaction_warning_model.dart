// lib/core/models/interaction_warning_model.dart

import 'drug_interaction_model.dart';
import 'interaction_severity.dart';

/// Patient-scoped interaction warning surfaced from on-device RAG checks.
class InteractionWarning {
  const InteractionWarning({
    required this.id,
    required this.profileId,
    required this.medicineIds,
    required this.drugA,
    required this.drugB,
    required this.severity,
    required this.title,
    required this.message,
    required this.recommendation,
    required this.source,
    required this.detectedAt,
    this.interactionId,
    this.acknowledged = false,
  });

  final String id;
  final String profileId;
  final List<String> medicineIds;
  final String drugA;
  final String drugB;
  final InteractionSeverity severity;
  final String title;
  final String message;
  final String recommendation;
  final String source;
  final DateTime detectedAt;
  final String? interactionId;
  final bool acknowledged;

  bool get isDanger => severity.isDanger;

  bool get requiresAcknowledgement => isDanger && !acknowledged;

  InteractionWarning copyWith({
    String? id,
    String? profileId,
    List<String>? medicineIds,
    String? drugA,
    String? drugB,
    InteractionSeverity? severity,
    String? title,
    String? message,
    String? recommendation,
    String? source,
    DateTime? detectedAt,
    String? interactionId,
    bool? acknowledged,
  }) {
    return InteractionWarning(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      medicineIds: medicineIds ?? this.medicineIds,
      drugA: drugA ?? this.drugA,
      drugB: drugB ?? this.drugB,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      recommendation: recommendation ?? this.recommendation,
      source: source ?? this.source,
      detectedAt: detectedAt ?? this.detectedAt,
      interactionId: interactionId ?? this.interactionId,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  factory InteractionWarning.fromInteraction({
    required DrugInteractionModel interaction,
    required String profileId,
    required List<String> medicineIds,
    bool acknowledged = false,
    DateTime? detectedAt,
  }) {
    return InteractionWarning(
      id: 'warn_${interaction.id}',
      profileId: profileId,
      medicineIds: medicineIds,
      drugA: interaction.drugA,
      drugB: interaction.drugB,
      severity: interaction.severity,
      title: '${interaction.drugA} + ${interaction.drugB}',
      message: interaction.description,
      recommendation: interaction.recommendation,
      source: interaction.source,
      detectedAt: detectedAt ?? DateTime.now(),
      interactionId: interaction.id,
      acknowledged: acknowledged,
    );
  }

  factory InteractionWarning.fromJson(Map<String, dynamic> json) {
    final rawIds = json['medicine_ids'];
    return InteractionWarning(
      id: json['id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      medicineIds: rawIds is List
          ? rawIds.map((e) => e.toString()).toList()
          : <String>[],
      drugA: json['drug_a']?.toString() ?? '',
      drugB: json['drug_b']?.toString() ?? '',
      severity: InteractionSeverity.fromString(
        json['severity']?.toString() ?? 'moderate',
      ),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      recommendation: json['recommendation']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      detectedAt: DateTime.tryParse(json['detected_at']?.toString() ?? '') ??
          DateTime.now(),
      interactionId: json['interaction_id']?.toString(),
      acknowledged: json['acknowledged'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'profile_id': profileId,
        'medicine_ids': medicineIds,
        'drug_a': drugA,
        'drug_b': drugB,
        'severity': severity.storageValue,
        'title': title,
        'message': message,
        'recommendation': recommendation,
        'source': source,
        'detected_at': detectedAt.toIso8601String(),
        'interaction_id': interactionId,
        'acknowledged': acknowledged,
      };
}
