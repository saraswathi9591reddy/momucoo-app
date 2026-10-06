import 'package:flutter_test/flutter_test.dart';
import 'package:momucoo/core/risk_engine.dart';

void main() {
  group('RiskEngine (port of AIAnalysis.jsx)', () {
    test('empty data -> Low, score 0, no anemia', () {
      final r = RiskEngine.evaluate();
      expect(r.score, 0);
      expect(r.risk, 'Low');
      expect(r.anemiaLikely, false);
      expect(r.anemiaStatus, 'No anemia detected');
      expect(r.factors, isEmpty);
      expect(r.recommendations, RiskEngine.defaultRecommendations);
    });

    test('normal CBC -> Low with healthy factor', () {
      final r = RiskEngine.evaluate(cbc: {'hb': '12.5', 'mcv': '90', 'mch': '30', 'hematocrit': '38', 'rbc': '4.5'});
      expect(r.score, 0);
      expect(r.risk, 'Low');
      expect(r.factors, ['Hemoglobin is within a healthier pregnancy range.']);
    });

    test('low hb only -> 35, Moderate (anemiaLikely, <45)', () {
      final r = RiskEngine.evaluate(cbc: {'hb': '10'});
      expect(r.score, 35);
      expect(r.anemiaLikely, true);
      expect(r.risk, 'Moderate');
    });

    test('low hb + low mcv -> 55, High via anemiaLikely && >=45', () {
      final r = RiskEngine.evaluate(cbc: {'hb': '10', 'mcv': '75'});
      expect(r.score, 55);
      expect(r.risk, 'High');
      expect(r.recommendations, RiskEngine.highRecommendations);
    });

    test('all markers low + many symptoms caps at 100', () {
      final r = RiskEngine.evaluate(
        cbc: {'hb': 9, 'mcv': 70, 'mch': 20, 'hematocrit': 28, 'rbc': 3},
        pregnancy: {'week': 24, 'symptoms': List.filled(10, 's')},
        scan: {'uploaded': true, 'name': 'scan.png'},
      );
      expect(r.score, 100); // 35+20+15+10+25 = 105 -> 100
      expect(r.risk, 'High');
      expect(r.factors, contains('10 symptom(s) were reported.'));
      expect(r.factors, contains('Pregnancy week 24 was included in the screening context.'));
      expect(r.factors, contains('Optional scan report selected: scan.png. A clinician should review the original scan.'));
    });

    test('rbc low with normal hb -> anemiaLikely, Moderate, score 0', () {
      final r = RiskEngine.evaluate(cbc: {'hb': '12', 'rbc': '3.5'});
      expect(r.anemiaLikely, true);
      expect(r.score, 0);
      expect(r.risk, 'Moderate');
    });

    test('hb missing disables anemiaLikely even with low mcv', () {
      final r = RiskEngine.evaluate(cbc: {'mcv': '70'});
      expect(r.anemiaLikely, false);
      expect(r.score, 20);
      expect(r.risk, 'Low');
    });

    test('symptoms only: 6 symptoms -> 25 capped, Low', () {
      final r = RiskEngine.evaluate(pregnancy: {'symptoms': List.filled(6, 'x')});
      expect(r.score, 25);
      expect(r.risk, 'Low');
    });

    test('score >= 60 without anemia flag edge -> High; 30 -> Moderate', () {
      expect(RiskEngine.evaluate(cbc: {'mcv': '70', 'mch': '20'}, pregnancy: {'symptoms': List.filled(5, 'x')}).risk, 'High'); // 20+15+25=60
      expect(RiskEngine.evaluate(cbc: {'mcv': '70', 'hematocrit': '30'}).risk, 'Moderate'); // 30
    });

    test('legacy symptoms used only when pregnancy.symptoms missing', () {
      expect(RiskEngine.evaluate(legacySymptoms: ['a', 'b']).score, 10);
      expect(RiskEngine.evaluate(pregnancy: {'symptoms': []}, legacySymptoms: ['a', 'b']).score, 0);
    });

    test('empty-string week is falsy (CBCAnalysis writes "")', () {
      final r = RiskEngine.evaluate(pregnancy: {'week': '', 'symptoms': []});
      expect(r.factors, isEmpty);
    });

    test('non-numeric strings coerce to 0', () {
      final r = RiskEngine.evaluate(cbc: {'hb': 'abc'});
      expect(r.score, 0);
      expect(r.factors, isEmpty);
    });
  });
}
