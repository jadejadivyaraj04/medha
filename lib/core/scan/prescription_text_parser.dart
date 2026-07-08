// lib/core/scan/prescription_text_parser.dart

import 'package:flutter/foundation.dart';

import '../models/medicine_model.dart';
import 'medicine_name_validator.dart';

/// Rule-based extraction of medicines from OCR text — the instant, zero-RAM
/// bottom tier of prescription parsing, used when the on-device LLM is
/// unavailable or times out.
///
/// Precision rules:
/// - UI/letterhead noise lines are stripped before parsing.
/// - A line becomes a medicine only if it carries a clinical signal (dosage,
///   frequency, or a Tab/Cap/Syp prefix) OR its name validates against the
///   known-medicines list.
/// - Validated names are repaired to their canonical spelling; unvalidated
///   fragments without dosing data are rejected (reason logged).
/// - Every result is flagged low-confidence where data is missing, so the
///   verify screen makes the user check those fields.
class PrescriptionTextParser {
  PrescriptionTextParser._();

  static final _dosage = RegExp(r'(\d{1,4})\s*mg\b', caseSensitive: false);
  static final _frequencyDigits = RegExp(r'\b(\d\s*-\s*\d\s*-\s*\d)\b');
  static final _frequencyWords = RegExp(
    r'\b(od|bd|bid|tds|tid|qid|q\d{1,2}h|hs|sos|prn|once daily|twice daily|thrice daily)\b',
    caseSensitive: false,
  );
  static final _duration = RegExp(
    r'(?:[x×]\s*)?(\d{1,2})\s*(?:days?|d|/7)\b',
    caseSensitive: false,
  );
  static final _dosageForm = RegExp(
    r'^(?:tab|cap|syp|inj)\b\.?\s*',
    caseSensitive: false,
  );
  // A believable medicine name: starts with a letter, mostly word characters.
  static final _namePart = RegExp(r'[A-Za-z][A-Za-z0-9\-]{2,}');

  /// Lines that are clearly phone/computer UI or letterhead, not prescription
  /// content — dropped before both the LLM tier and the rule tier see them.
  static final _noiseLine = RegExp(
    r'log in|sign up|create new account|facebook|whatsapp|browser|install|'
    r'inbox|window|help\b|http|www\.|\.com|imported from|learning|'
    r'signature|reg\.? no|ph[:.]|date[:.]|name[:.]|\bage\b|gender|weight|'
    r'clinical|hospital|medical college|research centre|university',
    caseSensitive: false,
  );

  /// Strips obvious non-prescription lines from raw OCR output.
  static String cleanOcrText(String ocrText) {
    return ocrText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.length >= 3 && !_noiseLine.hasMatch(line))
        .join('\n');
  }

  static List<MedicineModel> parse(String ocrText) {
    final medicines = <MedicineModel>[];
    final seenNames = <String>{};
    final lines = cleanOcrText(ocrText).split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        continue;
      }

      final hasDosage = _dosage.hasMatch(line);
      final hasFrequency =
          _frequencyDigits.hasMatch(line) || _frequencyWords.hasMatch(line);
      final hasForm = _dosageForm.hasMatch(line);

      if (!hasDosage && !hasFrequency && !hasForm) {
        // No clinical signal: keep the line only if it IS a known medicine
        // (e.g. an OCR row containing just "LEVOLIN" or "OEFTPL-P").
        final soleMatch =
            line.length <= 30 ? MedicineNameValidator.match(line) : null;
        if (soleMatch == null) {
          continue;
        }
        if (!seenNames.add(soleMatch.canonical.toLowerCase())) {
          continue;
        }
        medicines.add(
          MedicineModel(
            id: 'rx_ocr_${DateTime.now().millisecondsSinceEpoch}_$i',
            name: soleMatch.canonical,
            frequency: '1-0-1',
            withFood: 'any',
            durationDays: 0,
            confidence: soleMatch.exact ? 0.5 : 0.45,
            lowConfidenceFields: const {
              'name',
              'dosageMg',
              'frequency',
              'withFood',
              'durationDays',
            },
          ),
        );
        continue;
      }

      final rawName = _extractName(line);
      if (rawName == null) {
        _reject(line, 'no readable medicine name');
        continue;
      }

      final match = MedicineNameValidator.match(rawName);
      final dosageMatch = _dosage.firstMatch(line);

      // Precision gate: an unrecognized name must carry a dosage to survive
      // (a real medicine we don't know); otherwise it's OCR debris.
      if (match == null && dosageMatch == null) {
        _reject(line, 'name "$rawName" not recognized and no dosage present');
        continue;
      }

      final name = match?.canonical ?? rawName;
      if (!seenNames.add(name.toLowerCase())) {
        continue;
      }

      final frequencyRaw = _frequencyDigits.firstMatch(line)?.group(1) ??
          _frequencyWords.firstMatch(line)?.group(1) ??
          '';
      final durationMatch = _duration.firstMatch(line);

      final flagged = <String>{
        // Exact-validated names are trustworthy; repaired/unknown ones are not.
        if (match == null || !match.exact) 'name',
        if (dosageMatch == null) 'dosageMg',
        if (frequencyRaw.isEmpty ||
            !MedicineModel.isCanonicalFrequency(
              MedicineModel.normalizeFrequency(frequencyRaw),
            ))
          'frequency',
        'withFood',
        if (durationMatch == null) 'durationDays',
      };

      final confidence = switch ((match, match?.exact ?? false)) {
        (null, _) => 0.4,
        (_, true) => 0.75,
        (_, false) => 0.6,
      };

      medicines.add(
        MedicineModel(
          id: 'rx_ocr_${DateTime.now().millisecondsSinceEpoch}_$i',
          name: name,
          dosageMg: dosageMatch != null
              ? int.tryParse(dosageMatch.group(1)!)
              : null,
          frequency: frequencyRaw.isEmpty
              ? '1-0-1'
              : MedicineModel.normalizeFrequency(frequencyRaw),
          withFood: 'any',
          durationDays: durationMatch != null
              ? int.tryParse(durationMatch.group(1)!) ?? 0
              : 0,
          confidence: confidence,
          lowConfidenceFields: flagged,
        ),
      );
    }

    return medicines;
  }

  static void _reject(String line, String reason) {
    debugPrint('PrescriptionTextParser: rejected "$line" — $reason');
  }

  static String? _extractName(String line) {
    var text = line.replaceFirst(_dosageForm, '');
    final dosageMatch = _dosage.firstMatch(text);
    if (dosageMatch != null) {
      text = text.substring(0, dosageMatch.start);
    }
    final words = _namePart
        .allMatches(text)
        .map((m) => m.group(0)!)
        .where((w) => !_frequencyWords.hasMatch(w))
        .take(3)
        .toList();
    if (words.isEmpty) {
      return null;
    }
    final name = words.join(' ').trim();
    return name.length >= 3 ? name : null;
  }
}
