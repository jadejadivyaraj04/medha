// lib/ui/doubt_query/controller/doubt_query_controller.dart

import 'package:get/get.dart';

import '../../../core/ai/audio_recorder_service.dart';
import '../../../core/ai/gemma_service.dart';
import '../../../core/ai/tts_service.dart';
import '../../../core/ai/voice_doubt_delegate.dart';
import '../../../core/utils/medicine_text_helper.dart';
import '../../../data/repositories/medicine_repository.dart';

class DoubtQueryController extends GetxController {
  DoubtQueryController({
    required MedicineRepository medicineRepository,
    AudioRecorderService? audioRecorder,
    GemmaService? gemmaService,
    TtsService? ttsService,
  })  : _medicineRepository = medicineRepository,
        voiceDoubt = VoiceDoubtDelegate(
          audio: audioRecorder ?? Get.find<AudioRecorderService>(),
          gemma: gemmaService ?? Get.find<GemmaService>(),
          tts: ttsService ?? Get.find<TtsService>(),
        );

  final MedicineRepository _medicineRepository;
  final VoiceDoubtDelegate voiceDoubt;

  @override
  void onInit() {
    super.onInit();
    _loadMedicineContext();
  }

  @override
  void onClose() {
    voiceDoubt.dispose();
    super.onClose();
  }

  Future<void> _loadMedicineContext() async {
    final result = await _medicineRepository.getAll();
    result.fold(
      (_) => voiceDoubt.setMedicineContext(''),
      (medicines) {
        final active = medicines.where((medicine) => medicine.isActive).toList();
        if (active.isEmpty) {
          voiceDoubt.setMedicineContext('');
          return;
        }
        voiceDoubt.setMedicineContext(
          active.map(MedicineTextHelper.summaryLine).join('. '),
        );
      },
    );
  }
}
