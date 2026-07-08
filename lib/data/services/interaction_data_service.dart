// lib/data/services/interaction_data_service.dart

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../core/ai/knowledge/knowledge_entry.dart';
import '../../core/ai/rag_service.dart';
import '../../core/models/drug_interaction_model.dart';
import '../../core/models/food_rule_model.dart';
import '../../core/models/side_effect_model.dart';
import '../../core/network/error_detail_wrapper.dart';

/// On-device interaction data gateway — wraps [RagService] (no network API).
class InteractionDataService {
  InteractionDataService({RagService? ragService})
      : _rag = ragService ?? Get.find<RagService>();

  final RagService _rag;

  Future<Either<ErrorDetailWrapper, void>> ensureReady({
    String? huggingFaceToken,
  }) {
    return _rag.initialize(huggingFaceToken: huggingFaceToken);
  }

  Future<Either<ErrorDetailWrapper, List<DrugInteractionModel>>> findInteractions(
    List<String> medicineNames,
  ) {
    return _rag.findInteractions(medicineNames);
  }

  Future<Either<ErrorDetailWrapper, SideEffectModel?>> getSideEffects(
    String medicineName,
  ) {
    return _rag.getSideEffects(medicineName);
  }

  Future<Either<ErrorDetailWrapper, List<FoodRuleModel>>> getFoodRules(
    String medicineName,
  ) async {
    final result = await _rag.getFoodRules(medicineName);
    return result.map(_mapFoodRules);
  }

  bool get usesVectorSearch => _rag.usesVectorSearch.value;

  bool get isIndexing => _rag.isIndexing.value;

  List<FoodRuleModel> _mapFoodRules(List<KnowledgeFoodRuleEntry> entries) {
    return entries.map(FoodRuleModel.fromKnowledgeEntry).toList();
  }
}
