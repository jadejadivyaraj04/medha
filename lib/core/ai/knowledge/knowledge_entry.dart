// lib/core/ai/knowledge/knowledge_entry.dart

import 'dart:convert';

import '../../models/drug_interaction_model.dart';
import '../../models/generic_alternative_model.dart';
import '../../models/interaction_severity.dart';
import '../../models/side_effect_model.dart';

enum KnowledgeDocType { interaction, foodRule, sideEffect, genericAlternative }

/// One embeddable row in the on-device vector store.
class KnowledgeDocument {
  const KnowledgeDocument({
    required this.id,
    required this.type,
    required this.content,
    required this.metadata,
  });

  final String id;
  final KnowledgeDocType type;
  final String content;
  final Map<String, dynamic> metadata;

  String get metadataJson => jsonEncode(metadata);
}

class KnowledgeInteractionEntry {
  const KnowledgeInteractionEntry({
    required this.id,
    required this.pair,
    required this.aliases,
    required this.severity,
    required this.message,
    required this.recommendation,
    required this.source,
  });

  final String id;
  final List<String> pair;
  final Map<String, List<String>> aliases;
  final InteractionSeverity severity;
  final String message;
  final String recommendation;
  final String source;

  factory KnowledgeInteractionEntry.fromJson(Map<String, dynamic> json) {
    final pairRaw = json['pair'];
    final pair = pairRaw is List
        ? pairRaw.map((e) => e.toString()).toList()
        : <String>[];

    final aliasesRaw = json['aliases'];
    final aliases = <String, List<String>>{};
    if (aliasesRaw is Map) {
      for (final entry in aliasesRaw.entries) {
        final list = entry.value;
        aliases[entry.key.toString()] = list is List
            ? list.map((e) => e.toString()).toList()
            : <String>[];
      }
    }

    return KnowledgeInteractionEntry(
      id: json['id']?.toString() ?? '',
      pair: pair,
      aliases: aliases,
      severity: InteractionSeverity.fromString(
        json['severity']?.toString() ?? 'moderate',
      ),
      message: json['message']?.toString() ?? json['description']?.toString() ?? '',
      recommendation: json['recommendation']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
    );
  }

  KnowledgeDocument toDocument() {
    final aliasText = aliases.entries
        .map((e) => '${e.key}: ${e.value.join(', ')}')
        .join('; ');
    return KnowledgeDocument(
      id: 'interaction_$id',
      type: KnowledgeDocType.interaction,
      content:
          'Drug interaction ${pair.join(' with ')}. $message $recommendation. Aliases: $aliasText',
      metadata: {
        'type': 'interaction',
        'entry_id': id,
        'drug_a': pair.isNotEmpty ? pair[0] : '',
        'drug_b': pair.length > 1 ? pair[1] : '',
        'severity': severity.storageValue,
      },
    );
  }

  DrugInteractionModel toModel({required String drugA, required String drugB}) {
    return DrugInteractionModel(
      id: id,
      drugA: drugA,
      drugB: drugB,
      severity: severity,
      description: message,
      recommendation: recommendation,
      source: source,
    );
  }
}

class KnowledgeFoodRuleEntry {
  const KnowledgeFoodRuleEntry({
    required this.id,
    required this.medicine,
    required this.aliases,
    required this.rule,
    required this.message,
    required this.severity,
    required this.source,
  });

  final String id;
  final String medicine;
  final List<String> aliases;
  final String rule;
  final String message;
  final InteractionSeverity severity;
  final String source;

  factory KnowledgeFoodRuleEntry.fromJson(Map<String, dynamic> json) {
    final aliasesRaw = json['aliases'];
    return KnowledgeFoodRuleEntry(
      id: json['id']?.toString() ?? '',
      medicine: json['medicine']?.toString() ?? '',
      aliases: aliasesRaw is List
          ? aliasesRaw.map((e) => e.toString()).toList()
          : <String>[],
      rule: json['rule']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      severity: InteractionSeverity.fromString(
        json['severity']?.toString() ?? 'minor',
      ),
      source: json['source']?.toString() ?? '',
    );
  }

  KnowledgeDocument toDocument() {
    return KnowledgeDocument(
      id: 'food_$id',
      type: KnowledgeDocType.foodRule,
      content:
          'Food rule for $medicine ($rule). $message. Also known as: ${aliases.join(', ')}',
      metadata: {
        'type': 'food_rule',
        'entry_id': id,
        'medicine': medicine,
        'rule': rule,
        'severity': severity.storageValue,
      },
    );
  }
}

class KnowledgeSideEffectEntry {
  const KnowledgeSideEffectEntry({
    required this.medicine,
    required this.aliases,
    required this.effects,
    required this.source,
  });

  final String medicine;
  final List<String> aliases;
  final List<String> effects;
  final String source;

  factory KnowledgeSideEffectEntry.fromJson(Map<String, dynamic> json) {
    final aliasesRaw = json['aliases'];
    final effectsRaw = json['effects'];
    return KnowledgeSideEffectEntry(
      medicine: json['medicine']?.toString() ?? '',
      aliases: aliasesRaw is List
          ? aliasesRaw.map((e) => e.toString()).toList()
          : <String>[],
      effects: effectsRaw is List
          ? effectsRaw.map((e) => e.toString()).toList()
          : <String>[],
      source: json['source']?.toString() ?? '',
    );
  }

  KnowledgeDocument toDocument() {
    return KnowledgeDocument(
      id: 'side_${medicine.replaceAll(' ', '_').toLowerCase()}',
      type: KnowledgeDocType.sideEffect,
      content:
          'Side effects of $medicine: ${effects.join('. ')}. Aliases: ${aliases.join(', ')}',
      metadata: {
        'type': 'side_effect',
        'medicine': medicine,
      },
    );
  }

  SideEffectModel toModel() {
    return SideEffectModel(
      medicineName: medicine,
      effects: effects,
      source: source,
    );
  }
}

class KnowledgeGenericAlternativeEntry {
  const KnowledgeGenericAlternativeEntry({
    required this.medicine,
    required this.aliases,
    required this.genericName,
    required this.alternatives,
    required this.source,
  });

  final String medicine;
  final List<String> aliases;
  final String genericName;
  final List<GenericAlternativeOption> alternatives;
  final String source;

  factory KnowledgeGenericAlternativeEntry.fromJson(Map<String, dynamic> json) {
    final aliasesRaw = json['aliases'];
    final alternativesRaw = json['alternatives'];
    final alternatives = <GenericAlternativeOption>[];
    if (alternativesRaw is List) {
      for (final item in alternativesRaw) {
        if (item is Map) {
          alternatives.add(
            GenericAlternativeOption(
              name: item['name']?.toString() ?? '',
              note: item['note']?.toString() ?? '',
            ),
          );
        }
      }
    }

    return KnowledgeGenericAlternativeEntry(
      medicine: json['medicine']?.toString() ?? '',
      aliases: aliasesRaw is List
          ? aliasesRaw.map((e) => e.toString()).toList()
          : <String>[],
      genericName: json['generic_name']?.toString() ?? '',
      alternatives: alternatives,
      source: json['source']?.toString() ?? '',
    );
  }

  KnowledgeDocument toDocument() {
    final altText = alternatives.map((a) => '${a.name}: ${a.note}').join('; ');
    return KnowledgeDocument(
      id: 'generic_${medicine.replaceAll(' ', '_').toLowerCase()}',
      type: KnowledgeDocType.genericAlternative,
      content:
          'Generic for $medicine is $genericName. Alternatives: $altText. Aliases: ${aliases.join(', ')}',
      metadata: {
        'type': 'generic_alternative',
        'medicine': medicine,
      },
    );
  }

  GenericAlternativeModel toModel({required String resolvedName}) {
    return GenericAlternativeModel(
      medicineName: resolvedName,
      genericName: genericName,
      alternatives: alternatives,
      source: source,
    );
  }
}
