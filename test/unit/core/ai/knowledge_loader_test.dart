// test/unit/core/ai/knowledge_loader_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:medha/core/ai/knowledge/knowledge_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await KnowledgeLoader.load();
  });

  test('loads corpus entries', () async {
    await KnowledgeLoader.load();
    expect(KnowledgeLoader.corpusVersion, '1.0.0');
  });

  test('has interaction documents', () {
    final count = KnowledgeLoader.allDocuments()
        .where((doc) => doc.id.startsWith('interaction_'))
        .length;
    expect(count, greaterThan(0));
  });

  test('findInteractions_exact_pair_names', () {
    final results = KnowledgeLoader.findInteractions([
      'paracetamol',
      'warfarin',
    ]);
    expect(results, isNotEmpty);
  });

  test('findInteractions_crocin_warfarin', () {
    final results = KnowledgeLoader.findInteractions([
      'Crocin 500',
      'Warfarin',
    ]);
    expect(results, isNotEmpty);
    expect(results.first.severity.name, 'major');
  });
}
