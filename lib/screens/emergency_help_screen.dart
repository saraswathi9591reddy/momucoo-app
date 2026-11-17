import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/localization.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Fully localized Emergency Help screen.
class EmergencyHelpScreen extends StatelessWidget {
  const EmergencyHelpScreen({super.key});

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
      SnackBar(content: Text('${LocalizationService.tr('dial')} $number ${LocalizationService.tr('number_copied')}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, _, __) {
        final L = LocalizationService.tr;

        final redFlags = [
          L('red_flag_1'),
          L('red_flag_2'),
          L('red_flag_3'),
          L('red_flag_4'),
          L('red_flag_5'),
          L('red_flag_6'),
        ];

        return PageLayout(
          title: L('emergency_help'),
          eyebrow: L('emergency_eyebrow'),
          activePath: Routes.emergency,
          description: L('emergency_desc'),
          children: [
            // 1. Critical Emergency Banner
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
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: Color(0xFFDC2626), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        L('emergency_protocol_title'),
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    L('call_emergency_now'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF991B1B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    L('emergency_banner_desc'),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF7F1D1D), height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _call(context, '112'),
                        icon: const Icon(Icons.phone, size: 18),
                        label: Text(L('call_112'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        label: Text(L('call_108'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
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

            // 2. Red Flags Checklist
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
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFC0392B), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          L('red_flags_title'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (final flag in redFlags)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(color: const Color(0xFFFDE8E6), borderRadius: BorderRadius.circular(4)),
                            child: const Center(child: Text('!', style: TextStyle(color: Color(0xFFC0392B), fontSize: 11, fontWeight: FontWeight.bold))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(flag, style: const TextStyle(fontSize: 13, color: AppColors.ink, height: 1.3))),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L('next_day_review_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  const SizedBox(height: 6),
                  Text(L('next_day_review_desc'), style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
