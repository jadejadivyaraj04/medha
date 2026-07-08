// lib/ui/reminder_alert/controller/reminder_alert_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/ai/tts_service.dart';
import '../../../core/ai/tts_speech_builder.dart';
import '../../../core/models/dose_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../reminders/controller/reminders_controller.dart';

class ReminderAlertController extends GetxController {
  ReminderAlertController({required ReminderRepository repository})
      : _repository = repository;

  final ReminderRepository _repository;
  final _tts = Get.find<TtsService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final dose = Rxn<DoseModel>();

  @override
  void onReady() {
    super.onReady();
    _loadDose();
    _autoSpeak();
    _handleAutoAction();
  }

  void _handleAutoAction() {
    final args = Get.arguments;
    if (args is! Map) {
      return;
    }
    final autoAction = args['autoAction'] as String?;
    if (autoAction == 'taken') {
      markTaken();
      return;
    }
    if (autoAction == 'snooze') {
      snooze();
    }
  }

  void _loadDose() {
    final args = Get.arguments;
    if (args is Map && args['dose'] is Map) {
      dose.value = DoseModel.fromJson(
        Map<String, dynamic>.from(args['dose'] as Map),
      );
      return;
    }
    errorMessage.value = 'reminders.error_dose_not_found'.tr;
  }

  Future<void> _autoSpeak() async {
    final current = dose.value;
    if (current == null) {
      return;
    }
    await speakReminder();
  }

  Future<void> speakReminder() async {
    final current = dose.value;
    if (current == null) {
      return;
    }
    await _tts.speak(
      TtsSpeechBuilder.doseReminderReadoutFromModel(
        current,
        _formatTime(current),
      ),
    );
  }

  String _formatTime(DoseModel dose) {
    final dt = dose.scheduledDateTime;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<void> markTaken() async {
    final current = dose.value;
    if (current == null || isLoading.value) {
      return;
    }
    isLoading.value = true;
    final result = await _repository.updateDoseStatus(current.id, 'taken');
    result.fold(
      (error) => errorMessage.value = error.message,
      (updated) {
        dose.value = updated;
        _refreshRemindersTab();
        Get.back<void>();
        Get.snackbar(
          'reminders.taken_title'.tr,
          'reminders.taken_body'.trParams({'name': updated.medicineName}),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.surfaceElevated,
          colorText: AppColors.textPrimary,
        );
      },
    );
    isLoading.value = false;
  }

  Future<void> snooze() async {
    final current = dose.value;
    if (current == null || isLoading.value) {
      return;
    }
    isLoading.value = true;
    final result = await _repository.snoozeDose(current.id);
    result.fold(
      (error) => errorMessage.value = error.message,
      (updated) {
        dose.value = updated;
        _refreshRemindersTab();
        Get.back<void>();
      },
    );
    isLoading.value = false;
  }

  Future<void> skip() async {
    final current = dose.value;
    if (current == null || isLoading.value) {
      return;
    }
    isLoading.value = true;
    final result = await _repository.updateDoseStatus(current.id, 'skipped');
    result.fold(
      (error) => errorMessage.value = error.message,
      (updated) {
        dose.value = updated;
        _refreshRemindersTab();
        Get.back<void>();
      },
    );
    isLoading.value = false;
  }

  void _refreshRemindersTab() {
    if (Get.isRegistered<RemindersController>()) {
      Get.find<RemindersController>().load();
    }
  }
}
