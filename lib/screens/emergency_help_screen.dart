import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Port of frontend/src/pages/EmergencyHelp.jsx (route /emergency).
/// Matches the web app emergency protocol with 112/108 call actions,
/// red flag symptoms checklist, and next-day clinical review card.
class EmergencyHelpScreen extends StatelessWidget {
  const EmergencyHelpScreen({super.key});

  static const _redFlags = [
    'Sudden or severe chest pain or pressure',
    'Extreme shortness of breath even while sitting or resting',
    'Fainting, collapse, or loss of consciousness',
    'Coughing up blood or acute difficulty breathing',
    'Unusual vaginal bleeding or sudden severe abdominal pain',
    'Rapid, fluttering heartbeat accompanied by dizziness',
  ];

  Future<void> _call(BuildContext context, String number) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    } catch (_) {}
    await Clipboard.setData(ClipboardData(text: number));
    messenger.showSnackBar(
      SnackBar(content: Text('Dial $number now. Number copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Emergency Medical Help',
      eyebrow: 'MOMUCOO • URGENT PROTOCOL',
      activePath: Routes.emergency,
      description: 'Immediate clinical guidance and contact lines when symptoms feel severe or acute.',
      children: [
        // 1. Critical Emergency Banner (matching web app)
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEF4444), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFFDC2626), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'LIFE-THREATENING EMERGENCY PROTOCOL',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Call Emergency Services Immediately (112 / 108)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF991B1B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'If you experience severe acute symptoms during pregnancy, do not wait for an online screening or appointment. Contact your nearest hospital emergency department or dial your regional emergency line right now.',
                style: TextStyle(fontSize: 13, color: Color(0xFF7F1D1D), height: 1.4),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _call(context, '112'),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call Emergency (112)', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _call(context, '108'),
                    icon: const Icon(Icons.emergency, size: 18, color: Color(0xFFDC2626)),
                    label: const Text('Ambulance (108)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Red Flags Checklist Card
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
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFC0392B), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Red Flag Symptoms Requiring Urgent Care',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final flag in _redFlags)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8E6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text('!', style: TextStyle(color: Color(0xFFC0392B), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          flag,
                          style: const TextStyle(fontSize: 13, color: AppColors.ink, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // 3. Clinical Review Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFCF9F7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5D4CE)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next-Day Clinical Review Guidance',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
              ),
              SizedBox(height: 6),
              Text(
                'If symptoms are moderate (mild fatigue, pale skin, occasional headaches), schedule an in-person appointment with your obstetrician within 24–48 hours and request a complete blood count (CBC) with serum ferritin check.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
