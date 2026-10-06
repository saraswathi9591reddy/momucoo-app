import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';

/// Port of frontend/src/pages/CarePlan.jsx (static). Web highlights /dashboard in the menu.
class CarePlanScreen extends StatelessWidget {
  const CarePlanScreen({super.key});

  static const _routines = [
    'Take prescribed iron supplement after breakfast',
    'Pair iron-rich foods with vitamin C',
    'Rest and hydrate throughout the day',
  ];

  @override
  Widget build(BuildContext context) => PageLayout(
        title: 'My Care Plan',
        eyebrow: 'PERSONALIZED CARE',
        activePath: Routes.dashboard,
        description: 'A simple plan to support your anemia care journey.',
        children: [
          ContentCard(
            kicker: 'THIS WEEK',
            title: 'Build healthy routines',
            child: Column(children: [
              for (final r in _routines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.check_circle, size: 20, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r)),
                  ]),
                ),
            ]),
          ),
          const ContentCard(
            kicker: 'NEXT REVIEW',
            title: 'Repeat CBC test',
            child: Text('Schedule a follow-up test in 4 weeks and share the result with your doctor.'),
          ),
        ],
      );
}
