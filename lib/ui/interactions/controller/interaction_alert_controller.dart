// lib/ui/interactions/controller/interaction_alert_controller.dart

import 'package:get/get.dart';

import '../../../core/ai/tts_service.dart';
import '../../../core/interactions/interaction_helper.dart';
import '../../../core/models/drug_interaction_model.dart';

class InteractionAlertController extends GetxController {
  InteractionAlertController({
    TtsService? tts,
    List<DrugInteractionModel>? initialInteractions,
  })  : _tts = tts ?? Get.find<TtsService>() {
    if (initialInteractions != null) {
      interactions.assignAll(initialInteractions);
    }
  }

  final TtsService _tts;

  final interactions = <DrugInteractionModel>[].obs;
  final isSpeaking = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (interactions.isEmpty) {
      _loadFromRouteArguments();
    }
    _autoSpeak();
  }

  void _loadFromRouteArguments() {
    final args = Get.arguments;
    if (args is! Map<String, dynamic>) {
      return;
    }
    final raw = args['interactions'];
    if (raw is List<DrugInteractionModel>) {
      interactions.assignAll(raw);
    } else if (raw is List) {
      interactions.assignAll(
        raw.whereType<DrugInteractionModel>().toList(),
      );
    }
  }

  String get readoutText {
    if (interactions.isEmpty) {
      return 'interactions.danger_title'.tr;
    }
    final buffer = StringBuffer('interactions.danger_title'.tr);
    for (final item in interactions) {
      buffer
        ..write('. ')
        ..write(InteractionHelper.interactionTitle(item))
        ..write('. ')
        ..write(item.description);
    }
    return buffer.toString();
  }

  Future<void> speakAlert() async {
    isSpeaking.value = true;
    await _tts.speak(readoutText);
    isSpeaking.value = false;
  }

  Future<void> callDoctor() => InteractionHelper.callDoctor();

  void acknowledge() => Get.back(result: true);

  Future<void> _autoSpeak() async {
    if (interactions.isEmpty) {
      return;
    }
    await speakAlert();
  }
}
