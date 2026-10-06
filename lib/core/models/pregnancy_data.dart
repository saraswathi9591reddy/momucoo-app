import 'json_utils.dart';

/// localStorage key `pregnancyData`.
/// `week` is dynamic: CBCAnalysis writes a number or "", HealthCheck writes int|null,
/// PatientProfile writes number|null.
class PregnancyData {
  dynamic week;
  List<String> symptoms;
  List<Map<String, dynamic>>? chatTranscript; // [{from: 'bot'|'user', text}]
  String? createdAt;

  PregnancyData({this.week, List<String>? symptoms, this.chatTranscript, this.createdAt})
      : symptoms = symptoms ?? [];

  factory PregnancyData.fromJson(Map<String, dynamic> j) => PregnancyData(
        week: j['week'],
        symptoms: (j['symptoms'] as List?)?.map((e) => e.toString()).toList() ?? [],
        chatTranscript: (j['chatTranscript'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        createdAt: j['createdAt'] as String?,
      );

  bool get hasWeek => jsTruthy(week);

  Map<String, dynamic> toJson() => {
        'week': week,
        'symptoms': symptoms,
        if (chatTranscript != null) 'chatTranscript': chatTranscript,
        if (createdAt != null) 'createdAt': createdAt,
      };
}
