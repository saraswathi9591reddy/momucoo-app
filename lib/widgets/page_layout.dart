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
          children: [
            ListTile(
              leading: Image.asset(
                'assets/images/logo.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('🩸', style: TextStyle(fontSize: 22)),
              ),
              title: const Text('Momucoo', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 20)),
            ),
            for (final m in PageLayout.mainMenu) ListTile(leading: Icon(m.$1), title: Text(m.$2), onTap: () => go(m.$3)),
            const Divider(),
            ListTile(leading: const Icon(Icons.menu_book_outlined), title: const Text('Knowledge Hub'), onTap: () => go(Routes.knowledgeHub)),
            ListTile(leading: const Icon(Icons.chat_bubble_outline), title: const Text('Feedback'), onTap: () => go(Routes.feedback)),
            ListTile(leading: const Icon(Icons.sos_outlined), title: const Text('Emergency Help'), onTap: () => go(Routes.emergency)),
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
