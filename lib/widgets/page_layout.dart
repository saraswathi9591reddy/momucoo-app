import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';

/// Port of PageLayout.jsx. Web sidebar -> bottom nav (main menu) + drawer (secondary links, logout).
class PageLayout extends StatelessWidget {
  const PageLayout({super.key, required this.title, this.eyebrow, this.description, this.activePath, required this.children});
  final String title;
  final String? eyebrow;
  final String? description;
  final String? activePath;
  final List<Widget> children;

  static const mainMenu = [
    (Icons.home_outlined, 'Dashboard', Routes.dashboard),
    (Icons.favorite_border, 'Health', Routes.healthCheck),
    (Icons.bloodtype_outlined, 'CBC', Routes.cbcAnalysis),
    (Icons.smart_toy_outlined, 'AI', Routes.aiAnalysis),
    (Icons.description_outlined, 'Reports', Routes.reports),
    (Icons.person_outline, 'Profile', Routes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = mainMenu.indexWhere((m) => m.$3 == activePath);
    return Scaffold(
      appBar: MomucooAppBar(title: title),
      drawer: const MomucooDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (eyebrow != null)
              Text(eyebrow!, style: const TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.accent)),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(description!, style: const TextStyle(color: AppColors.muted)),
            ],
            const SizedBox(height: 16),
            for (final c in children) ...[c, const SizedBox(height: 16)],
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx < 0 ? 0 : idx,
        indicatorColor: idx < 0 ? Colors.transparent : AppColors.peachBg,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => context.go(mainMenu[i].$3),
        destinations: [for (final m in mainMenu) NavigationDestination(icon: Icon(m.$1), label: m.$2)],
      ),
    );
  }
}

/// App bar with the Momucoo brand and the profile initials avatar.
class MomucooAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MomucooAppBar({super.key, required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
            const Text('Momucoo', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: AppStorage.profileChanged,
            builder: (context, _, _) {
              final p = AppStorage.instance.profileOr('Ananya Sharma');
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
                      const Text(
                        'Momucoo',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pregnancy Care & Screening',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
              child: Text(
                'MAIN MENU',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1.2),
              ),
            ),
            ListTile(leading: const Icon(Icons.dashboard_outlined), title: const Text('Dashboard'), onTap: () => go(Routes.dashboard)),
            ListTile(leading: const Icon(Icons.person_outline), title: const Text('My Profile'), onTap: () => go(Routes.profile)),
            ListTile(leading: const Icon(Icons.favorite_border), title: const Text('Symptom Check'), onTap: () => go(Routes.healthCheck)),
            ListTile(leading: const Icon(Icons.bloodtype_outlined), title: const Text('CBC Analysis'), onTap: () => go(Routes.cbcAnalysis)),
            ListTile(leading: const Icon(Icons.auto_graph_outlined), title: const Text('Screening Results'), onTap: () => go(Routes.aiAnalysis)),
            ListTile(leading: const Icon(Icons.description_outlined), title: const Text('Reports & History'), onTap: () => go(Routes.reports)),
            ListTile(leading: const Icon(Icons.restaurant_outlined), title: const Text('Nutrition Guide'), onTap: () => go(Routes.carePlan)),
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 4, bottom: 4),
              child: Text(
                'SUPPORT & TOOLS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1.2),
              ),
            ),
            ListTile(leading: const Icon(Icons.menu_book_outlined), title: const Text('Knowledge Hub'), onTap: () => go(Routes.knowledgeHub)),
            ListTile(leading: const Icon(Icons.alarm_outlined), title: const Text('Reminders'), onTap: () => go(Routes.reminders)),
            ListTile(leading: const Icon(Icons.chat_bubble_outline), title: const Text('Feedback'), onTap: () => go(Routes.feedback)),
            ListTile(leading: const Icon(Icons.sos_outlined, color: AppColors.primary), title: const Text('Emergency Help', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)), onTap: () => go(Routes.emergency)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
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
