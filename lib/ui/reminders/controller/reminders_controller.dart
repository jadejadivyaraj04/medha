// lib/ui/reminders/controller/reminders_controller.dart

import 'package:get/get.dart';

import '../../../app/routes.dart';
import '../../../core/ai/tts_service.dart';
import '../../../core/ai/tts_speech_builder.dart';
import '../../../core/models/dose_model.dart';
import '../../../core/storage/storage_manager.dart';
import '../../../core/utils/adherence_date_helper.dart';
import '../../../data/repositories/adherence_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../shell/controller/shell_controller.dart';

class RemindersController extends GetxController {
  RemindersController({
    required ReminderRepository repository,
    required AdherenceRepository adherenceRepository,
  })  : _repository = repository,
        _adherenceRepository = adherenceRepository;

  final ReminderRepository _repository;
  final AdherenceRepository _adherenceRepository;
  final _tts = Get.find<TtsService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final doses = <DoseModel>[].obs;
  final streakDays = 0.obs;

  String get greetingName => StorageManager.getProfileName() ?? 'reminders.guest'.tr;

  String get todayLabel => AdherenceDateHelper.todayLabel(DateTime.now());

  int get takenCount => doses.where((dose) => dose.isTaken).length;

  int get totalCount => doses.length;

  Map<String, List<DoseModel>> get groupedDoses {
    final grouped = <String, List<DoseModel>>{
      'morning': [],
      'afternoon': [],
      'night': [],
    };
    for (final dose in doses) {
      grouped.putIfAbsent(dose.slot, () => []).add(dose);
    }
    return grouped;
  }

  @override
  void onInit() {
    super.onInit();
    load();
    if (Get.isRegistered<ShellController>()) {
      ever(Get.find<ShellController>().currentIndex, (index) {
        if (index == 2) {
          load();
        }
      });
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _repository.getTodayDoses();
    result.fold(
      (error) => errorMessage.value = error.message,
      (data) => doses.assignAll(data),
    );

    final now = DateTime.now();
    final statsResult =
        await _adherenceRepository.getMonthStats(now.year, now.month);
    statsResult.fold(
      (_) => streakDays.value = 0,
      (stats) => streakDays.value = stats.streakDays,
    );

    isLoading.value = false;
  }

  @override
  Future<void> refresh() => load();

  Future<void> markTaken(DoseModel dose) async {
    final result = await _repository.updateDoseStatus(dose.id, 'taken');
    result.fold(
      (error) => errorMessage.value = error.message,
      (updated) => _replaceDose(updated),
    );
  }

  Future<void> markSkipped(DoseModel dose) async {
    final result = await _repository.updateDoseStatus(dose.id, 'skipped');
    result.fold(
      (error) => errorMessage.value = error.message,
      (updated) => _replaceDose(updated),
    );
  }

  Future<void> snoozeDose(DoseModel dose) async {
    final result = await _repository.snoozeDose(dose.id);
    result.fold(
      (error) => errorMessage.value = error.message,
      (updated) => _replaceDose(updated),
    );
  }

  void _replaceDose(DoseModel updated) {
    final index = doses.indexWhere((item) => item.id == updated.id);
    if (index >= 0) {
      doses[index] = updated;
    }
  }

  void openHistory() => Get.toNamed(Routes.ADHERENCE_HISTORY);

  void previewAlert(DoseModel dose) {
    Get.toNamed(
      Routes.REMINDER_ALERT,
      arguments: {'dose': dose.toJson()},
    );
  }

  String slotTitle(String slot) {
    return switch (slot) {
      'morning' => 'reminders.slot.morning'.tr,
      'afternoon' => 'reminders.slot.afternoon'.tr,
      'night' => 'reminders.slot.night'.tr,
      _ => slot,
    };
  }

  String statusLabel(String status) {
    return switch (status) {
      'taken' => 'reminders.status.taken'.tr,
      'missed' => 'reminders.status.missed'.tr,
      'skipped' => 'reminders.status.skipped'.tr,
      'due_soon' => 'reminders.status.due_soon'.tr,
      _ => 'reminders.status.upcoming'.tr,
    };
  }

  String timeLabel(DoseModel dose) => AdherenceDateHelper.timeLabel(dose);

  Future<void> speakDose(DoseModel dose) async {
    await _tts.speak(
      TtsSpeechBuilder.doseReminderReadoutFromModel(
        dose,
        timeLabel(dose),
      ),
    );
  }
}
