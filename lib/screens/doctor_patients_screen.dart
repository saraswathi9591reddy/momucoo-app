import 'package:flutter/material.dart';

import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import '../widgets/primary_button.dart';
import 'batch3/batch3_widgets.dart';
import 'batch3/mock_data.dart';

/// Port of DoctorPatients.jsx (route /doctor-patients).
class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final q = _search.toLowerCase();
    final list = doctorPatients.where((n) => n.toLowerCase().contains(q));
    return PageLayout(
      title: 'Patients',
      eyebrow: 'PATIENT DIRECTORY',
      description: 'Search and open patient records for review.',
      children: [
        ContentCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SearchField(hint: 'Search patients', onChanged: (v) => setState(() => _search = v)),
            const SizedBox(height: 8),
            for (final name in list) ...[
              ListRow(title: name, subtitle: 'Last CBC: 12 Aug 2026'),
              // The web button has no click handler.
              Align(alignment: Alignment.centerLeft, child: SecondaryButton(label: 'Open record', onPressed: () {})),
            ],
          ]),
        ),
      ],
    );
  }
}
