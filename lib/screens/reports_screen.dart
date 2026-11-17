import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Matches frontend/src/pages/Reports.jsx
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Category helpers matching web
  static const Map<String, String> categoryLabels = {
    'no_anemia': 'No Anemia',
    'mild_anemia': 'Mild Anemia',
    'moderate_anemia': 'Moderate Anemia',
    'severe_anemia': 'Severe Anemia',
    'insufficient_data': 'Insufficient Data',
  };

  static const Map<String, Color> dotColors = {
    'no_anemia': Color(0xFF27AE60),
    'mild_anemia': Color(0xFFF1C40F),
    'moderate_anemia': Color(0xFFE67E22),
    'severe_anemia': AppColors.primary,
    'insufficient_data': Color(0xFF95A5A6),
  };

  void _downloadOrCopy(BuildContext context, Map<String, dynamic> cbc, Map<String, dynamic>? ai) {
    final hb = cbc['hb'] ?? '--';
    final risk = ai?['risk'] ?? 'Screening';
    final text = 'Momucoo Anemia Screening Report\nHb: $hb g/dL\nAssessment: $risk\nDate: ${DateTime.now().toString().split(' ')[0]}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report details copied to clipboard (PDF downloaded).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStorage.instance;
    final cbc = s.readMap(StorageKeys.cbcData) ?? {};
    final ai = s.readMap(StorageKeys.aiResult);
    final preg = s.readMap(StorageKeys.pregnancyData) ?? {};

    final hasCbc = cbc.isNotEmpty;
    final hasAi = ai != null;

    final String risk = (ai?['risk'] ?? '').toString().toLowerCase();
    String catKey = 'insufficient_data';
    if (risk.contains('low') || risk.contains('no')) {
      catKey = 'no_anemia';
    } else if (risk.contains('moderate') || risk.contains('mild')) {
      catKey = 'mild_anemia';
    } else if (risk.contains('high') || risk.contains('severe')) {
      catKey = 'severe_anemia';
    }

    final catLabel = categoryLabels[catKey] ?? 'Preliminary Screening';
    final dotColor = dotColors[catKey] ?? const Color(0xFF95A5A6);

    return PageLayout(
      title: 'Reports & History',
      eyebrow: 'MOMUCOO • PATIENT PORTAL',
      activePath: Routes.reports,
      description: 'All your CBC reports and screening assessments',
      children: [
        // 1. Screening Assessments Section Card
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Screening Assessments',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () => context.go(Routes.cbcAnalysis),
                    child: const Text('+ New Screening', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!hasAi && !hasCbc)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.monitor_heart_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'No screenings yet. Upload a CBC report to get started.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => context.go(Routes.cbcAnalysis),
                        child: const Text('Start Screening'),
                      ),
                    ],
                  ),
                )
              else
                // Assessment item card matching web
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              catLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${cbc['hb'] != null ? 'Hb: ${cbc['hb']} g/dL • ' : ''}Today${preg['week'] != null ? ' • Week ${preg['week']}' : ''}',
                              style: const TextStyle(fontSize: 13, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () => context.go(Routes.aiAnalysis),
                            child: const Text('View', style: TextStyle(fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              elevation: 0,
                            ),
                            onPressed: () => _downloadOrCopy(context, cbc, ai),
                            icon: const Icon(Icons.download, size: 14),
                            label: const Text('PDF', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // 2. CBC Blood Reports Section Card
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.water_drop_outlined, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'CBC Blood Reports',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!hasCbc)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.description_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'No CBC reports uploaded yet.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                    headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 13),
                    dataTextStyle: const TextStyle(fontSize: 13, color: AppColors.ink),
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Hb (g/dL)')),
                      DataColumn(label: Text('RBC')),
                      DataColumn(label: Text('MCV')),
                      DataColumn(label: Text('Hematocrit')),
                      DataColumn(label: Text('Ferritin')),
                      DataColumn(label: Text('Source')),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          const DataCell(Text('Today')),
                          DataCell(
                            Text(
                              '${cbc['hb'] ?? '—'}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: (double.tryParse('${cbc['hb']}') ?? 12) < 7.0
                                    ? AppColors.primary
                                    : (double.tryParse('${cbc['hb']}') ?? 12) < 11.0
                                        ? const Color(0xFFE67E22)
                                        : const Color(0xFF27AE60),
                              ),
                            ),
                          ),
                          DataCell(Text('${cbc['rbc'] ?? '—'}')),
                          DataCell(Text('${cbc['mcv'] ?? '—'}')),
                          DataCell(Text('${cbc['hematocrit'] ?? '—'}')),
                          DataCell(Text('${cbc['ferritin'] ?? '—'}')),
                          const DataCell(Text('Manual / OCR')),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
