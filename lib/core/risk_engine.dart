import 'models/models.dart';

/// Exact port of the scoring in frontend/src/pages/AIAnalysis.jsx.
class RiskResult {
  final int score;
  final String risk; // Low | Moderate | High
  final bool anemiaLikely;
  final String anemiaStatus;
  final List<String> factors;
  final List<String> recommendations;
  final ScanData scan;

  const RiskResult({
    required this.score,
    required this.risk,
    required this.anemiaLikely,
    required this.anemiaStatus,
    required this.factors,
    required this.recommendations,
    required this.scan,
  });

  AiResult toAiResult(DateTime now) =>
      AiResult(score: score, risk: risk, anemiaStatus: anemiaStatus, completedAt: now.toUtc().toIso8601String());
}

class RiskEngine {
  static const highRecommendations = [
    'Contact your prenatal care provider promptly with this result.',
    'Choose iron-rich foods with vitamin C as part of a clinician-approved diet.',
    'For severe breathlessness, fainting, chest pain, or heavy bleeding, call emergency services.',
  ];
  static const defaultRecommendations = [
    'Continue your prenatal care plan and repeat testing as advised.',
    'Discuss nutrition and supplements with your prenatal care provider.',
  ];

  /// [cbc], [pregnancy], [scan] are the raw decoded JSON maps (`{}` when missing, as on web).
  /// [legacySymptoms] is the `symptoms` key, used only when pregnancy.symptoms is falsy.
  static RiskResult evaluate({
    Map<String, dynamic> cbc = const {},
    Map<String, dynamic> pregnancy = const {},
    Map<String, dynamic> scan = const {},
    List<dynamic> legacySymptoms = const [],
  }) {
    final List<dynamic> symptoms = (pregnancy['symptoms'] as List?) ?? legacySymptoms;

    final hb = jsNumber(cbc['hb']);
    final mcv = jsNumber(cbc['mcv']);
    final mch = jsNumber(cbc['mch']);
    final hct = jsNumber(cbc['hematocrit']);
    final rbc = jsNumber(cbc['rbc']);

    final anemiaLikely = hb > 0 &&
        (hb < 11 || (mcv > 0 && mcv < 80) || (mch > 0 && mch < 27) || (hct > 0 && hct < 33) || (rbc > 0 && rbc < 3.8));
    final anemiaStatus = anemiaLikely ? 'Anemia likely' : 'No anemia detected';

    var score = 0;
    final factors = <String>[];

    if (hb > 0 && hb < 11) {
      score += 35;
      factors.add('Hemoglobin is below the usual pregnancy reference range.');
    } else if (hb > 0) {
      factors.add('Hemoglobin is within a healthier pregnancy range.');
    }
    if (mcv > 0 && mcv < 80) {
      score += 20;
      factors.add('MCV is low, which can support a microcytic anemia pattern.');
    }
    if (mch > 0 && mch < 27) {
      score += 15;
      factors.add('MCH is low.');
    }
    if (hct > 0 && hct < 33) {
      score += 10;
      factors.add('Hematocrit is lower than expected for pregnancy.');
    }

    final symptomScore = symptoms.length * 5;
    score += symptomScore < 25 ? symptomScore : 25;
    if (symptoms.isNotEmpty) factors.add('${symptoms.length} symptom(s) were reported.');

    if (jsTruthy(pregnancy['week'])) {
      factors.add('Pregnancy week ${pregnancy['week']} was included in the screening context.');
    }
    final scanModel = ScanData.fromJson(scan);
    if (jsTruthy(scan['uploaded'])) {
      factors.add('Optional scan report selected: ${scan['name']}. A clinician should review the original scan.');
    }

    var risk = 'Low';
    if (score >= 60 || (anemiaLikely && score >= 45)) {
      risk = 'High';
    } else if (score >= 30 || anemiaLikely) {
      risk = 'Moderate';
    }

    return RiskResult(
      score: score > 100 ? 100 : score,
      risk: risk,
      anemiaLikely: anemiaLikely,
      anemiaStatus: anemiaStatus,
      factors: factors,
      recommendations: risk == 'High' ? highRecommendations : defaultRecommendations,
      scan: scanModel,
    );
  }
}
