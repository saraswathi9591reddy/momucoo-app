import 'package:flutter_test/flutter_test.dart';
import 'package:momucoo/screens/batch2/cbc_parser.dart';

void main() {
  const cbcReport = '''
COMPLETE BLOOD COUNT
Haemoglobin (Hb)      9,8   g/dL    11.5 - 16.0
Total RBC Count        3.6  mill/µL  3.8 - 4.8
Hematocrit (PCV)      31.2  %
MCV                   76.4  fL
MCH                   24.1  pg
MCHC                  31.5  g/dL
RDW-CV                16.2  %
''';

  test('normalizeOcrText', () {
    expect(normalizeOcrText('a\r\n µL |x 9,8'), 'a uL Ix 9.8');
    expect(normalizeOcrText(), '');
  });

  test('extracts all seven CBC values from a typical report', () {
    expect(extractCbcValues(cbcReport), {
      'hb': '9.8',
      'rbc': '3.6',
      'mcv': '76.4',
      'mch': '24.1',
      'mchc': '31.5',
      'hematocrit': '31.2',
      'rdw': '16.2',
    });
  });

  test('MCH does not match MCHC, abbreviations work, missing keys omitted', () {
    final v = extractCbcValues('MCHC 33 HGB 12.1 HCT 36');
    expect(v, {'hb': '12.1', 'mchc': '33', 'hematocrit': '36'});
  });

  test('no values returns empty map', () {
    expect(extractCbcValues('patient name: test'), isEmpty);
  });

  test('extracts scan values', () {
    const scan = 'Gestational Age: 24 weeks 3 days. FHR 148 bpm. EFW 650 g. '
        'BPD 6,1 cm HC 22.3 cm AC 19.8 cm FL 4.4 cm';
    expect(extractScanValues(scan), {
      'gestationalAge': '24',
      'fetalHeartRate': '148',
      'estimatedWeight': '650',
      'biparietalDiameter': '6.1',
      'headCircumference': '22.3',
      'abdominalCircumference': '19.8',
      'femurLength': '4.4',
    });
  });

  test('getGestationalWeek', () {
    expect(getGestationalWeek('24'), 24);
    expect(getGestationalWeek('wk 9'), 9);
    expect(getGestationalWeek(null), '');
    expect(getGestationalWeek(''), '');
    expect(getGestationalWeek('none'), '');
  });
}
