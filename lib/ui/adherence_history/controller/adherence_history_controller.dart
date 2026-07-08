// lib/ui/adherence_history/controller/adherence_history_controller.dart

import 'package:get/get.dart';

import '../../../app/routes.dart';
import '../../../core/ai/tts_service.dart';
import '../../../core/models/adherence_month_stats.dart';
import '../../../core/models/dose_model.dart';
import '../../../core/utils/adherence_date_helper.dart';
import '../../../core/utils/adherence_stats_helper.dart';
import '../../../data/repositories/adherence_repository.dart';
import '../../../data/repositories/reminder_repository.dart';

class AdherenceHistoryController extends GetxController {
  AdherenceHistoryController({required AdherenceRepository repository})
      : _repository = repository;

  final AdherenceRepository _repository;
  final _tts = Get.find<TtsService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  ).obs;
  final monthStats = Rxn<AdherenceMonthStats>();
  final monthSummaries = <AdherenceDaySummary>[].obs;
  final expandedDayDoses = <String, List<DoseModel>>{}.obs;
  final loadingDayKeys = <String>{}.obs;

  String get monthLabel => AdherenceDateHelper.monthLabel(selectedMonth.value);

  bool get isCurrentMonth {
    final now = DateTime.now();
    return selectedMonth.value.year == now.year &&
        selectedMonth.value.month == now.month;
  }

  Map<String, AdherenceDaySummary> get summaryByDate {
    return {for (final item in monthSummaries) item.dateKey: item};
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    expandedDayDoses.clear();
    loadingDayKeys.clear();

    try {
      final month = selectedMonth.value;
      final summariesResult =
          await _repository.getDaySummaries(month.year, month.month);

      summariesResult.fold(
        (error) => errorMessage.value = error.message,
        (data) {
          monthSummaries.assignAll(data);
          monthStats.value = AdherenceStatsHelper.monthStatsFromSummaries(
            year: month.year,
            month: month.month,
            summaries: data,
          );
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => load();

  void previousMonth() {
    final current = selectedMonth.value;
    selectedMonth.value = DateTime(current.year, current.month - 1);
    load();
  }

  void nextMonth() {
    if (isCurrentMonth) {
      return;
    }
    final current = selectedMonth.value;
    selectedMonth.value = DateTime(current.year, current.month + 1);
    load();
  }

  Future<void> toggleDayExpansion(String dateKey) async {
    if (expandedDayDoses.containsKey(dateKey)) {
      expandedDayDoses.remove(dateKey);
      expandedDayDoses.refresh();
      return;
    }

    loadingDayKeys.add(dateKey);
    loadingDayKeys.refresh();

    final parts = dateKey.split('-');
    if (parts.length != 3) {
      loadingDayKeys.remove(dateKey);
      loadingDayKeys.refresh();
      return;
    }

    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    final result = await _repository.getDayDoses(date);
    result.fold(
      (error) => errorMessage.value = error.message,
      (doses) {
        expandedDayDoses[dateKey] = doses;
        expandedDayDoses.refresh();
      },
    );

    loadingDayKeys.remove(dateKey);
    loadingDayKeys.refresh();
  }

  String dayLabel(String dateKey) => AdherenceDateHelper.dayLabel(dateKey);

  String timeLabel(DoseModel dose) => AdherenceDateHelper.timeLabel(dose);

  String statusLabel(String status) {
    return switch (status) {
      'taken' => 'reminders.status.taken'.tr,
      'missed' => 'reminders.status.missed'.tr,
      'skipped' => 'reminders.status.skipped'.tr,
      'due_soon' => 'reminders.status.due_soon'.tr,
      _ => 'reminders.status.upcoming'.tr,
    };
  }

  String slotLabel(String slot) {
    return switch (slot) {
      'morning' => 'reminders.slot.morning'.tr,
      'afternoon' => 'reminders.slot.afternoon'.tr,
      'night' => 'reminders.slot.night'.tr,
      _ => slot,
    };
  }

  Future<void> speakMonthSummary() async {
    final stats = monthStats.value;
    if (stats == null || stats.totalDoses == 0) {
      await _tts.speak('adherence.empty_readout'.tr);
      return;
    }

    await _tts.speak(
      'adherence.month_readout'.trParams({
        'month': monthLabel,
        'percent': '${stats.adherencePercent.round()}',
        'taken': '${stats.takenDoses}',
        'total': '${stats.totalDoses}',
        'streak': '${stats.streakDays}',
      }),
    );
  }

  void openDoctorExport() {
    final month = selectedMonth.value;
    Get.toNamed(
      Routes.DOCTOR_EXPORT,
      arguments: {'year': month.year, 'month': month.month},
    );
  }
}
