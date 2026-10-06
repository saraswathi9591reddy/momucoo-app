import 'package:flutter/material.dart';

import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import '../widgets/primary_button.dart';
import 'batch4/content.dart';

/// Port of frontend/src/pages/Feedback.jsx (route /feedback). Not persisted, as on web.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  bool _sent = false;
  String _rating = feedbackOptions.first;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Feedback',
      eyebrow: 'HELP US IMPROVE',
      activePath: Routes.dashboard,
      description: 'Tell us what would make your care experience better.',
      children: [
        ContentCard(
          child: _sent
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Thank you for your feedback.', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Your response has been recorded.'),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Text('How was your experience?', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _rating,
                    isExpanded: true,
                    items: [for (final o in feedbackOptions) DropdownMenuItem(value: o, child: Text(o))],
                    onChanged: (v) => setState(() => _rating = v ?? _rating),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _notes, minLines: 4, maxLines: 8, decoration: const InputDecoration(hintText: 'Share more details')),
                  const SizedBox(height: 16),
                  PrimaryButton(label: 'Submit Feedback', onPressed: () => setState(() => _sent = true)),
                ]),
        ),
      ],
    );
  }
}
