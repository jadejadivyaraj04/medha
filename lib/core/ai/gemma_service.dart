// lib/core/ai/gemma_service.dart

import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:io' show FileSystemException;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show DioException, DioExceptionType;
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:get/get.dart';

import '../../app/app_config.dart';
import '../mock/mock_constants.dart';
import '../models/medicine_model.dart';
import '../network/error_detail_wrapper.dart';
import '../scan/prescription_ocr_service.dart';
import '../scan/prescription_text_parser.dart';
import 'audio_converter.dart';
import 'gemma_config.dart';
import 'resumable_model_downloader.dart';

/// On-device AI gateway — all flutter_gemma calls go through this service.
class GemmaService extends GetxService {
  final isModelReady = false.obs;
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;
  final downloadErrorMessage = ''.obs;
  final isParsing = false.obs;
  final isAnsweringDoubt = false.obs;

  final _downloader = ResumableModelDownloader();
  final _ocrService = PrescriptionOcrService();
  Future<void>? _pluginInitFuture;
  InferenceModel? _cachedVisionModel;
  InferenceModel? _cachedAudioModel;

  static const _doubtSystemInstruction = '''
You are Medha — an offline, private medicine reminder helper for elderly users in India.
The user speaks a short voice question about their medicines or schedule.

Rules:
- Answer calmly in simple language (match Gujarati, Hindi, or English if obvious from context).
- Use ONLY the active medicine list provided below — do not invent medicines.
- Do NOT diagnose, change doses, or replace a doctor.
- If the question needs medical judgment, say to call their doctor.
- Keep answers under 4 short sentences.
- End with a gentle reminder that Medha is AI, not a doctor.
''';

  static const _audioQueryHint =
      'Listen to my voice question about my medicines and answer clearly.';

  static const _extractionPrompt = '''
You are a prescription reading assistant for Medha (offline, private).
Extract ONLY medicines explicitly written on the prescription image.
Do NOT diagnose, suggest dose changes, or invent medicines.

Indian prescription conventions:
- Frequency means morning-afternoon-night, e.g. "1-0-1" = morning and night.
- OD / once daily = "1-0-0". BD / BID / twice daily = "1-0-1".
  TDS / TID / thrice daily = "1-1-1". HS / at bedtime = "0-0-1".
  SOS / PRN (as needed): use "0-0-0" and flag "frequency" as low confidence.
- "Tab" / "Cap" / "Syp" prefixes are dosage forms, not part of the name.
- Strength may be written 500mg / 500 mg / 0.5g — report it in milligrams.
- Duration may be written "x 5 days", "5/7" (= 5 days), "1 month" (= 30 days).
- Copy each medicine name exactly as written (brand names are fine).

Return ONLY valid JSON (no markdown fences, no commentary) matching:
{
  "medicines": [
    {
      "name": "string",
      "dosage_mg": number or null,
      "frequency": "1-0-1 style morning-afternoon-night",
      "with_food": "before|after|any",
      "duration_days": number,
      "confidence": 0.0 to 1.0,
      "low_confidence_fields": ["field names you are unsure about"]
    }
  ]
}

Rules:
- If a field is unclear, add its key to low_confidence_fields and set confidence below 0.7.
- Use snake_case keys exactly as shown.
- If nothing is readable, return {"medicines": []}.
''';

  static const _extractionQuery =
      'Read this prescription photo and return the medicines JSON now.';

  /// Text-tier variant: the input is OCR output, not an image, so the model
  /// must also repair obvious OCR artifacts in medicine names.
  static const _textExtractionPrompt = '''
You are a prescription reading assistant for Medha (offline, private).
You receive raw OCR text extracted from a photo of a doctor's prescription.
The OCR may contain recognition errors, broken lines, clinic letterhead, and
unrelated phone/computer UI fragments (browser tabs, social media buttons).
Extract ONLY the medicines from it. Do NOT diagnose or invent medicines.
Ignore letterhead, doctor/patient names, dates, diagnoses, and UI text.
Precision matters more than completeness: never output a lone dosage form
(like "Syp") or a UI fragment as a medicine. If you are not reasonably sure
a line is a medicine, leave it out.

Indian prescription conventions:
- Frequency means morning-afternoon-night, e.g. "1-0-1" = morning and night.
- OD / once daily = "1-0-0". BD / BID / twice daily = "1-0-1".
  TDS / TID / thrice daily = "1-1-1". HS / at bedtime = "0-0-1".
  SOS / PRN (as needed): use "0-0-0" and flag "frequency" as low confidence.
- "Tab" / "Cap" / "Syp" prefixes are dosage forms, not part of the name.
- Strength may be written 500mg / 500 mg / 0.5g — report it in milligrams.
- Duration may be written "x 5 days", "5/7" (= 5 days), "1 month" (= 30 days).
- Fix obvious OCR mistakes in medicine names (e.g. "Cr0cin" is "Crocin"),
  but if unsure, keep the OCR spelling and flag "name" as low confidence.

Return ONLY valid JSON (no markdown fences, no commentary) matching:
{
  "medicines": [
    {
      "name": "string",
      "dosage_mg": number or null,
      "frequency": "1-0-1 style morning-afternoon-night",
      "with_food": "before|after|any",
      "duration_days": number,
      "confidence": 0.0 to 1.0,
      "low_confidence_fields": ["field names you are unsure about"]
    }
  ]
}

Rules:
- If a field is unclear, add its key to low_confidence_fields and set confidence below 0.7.
- Use snake_case keys exactly as shown.
- If no medicines are readable, return {"medicines": []}.
''';

  static const _extractionRetryQuery =
      'That reply was not valid JSON. Reply again with ONLY the JSON object '
      'in the exact schema you were given — no markdown, no explanation.';

  @override
  void onInit() {
    super.onInit();
    _ensurePluginInitialized();
  }

  @override
  void onClose() {
    cancelModelDownload();
    disposeModel();
    super.onClose();
  }

  Future<void> _ensurePluginInitialized() async {
    _pluginInitFuture ??= FlutterGemma.initialize();
    await _pluginInitFuture;
    if (FlutterGemma.hasActiveModel()) {
      isModelReady.value = true;
    }
  }

  /// Downloads (if needed) and activates the on-device Gemma 3n model.
  Future<Either<ErrorDetailWrapper, void>> installModel({
    String? modelUrl,
    String? huggingFaceToken,
  }) async {
    await _ensurePluginInitialized();

    if (isDownloading.value) {
      return Left(
        ErrorDetailWrapper.unknown('A model download is already in progress.'),
      );
    }

    downloadErrorMessage.value = '';
    isDownloading.value = true;
    downloadProgress.value = 0.0;

    try {
      // Resumable download: an interrupted run keeps its .part file and the
      // next attempt continues from that byte offset instead of restarting.
      final path = await _downloader.download(
        url: modelUrl ?? GemmaConfig.defaultModelUrl,
        authToken: huggingFaceToken ?? GemmaConfig.huggingFaceToken,
        onProgress: (progress) {
          downloadProgress.value = progress * 0.98;
        },
      );

      await FlutterGemma.installModel(
        modelType: GemmaConfig.modelType,
        fileType: GemmaConfig.fileType,
      ).fromFile(path).install();

      downloadProgress.value = 1.0;
      isModelReady.value = true;
      return const Right(null);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        downloadErrorMessage.value = 'Download cancelled.';
        return Left(ErrorDetailWrapper.unknown('Download cancelled.'));
      }
      downloadErrorMessage.value = 'Could not download the on-device AI model.';
      return Left(ErrorDetailWrapper.unknown(e.message ?? e.toString()));
    } on FileSystemException catch (e) {
      // ENOSPC — the 3.4 GB model needs roughly 4 GB free.
      final isDiskFull = e.osError?.errorCode == 28;
      final message = isDiskFull
          ? 'Not enough free storage on this device. '
              'Free up about 4 GB and tap Retry — the download will '
              'continue from where it stopped.'
          : 'Could not save the AI model file: '
              '${e.osError?.message ?? e.message}';
      downloadErrorMessage.value = message;
      return Left(ErrorDetailWrapper.unknown(message));
    } catch (e) {
      downloadErrorMessage.value = 'Could not download the on-device AI model.';
      return Left(ErrorDetailWrapper.unknown(e.toString()));
    } finally {
      isDownloading.value = false;
    }
  }

  /// Whether the on-device model is installed and usable right now.
  Future<bool> isModelInstalled() async {
    await _ensurePluginInitialized();
    return FlutterGemma.hasActiveModel();
  }

  Future<Either<ErrorDetailWrapper, void>> ensureModelInstalled({
    String? modelUrl,
    String? huggingFaceToken,
  }) async {
    await _ensurePluginInitialized();
    if (FlutterGemma.hasActiveModel() || isModelReady.value) {
      isModelReady.value = true;
      return const Right(null);
    }
    return installModel(
      modelUrl: modelUrl,
      huggingFaceToken: huggingFaceToken,
    );
  }

  /// Splash/onboarding entry — simulates download in mock mode.
  Future<Either<ErrorDetailWrapper, void>> installModelForOnboarding() async {
    await _ensurePluginInitialized();
    if (AppConfig.isMock) {
      return _simulateModelInstall();
    }
    return ensureModelInstalled();
  }

  Future<Either<ErrorDetailWrapper, void>> _simulateModelInstall() async {
    if (isDownloading.value) {
      return const Right(null);
    }
    downloadErrorMessage.value = '';
    isDownloading.value = true;
    downloadProgress.value = 0.0;
    try {
      for (var step = 1; step <= 10; step++) {
        await Future<void>.delayed(const Duration(milliseconds: 220));
        downloadProgress.value = step / 10;
      }
      isModelReady.value = true;
      return const Right(null);
    } catch (e) {
      downloadErrorMessage.value = 'Could not set up the on-device AI model.';
      return Left(ErrorDetailWrapper.unknown(e.toString()));
    } finally {
      isDownloading.value = false;
    }
  }

  void cancelModelDownload() {
    _downloader.cancel();
  }

  /// Returns a warm vision-capable model instance (kept loaded across screens).
  Future<Either<ErrorDetailWrapper, InferenceModel>> getActiveModel({
    int? maxTokens,
    PreferredBackend? preferredBackend,
    bool? supportImage,
    int maxNumImages = 1,
  }) async {
    maxTokens ??= GemmaConfig.parseMaxTokens;
    preferredBackend ??= GemmaConfig.preferredBackend;
    // Loading vision resources at model level costs hundreds of MB; skip it
    // entirely on devices that only use the OCR text tier.
    supportImage ??= GemmaConfig.supportsVision;
    await _ensurePluginInitialized();

    if (!FlutterGemma.hasActiveModel()) {
      return Left(
        ErrorDetailWrapper.unknown(
          'On-device AI model is not installed yet.',
        ),
      );
    }

    try {
      if (_cachedVisionModel != null) {
        return Right(_cachedVisionModel!);
      }

      final model = await FlutterGemma.getActiveModel(
        maxTokens: maxTokens,
        preferredBackend: preferredBackend,
        supportImage: supportImage,
        maxNumImages: maxNumImages,
      );
      _cachedVisionModel = model;
      isModelReady.value = true;
      return Right(model);
    } catch (e) {
      return Left(ErrorDetailWrapper.unknown(e.toString()));
    }
  }

  /// Prescription → [MedicineModel] list, via a two-tier strategy:
  ///
  /// 1. ML Kit OCR + text-only Gemma — light enough for every device (the
  ///    GPU-only vision encoder never loads).
  /// 2. Direct Gemma vision parse — only where the hardware allows it
  ///    ([GemmaConfig.supportsVision]), as a fallback for photos whose text
  ///    the OCR cannot read (e.g. handwriting).
  Future<Either<ErrorDetailWrapper, List<MedicineModel>>> parsePrescription(
    Uint8List imageBytes, {
    String? imagePath,
  }) async {
    if (imageBytes.isEmpty) {
      return Left(ErrorDetailWrapper.unknown('Prescription image is empty.'));
    }

    if (isParsing.value) {
      return Left(
        ErrorDetailWrapper.unknown(
          'The previous scan is still being processed. Please wait a moment '
          'and try again.',
        ),
      );
    }

    if (!_isModelAvailableForInference()) {
      if (AppConfig.isMock) {
        return Right(await _mockParsePrescription());
      }
      return Left(
        ErrorDetailWrapper.unknown(
          'On-device AI model is not ready. Complete setup first.',
        ),
      );
    }

    isParsing.value = true;

    try {
      final modelResult = await getActiveModel();
      InferenceModel? model;
      ErrorDetailWrapper? modelError;
      modelResult.fold(
        (error) => modelError = error,
        (loaded) => model = loaded,
      );

      if (model == null) {
        if (AppConfig.isMock) {
          return Right(await _mockParsePrescription());
        }
        return Left(modelError!);
      }

      List<MedicineModel>? medicines;
      var ocrText = '';

      if (imagePath != null) {
        // Strip UI/letterhead noise so neither tier wastes effort (or
        // hallucinates medicines) on browser chrome and clinic headers.
        ocrText = PrescriptionTextParser.cleanOcrText(
          await _ocrService.extractText(imagePath),
        );
        if (ocrText.trim().length >= GemmaConfig.minOcrTextChars) {
          medicines = await _extractMedicines(model!, ocrText: ocrText);
        }
      }

      if ((medicines == null || medicines.isEmpty) &&
          GemmaConfig.supportsVision) {
        medicines = await _extractMedicines(model!, imageBytes: imageBytes);
      }

      // Bottom tier: instant rule-based parse of the OCR text, so slow or
      // failed LLM extraction still yields editable rows instead of nothing.
      if (medicines == null || medicines.isEmpty) {
        final ruleBased = PrescriptionTextParser.parse(ocrText)
            .map(_applyConfidenceRules)
            .toList();
        if (ruleBased.isNotEmpty) {
          return Right(ruleBased);
        }
      }

      if (medicines == null) {
        if (AppConfig.isMock) {
          return Right(await _mockParsePrescription(lowConfidence: true));
        }
        return Right(_lowConfidenceFallback());
      }

      if (medicines.isEmpty && AppConfig.isMock) {
        return Right(await _mockParsePrescription());
      }

      return Right(medicines);
    } catch (e) {
      if (AppConfig.isMock) {
        return Right(await _mockParsePrescription(lowConfidence: true));
      }
      return Left(ErrorDetailWrapper.unknown(e.toString()));
    } finally {
      isParsing.value = false;
    }
  }

  /// One extraction round-trip (with a single corrective retry on malformed
  /// JSON). Pass [imageBytes] for the vision tier or [ocrText] for the text
  /// tier — the text tier creates the chat without image support, so the
  /// GPU-only vision encoder stays unloaded.
  Future<List<MedicineModel>?> _extractMedicines(
    InferenceModel model, {
    String? ocrText,
    Uint8List? imageBytes,
  }) async {
    final useVision = imageBytes != null;

    final chat = await model.createChat(
      modelType: GemmaConfig.modelType,
      supportImage: useVision,
      temperature: GemmaConfig.parseTemperature,
      topK: GemmaConfig.parseTopK,
      systemInstruction: useVision ? _extractionPrompt : _textExtractionPrompt,
    );

    await chat.addQueryChunk(
      useVision
          ? Message.withImage(
              text: _extractionQuery,
              imageBytes: imageBytes,
              isUser: true,
            )
          : Message(
              text: 'OCR text from the prescription:\n$ocrText\n\n'
                  'Return the medicines JSON now.',
              isUser: true,
            ),
    );

    // The timeout abandons the native generation (it finishes in the
    // background) so the flow can fall back to the rule-based parser
    // instead of pinning the user to an endless spinner.
    try {
      final response = await chat
          .generateChatResponse()
          .timeout(GemmaConfig.parseResponseTimeout);
      var medicines = _parseStrictJson(_responseText(response));

      if (medicines == null) {
        await chat.addQueryChunk(
          Message(text: _extractionRetryQuery, isUser: true),
        );
        final retryResponse = await chat
            .generateChatResponse()
            .timeout(GemmaConfig.parseResponseTimeout);
        medicines = _parseStrictJson(_responseText(retryResponse));
      }

      return medicines;
    } on TimeoutException {
      debugPrint('GemmaService: extraction timed out — using fallback tier');
      // The native engine keeps generating after an abandoned future and
      // rejects any new query until it finishes — stop it explicitly or the
      // next scan fails with "AddQueryChunk before PredictDone".
      try {
        await chat.stopGeneration();
      } catch (e) {
        debugPrint('GemmaService: stopGeneration failed — $e');
      }
      try {
        await chat.session.close();
      } catch (e) {
        debugPrint('GemmaService: session close failed — $e');
      }
      return null;
    }
  }

  Future<void> disposeModel() async {
    final visionModel = _cachedVisionModel;
    final audioModel = _cachedAudioModel;
    _cachedVisionModel = null;
    _cachedAudioModel = null;
    if (visionModel != null) {
      await visionModel.close();
    }
    if (audioModel != null) {
      await audioModel.close();
    }
    isModelReady.value = FlutterGemma.hasActiveModel();
  }

  /// Offline voice doubt — Gemma 3n audio input → plain-language answer.
  Future<Either<ErrorDetailWrapper, String>> answerAudioDoubt(
    Uint8List audioBytes, {
    String medicineContext = '',
  }) async {
    if (audioBytes.isEmpty) {
      return Left(ErrorDetailWrapper.unknown('doubt.error_empty_audio'.tr));
    }

    if (!_isModelAvailableForInference()) {
      if (AppConfig.isMock) {
        return Right(await _mockDoubtAnswer(medicineContext));
      }
      return Left(
        ErrorDetailWrapper.unknown(
          'On-device AI model is not ready. Complete setup first.',
        ),
      );
    }

    isAnsweringDoubt.value = true;

    try {
      final prepared = AudioConverter.prepareForGemma(audioBytes);
      final modelResult = await getActiveAudioModel();
      InferenceModel? model;
      ErrorDetailWrapper? modelError;
      modelResult.fold(
        (error) => modelError = error,
        (loaded) => model = loaded,
      );

      if (model == null) {
        if (AppConfig.isMock) {
          return Right(await _mockDoubtAnswer(medicineContext));
        }
        return Left(modelError!);
      }

      final systemInstruction = _buildDoubtSystemInstruction(medicineContext);
      final chat = await model!.createChat(
        modelType: GemmaConfig.modelType,
        supportAudio: true,
        systemInstruction: systemInstruction,
      );

      await chat.addQueryChunk(
        Message.withAudio(
          text: _audioQueryHint,
          audioBytes: prepared,
          isUser: true,
        ),
      );

      final response = await chat.generateChatResponse();
      final answer = _finalizeDoubtAnswer(_responseText(response));

      if (answer.isEmpty) {
        if (AppConfig.isMock) {
          return Right(await _mockDoubtAnswer(medicineContext));
        }
        return Left(ErrorDetailWrapper.unknown('doubt.error_empty_answer'.tr));
      }

      return Right(answer);
    } catch (e) {
      if (AppConfig.isMock) {
        return Right(await _mockDoubtAnswer(medicineContext));
      }
      return Left(ErrorDetailWrapper.unknown(e.toString()));
    } finally {
      isAnsweringDoubt.value = false;
    }
  }

  Future<Either<ErrorDetailWrapper, InferenceModel>> getActiveAudioModel({
    int maxTokens = GemmaConfig.doubtMaxTokens,
    PreferredBackend? preferredBackend,
  }) async {
    preferredBackend ??= GemmaConfig.preferredBackend;
    await _ensurePluginInitialized();

    if (!FlutterGemma.hasActiveModel()) {
      return Left(
        ErrorDetailWrapper.unknown(
          'On-device AI model is not installed yet.',
        ),
      );
    }

    try {
      if (_cachedAudioModel != null) {
        return Right(_cachedAudioModel!);
      }

      final model = await FlutterGemma.getActiveModel(
        maxTokens: maxTokens,
        preferredBackend: preferredBackend,
        supportImage: false,
        supportAudio: true,
      );
      _cachedAudioModel = model;
      isModelReady.value = true;
      return Right(model);
    } catch (e) {
      return Left(ErrorDetailWrapper.unknown(e.toString()));
    }
  }

  String _buildDoubtSystemInstruction(String medicineContext) {
    final localeHint = _localeAnswerHint();
    final base = '$_doubtSystemInstruction\n$localeHint';
    if (medicineContext.trim().isEmpty) {
      return base;
    }
    return '$base\n\nActive medicines on this phone:\n$medicineContext';
  }

  String _localeAnswerHint() {
    return switch (Get.locale?.languageCode) {
      'gu' => 'Reply in simple Gujarati unless the user clearly spoke English.',
      'hi' => 'Reply in simple Hindi unless the user clearly spoke English.',
      _ => 'Reply in simple English unless the user clearly spoke Gujarati or Hindi.',
    };
  }

  String _finalizeDoubtAnswer(String raw) {
    final answer = raw.trim();
    if (answer.isEmpty) {
      return answer;
    }

    final disclaimer = 'scan.disclaimer'.tr;
    final lower = answer.toLowerCase();
    if (lower.contains('not a doctor') ||
        lower.contains('doctor nahi') ||
        answer.contains('ડૉક્ટર નથી') ||
        answer.contains('डॉक्टर नहीं')) {
      return answer;
    }

    return '$answer. $disclaimer';
  }

  Future<String> _mockDoubtAnswer(String medicineContext) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final base = medicineContext.trim().isEmpty
        ? 'doubt.mock_answer_no_meds'.tr
        : 'doubt.mock_answer_with_meds'.tr;
    return _finalizeDoubtAnswer(base);
  }

  bool _isModelAvailableForInference() =>
      isModelReady.value || FlutterGemma.hasActiveModel();

  String _responseText(ModelResponse response) {
    return switch (response) {
      TextResponse(:final token) => token,
      ThinkingResponse(:final content) => content,
      _ => response.toString(),
    };
  }

  /// Returns the parsed medicines, or null when the response is not the
  /// expected JSON shape (caller retries once before falling back).
  List<MedicineModel>? _parseStrictJson(String raw) {
    try {
      final jsonString = _extractJsonPayload(raw);
      final decoded = json.decode(jsonString);
      final items = decoded is Map<String, dynamic>
          ? decoded['medicines']
          : decoded;

      if (items is! List) {
        return null;
      }

      final medicines = <MedicineModel>[];
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (item is! Map<String, dynamic>) {
          continue;
        }
        final medicine = MedicineModel.fromExtractionJson(
          item,
          id: 'rx_${DateTime.now().millisecondsSinceEpoch}_$i',
        );
        medicines.add(_applyConfidenceRules(medicine));
      }

      return medicines;
    } catch (e) {
      debugPrint('GemmaService: strict JSON parse failed — $e');
      return null;
    }
  }

  MedicineModel _applyConfidenceRules(MedicineModel medicine) {
    final flagged = <String>{...medicine.lowConfidenceFields};

    if (medicine.name.trim().isEmpty) {
      flagged.add('name');
    }
    if (medicine.frequency.trim().isEmpty ||
        !MedicineModel.isCanonicalFrequency(medicine.frequency)) {
      flagged.add('frequency');
    }
    if (medicine.durationDays <= 0) {
      flagged.add('durationDays');
    }
    if (medicine.confidence < GemmaConfig.lowConfidenceThreshold) {
      if (medicine.name.isNotEmpty) {
        flagged.add('name');
      }
      if (medicine.dosageMg == null) {
        flagged.add('dosageMg');
      }
    }

    final adjustedConfidence = flagged.isEmpty
        ? medicine.confidence.clamp(0.0, 1.0)
        : medicine.confidence.clamp(0.0, GemmaConfig.lowConfidenceThreshold);

    return medicine.copyWith(
      confidence: adjustedConfidence,
      lowConfidenceFields: flagged,
    );
  }

  List<MedicineModel> _lowConfidenceFallback() {
    return [
      MedicineModel(
        id: 'rx_fallback_${DateTime.now().millisecondsSinceEpoch}',
        name: '',
        frequency: '',
        withFood: 'any',
        durationDays: 0,
        confidence: 0.0,
        lowConfidenceFields: const {
          'name',
          'dosageMg',
          'frequency',
          'withFood',
          'durationDays',
        },
      ),
    ];
  }

  String _extractJsonPayload(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return trimmed;
    }

    final fenceMatch = RegExp(
      r'```(?:json)?\s*([\s\S]*?)```',
      multiLine: true,
    ).firstMatch(trimmed);
    if (fenceMatch != null) {
      return fenceMatch.group(1)!.trim();
    }

    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return trimmed.substring(start, end + 1);
    }

    throw const FormatException('No JSON object found in model response');
  }

  Future<List<MedicineModel>> _mockParsePrescription({
    bool lowConfidence = false,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);

    if (lowConfidence) {
      return _lowConfidenceFallback();
    }

    return [
      const MedicineModel(
        id: 'm1',
        name: 'Crocin 500',
        dosageMg: 500,
        frequency: '1-0-1',
        withFood: 'after',
        durationDays: 5,
        confidence: 0.92,
      ),
      const MedicineModel(
        id: 'm2',
        name: 'Pan-D 40',
        dosageMg: 40,
        frequency: '1-0-0',
        withFood: 'before',
        durationDays: 14,
        confidence: 0.58,
        lowConfidenceFields: {'dosageMg', 'frequency'},
      ),
    ];
  }
}
