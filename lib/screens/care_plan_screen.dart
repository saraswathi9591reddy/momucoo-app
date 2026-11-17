import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Matches frontend/src/pages/CarePlan.jsx (Nutrition Guide)
class CarePlanScreen extends StatelessWidget {
  const CarePlanScreen({super.key});

  static const List<Map<String, String>> ironFoods = [
    {
      'name': 'Spinach & Dark Leafy Greens',
      'desc': 'High in non-heme iron. Pair with vitamin C for better absorption.',
      'icon': '🥬',
    },
    {
      'name': 'Lentils & Legumes',
      'desc': 'Dal, rajma, chana — excellent plant-based iron sources.',
      'icon': '🫘',
    },
    {
      'name': 'Fortified Cereals',
      'desc': 'Many breakfast cereals provide 10–18 mg iron per serving.',
      'icon': '🌾',
    },
    {
      'name': 'Jaggery (Gur)',
      'desc': 'Traditional iron-rich sweetener, 11 mg per 100g.',
      'icon': '🟫',
    },
    {
      'name': 'Dried Fruits',
      'desc': 'Raisins, apricots, and dates are iron-dense portable snacks.',
      'icon': '🍇',
    },
    {
      'name': 'Pumpkin Seeds',
      'desc': 'High in iron and zinc. Great as a snack or salad topping.',
      'icon': '🎃',
    },
    {
      'name': 'Liver & Red Meat',
      'desc': 'Rich in heme iron (most absorbable form). Consult your doctor.',
      'icon': '🥩',
    },
    {
      'name': 'Tofu & Soy Products',
      'desc': 'Good plant-based iron for vegetarians and vegans.',
      'icon': '🧆',
    },
  ];

  static const List<Map<String, String>> vitaminC = [
    {'name': 'Amla (Indian Gooseberry)', 'desc': 'One of the richest natural vitamin C sources.'},
    {'name': 'Oranges & Citrus', 'desc': 'Drink a glass of juice with iron-rich meals.'},
    {'name': 'Bell Peppers', 'desc': 'Red peppers have more vitamin C than oranges.'},
    {'name': 'Tomatoes', 'desc': 'Easy to add to most Indian dishes.'},
    {'name': 'Guava', 'desc': 'Extremely high in vitamin C, affordable and widely available.'},
  ];

  static const List<String> avoidList = [
    'Tea or coffee with meals (tannins block iron absorption)',
    'Calcium-rich foods at the same time as iron-rich foods',
    'Excessive whole bran without balancing with iron foods',
    'Antacids close to iron supplements (reduces absorption)',
  ];

  static const List<Map<String, String>> meals = [
    {'time': 'Morning', 'desc': 'Fortified cereal with amla juice, or poha with peas and lemon'},
    {'time': 'Mid-morning', 'desc': 'Handful of pumpkin seeds or dried apricots'},
    {'time': 'Lunch', 'desc': 'Dal with palak (spinach), brown rice, tomato salad'},
    {'time': 'Afternoon', 'desc': 'Guava or orange, jaggery with nuts'},
    {'time': 'Dinner', 'desc': 'Rajma curry, roti with green vegetables, lemon water'},
  ];

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Nutrition Guide',
      eyebrow: 'MOMUCOO • PATIENT PORTAL',
      activePath: Routes.carePlan,
      description: 'Iron-rich foods and dietary tips to support a healthy pregnancy',
      children: [
        // Warning alert matching web
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9E7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF9E79F)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFB7950B), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This is general nutritional information only. It is not a personalized meal plan or treatment advice. '
                  'Always consult a registered dietitian or your doctor before making major dietary changes during pregnancy.',
                  style: TextStyle(color: Color(0xFF7D6608), fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),

        // 1. Iron-rich foods section
        _CardWrapper(
          title: '🌿 Iron-Rich Foods',
          subtitle: 'WHO recommends 27 mg of iron daily during pregnancy.',
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final food in ironFoods)
                    Container(
                      width: constraints.maxWidth > 500 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5D4CE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(food['icon']!, style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(food['name']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 3),
                                Text(food['desc']!, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // 2. Vitamin C enhancement section
        _CardWrapper(
          title: '🍎 Enhance Iron Absorption with Vitamin C',
          subtitle: 'Eating vitamin C alongside iron-rich foods increases absorption by up to 3×.',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final v in vitaminC)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5F5E3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA9DFBF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(v['name']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1A5276))),
                      const SizedBox(height: 2),
                      Text(v['desc']!, style: const TextStyle(fontSize: 12, color: Color(0xFF4A6741))),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 3. Sample Daily Meal Plan
        _CardWrapper(
          title: '📅 Sample Daily Meal Plan',
          subtitle: 'Balanced suggestions for steady energy and optimal iron absorption.',
          child: Column(
            children: [
              for (final m in meals)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5D4CE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          m['time']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          m['desc']!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 4. What to Avoid
        _CardWrapper(
          title: '☕ What to Avoid with Iron-Rich Meals',
          subtitle: 'Certain foods and compounds can inhibit iron uptake in your body.',
          child: Column(
            children: [
              for (final a in avoidList)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✗ ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                      Expanded(
                        child: Text(
                          a,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF7B241C)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _CardWrapper extends StatelessWidget {
  const _CardWrapper({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
