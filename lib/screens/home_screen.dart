import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../router.dart';

/// Port of frontend/src/pages/Home.jsx (route /). Public landing page, no PageLayout.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _features = [
    ('💬', '01 / TALK IT OUT', 'Friendly AI chat', 'Say what you’re feeling in your own words. No judgement, no weird medical jargon.'),
    ('🩸', '02 / KNOW YOUR NUMBERS', 'CBC made less confusing', 'Keep blood values and optional pregnancy scans together in one clear report.'),
    ('🌱', '03 / FEEL PREPARED', 'Small steps, big calm', 'Get practical nutrition, risk, and emergency guidance for your next move.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('🩸 Momucoo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
                TextButton(onPressed: () => context.go(Routes.login), child: const Text('Login ↗')),
              ],
            ),
            const Row(children: [
              Icon(Icons.circle, size: 8, color: AppColors.success),
              SizedBox(width: 6),
              Flexible(child: Text('Your pregnancy care space', style: TextStyle(color: AppColors.muted))),
            ]),
            const SizedBox(height: 24),
            const Text('FOR THE FIRST TRIMESTER GIRLIES ✨',
                style: TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.accent)),
            const SizedBox(height: 8),
            Text('Pregnancy care, but make it simple.', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 12),
            const Text(
              'Your symptoms deserve a space that listens. Chat with Momucoo, understand your CBC, save scan reports, and get clear next steps without the medical-word overload.',
              style: TextStyle(color: AppColors.muted, fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => context.go(Routes.register), child: const Text('Start my care era →')),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () => context.go(Routes.login), child: const Text('I’m already in')),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: AppColors.peachBg,
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Image.asset('assets/images/hero.png', height: 200, fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Text('🤰', style: TextStyle(fontSize: 80))),
                  const SizedBox(height: 8),
                  const Text('soft care only ♡', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            for (final f in _features)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.$1, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(f.$2, style: const TextStyle(fontSize: 11, letterSpacing: 1.1, color: AppColors.accent, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(f.$3, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(f.$4, style: const TextStyle(color: AppColors.muted)),
                    ]),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Text('built for early pregnancy • private by design • always learning with you',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
