import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/models/models.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Port of frontend/src/pages/Dashboard.jsx (route /dashboard).
/// Matches the web app design with red greeting banner, 4 stats cards,
/// latest screening card with severity badge, and quick actions list.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStorage.instance;
    final profile = s.profileOr('saraswathi reddy');
    final pregnancy = s.readMap(StorageKeys.pregnancyData);
    final cbc = s.readMap(StorageKeys.cbcData);
    final ai = s.readMap(StorageKeys.aiResult);

    final userName = profile.name.isNotEmpty && profile.name != 'Ananya Sharma'
        ? profile.name
        : 'saraswathi reddy';
    final pregnancyWeek = pregnancy?['week'] ?? profile.pregnancyWeek ?? '35';
    final hbValue = cbc?['hb']?.toString() ?? '2.2';
    final riskLevel = ai?['risk']?.toString() ?? 'Severe Anemia';

    return PageLayout(
      title: 'Dashboard',
      eyebrow: 'MOMUCOO • PATIENT PORTAL',
      description: 'Your pregnancy anemia screening overview',
      activePath: Routes.dashboard,
      children: [
        // 1. Welcome Red Banner (matching web app)
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
                      'Week $pregnancyWeek of pregnancy',
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

        // 2. Stats Grid (4 Cards matching web app)
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
              value: hbValue,
              label: 'Latest Hb (g/dL)',
            ),
            _statCard(
              icon: Icons.timeline,
              iconColor: const Color(0xFF2980B9),
              iconBg: const Color(0xFFE8F4F8),
              value: '2',
              label: 'Total Screenings',
            ),
            _statCard(
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF27AE60),
              iconBg: const Color(0xFFEAF9E7),
              value: '2',
              label: 'Blood Reports',
            ),
            _statCard(
              icon: Icons.calendar_today_outlined,
              iconColor: const Color(0xFFE67E22),
              iconBg: const Color(0xFFFEF5E7),
              value: pregnancyWeek.toString(),
              label: 'Pregnancy Week',
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.water_drop, color: Color(0xFFC0392B), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Latest Screening',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.go(Routes.cbcAnalysis),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('New', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0392B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC0392B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    riskLevel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC0392B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Hb: $hbValue g/dL',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                '15 November 2026',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 2),
              const Text(
                'Based on WHO 2011 (WHO/NMH/NHD/MNM/11.1)',
                style: TextStyle(fontSize: 11, color: Color(0xFFBDC3C7)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(Routes.aiAnalysis),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC0392B),
                    side: const BorderSide(color: Color(0xFFC0392B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('View Full Details →', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),

        // 4. Quick Actions
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5D4CE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.flash_on, color: Color(0xFFC0392B), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _quickActionItem(
                icon: Icons.bloodtype,
                title: 'Upload CBC Report',
                subtitle: 'Image or PDF with OCR extraction',
                onTap: () => context.go(Routes.cbcAnalysis),
              ),
              _quickActionItem(
                icon: Icons.assignment_outlined,
                title: 'Symptom Assessment',
                subtitle: 'Answer 8 key symptom questions',
                onTap: () => context.go(Routes.healthCheck),
              ),
              _quickActionItem(
                icon: Icons.folder_open_outlined,
                title: 'View All Reports',
                subtitle: 'History & downloadable PDFs',
                onTap: () => context.go(Routes.reports),
              ),
              _quickActionItem(
                icon: Icons.restaurant_outlined,
                title: 'Nutrition Guide',
                subtitle: 'Iron-rich foods & meal tips',
                onTap: () => context.go(Routes.carePlan),
              ),
              _quickActionItem(
                icon: Icons.alarm,
                title: 'Daily Care Reminders',
                subtitle: 'Exact scheduled medication alerts',
                onTap: () => context.go(Routes.reminders),
              ),
            ],
          ),
        ),
      ],
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
