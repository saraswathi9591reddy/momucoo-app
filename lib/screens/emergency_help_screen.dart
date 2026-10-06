import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import 'batch4/content.dart';

/// Port of frontend/src/pages/EmergencyHelp.jsx (route /emergency).
/// Dials 112 via url_launcher; if that fails, copies the number and shows a SnackBar.
class EmergencyHelpScreen extends StatelessWidget {
  const EmergencyHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Emergency Help',
      eyebrow: 'URGENT SUPPORT',
      activePath: Routes.dashboard,
      description: 'Get immediate help when symptoms feel severe or sudden.',
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFDECEF),
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🚨', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Call emergency services', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('If you have chest pain, severe breathlessness, fainting, or heavy bleeding, call your local emergency number now.'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  icon: const Icon(Icons.call),
                  label: const Text('Call $emergencyNumber'),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    var launched = false;
                    try {
                      launched = await launchUrl(Uri.parse('tel:$emergencyNumber'));
                    } catch (_) {
                      launched = false;
                    }
                    if (launched) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Dial $emergencyNumber now. The number has been copied.')),
                    );
                    Clipboard.setData(const ClipboardData(text: emergencyNumber));
                  },
                ),
              ]),
            ),
          ]),
        ),
        const ContentCard(
          title: 'Non-urgent support',
          child: Text('For questions about your results, contact your doctor or book a consultation.'),
        ),
      ],
    );
  }
}
