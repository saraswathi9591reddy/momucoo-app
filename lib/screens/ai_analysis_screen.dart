import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/risk_engine.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Port of frontend/src/pages/AIAnalysis.jsx
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

  // Category config matching web AIAnalysis.jsx
  Map<String, dynamic> _categoryConfig(String risk) {
    switch (risk) {
      case 'Low':
        return {
          'label': 'No Anemia Detected',
          'description':
              'Your haemoglobin level is within the normal range for pregnancy (≥ 11.0 g/dL per WHO 2011 guidelines).',
          'color': const Color(0xFF27AE60),
          'bgColor': const Color(0xFFD4EFDF),
          'icon': Icons.check_circle,
        };
      case 'Moderate':
        return {
          'label': 'Mild Anemia',
          'description':
              'Your haemoglobin is between 10.0–10.9 g/dL. Mild anemia during pregnancy should be discussed with your doctor.',
          'color': const Color(0xFFE67E22),
          'bgColor': const Color(0xFFFEF9E7),
          'icon': Icons.warning_amber_rounded,
        };
      case 'High':
        return {
          'label': 'Severe Anemia',
          'description':
              'Your haemoglobin is below 7.0 g/dL. Severe anemia is a medical emergency. Seek immediate care.',
          'color': AppColors.primary,
          'bgColor': const Color(0xFFFDEDEC),
          'icon': Icons.warning_rounded,
        };
      default:
        return {
          'label': 'Insufficient Data',
          'description':
              'Haemoglobin value was not provided. Enter CBC values for a complete assessment.',
          'color': const Color(0xFF2980B9),
          'bgColor': const Color(0xFFEBF5FB),
          'icon': Icons.info_outline,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    if (r == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final config = _categoryConfig(r.risk);
    final Color catColor = config['color'] as Color;
    final Color catBg = config['bgColor'] as Color;
    final IconData catIcon = config['icon'] as IconData;

    final cbc = AppStorage.instance.readMap(StorageKeys.cbcData) ?? {};

    return PageLayout(
      title: 'Screening Result',
      eyebrow: 'MOMUCOO • PATIENT PORTAL',
      activePath: Routes.aiAnalysis,
      description: 'Clinical rule-based preliminary screening — WHO 2011 guidelines',
      children: [
        // Emergency flag
        if (r.anemiaLikely && r.risk == 'High')
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEDEC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Emergency symptoms reported. Seek immediate medical attention. '
                    'Do not rely on this screening tool during a medical emergency.',
                    style: TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

        // Result banner — matches web result-banner
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: catBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: catColor.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: catColor.withOpacity(0.15),
                ),
                child: Icon(catIcon, color: catColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preliminary Screening Result',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config['label'] as String,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: catColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      config['description'] as String,
                      style: const TextStyle(fontSize: 14, color: AppColors.ink),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (cbc['hb'] != null)
                          _Badge('Hb: ${cbc['hb']} g/dL', catColor, catBg),
                        _Badge('WHO 2011 (NMH/NHD/MNM/11.1)', const Color(0xFF2980B9),
                            const Color(0xFFEBF5FB)),
                        _Badge('${r.risk} Risk', catColor, catBg),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // CBC Values + Symptoms row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CBC values
            Expanded(
              child: _SectionCard(
                title: '📋 CBC Report Values',
                child: cbc.isEmpty
                    ? const Text(
                        'No CBC values entered yet.',
                        style: TextStyle(color: AppColors.muted, fontSize: 14),
                      )
                    : Column(
                        children: [
                          for (final entry in [
                            ('Haemoglobin', cbc['hb'], 'g/dL'),
                            ('RBC', cbc['rbc'], 'M/µL'),
                            ('MCV', cbc['mcv'], 'fL'),
                            ('MCH', cbc['mch'], 'pg'),
                            ('MCHC', cbc['mchc'], 'g/dL'),
                            ('Hematocrit', cbc['hematocrit'], '%'),
                            ('RDW', cbc['rdw'], '%'),
                            ('Ferritin', cbc['ferritin'], 'ng/mL'),
                          ].where((e) => e.$2 != null && e.$2.toString().isNotEmpty))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.$1,
                                      style: const TextStyle(
                                          fontSize: 13, color: AppColors.muted)),
                                  Text('${entry.$2} ${entry.$3}',
                                      style: const TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Symptoms
            Expanded(
              child: _SectionCard(
                title: '📊 Reported Symptoms',
                child: r.factors.isEmpty
                    ? const Text(
                        'No symptoms flagged.',
                        style: TextStyle(color: AppColors.muted, fontSize: 14),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Present:',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                          const SizedBox(height: 6),
                          for (final f in r.factors)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      size: 14, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                      child: Text(f,
                                          style: const TextStyle(
                                              fontSize: 13, color: AppColors.primary))),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Assessment Factors
        if (r.factors.isNotEmpty)
          _SectionCard(
            title: 'ℹ️ Assessment Factors',
            child: Column(
              children: [
                for (final f in r.factors)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ',
                            style: TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.w700)),
                        Expanded(child: Text(f, style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),

        // Recommendations
        if (r.recommendations.isNotEmpty)
          _SectionCard(
            title: '✅ Recommendations',
            child: Column(
              children: [
                for (final rec in r.recommendations)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FFF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA9DFBF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 16, color: Color(0xFF27AE60)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(rec,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF1a4731)))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF5FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFA9CCE3)),
          ),
          child: const Text(
            'Important Disclaimer: This is a preliminary clinical rule-based screening using '
            'WHO 2011 haemoglobin thresholds. It is NOT a medical diagnosis. Always consult a '
            'qualified healthcare professional for diagnosis and treatment.',
            style: TextStyle(fontSize: 13, color: Color(0xFF1A5276)),
          ),
        ),
        const SizedBox(height: 20),

        // Action buttons
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Download PDF Report'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5D4CE)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.go(Routes.cbcAnalysis),
              child: const Text('New Screening'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1ABC9C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.go(Routes.reports),
              child: const Text('View All Reports'),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5D4CE)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.go(Routes.dashboard),
              icon: const Icon(Icons.chevron_left, size: 16),
              label: const Text('Dashboard'),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color, this.bg);
  final String label;
  final Color color, bg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}
