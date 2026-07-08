// lib/data/repositories/interaction_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../core/models/drug_interaction_model.dart';
import '../../core/models/food_rule_model.dart';
import '../../core/models/interaction_warning_model.dart';
import '../../core/models/medicine_model.dart';
import '../../core/models/side_effect_model.dart';
import '../../core/network/error_detail_wrapper.dart';
import '../services/interaction_data_service.dart';
import 'interaction_repository.dart';
import 'medicine_repository.dart';

class InteractionRepositoryImpl implements InteractionRepository {
  InteractionRepositoryImpl({
    InteractionDataService? dataService,
    MedicineRepository? medicineRepository,
  })  : _dataService = dataService ?? InteractionDataService(),
        _medicineRepository = medicineRepository;

  final InteractionDataService _dataService;
  final MedicineRepository? _medicineRepository;

  @override
  Future<Either<ErrorDetailWrapper, void>> ensureReady() {
    return _dataService.ensureReady();
  }

  @override
  Future<Either<ErrorDetailWrapper, List<DrugInteractionModel>>> checkMedicines({
    required List<MedicineModel> activeMedicines,
    List<MedicineModel>? incomingMedicines,
  }) async {
    final ready = await ensureReady();
    return await ready.fold(
      (error) async => Left<ErrorDetailWrapper, List<DrugInteractionModel>>(error),
      (_) async {
        final names = _collectNames(
          activeMedicines: activeMedicines,
          incomingMedicines: incomingMedicines,
        );
        return _dataService.findInteractions(names);
      },
    );
  }

  @override
  Future<Either<ErrorDetailWrapper, SideEffectModel?>> getSideEffects(
    String medicineName,
  ) async {
    final ready = await ensureReady();
    return await ready.fold(
      (error) async => Left<ErrorDetailWrapper, SideEffectModel?>(error),
      (_) async => _dataService.getSideEffects(medicineName),
    );
  }

  @override
  Future<Either<ErrorDetailWrapper, List<FoodRuleModel>>> getFoodRules(
    String medicineName,
  ) async {
    final ready = await ensureReady();
    return await ready.fold(
      (error) async => Left<ErrorDetailWrapper, List<FoodRuleModel>>(error),
      (_) async => _dataService.getFoodRules(medicineName),
    );
  }

  @override
  Future<Either<ErrorDetailWrapper, List<InteractionWarning>>> getActiveWarnings({
    String? profileId,
  }) async {
    final repo = _medicineRepository;
    if (repo == null) {
      return const Right([]);
    }

    final medicinesResult = await repo.getAll(profileId: profileId);
    return medicinesResult.fold(
      Left.new,
      (medicines) async {
        final active = medicines.where((medicine) => medicine.isActive).toList();
        if (active.isEmpty) {
          return const Right(<InteractionWarning>[]);
        }

        final check = await checkMedicines(activeMedicines: active);
        return check.fold(
          Left.new,
          (interactions) => Right(
            interactions
                .map(
                  (interaction) => InteractionWarning.fromInteraction(
                    interaction: interaction,
                    profileId: profileId ?? '',
                    medicineIds: _medicineIdsForPair(
                      medicines: active,
                      drugA: interaction.drugA,
                      drugB: interaction.drugB,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<ErrorDetailWrapper, InteractionWarning>> acknowledgeWarning(
    String warningId, {
    String? profileId,
  }) async {
    final warningsResult = await getActiveWarnings(profileId: profileId);
    return warningsResult.fold(
      Left.new,
      (warnings) {
        for (final warning in warnings) {
          if (warning.id == warningId) {
            return Right(warning.copyWith(acknowledged: true));
          }
        }
        return Left(ErrorDetailWrapper.unknown('Interaction warning not found.'));
      },
    );
  }

  List<String> _collectNames({
    required List<MedicineModel> activeMedicines,
    List<MedicineModel>? incomingMedicines,
  }) {
    return <String>[
      ...activeMedicines.where((m) => m.isActive).map((m) => m.name),
      ...?incomingMedicines?.map((m) => m.name),
    ];
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
