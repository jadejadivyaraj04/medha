// lib/ui/ai_parsing/controller/ai_parsing_controller.dart

import 'package:get/get.dart';

import '../../../app/routes.dart';
import '../../../core/ai/gemma_service.dart';
import '../../../core/scan/scan_session_service.dart';

class AiParsingController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final statusIndex = 0.obs;

  final _gemma = Get.find<GemmaService>();
  final _session = Get.find<ScanSessionService>();

  final statusKeys = const [
    'scan.parsing.step_reading',
    'scan.parsing.step_medicines',
    'scan.parsing.step_schedule',
  ];

  @override
  void onReady() {
    super.onReady();
    _parsePrescription();
  }

  Future<void> _parsePrescription() async {
    isLoading.value = true;
    errorMessage.value = '';
    statusIndex.value = 0;

    if (!_session.hasImage) {
      errorMessage.value = 'scan.error_no_image'.tr;
      isLoading.value = false;
      return;
    }

    for (var i = 0; i < statusKeys.length; i++) {
      statusIndex.value = i;
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }

    final result = await _gemma.parsePrescription(
      _session.imageBytes!,
      imagePath: _session.imagePath,
    );
    result.fold(
      (error) => errorMessage.value = error.message,
      (medicines) {
        _session.setMedicines(medicines);
        Get.offNamed(Routes.VERIFY_EDIT);
      },
    );

    isLoading.value = false;
  }

  void retry() => _parsePrescription();

  void cancel() => Get.back<void>();

  void addManually() {
    _session.setMedicines(const []);
    Get.offNamed(Routes.VERIFY_EDIT);
  }
}
