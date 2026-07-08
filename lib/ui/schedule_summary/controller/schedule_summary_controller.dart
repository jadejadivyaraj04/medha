// lib/ui/schedule_summary/controller/schedule_summary_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_config.dart';
import '../../../app/routes.dart';
import '../../../core/ai/tts_service.dart';
import '../../../core/ai/tts_speech_builder.dart';
import '../../../core/interactions/interaction_helper.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/scan/scan_session_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/interaction_repository.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/reminder_repository.dart';

class ScheduleSummaryController extends GetxController {
  ScheduleSummaryController({
    required MedicineRepository repository,
    required ReminderRepository reminderRepository,
    required InteractionRepository interactionRepository,
  })  : _repository = repository,
        _reminderRepository = reminderRepository,
        _interactionRepository = interactionRepository;

  final MedicineRepository _repository;
  final ReminderRepository _reminderRepository;
  final InteractionRepository _interactionRepository;
  final _session = Get.find<ScanSessionService>();
  final _tts = Get.find<TtsService>();

  final isLoading = false.obs;
  final isCheckingInteractions = false.obs;
  final errorMessage = ''.obs;
  final medicines = <MedicineModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    medicines.assignAll(_session.medicines);
  }

  String summaryFor(MedicineModel medicine) {
    final dose = medicine.dosageMg != null ? '${medicine.dosageMg} mg' : '';
    final food = _foodLabel(medicine.withFood);
    final frequency = _frequencyLabel(medicine.frequency);
    final days = medicine.durationDays > 0 ? '${medicine.durationDays}' : '—';

    return 'scan.summary.line'.trParams({
      'name': medicine.name,
      'dose': dose.isEmpty ? '—' : dose,
      'frequency': frequency,
      'food': food,
      'days': days,
    });
  }

  String get fullReadout => TtsSpeechBuilder.scheduleReadout(medicines);

  Future<void> speakSummary() async {
    await _tts.speak(fullReadout);
  }

  Future<void> setReminders() async {
    if (medicines.isEmpty) {
      errorMessage.value = 'scan.summary.empty'.tr;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final batchId = 'rx_${DateTime.now().millisecondsSinceEpoch}';
    final addedAt = DateTime.now().toIso8601String();
    final stamped = medicines
        .map(
          (medicine) => medicine.copyWith(
            prescriptionId: batchId,
            addedAt: addedAt,
            status: 'active',
          ),
        )
        .toList();

    if (AppConfig.enableInteractionChecks) {
      final canContinue = await _runInteractionGate(stamped);
      if (!canContinue) {
        isLoading.value = false;
        return;
      }
    }

    final saveResult = await _repository.saveAll(stamped);
    await saveResult.fold(
      (error) async {
        errorMessage.value = error.message;
      },
      (_) async {
        if (Get.isRegistered<NotificationService>()) {
          await Get.find<NotificationService>().requestPermissions();
        }

        final scheduleResult =
            await _reminderRepository.scheduleConfirmedMedicines(stamped);
        scheduleResult.fold(
          (error) => errorMessage.value = error.message,
          (count) {
            _session.clear();
            Get.snackbar(
              'scan.summary.saved_title'.tr,
              'scan.summary.saved_body'.trParams({'count': '$count'}),
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
              duration: const Duration(seconds: 3),
              backgroundColor: AppColors.surfaceElevated,
              colorText: AppColors.textPrimary,
            );
            Get.offAllNamed(Routes.HOME);
          },
        );
      },
    );

    isLoading.value = false;
  }

  Future<bool> _runInteractionGate(List<MedicineModel> incoming) async {
    isCheckingInteractions.value = true;

    await _interactionRepository.ensureReady();

    final activeResult = await _repository.getAll();
    final activeMeds = activeResult.fold(
      (_) => <MedicineModel>[],
      (items) => items.where((item) => item.isActive).toList(),
    );

    final checkResult = await _interactionRepository.checkMedicines(
      activeMedicines: activeMeds,
      incomingMedicines: incoming,
    );

    isCheckingInteractions.value = false;

    return await checkResult.fold(
      (error) async {
        errorMessage.value = error.message;
        return false;
      },
      (interactions) async {
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

        return InteractionHelper.confirmDangerInteractions(interactions);
      },
    );
  }

  String _foodLabel(String value) {
    return switch (value) {
      'before' => 'scan.food.before'.tr,
      'after' => 'scan.food.after'.tr,
      _ => 'scan.food.any'.tr,
    };
  }

  String _frequencyLabel(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      return value;
    }
    final labels = <String>[];
    if (int.tryParse(parts[0]) != null && int.parse(parts[0]) > 0) {
      labels.add('scan.frequency.morning'.tr);
    }
    if (int.tryParse(parts[1]) != null && int.parse(parts[1]) > 0) {
      labels.add('scan.frequency.afternoon'.tr);
    }
    if (int.tryParse(parts[2]) != null && int.parse(parts[2]) > 0) {
      labels.add('scan.frequency.night'.tr);
    }
    return labels.isEmpty ? value : labels.join(', ');
  }
}
