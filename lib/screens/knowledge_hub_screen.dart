import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

class KnowledgeHubTopic {
  final String id;
  final String category;
  final String icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String summary;
  final List<String> keyPoints;
  final String fullText;

  const KnowledgeHubTopic({
    required this.id,
    required this.category,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.summary,
    required this.keyPoints,
    required this.fullText,
  });
}

class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen> {
  String _selectedCategory = 'All';
  final Set<String> _expandedIds = {};

  static const List<String> categories = [
    'All',
    'Basics',
    'Precautions',
    'Diet',
    'Tests',
    'Checkup',
  ];

  static const List<KnowledgeHubTopic> topics = [
    KnowledgeHubTopic(
      id: 'anemia-basics',
      category: 'Basics',
      icon: '🩸',
      color: Color(0xFFE74C3C),
      bgColor: Color(0xFFFDEDEC),
      title: 'Anemia During Pregnancy: What It Means',
      summary:
          'During pregnancy, your body produces more blood to support your baby. When iron levels are low, oxygen delivery drops.',
      keyPoints: [
        'Blood volume increases by ~40–50% during pregnancy',
        'Iron requirements jump from 18 mg to 27 mg daily',
        'Normal WHO threshold for pregnant women is Hb ≥ 11.0 g/dL',
        'Early screening prevents maternal exhaustion and preterm complications',
      ],
      fullText:
          'Anemia occurs when your blood does not have enough healthy red blood cells or hemoglobin to carry adequate oxygen throughout your tissues and to your growing baby. During pregnancy, mild iron depletion is very common, but moderate or severe anemia can increase the risk of fatigue, low birth weight, and postpartum complications. Regular CBC blood tests catch changes early so simple dietary steps or physician-approved iron supplements can restore balance.',
    ),
    KnowledgeHubTopic(
      id: 'warning-signs',
      category: 'Precautions',
      icon: '🛡️',
      color: Color(0xFFE67E22),
      bgColor: Color(0xFFFEF9E7),
      title: 'Warning Signs & When to Call Your Doctor',
      summary:
          'Recognize typical pregnancy tiredness versus symptoms that warrant urgent clinical attention.',
      keyPoints: [
        'Normal: mild fatigue improved by rest and hydration',
        'Requires checkup: severe dizziness, pale skin/gums, rapid heartbeat',
        'Emergency red flags: chest pain, extreme breathlessness, or fainting',
        'Never start high-dose iron pills without your doctor’s confirmation',
      ],
      fullText:
          'While fatigue is a frequent pregnancy companion, severe or worsening exhaustion should never be ignored. If you notice unusual shortness of breath during light walks, cold hands and feet, brittle nails, or pale inner eyelids, consult your healthcare provider promptly. For emergency signs like sudden chest pressure, acute breathlessness at rest, or fainting spells, seek hospital emergency care immediately.',
    ),
    KnowledgeHubTopic(
      id: 'nutrition-guide',
      category: 'Diet',
      icon: '🥗',
      color: Color(0xFF27AE60),
      bgColor: Color(0xFFEAFAF1),
      title: 'Iron-Rich Foods & Smart Absorption',
      summary:
          'How to maximize natural iron intake through balanced daily meals and vitamin C pairings.',
      keyPoints: [
        'Plant iron: Spinach, lentils (dal), chickpeas, beans, jaggery',
        'Animal iron: Lean poultry, eggs, fish (highly absorbable)',
        'Booster: Pair with Vitamin C (oranges, amla, guava, lemon, tomatoes)',
        'Blockers: Avoid tea, coffee, or calcium pills within 1 hour of meals',
      ],
      fullText:
          'Dietary iron comes in two forms: heme (from eggs and meats) and non-heme (from plant sources like lentils, leafy greens, fortified cereals, and jaggery). Because non-heme iron is absorbed less efficiently, pairing meals with vitamin C rich foods (like a squeeze of fresh lemon on dal or an orange slice) multiplies absorption up to three times. Keep tannins in tea and coffee away from your main meals as they bind to iron and block absorption.',
    ),
    KnowledgeHubTopic(
      id: 'understanding-cbc',
      category: 'Tests',
      icon: '📋',
      color: Color(0xFF2980B9),
      bgColor: Color(0xFFEBF5FB),
      title: 'Understanding Your Complete Blood Count (CBC)',
      summary:
          'Decode hemoglobin (Hb), RBC, MCV, and hematocrit values from your lab printout.',
      keyPoints: [
        'Hb (Haemoglobin): Main screening marker (WHO standard: ≥ 11.0 g/dL)',
        'MCV (Mean Corpuscular Volume): Size of red blood cells',
        'MCH & MCHC: Density of hemoglobin per cell',
        'RDW (Red Cell Distribution): Variation in cell size',
      ],
      fullText:
          'Your laboratory CBC report contains several key indicators. Hemoglobin (Hb) reflects the oxygen-carrying capacity of your blood and is the gold standard for anemia screening. Low MCV alongside low Hb often points toward microcytic iron deficiency anemia, whereas elevated MCV can suggest folate or Vitamin B12 deficiency. Your doctor analyzes these values together along with your gestational age.',
    ),
    KnowledgeHubTopic(
      id: 'doctor-prep',
      category: 'Checkup',
      icon: '📞',
      color: Color(0xFF8E44AD),
      bgColor: Color(0xFFF5EEF8),
      title: 'Preparing for Your Doctor Checkup',
      summary:
          'How to make the most of your prenatal consultations with organized reports and symptom notes.',
      keyPoints: [
        'Bring recent CBC reports and ultrasound gestational age notes',
        'Note any dizziness, restless legs, or palpitations',
        'List all current prenatal vitamins and supplements',
        'Ask about follow-up blood retests in the second & third trimesters',
      ],
      fullText:
          'Having your latest blood reports and scan results ready makes doctor visits much more productive. You can download and print your Momucoo Screening PDF report to share with your obstetrician. Always let your doctor know about any supplements you are taking, and discuss whether an oral iron supplement or adjustment to your prenatal vitamin regimen is appropriate.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTopics = _selectedCategory == 'All'
        ? topics
        : topics.where((t) => t.category == _selectedCategory).toList();

    return PageLayout(
      title: 'Knowledge Hub',
      eyebrow: 'MOMUCOO • PATIENT PORTAL',
      activePath: Routes.knowledgeHub,
      description:
          'Clear, evidence-based guidance for understanding anemia, nutrition, and maternal wellness during pregnancy.',
      children: [
        // Hero Welcome Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF5F2), Color(0xFFFFF9F5)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF5D5CB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'EVIDENCE-BASED MATERNAL EDUCATION',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Practical guides to care for yourself and your baby',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Learn how hemoglobin affects pregnancy, what your CBC report means, and how simple dietary steps help maintain healthy iron levels.',
                style: TextStyle(color: Color(0xFF4B5563), fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Category Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final cat in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedCategory == cat ? Colors.white : const Color(0xFF4B5563),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: _selectedCategory == cat ? AppColors.primary : const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Topics List (Filtered based on selection)
        if (filteredTopics.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            alignment: Alignment.center,
            child: Text(
              'No guides found for "$_selectedCategory".',
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          )
        else
          for (final topic in filteredTopics) ...[
            _buildTopicCard(topic),
            const SizedBox(height: 14),
          ],

        // WHO Guideline Disclaimer Note matching web
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.help_outline_rounded, color: Color(0xFF6C757D), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Information is sourced from World Health Organization (WHO 2011) Guidelines (WHO/NMH/NHD/MNM/11.1). '
                  'This educational content is not a replacement for formal prenatal medical consultation.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6C757D), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTopicCard(KnowledgeHubTopic topic) {
    final isExpanded = _expandedIds.contains(topic.id);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? topic.color : const Color(0xFFE5E7EB),
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isExpanded ? 0.06 : 0.03),
            blurRadius: isExpanded ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: topic.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(topic.icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: topic.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Summary
          Text(
            topic.summary,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF4B5563),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),

          // Key Facts List
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KEY FACTS:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                for (final point in topic.keyPoints)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ',
                            style: TextStyle(
                              color: topic.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            )),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF374151)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Expanded Full Text
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Text(
                topic.fullText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  height: 1.55,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Expand / Collapse Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                backgroundColor: isExpanded ? const Color(0xFFF3F4F6) : Colors.white,
                foregroundColor: isExpanded ? const Color(0xFF374151) : topic.color,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                setState(() {
                  if (isExpanded) {
                    _expandedIds.remove(topic.id);
                  } else {
                    _expandedIds.add(topic.id);
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded ? 'Collapse guide' : 'Read full guide',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
