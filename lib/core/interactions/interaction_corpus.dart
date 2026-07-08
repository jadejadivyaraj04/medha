// lib/core/interactions/interaction_corpus.dart

import '../ai/knowledge/knowledge_entry.dart';
import '../ai/knowledge/knowledge_loader.dart';
import '../models/drug_interaction_model.dart';
import '../models/side_effect_model.dart';

/// Legacy facade — delegates to [KnowledgeLoader].
class InteractionCorpus {
  InteractionCorpus._();

  static Future<void> load() => KnowledgeLoader.load();

  static List<DrugInteractionModel> findInteractions(List<String> medicineNames) {
    return KnowledgeLoader.findInteractions(medicineNames);
  }

  static SideEffectModel? findSideEffects(String medicineName) {
    return KnowledgeLoader.findSideEffects(medicineName);
  }

  static List<KnowledgeFoodRuleEntry> findFoodRules(String medicineName) {
    return KnowledgeLoader.findFoodRules(medicineName);
  }
}
