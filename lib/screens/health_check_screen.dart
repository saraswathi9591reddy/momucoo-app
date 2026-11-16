import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/models/models.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Port of frontend/src/pages/HealthCheck.jsx (route /health-check).
/// Matches the web app 8-question clinical symptom assessment wizard
/// with progress indicator, emergency symptom warnings, Yes/No/Not sure options,
/// and direct assessment result generation.
class HealthCheckScreen extends StatefulWidget {
  const HealthCheckScreen({super.key});

  @override
  State<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class SymptomItem {
  final String key;
  final String label;
  final String desc;
  final bool isEmergency;

  const SymptomItem({
    required this.key,
    required this.label,
    required this.desc,
    this.isEmergency = false,
  });
}

const _symptoms = [
  SymptomItem(
    key: 'fatigue',
    label: 'Fatigue or Weakness',
    desc: 'Do you feel unusually tired, weak, or lacking energy?',
  ),
  SymptomItem(
    key: 'breathlessness',
    label: 'Shortness of Breath',
    desc: 'Do you feel breathless during normal activities like walking?',
    isEmergency: true,
  ),
  SymptomItem(
    key: 'dizziness',
    label: 'Dizziness or Lightheadedness',
    desc: 'Do you feel dizzy, lightheaded, or like you might faint?',
  ),
  SymptomItem(
    key: 'pale_skin',
    label: 'Pale Skin or Gums',
    desc: 'Have others noticed your skin, lips, or gums appear paler than usual?',
  ),
  SymptomItem(
    key: 'rapid_heartbeat',
    label: 'Rapid or Irregular Heartbeat',
    desc: 'Do you notice your heart beating faster or irregularly at rest?',
  ),
  SymptomItem(
    key: 'headache',
    label: 'Frequent Headaches',
    desc: 'Are you experiencing headaches more often than usual?',
  ),
  SymptomItem(
    key: 'cold_hands',
    label: 'Cold Hands or Feet',
    desc: 'Do your hands and feet feel cold even in warm weather?',
  ),
  SymptomItem(
    key: 'chest_pain',
    label: 'Chest Pain',
    desc: 'Do you have any chest pain or tightness? (Emergency symptom)',
    isEmergency: true,
  ),
];

class _HealthCheckScreenState extends State<HealthCheckScreen> {
  int _step = 0; // 0 = intro, 1..8 = symptoms, 9 = week input
  final Map<String, String> _answers = {};
  final _weekCtrl = TextEditingController(text: '35');
  bool _submitting = false;

  @override
  void dispose() {
    _weekCtrl.dispose();
    super.dispose();
  }

  bool get _hasEmergency {
    return _answers['chest_pain'] == 'yes' || _answers['breathlessness'] == 'yes';
  }

  void _next() {
    if (_step == 0) {
      setState(() => _step = 1);
    } else if (_step <= _symptoms.length) {
      final currentKey = _symptoms[_step - 1].key;
      if (!_answers.containsKey(currentKey)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an option to continue')),
        );
        return;
      }
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  Future<void> _finish() async {
    setState(() => _submitting = true);
    final s = AppStorage.instance;

    final yesSymptoms = _answers.entries
        .where((e) => e.value == 'yes')
        .map((e) => e.key)
        .toList();

    await s.savePregnancyData(
      PregnancyData(
        week: _weekCtrl.text.trim(),
        symptoms: yesSymptoms,
      ),
    );

    if (mounted) {
      context.go(Routes.aiAnalysis);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = _symptoms.length + 1;
    final progress = _step == 0 ? 0.0 : (_step / totalSteps);

    return PageLayout(
      title: 'Symptom Assessment',
      eyebrow: 'MOMUCOO • PATIENT PORTAL',
      description: 'Answer questions about your symptoms for a complete screening',
      activePath: Routes.healthCheck,
      children: [
        // Progress Bar
        if (_step > 0) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step $_step of $totalSteps',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${(progress * 100).round()}% complete',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE5D4CE),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC0392B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Emergency Alert Banner
        if (_hasEmergency)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC0392B).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFC0392B), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Emergency symptoms reported. Please seek immediate clinical review.',
                    style: TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        // Step 0: Intro Card
        if (_step == 0)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5D4CE)),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDE8E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Color(0xFFC0392B), size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Symptom Check',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Answer 8 quick questions about how you have been feeling recently. This helps assess your anemia risk accurately based on WHO clinical guidelines.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0392B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Start Assessment →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )

        // Steps 1..8: Individual Symptom Questions
        else if (_step <= _symptoms.length) ...[
          Builder(builder: (context) {
            final item = _symptoms[_step - 1];
            final currentVal = _answers[item.key];

            return Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5D4CE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.isEmergency)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'EMERGENCY SYMPTOM',
                        style: TextStyle(color: Color(0xFFC0392B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                      ),
                    ),
                  Text(
                    item.label,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.desc,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  _optionTile('yes', 'Yes', 'I have been experiencing this', currentVal == 'yes'),
                  const SizedBox(height: 10),
                  _optionTile('no', 'No', 'I have not noticed this', currentVal == 'no'),
                  const SizedBox(height: 10),
                  _optionTile('unknown', 'Not Sure', 'I am uncertain or haven’t checked', currentVal == 'unknown'),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _back,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('← Back'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC0392B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Next →', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ]

        // Step 9: Pregnancy Week Final Step
        else ...[
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5D4CE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Pregnancy Week',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Clinical anemia thresholds adjust based on your trimester. Please confirm your gestational week (1–42).',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _weekCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Pregnancy Week',
                    hintText: 'e.g. 35',
                    filled: true,
                    fillColor: const Color(0xFFFCF9F7),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5D4CE))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5D4CE))),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: _back,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('← Back'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _finish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC0392B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          _submitting ? 'Analyzing...' : 'Complete Assessment ⚡',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _optionTile(String val, String title, String subtitle, bool selected) {
    return InkWell(
      onTap: () {
        final currentKey = _symptoms[_step - 1].key;
        setState(() => _answers[currentKey] = val);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFDE8E6) : const Color(0xFFFCF9F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFC0392B) : const Color(0xFFE5D4CE),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? const Color(0xFFC0392B) : const Color(0xFF9CA3AF),
                  width: 2,
                ),
                color: selected ? const Color(0xFFC0392B) : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? const Color(0xFFC0392B) : AppColors.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
