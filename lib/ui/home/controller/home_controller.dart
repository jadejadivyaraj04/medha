// lib/ui/home/controller/home_controller.dart

import 'package:get/get.dart';

import '../../../app/routes.dart';
import '../../../core/ai/tts_service.dart';
import '../../../core/models/dose_model.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/models/refill_info_model.dart';
import '../../../core/notifications/refill_notification_sync.dart';
import '../../../core/storage/storage_manager.dart';
import '../../../core/utils/adherence_date_helper.dart';
import '../../../core/utils/refill_calculator.dart';
import '../../../data/repositories/adherence_repository.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../shell/controller/shell_controller.dart';

class HomeController extends GetxController {
  HomeController({
    required ReminderRepository reminderRepository,
    required AdherenceRepository adherenceRepository,
    required MedicineRepository medicineRepository,
    TtsService? tts,
  })  : _reminderRepository = reminderRepository,
        _adherenceRepository = adherenceRepository,
        _medicineRepository = medicineRepository,
        _tts = tts ?? Get.find<TtsService>();

  final ReminderRepository _reminderRepository;
  final AdherenceRepository _adherenceRepository;
  final MedicineRepository _medicineRepository;
  final TtsService _tts;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final doses = <DoseModel>[].obs;
  final streakDays = 0.obs;
  final medicines = <MedicineModel>[].obs;
  final doseLogs = <DoseModel>[].obs;
  final refillInfos = <RefillInfo>[].obs;

  String get greetingName =>
      StorageManager.getProfileName() ?? 'reminders.guest'.tr;

  String get todayLabel => AdherenceDateHelper.todayLabel(DateTime.now());

  int get takenCount => doses.where((dose) => dose.isTaken).length;

  int get totalCount => doses.length;

  List<DoseModel> get upcomingDoses => doses
      .where((dose) => !dose.isTaken && !dose.isSkipped)
      .take(3)
      .toList();

  List<RefillInfo> get refillDueMedicines =>
      refillInfos.where((info) => info.isRefillDue).toList();

  @override
  void onInit() {
    super.onInit();
    load();
    if (Get.isRegistered<ShellController>()) {
      ever(Get.find<ShellController>().currentIndex, (index) {
        if (index == 0) {
          load();
        }
      });
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    final dosesResult = await _reminderRepository.getTodayDoses();
    dosesResult.fold(
      (error) => errorMessage.value = error.message,
      (data) => doses.assignAll(data),
    );

    final medsResult = await _medicineRepository.getAll();
    medsResult.fold(
      (_) => medicines.clear(),
      (data) => medicines.assignAll(data),
    );

    final logsResult = await _reminderRepository.getAllDoseLogs();
    logsResult.fold(
      (_) => doseLogs.clear(),
      (data) => doseLogs.assignAll(data),
    );

    final computed = <RefillInfo>[];
    for (final medicine in medicines) {
      final info = RefillCalculator.compute(
        medicine: medicine,
        doseLogs: doseLogs,
      );
      if (info != null) {
        computed.add(info);
      }
    }
    refillInfos.assignAll(computed);
    await RefillNotificationSync.sync(
      medicines: medicines,
      refillInfos: computed,
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

  void openRemindersTab() {
    if (Get.isRegistered<ShellController>()) {
      Get.find<ShellController>().selectTab(2);
      return;
    }
    Get.toNamed(Routes.REMINDERS);
  }

  void openMedicinesTab() {
    if (Get.isRegistered<ShellController>()) {
      Get.find<ShellController>().selectTab(1);
      return;
    }
    Get.toNamed(Routes.MEDICINES);
  }

  void openHistory() => Get.toNamed(Routes.ADHERENCE_HISTORY);

  Future<void> speakTodaySummary() async {
    if (doses.isEmpty) {
      await _tts.speak('home.empty_readout'.tr);
      return;
    }
    await _tts.speak(
      'home.today_readout'.trParams({
        'taken': '$takenCount',
        'total': '$totalCount',
      }),
    );
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
}
