// lib/ui/doctor_export/controller/doctor_export_controller.dart

import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/ai/tts_service.dart';
import '../../../core/interactions/interaction_helper.dart';
import '../../../core/models/doctor_export_report.dart';
import '../../../core/utils/adherence_date_helper.dart';
import '../../../data/repositories/doctor_export_repository.dart';

class DoctorExportController extends GetxController {
  DoctorExportController({required DoctorExportRepository repository})
      : _repository = repository;

  final DoctorExportRepository _repository;
  final _tts = Get.find<TtsService>();

  final isLoading = false.obs;
  final isExporting = false.obs;
  final errorMessage = ''.obs;
  final selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  ).obs;
  final report = Rxn<DoctorExportReport>();

  String get monthLabel => AdherenceDateHelper.monthLabel(selectedMonth.value);

  bool get isCurrentMonth {
    final now = DateTime.now();
    return selectedMonth.value.year == now.year &&
        selectedMonth.value.month == now.month;
  }

  bool get hasExportableData {
    final current = report.value;
    if (current == null) {
      return false;
    }
    return current.hasMedicines || current.hasAdherenceData;
  }

  @override
  void onInit() {
    super.onInit();
    _applyRouteArgs();
    load();
  }

  void _applyRouteArgs() {
    final args = Get.arguments;
    if (args is Map) {
      final year = args['year'];
      final month = args['month'];
      if (year is int && month is int) {
        selectedMonth.value = DateTime(year, month);
      }
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    final month = selectedMonth.value;
    final result = await _repository.buildReport(
      year: month.year,
      month: month.month,
    );

    result.fold(
      (error) {
        errorMessage.value = error.message;
        report.value = null;
      },
      (data) => report.value = data,
    );

    isLoading.value = false;
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

  String foodLabel(String withFood) {
    return switch (withFood) {
      'before' => 'doctor_export.food_before'.tr,
      'after' => 'doctor_export.food_after'.tr,
      _ => 'doctor_export.food_any'.tr,
    };
  }

  Future<void> exportAndShare({bool forCaregiver = false}) async {
    final currentReport = report.value;
    if (currentReport == null || isExporting.value || !hasExportableData) {
      return;
    }

    isExporting.value = true;
    errorMessage.value = '';

    final result = await _repository.generatePdf(currentReport);
    await result.fold(
      (error) async {
        errorMessage.value = error.message;
        Get.snackbar(
          'doctor_export.error_export_title'.tr,
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (path) async {
        final caregiver = currentReport.caregiver;
        final shareText = forCaregiver && caregiver != null
            ? 'doctor_export.share_body_caregiver'.trParams({
                'name': caregiver.name,
              })
            : 'doctor_export.share_body'.tr;

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(path)],
            subject: 'doctor_export.share_subject'.trParams({
              'name': currentReport.profile.name,
            }),
            text: shareText,
          ),
        );
      },
    );

    isExporting.value = false;
  }

  Future<void> callCaregiver() async {
    final phone = report.value?.caregiver?.phone ?? '';
    if (phone.trim().length < 10) {
      Get.snackbar(
        'caregiver.call_cta'.tr,
        'caregiver.error_phone_invalid'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    await InteractionHelper.callPhone(phone);
  }

  Future<void> speakPreview() async {
    final currentReport = report.value;
    if (currentReport == null) {
      await _tts.speak('doctor_export.empty_readout'.tr);
      return;
    }

    if (!hasExportableData) {
      await _tts.speak('doctor_export.empty_readout'.tr);
      return;
    }

    await _tts.speak(
      'doctor_export.preview_readout'.trParams({
        'name': currentReport.profile.name,
        'meds': '${currentReport.activeMedicines.length}',
        'month': monthLabel,
        'percent': '${currentReport.monthStats.adherencePercent.round()}',
      }),
    );
  }
}
