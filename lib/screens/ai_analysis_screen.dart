import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/localization.dart';
import '../core/risk_engine.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Port of frontend/src/pages/AIAnalysis.jsx with full localization.
class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  RiskResult? _result;

  @override
  void initState() {
    super.initState();
    final s = AppStorage.instance;
    final result = RiskEngine.evaluate(
      cbc: s.readMap(StorageKeys.cbcData) ?? {},
      pregnancy: s.readMap(StorageKeys.pregnancyData) ?? {},
      scan: s.readMap(StorageKeys.scanData) ?? {},
      legacySymptoms: s.legacySymptoms,
    );
    _result = result;
    s.saveAiResult(result.toAiResult(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, _, __) {
        final L = LocalizationService.tr;
        final res = _result;

        final riskStr = res?.risk ?? 'Moderate';
        String label = L('no_anemia_detected');
        String desc = L('res_no_anemia_desc');
        Color color = const Color(0xFF27AE60);
        Color bgColor = const Color(0xFFD4EFDF);
        IconData icon = Icons.check_circle;

        if (riskStr == 'Moderate') {
          label = L('mild_anemia');
          desc = L('res_mild_desc');
          color = const Color(0xFFE67E22);
          bgColor = const Color(0xFFFEF9E7);
          icon = Icons.warning_amber_rounded;
        } else if (riskStr == 'High') {
          label = L('severe_anemia');
          desc = L('res_severe_desc');
          color = AppColors.primary;
          bgColor = const Color(0xFFFDEDEC);
          icon = Icons.warning_rounded;
        }

        return PageLayout(
          title: L('screening_results'),
          eyebrow: L('patient_portal'),
          description: L('screening_desc'),
          activePath: Routes.aiAnalysis,
          children: [
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                            Text(
                              '${L('score')}: ${res?.score ?? 0}/100',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go(Routes.reports),
              icon: const Icon(Icons.folder_open_outlined),
              label: Text(L('view_reports_history')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
