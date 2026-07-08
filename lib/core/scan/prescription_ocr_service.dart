// lib/core/scan/prescription_ocr_service.dart

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device OCR (ML Kit) for the prescription scan pipeline.
///
/// This is the memory-light first tier of prescription parsing: it reads the
/// printed text off the photo in well under 100 MB of RAM, so it works on
/// every device — the multi-GB Gemma vision path is reserved for hardware
/// that can afford it.
class PrescriptionOcrService {
  /// Returns the recognized text (line per row), or '' when nothing legible.
  Future<String> extractText(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      return result.text;
    } catch (e) {
      debugPrint('PrescriptionOcrService: OCR failed — $e');
      return '';
    } finally {
      await recognizer.close();
    }
  }
}
