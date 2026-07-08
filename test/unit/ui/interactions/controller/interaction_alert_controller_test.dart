// test/unit/ui/interactions/controller/interaction_alert_controller_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medha/app/translations/app_translations.dart';
import 'package:medha/core/ai/tts_service.dart';
import 'package:medha/core/models/drug_interaction_model.dart';
import 'package:medha/core/models/interaction_severity.dart';
import 'package:medha/ui/interactions/controller/interaction_alert_controller.dart';

import '../../../../helpers/fake_tts_service.dart';

void main() {
  late InteractionAlertController controller;
  late FakeTtsService fakeTts;

  const majorInteraction = DrugInteractionModel(
    id: 'int_aspirin_warfarin',
    drugA: 'Aspirin',
    drugB: 'Warfarin',
    severity: InteractionSeverity.contraindicated,
    description: 'Greatly increases bleeding risk.',
    recommendation: 'Call your doctor immediately.',
    source: 'Medha on-device guide',
  );

  const moderateInteraction = DrugInteractionModel(
    id: 'int_pantop_clopi',
    drugA: 'Pan-D 40',
    drugB: 'Clopitab 75',
    severity: InteractionSeverity.moderate,
    description: 'May reduce anti-clotting effect.',
    recommendation: 'Ask your doctor.',
    source: 'Medha on-device guide',
  );

  InteractionAlertController buildController({
    List<DrugInteractionModel>? initialInteractions,
  }) =>
      InteractionAlertController(
        tts: fakeTts,
        initialInteractions: initialInteractions,
      );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppTranslations.load();
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (MethodCall call) async {
        if (call.method == 'canLaunch') {
          return true;
        }
        if (call.method == 'launch') {
          return true;
        }
        return null;
      },
    );
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en');
    fakeTts = FakeTtsService();
    Get.put<TtsService>(fakeTts);
    controller = buildController();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      null,
    );
    Get.reset();
  });

  group('InteractionAlertController - readoutText', () {
    test('readoutText_emptyInteractions_returnsDangerTitleOnly', () {
      expect(controller.readoutText, isNotEmpty);
      expect(controller.interactions, isEmpty);
    });

    test('readoutText_withInteractions_includesPairAndDescription', () {
      controller.interactions.assignAll([majorInteraction]);

      final text = controller.readoutText;

      expect(text, contains('Aspirin'));
      expect(text, contains('Warfarin'));
      expect(text, contains('bleeding risk'));
    });

    test('readoutText_multipleInteractions_concatenatesAll', () {
      controller.interactions.assignAll([
        majorInteraction,
        moderateInteraction,
      ]);

      final text = controller.readoutText;

      expect(text, contains('Aspirin'));
      expect(text, contains('Pan-D 40'));
      expect(text, contains('Clopitab 75'));
    });
  });

  group('InteractionAlertController - speakAlert', () {
    test('speakAlert_callsTtsWithReadoutText', () async {
      controller.interactions.assignAll([majorInteraction]);

      await controller.speakAlert();

      expect(controller.isSpeaking.value, false);
      expect(fakeTts.lastSpokenText, isNotNull);
      expect(fakeTts.lastSpokenText, contains('Aspirin'));
    });

    test('speakAlert_clearsIsSpeakingAfterCompletion', () async {
      controller.interactions.assignAll([majorInteraction]);

      final future = controller.speakAlert();
      expect(controller.isSpeaking.value, true);
      await future;
      expect(controller.isSpeaking.value, false);
    });
  });

  group('InteractionAlertController - initialInteractions', () {
    test('initialInteractions_populatesListOnCreate', () {
      final ctrl = buildController(
        initialInteractions: [majorInteraction, moderateInteraction],
      );

      expect(ctrl.interactions.length, 2);
      expect(ctrl.interactions.first.drugA, 'Aspirin');
    });

    test('initialInteractions_autoSpeakOnPut', () async {
      Get.put(
        buildController(initialInteractions: [majorInteraction]),
      );

      await pumpEventQueue();

      expect(fakeTts.lastSpokenText, isNotNull);
      expect(fakeTts.lastSpokenText, contains('Warfarin'));
    });
  });

  group('InteractionAlertController - navigation', () {
    test('acknowledge_doesNotThrow', () {
      expect(controller.acknowledge, returnsNormally);
    });

    test('callDoctor_doesNotThrow', () async {
      await expectLater(controller.callDoctor(), completes);
    });
  });
}
