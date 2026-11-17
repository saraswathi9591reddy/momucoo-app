import 'package:flutter/material.dart';

import '../core/localization.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Nutrition Guide with multi-language localization.
class CarePlanScreen extends StatelessWidget {
  const CarePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, _, __) {
        final L = LocalizationService.tr;

        return PageLayout(
          title: L('nutrition_guide'),
          eyebrow: L('patient_portal'),
          activePath: Routes.carePlan,
          description: L('nutrition_desc'),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9E7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF9E79F)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFB7950B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      L('nutrition_disclaimer'),
                      style: const TextStyle(color: Color(0xFF7D6608), fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            _CardWrapper(
              title: L('iron_rich_foods_title'),
              subtitle: L('iron_rich_foods_subtitle'),
              child: Column(
                children: [
                  _foodRow('🥬', L('food_spinach_title'), L('food_spinach_desc')),
                  _foodRow('🫘', L('food_lentils_title'), L('food_lentils_desc')),
                  _foodRow('🌾', L('food_cereals_title'), L('food_cereals_desc')),
                  _foodRow('🟫', L('food_jaggery_title'), L('food_jaggery_desc')),
                  _foodRow('🍇', L('food_dates_title'), L('food_dates_desc')),
                  _foodRow('🥚', L('food_eggs_title'), L('food_eggs_desc')),
                  _foodRow('🫐', L('food_beetroot_title'), L('food_beetroot_desc')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _foodRow(String icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5D4CE)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
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
