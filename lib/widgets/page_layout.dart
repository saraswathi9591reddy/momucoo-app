import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/localization.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';

/// Port of PageLayout.jsx. Web sidebar -> drawer (secondary links, logout).
class PageLayout extends StatelessWidget {
  const PageLayout({super.key, required this.title, this.eyebrow, this.description, this.activePath, required this.children});
  final String title;
  final String? eyebrow;
  final String? description;
  final String? activePath;
  final List<Widget> children;

  // Next flow helper with multi-language translation support
  (String, String, IconData)? _getNextScreen(String currentPath) {
    switch (currentPath) {
      case Routes.dashboard:
        return (LocalizationService.tr('go_to_profile'), Routes.profile, Icons.arrow_forward_rounded);
      case Routes.profile:
        return (LocalizationService.tr('start_symptom_check'), Routes.healthCheck, Icons.arrow_forward_rounded);
      case Routes.healthCheck:
        return (LocalizationService.tr('continue_to_cbc'), Routes.cbcAnalysis, Icons.arrow_forward_rounded);
      case Routes.cbcAnalysis:
        return (LocalizationService.tr('view_screening_results'), Routes.aiAnalysis, Icons.arrow_forward_rounded);
      case Routes.aiAnalysis:
        return (LocalizationService.tr('view_reports_history'), Routes.reports, Icons.arrow_forward_rounded);
      case Routes.reports:
        return (LocalizationService.tr('next_nutrition_guide'), Routes.carePlan, Icons.restaurant_rounded);
      case Routes.carePlan:
        return (LocalizationService.tr('next_knowledge_hub'), Routes.knowledgeHub, Icons.menu_book_rounded);
      case Routes.knowledgeHub:
        return (LocalizationService.tr('next_care_reminders'), Routes.reminders, Icons.alarm_rounded);
      case Routes.reminders:
        return (LocalizationService.tr('next_share_feedback'), Routes.feedback, Icons.rate_review_rounded);
      case Routes.feedback:
        return (LocalizationService.tr('next_emergency_help'), Routes.emergency, Icons.emergency_rounded);
      case Routes.emergency:
        return (LocalizationService.tr('return_to_dashboard'), Routes.dashboard, Icons.dashboard_rounded);
      default:
        return null;
    }
  }

  IconData _getPageIcon(String t) {
    final s = t.toLowerCase();
    if (s.contains('dashboard') || s.contains('ಡ್ಯಾಶ್') || s.contains('డాష్') || s.contains('डैश')) return Icons.grid_view_rounded;
    if (s.contains('profile') || s.contains('ಪ್ರೊಫೈಲ್') || s.contains('ప్రొఫైల్') || s.contains('प्रोफ़ाइल')) return Icons.badge_outlined;
    if (s.contains('symptom') || s.contains('health') || s.contains('ಲಕ್ಷಣ') || s.contains('లక్షణ') || s.contains('लक्षण')) return Icons.favorite_rounded;
    if (s.contains('cbc') || s.contains('ಸಿಬಿಸಿ') || s.contains('సిబిసి') || s.contains('सीबीसी')) return Icons.water_drop_rounded;
    if (s.contains('result') || s.contains('ai') || s.contains('ಫಲಿತಾಂಶ') || s.contains('ఫలిత') || s.contains('परिणाम')) return Icons.auto_awesome_rounded;
    if (s.contains('report') || s.contains('histor') || s.contains('ವರದಿ') || s.contains('రిపోర్ట్') || s.contains('रिपोर्ट')) return Icons.assessment_rounded;
    if (s.contains('nutrit') || s.contains('diet') || s.contains('ಆಹಾರ') || s.contains('ఆహార') || s.contains('आहार')) return Icons.restaurant_rounded;
    if (s.contains('remind') || s.contains('alarm') || s.contains('ಜ್ಞಾಪನೆ') || s.contains('రిమైండర్') || s.contains('रिमाइंडर')) return Icons.alarm_rounded;
    if (s.contains('knowledg') || s.contains('hub') || s.contains('ಜ್ಞಾನ') || s.contains('విజ్ఞాన') || s.contains('ज्ञान')) return Icons.menu_book_rounded;
    if (s.contains('feedback') || s.contains('ಪ್ರತಿಕ್ರಿಯೆ') || s.contains('ఫీడ్‌బ్యాక్') || s.contains('प्रतिक्रिया')) return Icons.rate_review_rounded;
    if (s.contains('emergency') || s.contains('sos') || s.contains('ತುರ್ತು') || s.contains('అత్యవసర') || s.contains('आपात')) return Icons.emergency_rounded;
    return Icons.spa_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final pageIcon = _getPageIcon(title);
    final isEmergency = title.toLowerCase().contains('emergency') || title.contains('ತುರ್ತು') || title.contains('అత్యవసర') || title.contains('आपात');
    final nextScreen = activePath != null ? _getNextScreen(activePath!) : null;

    final displayEyebrow = eyebrow != null ? LocalizationService.tr(eyebrow!) : LocalizationService.tr('patient_portal');
    final displayTitle = LocalizationService.tr(title);
    final displayDesc = description != null ? LocalizationService.tr(description!) : null;

    return Scaffold(
      appBar: MomucooAppBar(title: displayTitle),
      drawer: const MomucooDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Premium Gradient Hero Header Card
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isEmergency
                      ? [const Color(0xFFC0392B), const Color(0xFF962D22)]
                      : [
                          const Color(0xFFFFF7F5),
                          const Color(0xFFFFF0EC),
                          Colors.white,
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isEmergency ? const Color(0xFFE74C3C) : const Color(0xFFF6D8D0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isEmergency
                        ? const Color(0xFFC0392B).withOpacity(0.25)
                        : const Color(0xFFC0392B).withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isEmergency
                                ? Colors.white.withOpacity(0.2)
                                : const Color(0xFFFDEDEC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isEmergency ? Colors.white : AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                displayEyebrow.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w800,
                                  color: isEmergency ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayTitle,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isEmergency ? Colors.white : AppColors.ink,
                            letterSpacing: -0.4,
                          ),
                        ),
                        if (displayDesc != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            displayDesc,
                            style: TextStyle(
                              fontSize: 13,
                              color: isEmergency ? Colors.white70 : const Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Decorative Icon Badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isEmergency
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFFFDEDEC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isEmergency
                            ? Colors.white.withOpacity(0.3)
                            : const Color(0xFFFADBD8),
                      ),
                    ),
                    child: Icon(
                      pageIcon,
                      color: isEmergency ? Colors.white : AppColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            for (final c in children) ...[c, const SizedBox(height: 16)],

            // Next Step Action Banner at bottom of page
            if (nextScreen != null) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                    ),
                    onPressed: () => context.go(nextScreen.$2),
                    icon: Icon(nextScreen.$3, size: 20),
                    label: Text(
                      nextScreen.$1,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// App bar with Momucoo brand, Language Picker Modal, and Profile Initials.
class MomucooAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MomucooAppBar({super.key, required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.language, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      LocalizationService.tr('select_language'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                  ],
                ),
              ),
              const Divider(),
              for (final lang in AppLanguage.values)
                ValueListenableBuilder<AppLanguage>(
                  valueListenable: LocalizationService.currentLanguage,
                  builder: (context, current, _) {
                    final selected = current == lang;
                    return ListTile(
                      leading: Text(
                        selected ? '✓' : '  ',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      title: Text(
                        lang.nativeName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          color: selected ? AppColors.primary : AppColors.ink,
                        ),
                      ),
                      subtitle: Text(lang.englishName, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      onTap: () {
                        LocalizationService.setLanguage(lang);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Text('🩸', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 8),
            Text(LocalizationService.tr('app_title'), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
        actions: [
          // Language Switcher Button
          ValueListenableBuilder<AppLanguage>(
            valueListenable: LocalizationService.currentLanguage,
            builder: (context, lang, _) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                backgroundColor: AppColors.peachBg,
                side: const BorderSide(color: Color(0xFFF1E4DF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                avatar: const Icon(Icons.translate_rounded, size: 16, color: AppColors.primary),
                label: Text(
                  lang.nativeName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                onPressed: () => _showLanguageSelector(context),
              ),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: AppStorage.profileChanged,
            builder: (context, _, _) {
              final p = AppStorage.instance.profileOr('Saraswathi Reddy');
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => context.go(Routes.profile),
                  child: CircleAvatar(
                    backgroundColor: AppColors.peachBg,
                    child: Text(p.initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
              );
            },
          ),
        ],
      );
}

class MomucooDrawer extends StatelessWidget {
  const MomucooDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    void go(String path) {
      Navigator.of(context).pop();
      context.go(path);
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text('🩸', style: TextStyle(fontSize: 32)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        LocalizationService.tr('app_title'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LocalizationService.tr('dashboard_desc'),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
              child: Text(
                LocalizationService.tr('main_menu').toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1.2),
              ),
            ),
            ListTile(leading: const Icon(Icons.dashboard_outlined), title: Text(LocalizationService.tr('dashboard')), onTap: () => go(Routes.dashboard)),
            ListTile(leading: const Icon(Icons.person_outline), title: Text(LocalizationService.tr('my_profile')), onTap: () => go(Routes.profile)),
            ListTile(leading: const Icon(Icons.favorite_border), title: Text(LocalizationService.tr('symptom_check')), onTap: () => go(Routes.healthCheck)),
            ListTile(leading: const Icon(Icons.bloodtype_outlined), title: Text(LocalizationService.tr('cbc_analysis')), onTap: () => go(Routes.cbcAnalysis)),
            ListTile(leading: const Icon(Icons.auto_graph_outlined), title: Text(LocalizationService.tr('screening_results')), onTap: () => go(Routes.aiAnalysis)),
            ListTile(leading: const Icon(Icons.description_outlined), title: Text(LocalizationService.tr('reports_history')), onTap: () => go(Routes.reports)),
            ListTile(leading: const Icon(Icons.restaurant_outlined), title: Text(LocalizationService.tr('nutrition_guide')), onTap: () => go(Routes.carePlan)),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
              child: Text(
                LocalizationService.tr('support_tools').toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1.2),
              ),
            ),
            ListTile(leading: const Icon(Icons.menu_book_outlined), title: Text(LocalizationService.tr('knowledge_hub')), onTap: () => go(Routes.knowledgeHub)),
            ListTile(leading: const Icon(Icons.alarm_outlined), title: Text(LocalizationService.tr('daily_care_reminders')), onTap: () => go(Routes.reminders)),
            ListTile(leading: const Icon(Icons.chat_bubble_outline), title: Text(LocalizationService.tr('feedback')), onTap: () => go(Routes.feedback)),
            ListTile(leading: const Icon(Icons.sos_outlined, color: AppColors.primary), title: Text(LocalizationService.tr('emergency_help'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)), onTap: () => go(Routes.emergency)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(LocalizationService.tr('logout')),
              onTap: () async {
                await AppStorage.instance.setLoggedIn(false);
                if (context.mounted) go(Routes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}

