// lib/ui/medicine_detail/controller/medicine_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../core/ai/audio_recorder_service.dart';
import '../../../core/ai/gemma_service.dart';
import '../../../core/ai/rag_service.dart';
import '../../../core/ai/tts_service.dart';
import '../../../core/ai/tts_speech_builder.dart';
import '../../../core/ai/voice_doubt_delegate.dart';
import '../../../core/interactions/interaction_helper.dart';
import '../../../core/models/drug_interaction_model.dart';
import '../../../core/models/food_rule_model.dart';
import '../../../core/models/generic_alternative_model.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/models/prescription_compare_model.dart';
import '../../../core/models/side_effect_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/refill_info_model.dart';
import '../../../core/utils/medicine_text_helper.dart';
import '../../../core/utils/prescription_compare_helper.dart';
import '../../../core/utils/refill_calculator.dart';
import '../../../data/repositories/interaction_repository.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../home/controller/home_controller.dart';
import '../../interactions/widgets/food_rules_section.dart';
import '../../reminders/controller/reminders_controller.dart';

class MedicineDetailController extends GetxController {
  MedicineDetailController({
    required MedicineRepository repository,
    required InteractionRepository interactionRepository,
    required ReminderRepository reminderRepository,
    required RagService ragService,
    AudioRecorderService? audioRecorder,
    GemmaService? gemmaService,
  })  : _repository = repository,
        _interactionRepository = interactionRepository,
        _reminderRepository = reminderRepository,
        _ragService = ragService,
        voiceDoubt = VoiceDoubtDelegate(
          audio: audioRecorder ?? Get.find<AudioRecorderService>(),
          gemma: gemmaService ?? Get.find<GemmaService>(),
          tts: Get.find<TtsService>(),
        );

  final MedicineRepository _repository;
  final InteractionRepository _interactionRepository;
  final ReminderRepository _reminderRepository;
  final RagService _ragService;
  final VoiceDoubtDelegate voiceDoubt;
  final _tts = Get.find<TtsService>();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final isLoadingInteractions = false.obs;
  final isLoadingRagInsights = false.obs;
  final isLoadingPrescriptionCompare = false.obs;
  final errorMessage = ''.obs;
  final medicine = Rxn<MedicineModel>();
  final interactions = <DrugInteractionModel>[].obs;
  final foodRules = <FoodRuleModel>[].obs;
  final sideEffects = Rxn<SideEffectModel>();
  final genericAlternative = Rxn<GenericAlternativeModel>();
  final prescriptionCompare = Rxn<PrescriptionCompareResult>();
  final showDangerOverlay = false.obs;
  final dangerAcknowledged = false.obs;
  final refillInfo = Rxn<RefillInfo>();

  String? get medicineId => Get.arguments?['id'] as String?;

  bool get hasDanger => InteractionHelper.dangerOnly(interactions).isNotEmpty;

  String displayStatus(MedicineModel item) {
    if (hasDanger) {
      return item.status;
    }
    if (refillInfo.value?.isRefillDue == true && item.isActive) {
      return 'refill_due';
    }
    return item.status;
  }

  List<DrugInteractionModel> get dangerInteractions =>
      InteractionHelper.dangerOnly(interactions.toList());

  @override
  void onClose() {
    voiceDoubt.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final id = medicineId;
    if (id == null || id.isEmpty) {
      errorMessage.value = 'medicines.error_not_found'.tr;
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _repository.getById(id);
    await result.fold(
      (error) async {
        errorMessage.value = error.message;
      },
      (item) async {
        if (item == null) {
          errorMessage.value = 'medicines.error_not_found'.tr;
        } else {
          medicine.value = item;
          await _updateVoiceContext(item);
          await _loadRagInsights(item);
          await _loadPrescriptionCompare(item);
          if (AppConfig.enableInteractionChecks) {
            await _loadInteractionData(item);
          }
          await _loadRefillInfo(item);
        }
      },
    );

    isLoading.value = false;
  }

  Future<void> _loadInteractionData(MedicineModel item) async {
    isLoadingInteractions.value = true;

    await _interactionRepository.ensureReady();

    final allResult = await _repository.getAll();
    final activeMeds = allResult.fold(
      (_) => <MedicineModel>[],
      (items) => items.where((med) => med.isActive && med.id != item.id).toList(),
    );

    final interactionResult = await _interactionRepository.checkMedicines(
      activeMedicines: activeMeds,
      incomingMedicines: [item],
    );
    interactionResult.fold(
      (_) => interactions.clear(),
      (data) {
        interactions.assignAll(data);
        final dangers = InteractionHelper.dangerOnly(data);
        if (dangers.isNotEmpty && !dangerAcknowledged.value) {
          showDangerOverlay.value = true;
          speakDangerAlert();
        }
      },
    );

    isLoadingInteractions.value = false;
  }

  Future<void> _updateVoiceContext(MedicineModel item) async {
    final allResult = await _repository.getAll();
    allResult.fold(
      (_) => voiceDoubt.setMedicineContext(
        VoiceDoubtDelegate.contextForMedicine(focus: item),
      ),
      (medicines) {
        final others = medicines
            .where((med) => med.isActive && med.id != item.id)
            .toList();
        voiceDoubt.setMedicineContext(
          VoiceDoubtDelegate.contextForMedicine(
            focus: item,
            otherActive: others,
          ),
        );
      },
    );
  }

  Future<void> _loadRagInsights(MedicineModel item) async {
    isLoadingRagInsights.value = true;

    final sideEffectResult = await _ragService.getSideEffects(item.name);
    sideEffectResult.fold(
      (_) => sideEffects.value = null,
      (data) => sideEffects.value = data,
    );

    final foodRuleResult = await _ragService.getFoodRules(item.name);
    foodRuleResult.fold(
      (_) => foodRules.clear(),
      (entries) => foodRules.assignAll(
        entries.map(FoodRuleModel.fromKnowledgeEntry),
      ),
    );

    final genericResult = await _ragService.getGenericAlternatives(item.name);
    genericResult.fold(
      (_) => genericAlternative.value = null,
      (data) => genericAlternative.value = data,
    );

    isLoadingRagInsights.value = false;
  }

  Future<void> _loadPrescriptionCompare(MedicineModel item) async {
    isLoadingPrescriptionCompare.value = true;
    prescriptionCompare.value = null;

    final allResult = await _repository.getAll();
    await allResult.fold(
      (_) async => prescriptionCompare.value = null,
      (medicines) async {
        final currentRxId = item.prescriptionId;
        if (currentRxId == null || currentRxId.isEmpty) {
          return;
        }

        final grouped = <String, List<MedicineModel>>{};
        for (final med in medicines) {
          final key = med.prescriptionId;
          if (key == null || key.isEmpty || key == currentRxId) {
            continue;
          }
          grouped.putIfAbsent(key, () => []).add(med);
        }

        if (grouped.isEmpty) {
          return;
        }

        String? otherRxId;
        DateTime? otherDate;
        for (final entry in grouped.entries) {
          final latest = entry.value
              .map((med) => med.addedAt)
              .whereType<String>()
              .map(DateTime.tryParse)
              .whereType<DateTime>()
              .fold<DateTime?>(
                null,
                (prev, date) =>
                    prev == null || date.isAfter(prev) ? date : prev,
              );
          if (otherRxId == null ||
              (latest != null &&
                  (otherDate == null || latest.isAfter(otherDate)))) {
            otherRxId = entry.key;
            otherDate = latest;
          }
        }

        if (otherRxId == null) {
          return;
        }

        final currentMeds =
            medicines.where((med) => med.prescriptionId == currentRxId).toList();
        final otherMeds = grouped[otherRxId] ?? [];

        prescriptionCompare.value = PrescriptionCompareHelper.comparePrescriptions(
          currentPrescriptionId: currentRxId,
          currentMeds: currentMeds,
          otherPrescriptionId: otherRxId,
          otherMeds: otherMeds,
          otherLabel: PrescriptionCompareHelper.prescriptionLabel(
            otherRxId,
            otherDate,
          ),
        );
      },
    );

    isLoadingPrescriptionCompare.value = false;
  }

  Future<void> _loadRefillInfo(MedicineModel item) async {
    final logsResult = await _reminderRepository.getAllDoseLogs();
    logsResult.fold(
      (_) => refillInfo.value = null,
      (logs) {
        refillInfo.value = RefillCalculator.compute(
          medicine: item,
          doseLogs: logs,
        );
      },
    );
  }

  void acknowledgeDanger() {
    dangerAcknowledged.value = true;
    showDangerOverlay.value = false;
  }

  Future<void> callDoctor() => InteractionHelper.callDoctor();

  Future<void> speakDangerAlert() async {
    final dangers = dangerInteractions;
    if (dangers.isEmpty) {
      return;
    }
    final buffer = StringBuffer('interactions.danger_title'.tr);
    for (final item in dangers) {
      buffer
        ..write('. ')
        ..write(InteractionHelper.interactionTitle(item))
        ..write('. ')
        ..write(item.description);
    }
    await _tts.speak(buffer.toString());
  }

  Future<void> speakMedicine() async {
    final item = medicine.value;
    if (item == null) {
      return;
    }
    await _tts.speak(TtsSpeechBuilder.medicineReadout(item));
  }

  Future<void> speakFoodRules() async {
    if (foodRules.isEmpty) {
      await _tts.speak('interactions.no_food_rules'.tr);
      return;
    }

    await _tts.speak(
      TtsSpeechBuilder.foodRulesReadout(
        foodRules.map((rule) => FoodRuleLabels.label(rule.rule)).toList(),
        foodRules.map((rule) => rule.message).toList(),
      ),
    );
  }

  Future<void> speakSideEffects() async {
    final data = sideEffects.value;
    if (data == null || !data.hasEffects) {
      await _tts.speak('interactions.no_side_effects'.tr);
      return;
    }

    await _tts.speak(
      TtsSpeechBuilder.sideEffectsReadout(
        effects: data.effects,
        source: data.source,
      ),
    );
  }

  Future<void> speakGenericAlternatives() async {
    final data = genericAlternative.value;
    if (data == null || !data.hasAlternatives) {
      await _tts.speak('medicines.generic_empty'.tr);
      return;
    }

    final buffer = StringBuffer(
      'medicines.generic_readout'.trParams({'name': data.genericName}),
    );
    for (final option in data.alternatives) {
      buffer
        ..write('. ')
        ..write(option.name)
        ..write('. ')
        ..write(option.note);
    }
    await _tts.speak(buffer.toString());
  }

  Future<void> speakPrescriptionCompare() async {
    final compare = prescriptionCompare.value;
    if (compare == null) {
      await _tts.speak('medicines.compare_empty'.tr);
      return;
    }

    if (!compare.hasChanges) {
      await _tts.speak(
        'medicines.compare_no_changes'.trParams({
          'label': compare.otherLabel,
        }),
      );
      return;
    }

    final buffer = StringBuffer(
      'medicines.compare_readout'.trParams({'label': compare.otherLabel}),
    );
    for (final item in compare.significantItems) {
      buffer
        ..write('. ')
        ..write(item.displayName)
        ..write('. ')
        ..write(_diffTypeLabel(item.type));
    }
    await _tts.speak(buffer.toString());
  }

  String changedFieldsLabel(List<String> fields) {
    return fields
        .map(
          (field) => switch (field) {
            'dosageMg' => 'medicines.compare_field_dose'.tr,
            'frequency' => 'medicines.detail.frequency'.tr,
            'withFood' => 'medicines.detail.food'.tr,
            'durationDays' => 'medicines.detail.duration'.tr,
            _ => field,
          },
        )
        .join(' · ');
  }

  String _diffTypeLabel(PrescriptionDiffType type) {
    return switch (type) {
      PrescriptionDiffType.added => 'medicines.compare_added'.tr,
      PrescriptionDiffType.removed => 'medicines.compare_removed'.tr,
      PrescriptionDiffType.changed => 'medicines.compare_changed'.tr,
      PrescriptionDiffType.unchanged => 'medicines.compare_unchanged'.tr,
    };
  }

  Future<void> markTaken() async {
    final item = medicine.value;
    if (item == null) {
      return;
    }

    final dosesResult = await _reminderRepository.getTodayDoses();
    await dosesResult.fold(
      (error) async {
        errorMessage.value = error.message;
      },
      (doses) async {
        final pending = doses
            .where(
              (dose) =>
                  dose.medicineId == item.id &&
                  !dose.isTaken &&
                  !dose.isSkipped,
            )
            .toList();
        if (pending.isEmpty) {
          Get.snackbar(
            'medicines.taken_title'.tr,
            'home.no_dose_today'.tr,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.surfaceElevated,
            colorText: AppColors.textPrimary,
          );
          return;
        }

        final result =
            await _reminderRepository.updateDoseStatus(pending.first.id, 'taken');
        result.fold(
          (error) => errorMessage.value = error.message,
          (_) {
            Get.snackbar(
              'medicines.taken_title'.tr,
              'medicines.taken_body'.trParams({'name': item.name}),
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
              duration: const Duration(seconds: 3),
              backgroundColor: AppColors.surfaceElevated,
              colorText: AppColors.textPrimary,
            );
            if (Get.isRegistered<RemindersController>()) {
              Get.find<RemindersController>().load();
            }
            if (Get.isRegistered<HomeController>()) {
              Get.find<HomeController>().load();
            }
          },
        );
      },
    );
  }

  Future<void> markCompleted() async {
    final item = medicine.value;
    if (item == null || isSaving.value) {
      return;
    }

    isSaving.value = true;
    final updated = item.copyWith(status: 'completed');
    final result = await _repository.update(updated);
    result.fold(
      (error) => errorMessage.value = error.message,
      (saved) => medicine.value = saved,
    );
    isSaving.value = false;
  }

  String labelFor(String key, String value) {
    return switch (key) {
      'frequency' => MedicineTextHelper.frequencyLabel(value),
      'withFood' => MedicineTextHelper.foodLabel(value),
      'durationDays' => 'medicines.duration_days'.trParams({'days': value}),
      _ => value,
    };
  }
}
