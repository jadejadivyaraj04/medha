// lib/core/ai/vector_indexer.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';

import 'knowledge/knowledge_entry.dart';
import 'rag_config.dart';

/// Embeds knowledge documents into flutter_gemma's SQLite vector store.
class VectorIndexer {
  VectorIndexer({FlutterGemmaPlugin? plugin})
      : _plugin = plugin ?? FlutterGemmaPlugin.instance;

  final FlutterGemmaPlugin _plugin;

  Future<String> databasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/${RagConfig.vectorDbFileName}';
  }

  Future<bool> hasDocuments() async {
    try {
      final stats = await _plugin.getVectorStoreStats();
      return stats.documentCount > 0;
    } catch (_) {
      return false;
    }
  }

  Future<void> initializeStore() async {
    final path = await databasePath();
    await _plugin.initializeVectorStore(path);
    _plugin.enableHnsw = false;
  }

  Future<void> clearStore() async {
    try {
      await _plugin.clearVectorStore();
    } catch (_) {
      // Store may not exist yet.
    }
  }

  Future<void> indexDocuments({
    required List<KnowledgeDocument> documents,
    void Function(double progress)? onProgress,
  }) async {
    if (documents.isEmpty) {
      onProgress?.call(1);
      return;
    }

    final embedder = _plugin.initializedEmbeddingModel;
    if (embedder == null) {
      throw StateError('embedding_model_not_ready');
    }

    await initializeStore();
    await clearStore();

    const batchSize = 8;
    var processed = 0;

    for (var start = 0; start < documents.length; start += batchSize) {
      final end = (start + batchSize > documents.length)
          ? documents.length
          : start + batchSize;
      final batch = documents.sublist(start, end);
      final contents = batch.map((doc) => doc.content).toList();

      final embeddings = await embedder.generateEmbeddings(
        contents,
        taskType: TaskType.retrievalDocument,
      );

      for (var i = 0; i < batch.length; i++) {
        await _plugin.addDocumentWithEmbedding(
          id: batch[i].id,
          content: batch[i].content,
          embedding: embeddings[i],
          metadata: batch[i].metadataJson,
        );
      }

      processed = end;
      onProgress?.call(processed / documents.length);
    }

    onProgress?.call(1);
  }

  Future<List<RetrievalResult>> search({
    required String query,
    int topK = RagConfig.searchTopK,
    double threshold = RagConfig.nameMatchThreshold,
  }) async {
    try {
      return await _plugin.searchSimilar(
        query: query,
        topK: topK,
        threshold: threshold,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('VectorIndexer.search failed: $e');
      }
      return [];
    }
  }
}
