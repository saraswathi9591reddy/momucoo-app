import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import '../widgets/primary_button.dart';
import 'batch3/batch3_widgets.dart';

/// Port of Appointments.jsx (route /appointments).
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool _booked = false;

  @override
  Widget build(BuildContext context) => PageLayout(
        title: 'Appointments',
        eyebrow: 'CARE CONNECT',
        activePath: Routes.appointments,
        description: 'Manage your upcoming conversations with healthcare professionals.',
        children: [
          ContentCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const ListRow(title: 'Dr. Ananya Rao', subtitle: 'General Physician • Tomorrow, 10:30 AM • Video'),
              const Align(alignment: Alignment.centerLeft, child: StatusPill('Confirmed')),
              const SizedBox(height: 12),
              ActionRow(children: [
                PrimaryButton(label: 'View Consultation', onPressed: () => context.go(Routes.consultation)),
                SecondaryButton(label: 'Reschedule', onPressed: () => setState(() => _booked = true)),
              ]),
              if (_booked) ...[
                const SizedBox(height: 12),
                const Text('Rescheduling options will be sent to your registered contact.', style: TextStyle(color: AppColors.success)),
              ],
            ]),
          ),
          ContentCard(
            title: 'Need a new appointment?',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Find a doctor based on specialty, availability, and experience.'),
              const SizedBox(height: 12),
              SecondaryButton(label: 'Find a Doctor →', onPressed: () => context.go(Routes.findDoctor)),
            ]),
          ),
        ],
      );
}
