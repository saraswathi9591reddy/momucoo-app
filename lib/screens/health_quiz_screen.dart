import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import 'batch4/content.dart';

/// Port of frontend/src/pages/HealthQuiz.jsx (route /health-quiz).
class HealthQuizScreen extends StatefulWidget {
  const HealthQuizScreen({super.key});

  @override
  State<HealthQuizScreen> createState() => _HealthQuizScreenState();
}

class _HealthQuizScreenState extends State<HealthQuizScreen> {
  String _answer = '';

  @override
  Widget build(BuildContext context) {
    final feedback = quizFeedback(_answer);
    return PageLayout(
      title: 'Health Quiz',
      eyebrow: 'LEARN ABOUT ANEMIA',
      activePath: Routes.dashboard,
      description: 'Answer a few questions to strengthen your health knowledge.',
      children: [
        ContentCard(
          kicker: 'QUESTION 1 OF 3',
          title: quizQuestion,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final o in quizOptions)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(14),
                    backgroundColor: _answer == o ? AppColors.peachBg : null,
                    foregroundColor: AppColors.ink,
                    side: BorderSide(color: _answer == o ? AppColors.primary : AppColors.border, width: _answer == o ? 2 : 1),
                  ),
                  onPressed: () => setState(() => _answer = o),
                  child: Text(o),
                ),
              ),
            if (feedback != null) Text(feedback, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
          ]),
        ),
      ],
    );
  }
}
