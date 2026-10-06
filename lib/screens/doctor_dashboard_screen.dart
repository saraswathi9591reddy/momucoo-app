import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import '../widgets/primary_button.dart';
import 'batch3/batch3_widgets.dart';

/// Port of DoctorDashboard.jsx (route /doctor-dashboard).
class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => PageLayout(
        title: 'Doctor Dashboard',
        eyebrow: 'CLINIC OVERVIEW',
        description: 'Review patient activity and follow-ups in one place.',
        children: [
          const StatCard(value: '24', label: 'Active patients'),
          const StatCard(value: '8', label: "Today's appointments"),
          const StatCard(value: '5', label: 'Reports to review'),
          ContentCard(
            title: 'Quick actions',
            child: ActionRow(children: [
              PrimaryButton(label: 'View Patients', onPressed: () => context.go(Routes.doctorPatients)),
              SecondaryButton(label: 'Review Reports', onPressed: () => context.go(Routes.doctorReview)),
            ]),
          ),
        ],
      );
}
