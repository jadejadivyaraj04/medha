// test/unit/core/scan/prescription_text_parser_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:medha/core/scan/medicine_name_validator.dart';
import 'package:medha/core/scan/prescription_text_parser.dart';

void main() {
  group('MedicineNameValidator', () {
    test('match_exactBrandName_returnsCanonical', () {
      expect(MedicineNameValidator.match('CALPOL')!.canonical, 'Calpol');
      expect(MedicineNameValidator.match('Syp CALPOL 250')!.exact, isTrue);
    });

    test('match_ocrCorruptedName_repairsSpelling', () {
      // Real OCR misreads captured from a scanned prescription.
      final meftal = MedicineNameValidator.match('OEFTPL-P');
      expect(meftal, isNotNull);
      expect(meftal!.canonical.toLowerCase(), contains('meftal'));
      expect(meftal.exact, isFalse);
    });

    test('match_uiNoise_returnsNull', () {
      expect(MedicineNameValidator.match('Brave Browser'), isNull);
      expect(MedicineNameValidator.match('Create new account'), isNull);
      expect(MedicineNameValidator.match('URTI'), isNull);
    });
  });

  group('PrescriptionTextParser', () {
    // OCR output captured from a real prescription photographed off a
    // computer screen — full of browser and Facebook UI noise.
    const realOcrSample = '''
BES
aaloe: 7.00 to 8.45
Reg. No.:52547
Ph: 8086993168
Date: 20-q-2022
Weight:
13-25 ką
Tab
WindowHelp
pid=10213299700082758&set=a.4831051189901
D Imported from Go...
A/MI Learning M Inbox (576) - deve..
MBBS (Govt. Medical College, Thrissur)
M.D. Paediatrics (JIPMER)
CHC, Nemmara
Name: ASHUIKA
Age, Gender:
Clinical Description:
JRTI
Advice:
Syp CALPOL (25o/5) 4 mL QGH x 3d
9yp
DELCON
sd
LEVOLIN
3 mL TOS
OEFTPL-P (00/5)
x sd
Syp
p for Facebook to connect with friends, family and pec
Log in
or
Create new account
''';

    test('parse_realNoisyOcr_extractsOnlyValidatedMedicines', () {
      final medicines = PrescriptionTextParser.parse(realOcrSample);

      final names =
          medicines.map((m) => m.name.toLowerCase()).toList().join(' ');
      expect(names, contains('calpol'));
      expect(names, contains('delcon'));
      expect(names, contains('levolin'));
      expect(names, contains('meftal'));

      // Precision: no UI junk or fragments promoted to medicines.
      expect(names, isNot(contains('facebook')));
      expect(names, isNot(contains('browser')));
      expect(names, isNot(contains('log')));
      expect(names, isNot(contains('window')));

      // Everything from the rule tier demands user review.
      for (final medicine in medicines) {
        expect(medicine.hasLowConfidence, isTrue);
      }
    });

    test('parse_completeLine_extractsAllFields', () {
      final medicines = PrescriptionTextParser.parse(
        'Tab MEFTAL-P 250 mg 1-0-1 x 5 days',
      );
      expect(medicines, hasLength(1));
      expect(medicines.first.name, 'Meftal-P');
      expect(medicines.first.dosageMg, 250);
      expect(medicines.first.frequency, '1-0-1');
      expect(medicines.first.durationDays, 5);
      // Exact name + full dosing: only withFood should remain flagged.
      expect(medicines.first.lowConfidenceFields, {'withFood'});
    });

    test('parse_letterheadOnly_returnsEmpty', () {
      const noise = '''
Adichunchanagiri Institute of Medical Sciences
Hospital & Research Centre
Signature of Doctor
Brave Browser
Log in
''';
      expect(PrescriptionTextParser.parse(noise), isEmpty);
    });

    test('cleanOcrText_stripsUiAndLetterheadLines', () {
      final cleaned = PrescriptionTextParser.cleanOcrText(realOcrSample);
      expect(cleaned, isNot(contains('Facebook')));
      expect(cleaned, isNot(contains('Log in')));
      expect(cleaned, isNot(contains('Medical College')));
      expect(cleaned, contains('CALPOL'));
      expect(cleaned, contains('LEVOLIN'));
    });
  });
}
