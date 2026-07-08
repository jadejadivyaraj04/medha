// lib/ui/verify_edit/controller/verify_edit_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../app/routes.dart';
import '../../../core/ai/tts_service.dart';
import '../../../core/interactions/interaction_helper.dart';
import '../../../core/models/drug_interaction_model.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/scan/scan_session_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/interaction_repository.dart';
import '../../../data/repositories/medicine_repository.dart';

class MedicineFieldControllers {
  MedicineFieldControllers({
    required this.medicineId,
    required this.nameCtrl,
    required this.doseCtrl,
    required this.frequencyCtrl,
    required this.durationCtrl,
    required this.withFood,
  });

  final String medicineId;
  final TextEditingController nameCtrl;
  final TextEditingController doseCtrl;
  final TextEditingController frequencyCtrl;
  final TextEditingController durationCtrl;
  final RxString withFood;

  void dispose() {
    nameCtrl.dispose();
    doseCtrl.dispose();
    frequencyCtrl.dispose();
    durationCtrl.dispose();
  }
}

class VerifyEditController extends GetxController {
  VerifyEditController({
    required MedicineRepository medicineRepository,
    required InteractionRepository interactionRepository,
    TtsService? tts,
  })  : _medicineRepository = medicineRepository,
        _interactionRepository = interactionRepository,
        _tts = tts ?? Get.find<TtsService>();

  final MedicineRepository _medicineRepository;
  final InteractionRepository _interactionRepository;
  final TtsService _tts;
  final _session = Get.find<ScanSessionService>();

  final medicines = <MedicineModel>[].obs;
  final reviewedFields = <String, Set<String>>{}.obs;
  final isEmptyState = false.obs;

  /// Bumped on every keystroke so Obx-wrapped [canConfirm] re-evaluates even
  /// when only non-reactive TextEditingController text changed.
  final formRevision = 0.obs;
  final isCheckingInteractions = false.obs;
  final showDangerOverlay = false.obs;
  final dangerInteractions = <DrugInteractionModel>[].obs;

  final _fieldControllers = <String, MedicineFieldControllers>{};

  @override
  void onInit() {
    super.onInit();
    _loadFromSession();
  }

  @override
  void onClose() {
    for (final item in _fieldControllers.values) {
      item.dispose();
    }
    super.onClose();
  }

  void _loadFromSession() {
    medicines.assignAll(_session.medicines);
    isEmptyState.value = medicines.isEmpty;

    for (final medicine in medicines) {
      _fieldControllers[medicine.id] = MedicineFieldControllers(
        medicineId: medicine.id,
        nameCtrl: TextEditingController(text: medicine.name),
        doseCtrl: TextEditingController(
          text: medicine.dosageMg?.toString() ?? '',
        ),
        frequencyCtrl: TextEditingController(text: medicine.frequency),
        durationCtrl: TextEditingController(
          text: medicine.durationDays > 0 ? '${medicine.durationDays}' : '',
        ),
        withFood: medicine.withFood.obs,
      );

      _attachReviewListeners(medicine);
    }
  }

  void _attachReviewListeners(MedicineModel medicine) {
    final fields = _fieldControllers[medicine.id];
    if (fields == null) {
      return;
    }

    void mark(String field) {
      if (medicine.isFieldLowConfidence(field)) {
        markFieldReviewed(medicine.id, field);
      }
    }

    void touch(String field) {
      mark(field);
      formRevision.value++;
    }

    fields.nameCtrl.addListener(() => touch('name'));
    fields.doseCtrl.addListener(() => touch('dosageMg'));
    fields.frequencyCtrl.addListener(() => touch('frequency'));
    fields.durationCtrl.addListener(() => touch('durationDays'));
    ever(fields.withFood, (_) => touch('withFood'));
  }

  MedicineFieldControllers? controllersFor(String medicineId) {
    return _fieldControllers[medicineId];
  }

  bool isFieldFlagged(MedicineModel medicine, String field) {
    return medicine.isFieldLowConfidence(field);
  }

  bool isFieldReviewed(String medicineId, String field) {
    return reviewedFields[medicineId]?.contains(field) ?? false;
  }

  void markFieldReviewed(String medicineId, String field) {
    final current = reviewedFields[medicineId] ?? <String>{};
    current.add(field);
    reviewedFields[medicineId] = current;
    reviewedFields.refresh();
  }

  bool _medicineReviewComplete(MedicineModel medicine) {
    const fields = ['name', 'dosageMg', 'frequency', 'withFood', 'durationDays'];
    for (final field in fields) {
      if (medicine.isFieldLowConfidence(field) &&
          !isFieldReviewed(medicine.id, field)) {
        return false;
      }
    }
    return true;
  }

  bool get canConfirm {
    formRevision.value; // subscribe to keystrokes
    if (medicines.isEmpty || isCheckingInteractions.value) {
      return false;
    }
    for (final medicine in medicines) {
      final fields = _fieldControllers[medicine.id];
      if (fields == null) {
        return false;
      }
      if (fields.nameCtrl.text.trim().isEmpty) {
        return false;
      }
      if (!_medicineReviewComplete(medicine)) {
        return false;
      }
    }
    return true;
  }

  void addMedicine() {
    final id = 'rx_manual_${DateTime.now().millisecondsSinceEpoch}';
    final medicine = MedicineModel(
      id: id,
      name: '',
      frequency: '1-0-1',
      withFood: 'any',
      durationDays: 5,
      confidence: 1.0,
    );
    medicines.add(medicine);
    isEmptyState.value = false;

    _fieldControllers[id] = MedicineFieldControllers(
      medicineId: id,
      nameCtrl: TextEditingController(),
      doseCtrl: TextEditingController(),
      frequencyCtrl: TextEditingController(text: '1-0-1'),
      durationCtrl: TextEditingController(text: '5'),
      withFood: 'any'.obs,
    );
    _attachReviewListeners(medicine);
  }

  void removeMedicine(String medicineId) {
    final fields = _fieldControllers.remove(medicineId);
    fields?.dispose();
    medicines.removeWhere((item) => item.id == medicineId);
    reviewedFields.remove(medicineId);
    isEmptyState.value = medicines.isEmpty;
  }

  Future<void> confirmAndContinue() async {
    if (!canConfirm) {
      return;
    }

    final updated = medicines.map(_buildMedicineFromFields).toList();
    _session.setMedicines(updated);

    if (AppConfig.enableInteractionChecks) {
      final canContinue = await _runInteractionCheck(updated);
      if (!canContinue) {
        return;
      }
    }

    Get.toNamed(Routes.SCHEDULE_SUMMARY);
  }

  void acknowledgeDangerAndContinue() {
    showDangerOverlay.value = false;
    Get.toNamed(Routes.SCHEDULE_SUMMARY);
  }

  Future<void> callDoctor() => InteractionHelper.callDoctor();

  Future<void> speakDangerAlert() async {
    if (dangerInteractions.isEmpty) {
      return;
    }
    final buffer = StringBuffer('interactions.danger_title'.tr);
    for (final item in dangerInteractions) {
      buffer
        ..write('. ')
        ..write(InteractionHelper.interactionTitle(item))
        ..write('. ')
        ..write(item.description);
    }
    await _tts.speak(buffer.toString());
  }

  Future<bool> _runInteractionCheck(List<MedicineModel> incoming) async {
    isCheckingInteractions.value = true;

    await _interactionRepository.ensureReady();

    final activeResult = await _medicineRepository.getAll();
    final activeMeds = activeResult.fold(
      (_) => <MedicineModel>[],
      (items) => items.where((item) => item.isActive).toList(),
    );

    final checkResult = await _interactionRepository.checkMedicines(
      activeMedicines: activeMeds,
      incomingMedicines: incoming,
    );

    isCheckingInteractions.value = false;

    return checkResult.fold(
      (_) => true,
      (interactions) {
        final moderate = interactions.where((item) => !item.isDanger).toList();
        if (moderate.isNotEmpty) {
          Get.snackbar(
            'interactions.warning_title'.tr,
            'interactions.warning_body'.trParams({
              'count': '${moderate.length}',
            }),
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 4),
            backgroundColor: AppColors.warningLight,
            colorText: AppColors.textPrimary,
          );
        }

        final dangers = InteractionHelper.dangerOnly(interactions);
        if (dangers.isEmpty) {
          return true;
        }

        dangerInteractions.assignAll(dangers);
        showDangerOverlay.value = true;
        speakDangerAlert();
        return false;
      },
    );
  }

  MedicineModel _buildMedicineFromFields(MedicineModel original) {
    final fields = _fieldControllers[original.id];
    if (fields == null) {
      return original;
    }

    // Built explicitly (not copyWith) so a cleared dose field becomes null
    // instead of silently keeping the AI-parsed value.
    final doseText = fields.doseCtrl.text.trim();
    return MedicineModel(
      id: original.id,
      name: fields.nameCtrl.text.trim(),
      dosageMg: doseText.isEmpty ? null : int.tryParse(doseText),
      frequency: fields.frequencyCtrl.text.trim(),
      withFood: fields.withFood.value,
      durationDays: int.tryParse(fields.durationCtrl.text.trim()) ?? 0,
      confidence: 1.0,
      status: original.status,
      prescriptionId: original.prescriptionId,
      addedAt: original.addedAt,
    );
  }
}
