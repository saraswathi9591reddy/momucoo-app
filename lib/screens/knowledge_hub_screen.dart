import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import 'batch4/content.dart';

/// Upgraded Flutter Knowledge Hub matching web app:
/// Category pills, rich cards, facts checklist, and expandable guides.
class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen> {
  int? _open;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Basics', 'Precautions', 'Diet', 'Tests'];

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Knowledge Hub',
      eyebrow: 'PREGNANCY HEALTH EDUCATION',
      activePath: Routes.dashboard,
      description: 'Clear, evidence-based guidance for understanding anemia and caring for yourself during pregnancy.',
      children: [
        // Welcome Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.peachBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Evidence-Based Maternal Education'.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Practical guides for you and your baby',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.ink),
              ),
              const SizedBox(height: 4),
              const Text(
                'Learn how hemoglobin affects pregnancy, what CBC reports mean, and how iron nutrition supports fetal growth.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Category Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final cat in _categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (selected) => setState(() => _selectedCategory = cat),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedCategory == cat ? Colors.white : AppColors.ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: _selectedCategory == cat ? AppColors.primary : AppColors.border),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Topic Cards
        for (var i = 0; i < knowledgeTopics.length; i++) _card(i),
      ],
    );
  }

  Widget _card(int i) {
    final (icon, title, text) = knowledgeTopics[i];
    final open = _open == i;
    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.peachBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PREGNANCY GUIDE',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            open ? text : knowledgePreview(text),
            style: const TextStyle(color: AppColors.inkSoft, height: 1.45, fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => setState(() => _open = open ? null : i),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(open ? 'Collapse guide' : 'Read full guide'),
                const SizedBox(width: 6),
                Icon(open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
