import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';

/// Port of frontend/src/pages/ProgressTracking.jsx (static).
class ProgressTrackingScreen extends StatelessWidget {
  const ProgressTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) => PageLayout(
        title: 'Progress Tracking',
        eyebrow: 'HEALTH TRENDS',
        activePath: Routes.progressTracking,
        description: 'Track your latest measurements and follow-up milestones.',
        children: [
          ContentCard(
            kicker: 'HEMOGLOBIN',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text('9.2 g/dL', style: Theme.of(context).textTheme.headlineSmall),
                  const StatusPill('Needs attention', color: AppColors.warning, background: AppColors.peachBg),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(10)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Text('10.1'),
                  Text('9.6'),
                  Text('9.2', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ]),
              ),
              const SizedBox(height: 12),
              const Text('Your next measurement will help show whether your care plan is working.'),
            ]),
          ),
        ],
      );
}
