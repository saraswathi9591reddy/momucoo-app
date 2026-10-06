import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/risk_engine.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import '../widgets/primary_button.dart';

/// Port of frontend/src/pages/AIAnalysis.jsx. Scoring lives in RiskEngine.
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

  Widget _heading(String title, String tag) => Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text(tag, style: const TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.accent)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final r = _result;
    if (r == null) return const Scaffold(body: Center(child: Text('🤖 Analyzing...')));
    final v = r.scan.values;
    final low = r.risk == 'Low';
    return PageLayout(
      title: 'AI Health Analysis',
      eyebrow: 'HEMACARE AI ENGINE',
      activePath: Routes.aiAnalysis,
      description: 'A preliminary screening based on your symptoms and CBC information.',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 6)),
                alignment: Alignment.center,
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: '${r.score}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  const TextSpan(text: '/100', style: TextStyle(color: AppColors.muted)),
                ])),
              ),
              const SizedBox(height: 12),
              const Text('SCREENING RESULT', style: TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.accent)),
              Text('${r.risk} Risk', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(r.anemiaLikely
                  ? 'This CBC pattern is consistent with anemia risk and should be reviewed by a clinician.'
                  : 'This CBC pattern does not suggest anemia based on the entered values.'),
              const SizedBox(height: 10),
              StatusPill(r.anemiaStatus,
                  color: low ? AppColors.success : AppColors.warning, background: low ? AppColors.successBg : AppColors.peachBg),
            ]),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _heading('Pregnancy scan report', r.scan.uploaded ? 'UPLOADED' : 'NOT UPLOADED'),
              const SizedBox(height: 8),
              if (r.scan.uploaded) ...[
                Text('File: ${r.scan.name}'),
                const SizedBox(height: 8),
                _ScanValue('Gestational age', v['gestationalAge']),
                _ScanValue('Fetal heart rate', v['fetalHeartRate'], unit: 'bpm'),
                _ScanValue('Estimated fetal weight', v['estimatedWeight'], unit: 'g'),
                _ScanValue('BPD', v['biparietalDiameter']),
                _ScanValue('Head circumference', v['headCircumference']),
                _ScanValue('Abdominal circumference', v['abdominalCircumference']),
                _ScanValue('Femur length', v['femurLength']),
              ] else
                const Text('No pregnancy scan was uploaded.'),
            ]),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _heading('🔍 What influenced your result?', '${r.factors.length} FACTORS'),
              const SizedBox(height: 8),
              if (r.factors.isEmpty)
                const Text('No major factors detected from the entered information.')
              else
                for (final f in r.factors)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('✓ ', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                      Expanded(child: Text(f)),
                    ]),
                  ),
            ]),
          ),
        ),
        ContentCard(
          kicker: 'NEXT STEPS',
          title: 'Care recommendations',
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final rec in r.recommendations) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('→ $rec')),
            const SizedBox(height: 8),
            SecondaryButton(label: 'View Nutrition Plan', onPressed: () => context.go(Routes.carePlan)),
            const SizedBox(height: 8),
            SecondaryButton(label: 'Emergency Help', onPressed: () => context.go(Routes.emergency)),
          ]),
        ),
        SecondaryButton(label: '← Review CBC', onPressed: () => context.go(Routes.cbcAnalysis)),
        PrimaryButton(label: 'Share Feedback →', onPressed: () => context.go(Routes.feedback)),
      ],
    );
  }
}

class _ScanValue extends StatelessWidget {
  const _ScanValue(this.label, this.value, {this.unit = ''});
  final String label;
  final dynamic value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final s = (value == null || value == '' || value == 0) ? 'Not detected' : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
        const SizedBox(width: 8),
        Flexible(child: Text('$s $unit'.trim(), textAlign: TextAlign.end)),
      ]),
    );
  }
}
