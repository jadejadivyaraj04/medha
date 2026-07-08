// lib/data/repositories/interaction_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/models/drug_interaction_model.dart';
import '../../core/models/food_rule_model.dart';
import '../../core/models/interaction_warning_model.dart';
import '../../core/models/medicine_model.dart';
import '../../core/models/side_effect_model.dart';
import '../../core/network/error_detail_wrapper.dart';

abstract class InteractionRepository {
  Future<Either<ErrorDetailWrapper, void>> ensureReady();

  Future<Either<ErrorDetailWrapper, List<DrugInteractionModel>>> checkMedicines({
    required List<MedicineModel> activeMedicines,
    List<MedicineModel>? incomingMedicines,
  });

  Future<Either<ErrorDetailWrapper, SideEffectModel?>> getSideEffects(
    String medicineName,
  );

  Future<Either<ErrorDetailWrapper, List<FoodRuleModel>>> getFoodRules(
    String medicineName,
  );

  /// Active interaction warnings for the patient profile (on-device RAG).
  Future<Either<ErrorDetailWrapper, List<InteractionWarning>>> getActiveWarnings({
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, InteractionWarning>> acknowledgeWarning(
    String warningId, {
    String? profileId,
  });
}
