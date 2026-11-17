import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/localization.dart';
import '../core/models/models.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Fully localized Dashboard screen.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    final L = LocalizationService.tr;
    if (hour < 12) return L('good_morning');
    if (hour < 17) return L('good_afternoon');
    return L('good_evening');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, _, __) {
        final L = LocalizationService.tr;
        final s = AppStorage.instance;
        final profile = s.profileOr('saraswathi reddy');
        final pregnancy = s.readMap(StorageKeys.pregnancyData);
        final cbc = s.readMap(StorageKeys.cbcData);
        final ai = s.readMap(StorageKeys.aiResult);

        final userName = profile.name.isNotEmpty && profile.name != 'Ananya Sharma'
            ? profile.name
            : 'Saraswathi Reddy';
        final pregnancyWeek = pregnancy?['week'] ?? profile.pregnancyWeek ?? '35';
        final hbValue = cbc?['hb']?.toString() ?? '2.2';
        final riskLevel = ai?['risk']?.toString() ?? 'Severe Anemia';

        return PageLayout(
          title: L('dashboard'),
          eyebrow: L('patient_portal'),
          description: L('dashboard_desc'),
          activePath: Routes.dashboard,
          children: [
            // 1. Welcome Red Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC0392B), Color(0xFFE74C3C)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC0392B).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greeting()},',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          L('week_of_pregnancy').replaceFirst('{0}', pregnancyWeek),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Text('🩸', style: TextStyle(fontSize: 28))),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Stats Grid (4 Cards)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _statCard(
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFFC0392B),
                  iconBg: const Color(0xFFFDE8E6),
                  value: '$hbValue g/dL',
                  label: L('latest_hb'),
                ),
                _statCard(
                  icon: Icons.bar_chart_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  iconBg: const Color(0xFFEDE9FE),
                  value: '3',
                  label: L('total_screenings'),
                ),
                _statCard(
                  icon: Icons.folder_open_outlined,
                  iconColor: const Color(0xFF0EA5E9),
                  iconBg: const Color(0xFFE0F2FE),
                  value: '2',
                  label: L('blood_reports'),
                ),
                _statCard(
                  icon: Icons.pregnant_woman_rounded,
                  iconColor: const Color(0xFF16A34A),
                  iconBg: const Color(0xFFDCFCE7),
                  value: 'W$pregnancyWeek',
                  label: L('pregnancy_week'),
                ),
              ],
            ),

            // 3. Latest Screening Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5D4CE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        L('latest_screening'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8E6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          L('new'),
                          style: const TextStyle(
                            color: Color(0xFFC0392B),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    riskLevel,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC0392B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hb: $hbValue g/dL',
                    style: const TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go(Routes.aiAnalysis),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFC0392B)),
                        foregroundColor: const Color(0xFFC0392B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        L('view_full_details'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Quick Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L('quick_actions'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                _quickActionItem(
                  icon: Icons.upload_file_outlined,
                  title: L('upload_cbc_report'),
                  subtitle: L('upload_cbc_subtitle'),
                  onTap: () => context.go(Routes.cbcAnalysis),
                ),
                _quickActionItem(
                  icon: Icons.assignment_outlined,
                  title: L('symptom_assessment'),
                  subtitle: L('symptom_subtitle'),
                  onTap: () => context.go(Routes.healthCheck),
                ),
                _quickActionItem(
                  icon: Icons.folder_open_outlined,
                  title: L('view_all_reports'),
                  subtitle: L('view_reports_subtitle'),
                  onTap: () => context.go(Routes.reports),
                ),
                _quickActionItem(
                  icon: Icons.restaurant_outlined,
                  title: L('nutrition_guide'),
                  subtitle: L('nutrition_guide_subtitle'),
                  onTap: () => context.go(Routes.carePlan),
                ),
                _quickActionItem(
                  icon: Icons.alarm,
                  title: L('daily_care_reminders'),
                  subtitle: L('care_reminders_subtitle'),
                  onTap: () => context.go(Routes.reminders),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5D4CE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _quickActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFCF9F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5D4CE)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFFC0392B), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
