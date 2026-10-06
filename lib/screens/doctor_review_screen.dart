import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import '../widgets/primary_button.dart';

/// Port of DoctorReview.jsx (route /doctor-review). Static; Save has no handler on web.
class DoctorReviewScreen extends StatelessWidget {
  const DoctorReviewScreen({super.key});

  @override
  Widget build(BuildContext context) => PageLayout(
        title: 'Report Review',
        eyebrow: 'CLINICAL REVIEW',
        description: 'Review flagged screening results and add a clinical note.',
        children: [
          ContentCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const ListRow(title: 'Ananya Sharma', subtitle: 'Hemoglobin 9.2 g/dL • Moderate risk'),
              const Align(
                alignment: Alignment.centerLeft,
                child: StatusPill('Needs review', color: AppColors.warning, background: AppColors.peachBg),
              ),
              const SizedBox(height: 12),
              const TextField(minLines: 3, maxLines: 6, decoration: InputDecoration(hintText: 'Add a note for the patient')),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Save Review', onPressed: () {}),
            ]),
          ),
        ],
      );
}
