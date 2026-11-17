import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/localization.dart';
import '../core/models/models.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

class SymptomItem {
  final String key;
  final String labelKey;
  final String descKey;
  final bool isEmergency;

  const SymptomItem({
    required this.key,
    required this.labelKey,
    required this.descKey,
    this.isEmergency = false,
  });
}

const _symptoms = [
  SymptomItem(key: 'fatigue', labelKey: 'sym_fatigue', descKey: 'sym_fatigue_desc'),
  SymptomItem(key: 'breathlessness', labelKey: 'sym_breath', descKey: 'sym_breath_desc', isEmergency: true),
  SymptomItem(key: 'dizziness', labelKey: 'sym_dizzy', descKey: 'sym_dizzy_desc'),
  SymptomItem(key: 'pale_skin', labelKey: 'sym_pale', descKey: 'sym_pale_desc'),
  SymptomItem(key: 'rapid_heartbeat', labelKey: 'sym_heart', descKey: 'sym_heart_desc'),
  SymptomItem(key: 'headache', labelKey: 'sym_headache', descKey: 'sym_headache_desc'),
  SymptomItem(key: 'cold_hands', labelKey: 'sym_cold', descKey: 'sym_cold_desc'),
  SymptomItem(key: 'chest_pain', labelKey: 'sym_chest', descKey: 'sym_chest_desc', isEmergency: true),
];

class HealthCheckScreen extends StatefulWidget {
  const HealthCheckScreen({super.key});
  @override
  State<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends State<HealthCheckScreen> {
  int _step = 0;
  final Map<String, String> _answers = {};
  final _weekCtrl = TextEditingController(text: '35');
  bool _submitting = false;

  @override
  void dispose() {
    _weekCtrl.dispose();
    super.dispose();
  }

  bool get _hasEmergency =>
      _answers['chest_pain'] == 'yes' || _answers['breathlessness'] == 'yes';

  void _next() {
    if (_step == 0) {
      setState(() => _step = 1);
    } else if (_step <= _symptoms.length) {
      final currentKey = _symptoms[_step - 1].key;
      if (!_answers.containsKey(currentKey)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationService.tr('please_select_option'))),
        );
        return;
      }
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _finish() async {
    setState(() => _submitting = true);
    final s = AppStorage.instance;
    final yesSymptoms = _answers.entries
        .where((e) => e.value == 'yes')
        .map((e) => e.key)
        .toList();
    await s.savePregnancyData(PregnancyData(week: _weekCtrl.text.trim(), symptoms: yesSymptoms));
    if (mounted) context.go(Routes.aiAnalysis);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, _, __) {
        final L = LocalizationService.tr;
        final totalSteps = _symptoms.length + 1;
        final progress = _step == 0 ? 0.0 : (_step / totalSteps);

        return PageLayout(
          title: L('symptom_check'),
          eyebrow: L('patient_portal'),
          description: L('symptom_desc'),
          activePath: Routes.healthCheck,
          children: [
            if (_step > 0) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${L('step')} $_step ${L('of')} $totalSteps',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${(progress * 100).round()}% ${L('complete')}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFE5D4CE),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC0392B)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],

            if (_hasEmergency) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        L('emergency_symptom_warning'),
                        style: const TextStyle(color: Color(0xFF7F1D1D), fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Intro card
            if (_step == 0) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5D4CE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.assignment_outlined, color: Color(0xFFC0392B), size: 36),
                    const SizedBox(height: 16),
                    Text(L('symptom_check'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    const SizedBox(height: 10),
                    Text(L('symptom_intro_body'), style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC0392B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(L('begin_assessment'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Symptom question card
            if (_step >= 1 && _step <= _symptoms.length) ...[
              Builder(builder: (ctx) {
                final sym = _symptoms[_step - 1];
                final selectedAnswer = _answers[sym.key];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: sym.isEmergency ? const Color(0xFFEF4444) : const Color(0xFFE5D4CE),
                      width: sym.isEmergency ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sym.isEmergency)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            L('emergency_symptom'),
                            style: const TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      Text(
                        L(sym.labelKey),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
                      ),
                      const SizedBox(height: 8),
                      Text(L(sym.descKey), style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4)),
                      const SizedBox(height: 20),
                      _optionTile('yes', L('yes'), L('yes_desc'), selectedAnswer == 'yes'),
                      const SizedBox(height: 10),
                      _optionTile('no', L('no'), L('no_desc'), selectedAnswer == 'no'),
                      const SizedBox(height: 10),
                      _optionTile('unsure', L('not_sure'), L('not_sure_desc'), selectedAnswer == 'unsure'),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          if (_step > 1)
                            OutlinedButton(
                              onPressed: _back,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(L('back')),
                            ),
                          if (_step > 1) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC0392B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                _step < _symptoms.length ? L('next_question') : L('last_step'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Week input
            if (_step > _symptoms.length) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5D4CE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L('pregnancy_week'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    const SizedBox(height: 8),
                    Text(L('pregnancy_week_hint'), style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _weekCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: L('pregnancy_week'),
                        hintText: L('eg_week'),
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
                          child: Text(L('back')),
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
                              _submitting ? L('analyzing') : L('complete_assessment'),
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
      },
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
              child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
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
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
