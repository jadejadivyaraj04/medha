// lib/core/ai/gemma_config.dart

import 'dart:io' show Platform;

import 'package:flutter_gemma/flutter_gemma.dart';

/// On-device model defaults for Medha (Gemma 3n E2B — vision + prescription OCR).
class GemmaConfig {
  GemmaConfig._();

  /// Gemma 3n E2B multimodal `.litertlm` (arm64 mobile).
  static const defaultModelUrl =
      'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/gemma-3n-E2B-it-int4.litertlm';

  /// Gemma models on Hugging Face are license-gated: accept the license on
  /// huggingface.co/google/gemma-3n-E2B-it-litert-lm, then pass a read token via
  /// `--dart-define=HUGGINGFACE_TOKEN=hf_...` (never commit a real token).
  static const String _huggingFaceToken =
      String.fromEnvironment('HUGGINGFACE_TOKEN');

  static String? get huggingFaceToken =>
      _huggingFaceToken.isEmpty ? null : _huggingFaceToken;

  static const modelType = ModelType.gemmaIt;
  static const fileType = ModelFileType.task;

  /// GPU inference needs the multi-GB weights resident in memory, which
  /// exceeds the iOS per-app jetsam limit even with the increased-memory
  /// entitlement on 4 GB devices; CPU keeps the model file memory-mapped.
  static PreferredBackend get preferredBackend =>
      Platform.isIOS ? PreferredBackend.cpu : PreferredBackend.gpu;

  /// The Gemma 3n vision encoder is GPU-only by model design and the engine
  /// double-instantiates vision sessions, which exceeds the iOS jetsam limit.
  /// Prescription parsing on iOS uses the ML Kit OCR → text-only Gemma tier;
  /// the direct image tier stays enabled on Android.
  static bool get supportsVision => !Platform.isIOS;

  /// Minimum characters of OCR output to trust the text tier; anything less
  /// (e.g. handwriting the OCR can't read) falls through to the vision tier
  /// on devices that support it.
  static const int minOcrTextChars = 40;

  /// Hard cap per LLM extraction attempt. CPU inference on low-RAM phones
  /// can take many minutes; past this we fall back to the rule-based parser
  /// so the user is never stuck on a spinner.
  static const Duration parseResponseTimeout = Duration(seconds: 60);

  /// Smaller context on iOS shrinks the per-session KV-cache; the engine
  /// creates two native sessions for vision, so this counts double.
  static int get parseMaxTokens => Platform.isIOS ? 2048 : 3072;
  static const int doubtMaxTokens = 1024;
  static const double parseTemperature = 0.1;
  static const int parseTopK = 1;
  static const double lowConfidenceThreshold = 0.7;
  static const Duration maxRecordingDuration = Duration(seconds: 30);
}
