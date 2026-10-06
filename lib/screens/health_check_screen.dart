import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/models/models.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';
import '../widgets/primary_button.dart';

/// Port of frontend/src/pages/HealthCheck.jsx: scripted 4-question chatbot.
class HealthCheckScreen extends StatefulWidget {
  const HealthCheckScreen({super.key});

  @override
  State<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

const _anemiaWords = ['tired', 'fatigue', 'weak', 'dizzy', 'breathless', 'breath', 'pale', 'headache', 'heartbeat', 'palpitation'];
const _questions = [
  'How are you feeling today? You can describe anything you have noticed in your own words.',
  'Have you felt unusually tired, weak, dizzy, or short of breath recently?',
  'How many weeks pregnant are you?',
  'Have you been taking your prenatal vitamins or iron supplements?',
];

class _HealthCheckScreenState extends State<HealthCheckScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final List<Map<String, dynamic>> _messages;
  int _step = 0;
  List<String> _symptoms = [];
  String _week = '';
  bool _finished = false;

  String get _name {
    final p = AppStorage.instance.profile;
    return p == null ? 'there' : p.name;
  }

  @override
  void initState() {
    super.initState();
    // Web captures the name once for the greeting.
    _messages = [
      {'from': 'bot', 'text': 'Hi $_name, I’m Momucoo. I’m here to listen and help you understand your early-pregnancy symptoms.'},
      {'from': 'bot', 'text': _questions[0]},
    ];
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _add(String from, String text) => _messages.add({'from': from, 'text': text});

  Future<void> _send([String? value]) async {
    final answer = (value ?? _input.text).trim();
    if (answer.isEmpty || _finished) return;
    final before = List<Map<String, dynamic>>.of(_messages);
    setState(() {
      _add('user', answer);
      _input.clear();
      if (_step == 0) {
        final lower = answer.toLowerCase();
        final found = _anemiaWords.where(lower.contains).toList();
        _symptoms = found;
        _add(
            'bot',
            found.isNotEmpty
                ? 'Thank you for sharing that. I noticed ${found.length > 1 ? 'a few symptoms' : 'a symptom'} that can sometimes be linked with low iron or anemia. I’ll ask two quick questions to understand better.'
                : 'Thank you for sharing that. Every detail helps, and I’ll ask a couple of gentle questions next.');
      } else if (_step == 1) {
        if (RegExp('yes|often|sometimes|frequently|a lot', caseSensitive: false).hasMatch(answer)) {
          _symptoms = {..._symptoms, 'tired or dizzy'}.toList();
        }
        _add('bot', 'Got it. Knowing your pregnancy stage will help us read your blood results more carefully.');
      } else if (_step == 2) {
        _week = answer;
        _add('bot', 'Thanks. One last question: ${_questions[3]}');
      } else {
        final positive = RegExp('yes|taking|regular', caseSensitive: false).hasMatch(answer);
        _add(
            'bot',
            positive
                ? 'That’s good to know. Please continue only as advised by your prenatal care provider.'
                : 'Thanks for telling me. Please discuss supplements with your prenatal care provider before starting or changing them.');
        _finished = true;
      }
      if (!_finished) {
        _step++;
        if (_step == 1) _add('bot', _questions[1]);
        if (_step == 2) _add('bot', _questions[2]);
      }
    });
    if (_finished) {
      // Web saves the transcript up to and including the last user answer.
      await AppStorage.instance.savePregnancyData(PregnancyData(
        week: _parseIntLike(_week),
        symptoms: _symptoms,
        chatTranscript: [...before, {'from': 'user', 'text': answer}],
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ));
    }
  }

  /// `Number.parseInt(week, 10) || null`.
  static int? _parseIntLike(String s) {
    final m = RegExp(r'^\s*([+-]?\d+)').firstMatch(s);
    final n = m == null ? null : int.tryParse(m.group(1)!);
    return (n == null || n == 0) ? null : n;
  }

  Widget _bubble(String from, Widget child) {
    final user = from == 'user';
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: user ? AppColors.primary : AppColors.peachBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: DefaultTextStyle.merge(style: TextStyle(color: user ? Colors.white : AppColors.ink), child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quick = _step == 1
        ? const ['Yes, quite often', 'Sometimes', 'No, not really']
        : _step == 3
            ? const ['Yes, regularly', 'Sometimes', 'Not currently']
            : const <String>[];
    return PageLayout(
      title: 'Health Check',
      eyebrow: 'MOMUCOO AI CHAT',
      activePath: Routes.healthCheck,
      description: 'Talk naturally about how you feel. Momucoo will ask friendly anemia-related questions before your report review.',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Row(children: [
                CircleAvatar(backgroundColor: AppColors.primary, child: Text('M', style: TextStyle(color: Colors.white))),
                SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Momucoo AI', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('Friendly pregnancy health assistant • Online', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  ]),
                ),
              ]),
              const SizedBox(height: 12),
              for (final m in _messages) _bubble(m['from'] as String, Text(m['text'] as String)),
              if (_finished)
                _bubble(
                    'bot',
                    const Text.rich(TextSpan(children: [
                      TextSpan(text: 'Preliminary insight\n', style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(
                          text:
                              'Your symptoms have been recorded. Symptoms alone cannot diagnose anemia, so let’s combine them with your CBC values and optional scan report.'),
                    ]))),
              const SizedBox(height: 12),
              if (!_finished) ...[
                Row(children: [
                  Expanded(
                    child: TextField(
                      key: const Key('chat-input'),
                      controller: _input,
                      keyboardType: _step == 2 ? TextInputType.number : TextInputType.text,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(hintText: 'Type how you feel...'),
                    ),
                  ),
                  IconButton(
                    key: const Key('chat-send'),
                    tooltip: 'Send message',
                    onPressed: () => _send(),
                    icon: const Icon(Icons.send, color: AppColors.primary),
                  ),
                ]),
                if (quick.isNotEmpty)
                  Wrap(spacing: 8, runSpacing: 4, children: [
                    for (final q in quick) ActionChip(label: Text(q), onPressed: () => _send(q)),
                  ]),
              ] else
                PrimaryButton(label: 'Continue to Blood & Scan Reports →', onPressed: () => context.go(Routes.cbcAnalysis)),
              const SizedBox(height: 12),
              const Text('Momucoo offers screening support, not a diagnosis. For severe symptoms, use Emergency Help.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
        ),
      ],
    );
  }
}
