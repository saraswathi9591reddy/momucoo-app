/// Static content ported verbatim from frontend/src/pages (batch 4).
library;

const knowledgeTopics = <(String, String, String)>[
  ('🩸', 'Anemia during pregnancy', 'Anemia means the blood may not carry enough oxygen. During pregnancy, your body needs more iron to support you and your baby. Screening and follow-up help catch low iron early.'),
  ('🛡️', 'Precautions and warning signs', 'Attend scheduled prenatal checkups, take only supplements recommended for you, and share worsening fatigue, dizziness, breathlessness, paleness, or racing heartbeat with your care provider. For fainting, chest pain, severe breathlessness, or heavy bleeding, seek emergency help.'),
  ('🥗', 'Pregnancy-friendly diet', 'Include iron-rich foods such as lentils, beans, leafy greens, eggs, meat, and fortified foods. Pair plant-based iron with vitamin C from oranges, guava, tomatoes, or peppers. Tea and coffee close to meals may reduce iron absorption.'),
  ('📞', 'Contacting your care provider', 'Keep your CBC and scan reports ready, explain when symptoms started, and mention every medicine or supplement you take. Use Momucoo reports as a conversation aid, not as a replacement for professional prenatal care.'),
  ('📊', 'Understanding CBC reports', 'Hemoglobin shows oxygen-carrying protein, RBC is the red blood cell count, MCV describes cell size, and MCH describes hemoglobin per cell. Pregnancy reference ranges can differ by trimester, so your provider should interpret the full report together.'),
];

/// JS `text.slice(0, 92) + "..."` (UTF-16 units, like Dart).
String knowledgePreview(String text) => '${text.length > 92 ? text.substring(0, 92) : text}...';

const quizQuestion = 'Which nutrient helps the body make hemoglobin?';
const quizOptions = ['Iron', 'Calcium', 'Vitamin D'];
const quizCorrect = 'Iron';

/// Mirrors the web feedback text for a chosen answer ('' = none chosen).
String? quizFeedback(String answer) {
  if (answer.isEmpty) return null;
  return answer == quizCorrect ? 'Correct. Iron is essential for hemoglobin production.' : 'Not quite. Try reviewing the Knowledge Hub.';
}

class Reminder {
  const Reminder(this.text, this.time, this.done);
  final String text, time;
  final bool done;
  Reminder toggled() => Reminder(text, time, !done);
}

const initialReminders = [
  Reminder('Take iron supplement', '08:30 AM', false),
  Reminder('Drink a glass of water', '11:00 AM', true),
  Reminder('Prepare for doctor consultation', 'Tomorrow', false),
];

const feedbackOptions = ['Very good', 'Good', 'Needs improvement'];
const emergencyNumber = '112';
