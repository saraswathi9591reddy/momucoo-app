import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import '../widgets/primary_button.dart';
import 'batch3/batch3_widgets.dart';
import 'batch3/mock_data.dart';

/// Port of FindDoctor.jsx (route /find-doctor).
class FindDoctorScreen extends StatefulWidget {
  const FindDoctorScreen({super.key});

  @override
  State<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends State<FindDoctorScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final q = _search.toLowerCase();
    final filtered = doctors.where((d) => '${d.name} ${d.specialty}'.toLowerCase().contains(q)).toList();
    return PageLayout(
      title: 'Find the right doctor',
      eyebrow: 'CARE CONNECT',
      activePath: Routes.findDoctor,
      description: 'Connect with a healthcare professional for a closer review of your screening results.',
      children: [
        SearchField(hint: 'Search by doctor or specialty', icon: true, onChanged: (v) => setState(() => _search = v)),
        for (final d in filtered)
          ContentCard(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CircleAvatar(radius: 26, backgroundColor: AppColors.peachBg, child: Text('👨‍⚕️', style: TextStyle(fontSize: 24))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(d.specialty, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('⭐ ${d.rating} • ${d.experience}', style: const TextStyle(color: AppColors.muted)),
                  Text('🟢 Available ${d.available}', style: const TextStyle(color: AppColors.success)),
                  const SizedBox(height: 10),
                  PrimaryButton(label: 'Book Appointment →', onPressed: () => context.go(Routes.appointments)),
                ]),
              ),
            ]),
          ),
        if (filtered.isEmpty) const ContentCard(title: 'No doctors found', child: Text('Try a different name or specialty.')),
      ],
    );
  }
}
