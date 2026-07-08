// lib/data/repositories/mock_interaction_repository.dart

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../core/ai/knowledge/knowledge_entry.dart';
import '../../core/ai/knowledge/knowledge_loader.dart';
import '../../core/interactions/interaction_corpus.dart';
import '../../core/mock/domain_mock_data.dart';
import '../../core/mock/mock_constants.dart';
import '../../core/models/drug_interaction_model.dart';
import '../../core/models/food_rule_model.dart';
import '../../core/models/interaction_warning_model.dart';
import '../../core/models/medicine_model.dart';
import '../../core/models/side_effect_model.dart';
import '../../core/network/error_detail_wrapper.dart';
import '../../core/storage/storage_manager.dart';
import 'interaction_repository.dart';
import 'medicine_repository.dart';

class MockInteractionRepository implements InteractionRepository {
  static final Map<String, bool> _acknowledgedWarnings = {};

  @override
  Future<Either<ErrorDetailWrapper, void>> ensureReady() async {
    await Future<void>.delayed(mockNetworkDelay);
    await KnowledgeLoader.load();
    return const Right(null);
  }

  @override
  Future<Either<ErrorDetailWrapper, List<DrugInteractionModel>>> checkMedicines({
    required List<MedicineModel> activeMedicines,
    List<MedicineModel>? incomingMedicines,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    await KnowledgeLoader.load();

    final names = <String>[
      ...activeMedicines.where((m) => m.isActive).map((m) => m.name),
      ...?incomingMedicines?.map((m) => m.name),
    ];

    return Right(InteractionCorpus.findInteractions(names));
  }

  @override
  Future<Either<ErrorDetailWrapper, SideEffectModel?>> getSideEffects(
    String medicineName,
  ) async {
    await Future<void>.delayed(mockNetworkDelay);
    await KnowledgeLoader.load();
    return Right(KnowledgeLoader.findSideEffects(medicineName));
  }

  @override
  Future<Either<ErrorDetailWrapper, List<FoodRuleModel>>> getFoodRules(
    String medicineName,
  ) async {
    await Future<void>.delayed(mockNetworkDelay);
    await KnowledgeLoader.load();
    final rules = KnowledgeLoader.findFoodRules(medicineName);
    return Right(_mapFoodRules(rules));
  }

  @override
  Future<Either<ErrorDetailWrapper, List<InteractionWarning>>> getActiveWarnings({
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    await KnowledgeLoader.load();

    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return const Right([]);
    }

    final medicines = await _loadMedicines(id);
    final active = medicines.where((medicine) => medicine.isActive).toList();
    if (active.isEmpty) {
      return Right(
        DomainMockData.seedInteractionWarnings(profileId: id),
      );
    }

    final check = await checkMedicines(activeMedicines: active);
    final warnings = check.fold(
      (_) => <InteractionWarning>[],
      (interactions) => _mapWarnings(
        profileId: id,
        medicines: active,
        interactions: interactions,
      ),
    );

    if (warnings.isEmpty) {
      return Right(DomainMockData.seedInteractionWarnings(profileId: id));
    }

    return Right(warnings);
  }

  @override
  Future<Either<ErrorDetailWrapper, InteractionWarning>> acknowledgeWarning(
    String warningId, {
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return Left(ErrorDetailWrapper.unknown('No active profile found.'));
    }

    final warningsResult = await getActiveWarnings(profileId: id);
    return warningsResult.fold(
      Left.new,
      (warnings) {
        for (final warning in warnings) {
          if (warning.id == warningId) {
            _acknowledgedWarnings[warningId] = true;
            return Right(warning.copyWith(acknowledged: true));
          }
        }
        return Left(ErrorDetailWrapper.unknown('Interaction warning not found.'));
      },
    );
  }

  List<FoodRuleModel> _mapFoodRules(List<KnowledgeFoodRuleEntry> entries) {
    return entries.map(FoodRuleModel.fromKnowledgeEntry).toList();
  }

  Future<List<MedicineModel>> _loadMedicines(String profileId) async {
    if (Get.isRegistered<MedicineRepository>()) {
      final result =
          await Get.find<MedicineRepository>().getAll(profileId: profileId);
      return result.getOrElse(() => <MedicineModel>[]);
    }

    final raw = StorageManager.getMedicinesForProfile(profileId);
    if (raw.isEmpty) {
      return [];
    }
    return raw.map(MedicineModel.fromJson).toList();
  }

  List<InteractionWarning> _mapWarnings({
    required String profileId,
    required List<MedicineModel> medicines,
    required List<DrugInteractionModel> interactions,
  }) {
    final warnings = <InteractionWarning>[];
    for (final interaction in interactions) {
      final ids = _medicineIdsForPair(
        medicines: medicines,
        drugA: interaction.drugA,
        drugB: interaction.drugB,
      );
      final warning = InteractionWarning.fromInteraction(
        interaction: interaction,
        profileId: profileId,
        medicineIds: ids,
        acknowledged: _acknowledgedWarnings['warn_${interaction.id}'] ?? false,
      );
      warnings.add(warning);
    }
    warnings.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return warnings;
  }

  List<String> _medicineIdsForPair({
    required List<MedicineModel> medicines,
    required String drugA,
    required String drugB,
  }) {
    final ids = <String>[];
    for (final medicine in medicines) {
      final name = medicine.name.toLowerCase();
      if (name.contains(drugA.toLowerCase()) ||
          drugA.toLowerCase().contains(name) ||
          name.contains(drugB.toLowerCase()) ||
          drugB.toLowerCase().contains(name)) {
        ids.add(medicine.id);
      }
    }
    return ids;
  }
}
