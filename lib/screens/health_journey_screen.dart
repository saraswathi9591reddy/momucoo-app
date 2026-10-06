import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Port of frontend/src/pages/HealthJourney.jsx (static).
class HealthJourneyScreen extends StatelessWidget {
  const HealthJourneyScreen({super.key});

  static const _steps = [
    ('01', 'Health check completed', 'Symptoms recorded on 03 Sep 2026', true),
    ('02', 'CBC report analyzed', 'Latest hemoglobin: 9.2 g/dL', true),
    ('03', 'Consult a doctor', 'Book a consultation to discuss your results.', false),
  ];

  @override
  Widget build(BuildContext context) => PageLayout(
        title: 'Health Journey',
        eyebrow: 'YOUR PROGRESS',
        activePath: Routes.healthJourney,
        description: 'See the milestones you have completed on your care journey.',
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                for (final s in _steps)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CircleAvatar(
                        backgroundColor: s.$4 ? AppColors.success : AppColors.border,
                        child: Text(s.$1, style: TextStyle(color: s.$4 ? Colors.white : AppColors.ink, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s.$2, style: Theme.of(context).textTheme.titleMedium),
                          Text(s.$3, style: const TextStyle(color: AppColors.muted)),
                        ]),
                      ),
                    ]),
                  ),
              ]),
            ),
          ),
        ],
      );
}
