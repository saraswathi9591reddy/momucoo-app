import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/localization.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Matches frontend/src/pages/Reports.jsx with full multi-language localization.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  void _downloadOrCopy(BuildContext context, Map<String, dynamic> cbc, Map<String, dynamic>? ai) {
    final hb = cbc['hb'] ?? '--';
    final risk = ai?['risk'] ?? 'Screening';
    final text = 'Momucoo Anemia Screening Report\nHb: $hb g/dL\nAssessment: $risk\nDate: ${DateTime.now().toString().split(' ')[0]}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocalizationService.tr('report_copied_msg'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, _, __) {
        final L = LocalizationService.tr;
        final s = AppStorage.instance;
        final cbc = s.readMap(StorageKeys.cbcData) ?? {};
        final ai = s.readMap(StorageKeys.aiResult);

        final hbVal = cbc['hb']?.toString() ?? '11.4';
        final risk = ai?['risk']?.toString() ?? 'Mild Anemia';

        return PageLayout(
          title: L('reports_history'),
          eyebrow: L('patient_portal'),
          description: L('reports_desc'),
          activePath: Routes.reports,
          children: [
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(L('cbc_blood_report'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFD4EFDF), borderRadius: BorderRadius.circular(20)),
                        child: Text(risk, style: const TextStyle(color: Color(0xFF1E8449), fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('${L('cbc_hb')}: $hbVal g/dL', style: const TextStyle(fontSize: 14, color: AppColors.inkSoft)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _downloadOrCopy(context, cbc, ai),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(L('download_pdf_report')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
