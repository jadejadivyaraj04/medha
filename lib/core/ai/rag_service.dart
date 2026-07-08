// lib/core/ai/rag_service.dart

import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:get/get.dart';

import '../models/drug_interaction_model.dart';
import '../models/generic_alternative_model.dart';
import '../models/side_effect_model.dart';
import '../network/error_detail_wrapper.dart';
import '../storage/storage_manager.dart';
import 'knowledge/knowledge_entry.dart';
import 'knowledge/knowledge_loader.dart';
import 'rag_config.dart';
import 'vector_indexer.dart';

/// On-device RAG — EmbeddingGemma vector store with bundled-corpus fallback.
class RagService extends GetxService {
  RagService({VectorIndexer? indexer}) : _indexer = indexer ?? VectorIndexer();

  final isReady = false.obs;
  final isIndexing = false.obs;
  final indexProgress = 0.0.obs;
  final indexStatusMessage = ''.obs;
  final usesVectorSearch = false.obs;

  final VectorIndexer _indexer;
  Future<void>? _initInProgress;

  @override
  void onInit() {
    super.onInit();
    _ensurePluginInitialized();
  }

  Future<void> _ensurePluginInitialized() async {
    try {
      await FlutterGemma.initialize();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RagService: FlutterGemma.initialize failed: $e');
      }
    }
  }

  /// Loads corpus and builds the vector index on first run when embedder is ready.
  Future<Either<ErrorDetailWrapper, void>> initialize({
    String? huggingFaceToken,
  }) async {
    if (isReady.value) {
      return const Right(null);
    }

    if (_initInProgress != null) {
      await _initInProgress;
      return const Right(null);
    }

    _initInProgress = _runInitialize(huggingFaceToken: huggingFaceToken);
    try {
      await _initInProgress;
      return const Right(null);
    } catch (e) {
      isReady.value = true;
      return Left(ErrorDetailWrapper.unknown(e.toString()));
    } finally {
      _initInProgress = null;
    }
  }

  Future<void> _runInitialize({String? huggingFaceToken}) async {
    isIndexing.value = true;
    indexProgress.value = 0;
    indexStatusMessage.value = 'rag.indexing_loading'.tr;

    try {
      await KnowledgeLoader.load();

      final embedderReady = await _ensureEmbedder(huggingFaceToken: huggingFaceToken);
      usesVectorSearch.value = false;

      if (embedderReady) {
        final needsIndex = !_isVectorIndexCurrent();
        if (needsIndex) {
          indexStatusMessage.value = 'rag.indexing_embedding'.tr;
          await _buildVectorIndex();
          usesVectorSearch.value = true;
          await StorageManager.saveRagCorpusVersion(RagConfig.corpusVersion);
          await StorageManager.setRagVectorIndexed(value: true);
        } else {
          await _indexer.initializeStore();
          usesVectorSearch.value = await _indexer.hasDocuments();
        }
      } else {
        indexStatusMessage.value = 'rag.indexing_fallback'.tr;
      }

      isReady.value = true;
      indexProgress.value = 1;
      indexStatusMessage.value = usesVectorSearch.value
          ? 'rag.indexing_ready_vector'.tr
          : 'rag.indexing_ready_corpus'.tr;
    } catch (e) {
      isReady.value = true;
      usesVectorSearch.value = false;
      indexStatusMessage.value = 'rag.indexing_fallback'.tr;
      if (kDebugMode) {
        debugPrint('RagService initialize error (corpus fallback active): $e');
      }
    } finally {
      isIndexing.value = false;
    }
  }

  bool _isVectorIndexCurrent() {
    return StorageManager.isRagVectorIndexed &&
        StorageManager.getRagCorpusVersion() == RagConfig.corpusVersion;
  }

  Future<bool> _ensureEmbedder({String? huggingFaceToken}) async {
    await _ensurePluginInitialized();

    if (FlutterGemma.hasActiveEmbedder() ||
        FlutterGemmaPlugin.instance.initializedEmbeddingModel != null) {
      return true;
    }

    if (huggingFaceToken == null || huggingFaceToken.trim().isEmpty) {
      return false;
    }

    try {
      indexStatusMessage.value = 'rag.indexing_embedder'.tr;
      await FlutterGemma.installEmbedder()
          .modelFromNetwork(RagConfig.embedderModelUrl, token: huggingFaceToken)
          .tokenizerFromNetwork(
            RagConfig.embedderTokenizerUrl,
            token: huggingFaceToken,
            iosPath: RagConfig.embedderIosTokenizerUrl,
            iosToken: huggingFaceToken,
          )
          .withModelProgress((progress) {
            indexProgress.value = progress / 200;
          })
          .withTokenizerProgress((progress) {
            indexProgress.value = 0.5 + (progress / 200);
          })
          .install();

      await FlutterGemma.getActiveEmbedder(
        preferredBackend: PreferredBackend.cpu,
      );
      return FlutterGemma.hasActiveEmbedder();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RagService: embedder install failed: $e');
      }
      return false;
    }
  }

  Future<void> _buildVectorIndex() async {
    final documents = KnowledgeLoader.allDocuments();
    await _indexer.indexDocuments(
      documents: documents,
      onProgress: (progress) {
        indexProgress.value = progress;
      },
    );
  }

  Future<Either<ErrorDetailWrapper, SideEffectModel?>> getSideEffects(
    String medicineName,
  ) async {
    if (medicineName.trim().isEmpty) {
      return const Right(null);
    }

    final ready = await _ensureLoaded();
    return await ready.fold(
      (error) async => Left<ErrorDetailWrapper, SideEffectModel?>(error),
      (_) async {
        final resolved = await _resolveMedicineName(medicineName);
        return Right(KnowledgeLoader.findSideEffects(resolved ?? medicineName));
      },
    );
  }

  Future<Either<ErrorDetailWrapper, List<DrugInteractionModel>>> findInteractions(
    List<String> medicineNames,
  ) async {
    if (medicineNames.isEmpty) {
      return const Right([]);
    }

    final ready = await _ensureLoaded();
    return await ready.fold(
      (error) async => Left<ErrorDetailWrapper, List<DrugInteractionModel>>(error),
      (_) async {
        final resolved = <String>[];
        for (final name in medicineNames) {
          final trimmed = name.trim();
          if (trimmed.isEmpty) {
            continue;
          }
          resolved.add(await _resolveMedicineName(trimmed) ?? trimmed);
        }
        return Right(KnowledgeLoader.findInteractions(resolved));
      },
    );
  }

  Future<Either<ErrorDetailWrapper, List<KnowledgeFoodRuleEntry>>> getFoodRules(
    String medicineName,
  ) async {
    if (medicineName.trim().isEmpty) {
      return const Right([]);
    }

    final ready = await _ensureLoaded();
    return await ready.fold(
      (error) async =>
          Left<ErrorDetailWrapper, List<KnowledgeFoodRuleEntry>>(error),
      (_) async {
        final resolved = await _resolveMedicineName(medicineName);
        return Right(KnowledgeLoader.findFoodRules(resolved ?? medicineName));
      },
    );
  }

  Future<Either<ErrorDetailWrapper, GenericAlternativeModel?>> getGenericAlternatives(
    String medicineName,
  ) async {
    if (medicineName.trim().isEmpty) {
      return const Right(null);
    }

    final ready = await _ensureLoaded();
    return await ready.fold(
      (error) async =>
          Left<ErrorDetailWrapper, GenericAlternativeModel?>(error),
      (_) async {
        final resolved = await _resolveMedicineName(medicineName);
        return Right(
          KnowledgeLoader.findGenericAlternatives(resolved ?? medicineName),
        );
      },
    );
  }

  Future<String?> _resolveMedicineName(String rawName) async {
    if (!usesVectorSearch.value) {
      return null;
    }

    final results = await _indexer.search(
      query: '$rawName indian medicine drug',
      topK: 1,
      threshold: RagConfig.nameMatchThreshold,
    );

    if (results.isEmpty) {
      return null;
    }

    final metadata = _parseMetadata(results.first.metadata);
    final medicine = metadata['medicine']?.toString();
    if (medicine != null && medicine.isNotEmpty) {
      return medicine;
    }

    final drugA = metadata['drug_a']?.toString() ?? '';
    final drugB = metadata['drug_b']?.toString() ?? '';
    if (drugA.isNotEmpty || drugB.isNotEmpty) {
      final probe = KnowledgeLoader.findInteractions([rawName, drugA, drugB]);
      if (probe.isNotEmpty) {
        return drugA.isNotEmpty ? drugA : drugB;
      }
    }

    return null;
  }

  Map<String, dynamic> _parseMetadata(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return {};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Ignore malformed metadata.
    }
    return {};
  }

  Future<Either<ErrorDetailWrapper, void>> _ensureLoaded() async {
    if (isReady.value) {
      return const Right(null);
    }
    return initialize();
  }
}
