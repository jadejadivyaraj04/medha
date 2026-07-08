// lib/core/scan/medicine_name_validator.dart

/// Validates OCR-extracted medicine name candidates against a bundled list
/// of common Indian brand and generic names, with fuzzy matching to absorb
/// OCR character errors (e.g. "OEFTPL-P" → "Meftal-P", "Cr0cin" → "Crocin").
class MedicineNameValidator {
  MedicineNameValidator._();

  /// Common Indian medicines — brands and generics, lowercase.
  /// Not exhaustive: unknown names with strong dosing signals still pass the
  /// parser as low-confidence; this list only upgrades/repairs known ones.
  static const List<String> _knownMedicines = [
    // Analgesic / antipyretic / anti-inflammatory
    'paracetamol', 'crocin', 'calpol', 'dolo', 'metacin', 'ibuprofen',
    'combiflam', 'brufen', 'diclofenac', 'voveran', 'aceclofenac', 'zerodol',
    'mefenamic', 'meftal', 'meftal-p', 'meftal-spas', 'sumo', 'nise',
    'nimesulide', 'naproxen', 'tramadol', 'ultracet',
    // Cough / cold / allergy
    'delcon', 'sinarest', 'd-cold', 'cheston', 'ascoril', 'benadryl',
    'grilinctus', 'alex', 'corex', 'zedex', 'cetirizine', 'cetzine',
    'okacet', 'zyrtec', 'levocetirizine', 'levocet', 'xyzal', 'teczine',
    'fexofenadine', 'allegra', 'avil', 'chlorpheniramine', 'montelukast',
    'montair', 'montek', 'telekast', 'ambroxol', 'mucolite',
    // Respiratory
    'levolin', 'asthalin', 'ventorlin', 'salbutamol', 'levosalbutamol',
    'budecort', 'foracort', 'budesonide', 'seroflo', 'duolin', 'deriphyllin',
    // Antibiotic / antimicrobial
    'amoxicillin', 'mox', 'novamox', 'augmentin', 'amoxyclav', 'clavam',
    'azithromycin', 'azithral', 'azee', 'zithrocin', 'cefixime', 'taxim-o',
    'cefix', 'zifi', 'monocef', 'ceftriaxone', 'ciprofloxacin', 'ciplox',
    'norfloxacin', 'norflox', 'ofloxacin', 'zenflox', 'oflox', 'zanocin',
    'levofloxacin', 'levoflox', 'doxycycline', 'doxy', 'metronidazole',
    'flagyl', 'metrogyl', 'ornidazole', 'albendazole', 'zentel', 'ivermectin',
    'nitrofurantoin', 'septran', 'cotrimoxazole',
    // Gastro
    'omeprazole', 'omez', 'ocid', 'pantoprazole', 'pan', 'pan-d', 'pantocid',
    'rabeprazole', 'razo', 'rablet', 'esomeprazole', 'nexpro', 'ranitidine',
    'aciloc', 'rantac', 'famotidine', 'domperidone', 'domstal', 'ondansetron',
    'emeset', 'ondem', 'vomikind', 'digene', 'gelusil', 'sucralfate',
    'cyclopam', 'drotin', 'buscopan', 'dulcolax', 'cremaffin', 'looz',
    'ors', 'electral', 'enterogermina', 'econorm', 'sporlac',
    // Diabetes
    'metformin', 'glycomet', 'glucophage', 'glimepiride', 'amaryl',
    'gliclazide', 'sitagliptin', 'januvia', 'vildagliptin', 'galvus',
    'dapagliflozin', 'insulin',
    // Cardiac / BP / lipids
    'telmisartan', 'telma', 'amlodipine', 'amlong', 'amlokind', 'losartan',
    'losar', 'repace', 'atenolol', 'aten', 'metoprolol', 'betaloc',
    'ramipril', 'cardace', 'enalapril', 'atorvastatin', 'atorva', 'lipicure',
    'storvas', 'rosuvastatin', 'rosuvas', 'aspirin', 'ecosprin',
    'clopidogrel', 'clopilet', 'deplatt', 'isosorbide', 'sorbitrate',
    // Thyroid / hormones / steroids
    'levothyroxine', 'thyronorm', 'eltroxin', 'prednisolone', 'wysolone',
    'omnacortil', 'dexamethasone', 'betnesol',
    // Supplements
    'shelcal', 'calcium', 'supradyn', 'becosules', 'zincovit', 'neurobion',
    'folic', 'ferrous', 'orofer', 'dexorange', 'evion', 'limcee', 'zincolife',
  ];

  /// Returns the canonical (list) name when [candidate] matches a known
  /// medicine exactly or within OCR-error distance; null when unrecognized.
  static NameMatch? match(String candidate) {
    final words = candidate
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9\-]+'))
        .where((w) => w.length >= 3)
        .toList();

    for (final word in words) {
      for (final known in _knownMedicines) {
        if (word == known) {
          return NameMatch(canonical: _titleCase(known), exact: true);
        }
      }
    }

    // Fuzzy pass: absorb 1-2 OCR character errors on longer names.
    for (final word in words) {
      if (word.length < 5) {
        continue;
      }
      for (final known in _knownMedicines) {
        if (known.length < 5) {
          continue;
        }
        final maxDistance = word.length >= 7 ? 2 : 1;
        if ((word.length - known.length).abs() <= maxDistance &&
            _levenshtein(word, known, maxDistance) <= maxDistance) {
          return NameMatch(canonical: _titleCase(known), exact: false);
        }
      }
    }

    return null;
  }

  static String _titleCase(String name) {
    return name
        .split('-')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join('-');
  }

  /// Bounded Levenshtein distance; returns maxDistance + 1 when exceeded.
  static int _levenshtein(String a, String b, int maxDistance) {
    if (a == b) {
      return 0;
    }
    var previous = List<int>.generate(b.length + 1, (i) => i);
    final current = List<int>.filled(b.length + 1, 0);

    for (var i = 1; i <= a.length; i++) {
      current[0] = i;
      var rowMin = current[0];
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        current[j] = [
          current[j - 1] + 1,
          previous[j] + 1,
          previous[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
        if (current[j] < rowMin) {
          rowMin = current[j];
        }
      }
      if (rowMin > maxDistance) {
        return maxDistance + 1;
      }
      previous = List<int>.from(current);
    }
    return previous[b.length];
  }
}

class NameMatch {
  const NameMatch({required this.canonical, required this.exact});

  final String canonical;
  final bool exact;
}
