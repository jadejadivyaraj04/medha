// lib/core/ai/rag_config.dart

/// RAG / EmbeddingGemma configuration for Medha on-device knowledge lookup.
class RagConfig {
  RagConfig._();

  /// Bump when [medha_knowledge_corpus.json] changes to trigger re-indexing.
  static const corpusVersion = '1.0.0';

  static const vectorDbFileName = 'medha_knowledge_vectors.db';

  /// Cosine similarity floor for medicine-name resolution via vector search.
  static const nameMatchThreshold = 0.42;

  static const searchTopK = 3;

  /// EmbeddingGemma 4-bit — smaller download than full 300M.
  static const embedderModelUrl =
      'https://huggingface.co/google/embeddinggemma-300m-4bit/resolve/main/model.tflite';

  static const embedderTokenizerUrl =
      'https://huggingface.co/google/embeddinggemma-300m-4bit/resolve/main/sentencepiece.model';

  /// iOS requires tokenizer.json (sentencepiece conflicts with protobuf on iOS).
  static const embedderIosTokenizerUrl =
      'https://huggingface.co/google/embeddinggemma-300m-4bit/resolve/main/tokenizer.json';
}
