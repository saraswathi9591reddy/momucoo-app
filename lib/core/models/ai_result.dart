/// localStorage key `aiResult` (persisted subset): {score, risk, anemiaStatus, completedAt}.
class AiResult {
  final int score;
  final String risk; // Low | Moderate | High
  final String anemiaStatus;
  final String completedAt;

  const AiResult({required this.score, required this.risk, required this.anemiaStatus, required this.completedAt});

  factory AiResult.fromJson(Map<String, dynamic> j) => AiResult(
        score: (j['score'] as num?)?.toInt() ?? 0,
        risk: (j['risk'] ?? '').toString(),
        anemiaStatus: (j['anemiaStatus'] ?? '').toString(),
        completedAt: (j['completedAt'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'score': score, 'risk': risk, 'anemiaStatus': anemiaStatus, 'completedAt': completedAt};
}
