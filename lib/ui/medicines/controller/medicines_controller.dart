// lib/ui/medicines/controller/medicines_controller.dart

import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../app/routes.dart';
import '../../../core/ai/tts_service.dart';
import '../../../core/ai/tts_speech_builder.dart';
import '../../../core/models/drug_interaction_model.dart';
import '../../../core/models/dose_model.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/models/refill_info_model.dart';
import '../../../core/utils/refill_calculator.dart';
import '../../../data/repositories/interaction_repository.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../shell/controller/shell_controller.dart';
import '../../../core/interactions/interaction_helper.dart';

enum MedicineFilter { all, active, completed }

class MedicinesController extends GetxController {
  MedicinesController({
    required MedicineRepository repository,
    required InteractionRepository interactionRepository,
    required ReminderRepository reminderRepository,
  })  : _repository = repository,
        _interactionRepository = interactionRepository,
        _reminderRepository = reminderRepository;

  final MedicineRepository _repository;
  final InteractionRepository _interactionRepository;
  final ReminderRepository _reminderRepository;
  final _tts = Get.find<TtsService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final items = <MedicineModel>[].obs;
  final selectedFilter = MedicineFilter.all.obs;
  final dangerInteractions = <DrugInteractionModel>[].obs;
  final refillInfoById = <String, RefillInfo>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    if (Get.isRegistered<ShellController>()) {
      ever(Get.find<ShellController>().currentIndex, (index) {
        if (index == 1) {
          load();
        }
      });
    }
  }

  List<MedicineModel> get filteredItems {
    return switch (selectedFilter.value) {
      MedicineFilter.active => items.where((item) => item.isActive).toList(),
      MedicineFilter.completed =>
        items.where((item) => item.isCompleted).toList(),
      MedicineFilter.all => items.toList(),
    };
  }

  Map<String, List<MedicineModel>> get groupedItems {
    final grouped = <String, List<MedicineModel>>{};
    for (final medicine in filteredItems) {
      final key = medicine.prescriptionId ?? '__other__';
      grouped.putIfAbsent(key, () => []).add(medicine);
    }
    return grouped;
  }

  String groupTitle(String groupKey) {
    if (groupKey == '__other__') {
      return 'medicines.group_other'.tr;
    }
    return 'medicines.group_prescription'.tr;
  }

  bool hasDangerInteraction(MedicineModel medicine) {
    return InteractionHelper.medicineInDanger(
      medicine.name,
      dangerInteractions,
    );
  }

  bool isRefillDue(MedicineModel medicine) {
    return refillInfoById[medicine.id]?.isRefillDue ?? false;
  }

  String displayStatus(MedicineModel medicine) {
    if (hasDangerInteraction(medicine)) {
      return medicine.status;
    }
    if (isRefillDue(medicine) && medicine.isActive) {
      return 'refill_due';
    }
    return medicine.status;
  }

  RefillInfo? refillInfoFor(MedicineModel medicine) =>
      refillInfoById[medicine.id];

  void selectFilter(MedicineFilter filter) => selectedFilter.value = filter;

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _repository.getAll();
    result.fold(
      (error) => errorMessage.value = error.message,
      (data) => items.assignAll(data),
    );

    if (AppConfig.enableInteractionChecks && items.isNotEmpty) {
      await _interactionRepository.ensureReady();
      await _loadDangerInteractions();
    } else {
      dangerInteractions.clear();
    }

    await _loadRefillInfo();

    isLoading.value = false;
  }

  Future<void> _loadRefillInfo() async {
    final logsResult = await _reminderRepository.getAllDoseLogs();
    final logs = logsResult.getOrElse(() => <DoseModel>[]);
    final computed = <String, RefillInfo>{};
    for (final medicine in items) {
      final info = RefillCalculator.compute(
        medicine: medicine,
        doseLogs: logs,
      );
      if (info != null) {
        computed[medicine.id] = info;
      }
    }
    refillInfoById.assignAll(computed);
  }

  Future<void> _loadDangerInteractions() async {
    final active = items.where((item) => item.isActive).toList();
    if (active.length < 2) {
      dangerInteractions.clear();
      return;
    }

    final result = await _interactionRepository.checkMedicines(
      activeMedicines: active,
    );
    result.fold(
      (_) => dangerInteractions.clear(),
      (data) => dangerInteractions.assignAll(
        InteractionHelper.dangerOnly(data),
      ),
    );
  }

  @override
  Future<void> refresh() => load();

  void openScan() => Get.toNamed(Routes.SCAN);

  void openDetail(MedicineModel medicine) {
    Get.toNamed(
      Routes.MEDICINE_DETAILS,
      arguments: {'id': medicine.id},
    );
  }

  Future<void> speakMedicine(MedicineModel medicine) async {
    await _tts.speak(TtsSpeechBuilder.medicineReadout(medicine));
  }
}
