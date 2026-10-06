import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/models/models.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';

/// Port of frontend/src/pages/Dashboard.jsx (route /dashboard, also the fallback route).
/// The web page's own sidebar is replaced by PageLayout's bottom nav + drawer.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStorage.instance;
    final profile = s.profileOr('Ananya Sharma');
    final pregnancy = s.readMap(StorageKeys.pregnancyData);
    final cbc = s.readMap(StorageKeys.cbcData);
    final scan = s.readMap(StorageKeys.scanData);
    final ai = s.readMap(StorageKeys.aiResult);
    final scanUploaded = scan != null && jsTruthy(scan['uploaded']);
    final symptomCount = (pregnancy?['symptoms'] as List?)?.length ?? 0;
    final week = pregnancy?['week'];

    return PageLayout(
      title: profile.name,
      eyebrow: 'PATIENT',
      activePath: Routes.dashboard,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('YOUR HEALTH JOURNEY',
                  style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Take control of your health today.',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Georgia', fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Check your symptoms, analyze your CBC and understand your pregnancy health.',
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                onPressed: () => context.go(Routes.healthCheck),
                child: const Text('Start Health Check →'),
              ),
            ],
          ),
        ),
        ContentCard(
          kicker: 'PATIENT HISTORY',
          title: 'Completed health analysis',
          child: Column(
            children: [
              HistoryItem(
                done: pregnancy != null,
                icon: '💬',
                title: 'Pregnancy symptom chat',
                detail: pregnancy != null
                    ? 'Week ${jsTruthy(week) ? week : 'not entered'} • $symptomCount symptom(s)'
                    : 'Not completed',
                onTap: () => context.go(Routes.healthCheck),
              ),
              HistoryItem(
                done: cbc != null,
                icon: '🩸',
                title: 'CBC blood report',
                detail: cbc != null ? 'Hemoglobin ${cbc['hb'] ?? ''} g/dL • Latest report' : 'Not uploaded',
                onTap: () => context.go(Routes.cbcAnalysis),
              ),
              HistoryItem(
                done: scanUploaded,
                icon: '🖥️',
                title: 'Pregnancy scan report',
                detail: scanUploaded ? '${scan['name'] ?? ''}' : 'Optional report not uploaded',
                onTap: () => context.go(Routes.cbcAnalysis),
              ),
              HistoryItem(
                done: ai != null,
                icon: '🤖',
                title: 'AI anemia risk analysis',
                detail: ai != null ? '${ai['risk']} risk • Score ${ai['score']}/100' : 'Waiting for CBC analysis',
                onTap: () => context.go(Routes.aiAnalysis),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: () => context.go(Routes.reports), child: const Text('View all reports →')),
              ),
            ],
          ),
        ),
        ContentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text('🤖 AI Health Insight', style: Theme.of(context).textTheme.titleLarge)),
                const StatusPill('NEW', color: AppColors.primary, background: AppColors.peachBg),
              ]),
              const SizedBox(height: 8),
              const Text('Your latest CBC values show a pattern that may need professional evaluation.',
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 10),
              for (final f in const ['🔴 Low hemoglobin', '🟠 Low MCV', '🟡 Fatigue reported'])
                Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(f)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => context.go(Routes.aiAnalysis), child: const Text('View Full Analysis →')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Web `HistoryItem` button with done state.
class HistoryItem extends StatelessWidget {
  const HistoryItem({super.key, required this.done, required this.icon, required this.title, required this.detail, this.onTap});
  final bool done;
  final String icon, title, detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: done ? AppColors.successBg : AppColors.cream,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Text(icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(detail, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  ]),
                ),
                Text(done ? '✓' : '→',
                    style: TextStyle(fontWeight: FontWeight.w700, color: done ? AppColors.success : AppColors.muted)),
              ]),
            ),
          ),
        ),
      );
}
