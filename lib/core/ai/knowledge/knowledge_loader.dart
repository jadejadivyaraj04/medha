// lib/core/ai/knowledge/knowledge_loader.dart

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../../models/drug_interaction_model.dart';
import '../../models/generic_alternative_model.dart';
import '../../models/side_effect_model.dart';
import 'knowledge_entry.dart';

/// Loads and queries the bundled Medha knowledge corpus (interactions + food rules).
class KnowledgeLoader {
  KnowledgeLoader._();

  static const _assetPath =
      'lib/core/ai/knowledge/medha_knowledge_corpus.json';

  static String _corpusVersion = '';
  static List<KnowledgeInteractionEntry> _interactions = [];
  static List<KnowledgeFoodRuleEntry> _foodRules = [];
  static List<KnowledgeSideEffectEntry> _sideEffects = [];
  static List<KnowledgeGenericAlternativeEntry> _genericAlternatives = [];
  static bool _loaded = false;

  static String get corpusVersion => _corpusVersion;

  static Future<void> load() async {
    if (_loaded) {
      return;
    }

    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    _corpusVersion = json['version']?.toString() ?? '1.0.0';

    final interactions = json['interactions'];
    _interactions = interactions is List
        ? interactions
            .where((e) => e is Map)
            .map(
              (e) => KnowledgeInteractionEntry.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList()
        : <KnowledgeInteractionEntry>[];

    final foodRules = json['food_rules'];
    _foodRules = foodRules is List
        ? foodRules
            .where((e) => e is Map)
            .map(
              (e) => KnowledgeFoodRuleEntry.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList()
        : <KnowledgeFoodRuleEntry>[];

    final sideEffects = json['side_effects'];
    _sideEffects = sideEffects is List
        ? sideEffects
            .where((e) => e is Map)
            .map(
              (e) => KnowledgeSideEffectEntry.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList()
        : <KnowledgeSideEffectEntry>[];

    final generics = json['generic_alternatives'];
    _genericAlternatives = generics is List
        ? generics
            .where((e) => e is Map)
            .map(
              (e) => KnowledgeGenericAlternativeEntry.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList()
        : <KnowledgeGenericAlternativeEntry>[];

    _loaded = true;
  }

  static List<KnowledgeDocument> allDocuments() {
    return [
      ..._interactions.map((e) => e.toDocument()),
      ..._foodRules.map((e) => e.toDocument()),
      ..._sideEffects.map((e) => e.toDocument()),
      ..._genericAlternatives.map((e) => e.toDocument()),
    ];
  }

  static List<DrugInteractionModel> findInteractions(List<String> medicineNames) {
    if (!_loaded || medicineNames.length < 2) {
      return [];
    }

    final uniqueNames = medicineNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    if (uniqueNames.length < 2) {
      return [];
    }

    final results = <DrugInteractionModel>[];
    final seenIds = <String>{};

    for (final entry in _interactions) {
      if (entry.pair.length < 2) {
        continue;
      }

      final sideA = entry.pair[0];
      final sideB = entry.pair[1];

      String? medOnSideA;
      String? medOnSideB;

      for (final name in uniqueNames) {
        if (_matchesSide(name, sideA, entry)) {
          medOnSideA ??= name;
        }
        if (_matchesSide(name, sideB, entry)) {
          medOnSideB ??= name;
        }
      }

      if (medOnSideA == null ||
          medOnSideB == null ||
          _normalize(medOnSideA) == _normalize(medOnSideB)) {
        continue;
      }

      if (seenIds.contains(entry.id)) {
        continue;
      }
      seenIds.add(entry.id);

      results.add(
        entry.toModel(drugA: medOnSideA, drugB: medOnSideB),
      );
    }

    results.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return results;
  }

  static List<KnowledgeFoodRuleEntry> findFoodRules(String medicineName) {
    if (!_loaded) {
      return [];
    }

    final trimmed = medicineName.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    return _foodRules
        .where((rule) => _matchesMedicine(trimmed, rule.medicine, rule.aliases))
        .toList();
  }

  static SideEffectModel? findSideEffects(String medicineName) {
    if (!_loaded) {
      return null;
    }

    final trimmed = medicineName.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    for (final entry in _sideEffects) {
      if (_matchesMedicine(trimmed, entry.medicine, entry.aliases)) {
        return entry.toModel();
      }
    }

    return null;
  }

  static GenericAlternativeModel? findGenericAlternatives(String medicineName) {
    if (!_loaded) {
      return null;
    }

    final trimmed = medicineName.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    for (final entry in _genericAlternatives) {
      if (_matchesMedicine(trimmed, entry.medicine, entry.aliases)) {
        return entry.toModel(resolvedName: trimmed);
      }
    }

    return null;
  }

  static bool _matchesSide(
    String medicineName,
    String sideDrug,
    KnowledgeInteractionEntry entry,
  ) {
    final med = _normalize(medicineName);
    final side = _normalize(sideDrug);
    if (med.contains(side) || side.contains(med)) {
      return true;
    }

    final aliases = entry.aliases[sideDrug] ?? [];
    if (_matchesMedicine(medicineName, sideDrug, aliases)) {
      return true;
    }

    return false;
  }

  static bool _matchesMedicine(
    String medicineName,
    String canonical,
    List<String> aliases,
  ) {
    final normalized = _normalize(medicineName);
    final canonicalNorm = _normalize(canonical);
    if (normalized.contains(canonicalNorm) ||
        canonicalNorm.contains(normalized)) {
      return true;
    }

    for (final alias in aliases) {
      final aliasNorm = _normalize(alias);
      if (aliasNorm.isEmpty) {
        continue;
      }
      if (normalized.contains(aliasNorm) || aliasNorm.contains(normalized)) {
        return true;
      }
    }

    return false;
  }

  static String _normalize(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s\-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
