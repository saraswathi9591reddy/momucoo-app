import 'package:flutter/material.dart';

import '../core/localization.dart';
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

  // Localized title & summary
  final Map<String, String>? localizedTitle;
  final Map<String, String>? localizedSummary;

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
    this.localizedTitle,
    this.localizedSummary,
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
      localizedTitle: {
        'kn': 'ಗರ್ಭಾವಸ್ಥೆಯಲ್ಲಿ ರಕ್ತಹೀನತೆ: ಇದರ ಅರ್ಥವೇನು?',
        'te': 'గర్భధారణ సమయంలో రక్తహీనత: దీని అర్థం ఏమిటి?',
        'hi': 'गर्भावस्था में एनीमिया: इसका क्या मतलब है?',
        'ta': 'கர்ப்ப காலத்தில் இரத்த சோகை: இதன் பொருள் என்ன?',
      },
      localizedSummary: {
        'kn': 'ಗರ್ಭಾವಸ್ಥೆಯಲ್ಲಿ ನಿಮ್ಮ ದೇಹವು ಮಗುವಿಗೆ ಪೂರಕವಾಗಿ 50% ಹೆಚ್ಚು ರಕ್ತ ಉತ್ಪಾದಿಸುತ್ತದೆ. ಕಬ್ಬಿಣದ ಕೊರತೆಯಾದರೆ ಆಮ್ಲಜನಕ ಸರಬರಾಜು ಕಡಿಮೆಯಾಗುತ್ತದೆ.',
        'te': 'గర్భధారణ సమయంలో మీ శరీరం శిశువుకు మద్దతుగా 50% ఎక్కువ రక్తాన్ని ఉత్పత్తి చేస్తుంది. ఇనుము లోపిస్తే ఆక్సిజన్ తగ్గుతుంది.',
        'hi': 'गर्भावस्था में आपका शरीर बच्चे के लिए 50% अधिक रक्त का उत्पादन करता है। आयरन की कमी से ऑक्सीजन की आपूर्ति कम हो जाती है।',
        'ta': 'கர்ப்ப காலத்தில் உங்கள் உடல் குழந்தைக்கு ஆதரவாக 50% அதிக இரத்தத்தை உற்பத்தி செய்கிறது. இரும்புச்சத்து குறைந்தால் ஆக்ஸிஜன் அளவு குறையும்.',
      },
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
      localizedTitle: {
        'kn': 'ಎಚ್ಚರಿಕೆ ಚಿಹ್ನೆಗಳು & ವೈದ್ಯರನ್ನು ಯಾವಾಗ ಕರೆಯಬೇಕು',
        'te': 'హెచ్చరిక సంకేతాలు & వైద్యుడిని ఎప్పుడు సంప్రదించాలి',
        'hi': 'चेतावनी संकेत और अपने डॉक्टर को कब कॉल करें',
        'ta': 'எச்சரிக்கை அறிகுறிகள் & உங்கள் மருத்துவரை எப்போது அழைக்க வேண்டும்',
      },
      localizedSummary: {
        'kn': 'ಸಾಮಾನ್ಯ ಗರ್ಭಾವಸ್ಥೆಯ ಆಯಾಸ ಮತ್ತು ತಕ್ಷಣ ವೈದ್ಯಕೀಯ ನೆರವು ಅಗತ್ಯವಿರುವ ಲಕ್ಷಣಗಳನ್ನು ಗುರುತಿಸಿ.',
        'te': 'సాధారణ గర్భధారణ అలసట మరియు అత్యవసర వైద్య సంరక్షణ అవసరమైన లక్షణాలను గుర్తించండి.',
        'hi': 'सामान्य गर्भावस्था की थकान और तत्काल चिकित्सा ध्यान देने वाले लक्षणों के बीच अंतर पहचानें।',
        'ta': 'வழக்கமான கர்ப்ப சோர்வு மற்றும் உடனடி மருத்துவ கவனிப்பு தேவைப்படும் அறிகுறிகளை அடையாளம் காணவும்.',
      },
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
      localizedTitle: {
        'kn': 'ಕಬ್ಬಿಣಾಂಶ ಭರಿತ ಆಹಾರಗಳು & ಉತ್ತಮ ಹೀರಿಕೊಳ್ಳುವಿಕೆ',
        'te': 'ఇనుము-రిచ్ ఆహారాలు & స్మార్ట్ శోషణ',
        'hi': 'आयरन युक्त खाद्य पदार्थ और स्मार्ट अवशोषण',
        'ta': 'இரும்புச்சத்து நிறைந்த உணவுகள் & சிறந்த உறிஞ்சுதல்',
      },
      localizedSummary: {
        'kn': 'ಸಮತೋಲಿತ ದೈನಂದಿನ ಊಟ ಮತ್ತು ವಿಟಮಿನ್ ಸಿ ಜೊತೆಗೂಡಿಸುವ ಮೂಲಕ ನೈಸರ್ಗಿಕ ಕಬ್ಬಿಣದ ಸೇವನೆಯನ್ನು ಹೆಚ್ಚಿಸಿ.',
        'te': 'సమతుల్య రోజువారీ భోజనం మరియు విటమిన్ సి కలయికల ద్వారా సహజ ఇనుము తీసుకోవడం పెంచండి.',
        'hi': 'संतुलित दैनिक भोजन और विटामिन सी के साथ प्राकृतिक आयरन के सेवन को अधिकतम कैसे करें।',
        'ta': 'சீரான தினசரி உணவு மற்றும் வைட்டமின் சி சேர்க்கைகள் மூலம் இயற்கை இரும்புச்சத்து உட்கொள்ளலை அதிகரிக்கவும்.',
      },
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
      localizedTitle: {
        'kn': 'ನಿಮ್ಮ ಸಿಬಿಸಿ ರಕ್ತ ಪರೀಕ್ಷೆಯನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳುವುದು',
        'te': 'మీ పూర్తి రక్త గణన (CBC) ని అర్థం చేసుకోవడం',
        'hi': 'अपनी पूर्ण रक्त गणना (CBC) को समझना',
        'ta': 'உங்கள் முழுமையான இரத்த எண்ணிக்கையை (CBC) புரிந்துகொள்வது',
      },
      localizedSummary: {
        'kn': 'ನಿಮ್ಮ ಲ್ಯಾಬ್ ವರದಿಯಿಂದ ಹಿಮೋಗ್ಲೋಬಿನ್ (Hb), RBC, MCV, ಮತ್ತು ಹೆಮಟೋಕ್ರಿಟ್ ಮೌಲ್ಯಗಳನ್ನು ಡಿಕೋಡ್ ಮಾಡಿ.',
        'te': 'మీ ల్యాబ్ నివేదిక నుండి హిమోగ్లోబిన్ (Hb), RBC, MCV విలువలను అర్థం చేసుకోండి.',
        'hi': 'अपनी लैब रिपोर्ट से हीमोग्लोबिन (Hb), RBC, MCV और हेमटोक्रिट मानों को समझें।',
        'ta': 'உங்கள் ஆய்வக அறிக்கையிலிருந்து ஹீமோகுளோபின் (Hb), RBC, MCV மதிப்புகளை புரிந்து கொள்ளுங்கள்.',
      },
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
      icon: '🩺',
      color: Color(0xFF8E44AD),
      bgColor: Color(0xFFF5EEF8),
      title: 'Preparing for Your Doctor Checkup',
      summary:
          'How to make the most of your prenatal consultations with organized reports and symptom notes.',
      localizedTitle: {
        'kn': 'ವೈದ್ಯರ ತಪಾಸಣೆಗೆ ಸಿದ್ಧತೆ',
        'te': 'వైద్యుని తనిఖీకి సిద్ధమవ్వడం',
        'hi': 'अपने डॉक्टर चेकअप की तैयारी',
        'ta': 'உங்கள் மருத்துவ பரிசோதனைக்கு தயாராகுதல்',
      },
      localizedSummary: {
        'kn': 'ಸಂಘಟಿತ ವರದಿಗಳು ಮತ್ತು ರೋಗಲಕ್ಷಣ ಟಿಪ್ಪಣಿಗಳೊಂದಿಗೆ ನಿಮ್ಮ ವೈದ್ಯರ ಭೇಟಿಯನ್ನು ಹೇಗೆ ಹೆಚ್ಚು ಉಪಯುಕ್ತವಾಗಿಸುವುದು.',
        'te': 'నివేదికలు మరియు లక్షణాల నోట్లతో మీ వైద్యుడి సంప్రదింపులను ఎలా ఉపయోగించుకోవాలి.',
        'hi': 'व्यवस्थित रिपोर्ट और लक्षण नोट्स के साथ अपने डॉक्टर के परामर्श का अधिकतम लाभ कैसे उठाएं।',
        'ta': 'அறிக்கைகள் மற்றும் அறிகுறி குறிப்புகளுடன் உங்கள் மருத்துவ ஆலோசனையை எவ்வாறு பயனுள்ளதாக்குவது.',
      },
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
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, lang, __) {
        final L = LocalizationService.tr;

        final categories = [
          ('All', L('all')),
          ('Basics', L('basics')),
          ('Precautions', L('precautions')),
          ('Diet', L('diet')),
          ('Tests', L('tests')),
          ('Checkup', L('checkup')),
        ];

        final filteredTopics = _selectedCategory == 'All'
            ? topics
            : topics.where((t) => t.category == _selectedCategory).toList();

        return PageLayout(
          title: L('knowledge_hub'),
          eyebrow: L('patient_portal'),
          activePath: Routes.knowledgeHub,
          description: L('knowledge_desc'),
          children: [
            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final cat in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat.$2),
                        selected: _selectedCategory == cat.$1,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = cat.$1;
                          });
                        },
                        selectedColor: const Color(0xFFC0392B),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedCategory == cat.$1 ? Colors.white : AppColors.ink,
                          fontWeight: _selectedCategory == cat.$1 ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: _selectedCategory == cat.$1 ? const Color(0xFFC0392B) : const Color(0xFFE5D4CE),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Topics List
            for (final topic in filteredTopics)
              _buildTopicCard(topic, lang.code, L),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildTopicCard(KnowledgeHubTopic topic, String langCode, String Function(String) L) {
    final isExpanded = _expandedIds.contains(topic.id);
    final titleText = topic.localizedTitle?[langCode] ?? topic.title;
    final summaryText = topic.localizedSummary?[langCode] ?? topic.summary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5D4CE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag & Icon
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: topic.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(topic.icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L(topic.category.toLowerCase()).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: topic.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      titleText,
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
            summaryText,
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
                side: const BorderSide(color: Color(0xFFE5D4CE)),
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
