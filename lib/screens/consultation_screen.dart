import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import '../widgets/primary_button.dart';
import 'batch3/batch3_widgets.dart';

/// Port of Consultation.jsx (route /consultation). The web alert() becomes an AlertDialog.
class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  static const joinMessage = 'Your consultation room will open at the scheduled time.';

  @override
  Widget build(BuildContext context) => PageLayout(
        title: 'Consultation',
        eyebrow: 'CARE CONNECT',
        activePath: Routes.appointments,
        description: 'Prepare for your next conversation with a healthcare professional.',
        children: [
          ContentCard(
            kicker: 'UPCOMING CONSULTATION',
            title: 'Dr. Ananya Rao',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('General Physician • Video consultation • Tomorrow at 10:30 AM'),
              const SizedBox(height: 12),
              ActionRow(children: [
                PrimaryButton(
                  label: 'Join Consultation',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (c) => AlertDialog(
                      content: const Text(joinMessage),
                      actions: [TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK'))],
                    ),
                  ),
                ),
                SecondaryButton(label: 'View Appointments', onPressed: () => context.go(Routes.appointments)),
              ]),
            ]),
          ),
          ContentCard(
            title: 'What to keep ready',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final item in const ['Your latest CBC report', 'Current medicines and supplements', 'Questions about symptoms or pregnancy care'])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ]),
                ),
            ]),
          ),
        ],
      );
}
