// lib/core/ai/tts_speech_builder.dart

import 'package:get/get.dart';

import '../models/dose_model.dart';
import '../models/medicine_model.dart';

/// Builds calm, sentence-style scripts for offline TTS — not bullet lists.
class TtsSpeechBuilder {
  TtsSpeechBuilder._();

  static String sanitize(String text) {
    return text
        .replaceAll('—', '. ')
        .replaceAll('–', '. ')
        .replaceAll(RegExp(r'\s*-\s*'), ', ')
        .replaceAll(RegExp(r'\.{2,}'), '.')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(' .', '.')
        .trim();
  }

  static String medicineReadout(MedicineModel medicine) {
    final buffer = StringBuffer(
      'tts.prescribed_intro'.trParams({'name': medicine.name}),
    );

    if (medicine.dosageMg != null) {
      buffer.write(' ');
      buffer.write(
        'tts.dose_fragment'.trParams({'dose': '${medicine.dosageMg}'}),
      );
    }

    buffer
      ..write(' ')
      ..write(timingSpeech(medicine.frequency));

    final food = foodSpeech(medicine.withFood);
    if (food.isNotEmpty) {
      buffer
        ..write(' ')
        ..write(food);
    }

    if (medicine.durationDays > 0) {
      buffer
        ..write(' ')
        ..write(
          'tts.duration_fragment'.trParams({
            'days': '${medicine.durationDays}',
          }),
        );
    }

    return sanitize(buffer.toString());
  }

  static String scheduleReadout(List<MedicineModel> medicines) {
    if (medicines.isEmpty) {
      return 'scan.summary.empty'.tr;
    }

    final parts = <String>[('tts.schedule_intro'.tr)];
    for (var i = 0; i < medicines.length; i++) {
      if (i > 0) {
        parts.add('tts.schedule_next'.tr);
      }
      parts.add(medicineReadout(medicines[i]));
    }
    return sanitize(parts.join(' '));
  }

  static String doseReminderReadout({
    required String medicineName,
    int? dosageMg,
    required String withFood,
    String? timeLabel,
  }) {
    final buffer = StringBuffer('tts.reminder_intro'.tr);

    buffer.write(' ');
    buffer.write(
      'tts.reminder_medicine'.trParams({'name': medicineName}),
    );

    if (dosageMg != null) {
      buffer.write(' ');
      buffer.write(
        'tts.dose_fragment'.trParams({'dose': '$dosageMg'}),
      );
    }

    if (timeLabel != null && timeLabel.trim().isNotEmpty) {
      buffer.write(' ');
      buffer.write(
        'tts.reminder_time'.trParams({'time': timeLabel}),
      );
    }

    final food = foodSpeech(withFood);
    if (food.isNotEmpty) {
      buffer
        ..write(' ')
        ..write(food);
    }

    return sanitize(buffer.toString());
  }

  static String doseReminderReadoutFromModel(DoseModel dose, String timeLabel) {
    return doseReminderReadout(
      medicineName: dose.medicineName,
      dosageMg: dose.dosageMg,
      withFood: dose.withFood,
      timeLabel: timeLabel,
    );
  }

  static String timingSpeech(String frequency) {
    final parts = frequency.split('-');
    if (parts.length != 3) {
      return 'tts.timing_as_prescribed'.tr;
    }

    final morning = int.tryParse(parts[0]) ?? 0;
    final afternoon = int.tryParse(parts[1]) ?? 0;
    final night = int.tryParse(parts[2]) ?? 0;

    if (morning > 0 && afternoon == 0 && night > 0) {
      return 'tts.timing_morning_night'.tr;
    }
    if (morning > 0 && afternoon == 0 && night == 0) {
      return 'tts.timing_morning'.tr;
    }
    if (morning == 0 && afternoon == 0 && night > 0) {
      return 'tts.timing_night'.tr;
    }
    if (morning == 0 && afternoon > 0 && night == 0) {
      return 'tts.timing_afternoon'.tr;
    }
    if (morning > 0 && afternoon > 0 && night > 0) {
      return 'tts.timing_three_times'.tr;
    }
    if (morning > 0 && afternoon > 0 && night == 0) {
      return 'tts.timing_morning_afternoon'.tr;
    }
    if (morning == 0 && afternoon > 0 && night > 0) {
      return 'tts.timing_afternoon_night'.tr;
    }

    final slots = <String>[];
    if (morning > 0) {
      slots.add('tts.slot_morning'.tr);
    }
    if (afternoon > 0) {
      slots.add('tts.slot_afternoon'.tr);
    }
    if (night > 0) {
      slots.add('tts.slot_night'.tr);
    }

    if (slots.isEmpty) {
      return 'tts.timing_as_prescribed'.tr;
    }

    return 'tts.timing_custom'.trParams({'times': slots.join(', ')});
  }

  static String foodSpeech(String withFood) {
    return switch (withFood) {
      'before' => 'tts.food_before'.tr,
      'after' => 'tts.food_after'.tr,
      _ => '',
    };
  }

  static String foodRulesReadout(List<String> ruleLabels, List<String> messages) {
    if (ruleLabels.isEmpty) {
      return 'interactions.no_food_rules'.tr;
    }

    final buffer = StringBuffer('interactions.food_rules_title'.tr);
    for (var i = 0; i < ruleLabels.length; i++) {
      buffer
        ..write('. ')
        ..write(ruleLabels[i])
        ..write('. ')
        ..write(messages[i]);
    }
    buffer
      ..write('. ')
      ..write('interactions.source_note'.tr);
    return sanitize(buffer.toString());
  }

  static String sideEffectsReadout({
    required List<String> effects,
    required String source,
  }) {
    if (effects.isEmpty) {
      return 'interactions.no_side_effects'.tr;
    }

    final buffer = StringBuffer('interactions.side_effects_title'.tr);
    for (final effect in effects) {
      buffer
        ..write('. ')
        ..write(effect);
    }
    if (source.trim().isNotEmpty) {
      buffer
        ..write('. ')
        ..write('interactions.source_label'.trParams({'source': source}));
    }
    buffer
      ..write('. ')
      ..write('interactions.source_note'.tr);
    return sanitize(buffer.toString());
  }
}
