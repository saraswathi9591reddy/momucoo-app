import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import 'batch4/content.dart';

/// Port of frontend/src/pages/KnowledgeHub.jsx (route /knowledge-hub).
class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen> {
  int? _open;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Knowledge Hub',
      eyebrow: 'PREGNANCY HEALTH EDUCATION',
      activePath: Routes.dashboard,
      description: 'Simple, reliable guidance for understanding anemia and caring for yourself during pregnancy.',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.peachBg, borderRadius: BorderRadius.circular(16)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Learn at your pace', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
            SizedBox(height: 4),
            Text('Open a guide to read practical information before your next checkup.', style: TextStyle(color: AppColors.muted)),
          ]),
        ),
        for (var i = 0; i < knowledgeTopics.length; i++) _card(i),
      ],
    );
  }

  Widget _card(int i) {
    final (icon, title, text) = knowledgeTopics[i];
    final open = _open == i;
    return ContentCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        const Text('PREGNANCY GUIDE', style: TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.accent)),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(open ? text : knowledgePreview(text), style: const TextStyle(color: AppColors.inkSoft, height: 1.4)),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: AppColors.primary),
          onPressed: () => setState(() => _open = open ? null : i),
          child: Text(open ? 'Close guide ↑' : 'Read guide →'),
        ),
      ]),
    );
  }
}
