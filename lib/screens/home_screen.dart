import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';

/// Port of frontend/src/pages/Home.jsx (route /). Public landing page, no PageLayout.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _features = [
    (
      '💬',
      '01 / TALK IT OUT',
      'Friendly AI chat',
      'Say what you’re feeling in your own words. No judgement, no weird medical jargon.',
    ),
    (
      '🩸',
      '02 / KNOW YOUR NUMBERS',
      'CBC made less confusing',
      'Keep blood values and optional pregnancy scans together in one clear report.',
    ),
    (
      '🌱',
      '03 / FEEL PREPARED',
      'Small steps, big calm',
      'Get practical nutrition, risk, and emergency guidance for your next move.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final loggedIn = AppStorage.instance.isLoggedIn;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final horizontalPadding = wide ? 32.0 : 20.0;
            final contentWidth = constraints.maxWidth - horizontalPadding * 2;
            final illustrationSize = wide
                ? 360.0
                : contentWidth.clamp(200.0, 320.0).toDouble();
            final theme = Theme.of(context);

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.cream,
                    Color(0xFFFFF7F2),
                    Color(0xFFFFEDE4),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '🩸 Momucoo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                            const Spacer(),
                            if (wide) ...[
                              _careSpaceLabel(),
                              const SizedBox(width: 20),
                            ],
                            OutlinedButton(
                              onPressed: () => context.go(
                                loggedIn ? Routes.dashboard : Routes.login,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.ink,
                                side: const BorderSide(color: AppColors.ink),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: Text(loggedIn ? 'Dashboard ↗' : 'Login ↗'),
                            ),
                          ],
                        ),
                        if (!wide) ...[
                          const SizedBox(height: 10),
                          _careSpaceLabel(),
                        ],
                        SizedBox(height: wide ? 52 : 30),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _intro(
                                  context,
                                  theme,
                                  loggedIn,
                                  wide: true,
                                ),
                              ),
                              const SizedBox(width: 36),
                              _illustration(illustrationSize),
                            ],
                          )
                        else ...[
                          _intro(context, theme, loggedIn, wide: false),
                          const SizedBox(height: 24),
                          Center(child: _illustration(illustrationSize)),
                        ],
                        SizedBox(height: wide ? 48 : 28),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < _features.length; i++) ...[
                                if (i > 0) const SizedBox(width: 14),
                                Expanded(
                                  child: _featureCard(_features[i], i, theme),
                                ),
                              ],
                            ],
                          )
                        else
                          for (var i = 0; i < _features.length; i++) ...[
                            _featureCard(_features[i], i, theme),
                            if (i < _features.length - 1)
                              const SizedBox(height: 12),
                          ],
                        const SizedBox(height: 18),
                        const Text(
                          'built for early pregnancy • private by design • always learning with you',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _careSpaceLabel() => const Wrap(
    spacing: 7,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Icon(Icons.circle, size: 8, color: Color(0xFF8AC795)),
      Text(
        'Your pregnancy care space',
        style: TextStyle(color: AppColors.muted, fontSize: 12),
      ),
    ],
  );

  Widget _intro(
    BuildContext context,
    ThemeData theme,
    bool loggedIn, {
    required bool wide,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.successBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'FOR THE FIRST TRIMESTER GIRLIES ✨',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
      const SizedBox(height: 14),
      Text(
        'Pregnancy care, but make it simple.',
        style: theme.textTheme.headlineLarge?.copyWith(
          fontSize: wide ? 58 : 38,
          height: 0.99,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 14),
      const Text(
        'Your symptoms deserve a space that listens. Chat with Momucoo, understand your CBC, save scan reports, and get clear next steps without the medical-word overload.',
        style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.5),
      ),
      const SizedBox(height: 20),
      if (loggedIn)
        SizedBox(
          width: wide ? null : double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(Routes.dashboard),
            style: _primaryButtonStyle(),
            child: const Text('Open Dashboard →'),
          ),
        )
      else if (wide)
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            ElevatedButton(
              onPressed: () => context.go(Routes.register),
              style: _primaryButtonStyle(),
              child: const Text('Start my care era →'),
            ),
            OutlinedButton(
              onPressed: () => context.go(Routes.login),
              style: _secondaryButtonStyle(),
              child: const Text('I’m already in'),
            ),
          ],
        )
      else ...[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(Routes.register),
            style: _primaryButtonStyle(),
            child: const Text('Start my care era →'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go(Routes.login),
            style: _secondaryButtonStyle(),
            child: const Text('I’m already in'),
          ),
        ),
      ],
    ],
  );

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    elevation: 2,
    shadowColor: AppColors.ink,
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );

  ButtonStyle _secondaryButtonStyle() => OutlinedButton.styleFrom(
    foregroundColor: AppColors.ink,
    side: const BorderSide(color: AppColors.ink),
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );

  Widget _illustration(double size) {
    final circleSize = size * 0.88;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.ink,
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: circleSize * 0.79,
                height: circleSize * 0.79,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: const Center(
                  child: Text('🤰', style: TextStyle(fontSize: 82)),
                ),
              ),
            ),
          ),
          Positioned(
            left: size * 0.01,
            top: size * 0.16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '01',
                    style: TextStyle(
                      color: AppColors.peach,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'check in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: size * 0.01,
            bottom: size * 0.16,
            child: Transform.rotate(
              angle: -0.06,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.peach,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'soft care only ♡',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(
    (String, String, String, String) feature,
    int index,
    ThemeData theme,
  ) {
    final background = switch (index) {
      1 => const Color(0xFFC5E98A),
      2 => AppColors.ink,
      _ => Colors.white,
    };
    final foreground = index == 2 ? Colors.white : AppColors.ink;
    final secondary = index == 2 ? Colors.white70 : AppColors.muted;
    final kicker = index == 2 ? AppColors.peach : AppColors.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: index == 0 ? Border.all(color: AppColors.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(feature.$1, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 8),
          Text(
            feature.$2,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.1,
              color: kicker,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            feature.$3,
            style: theme.textTheme.titleLarge?.copyWith(color: foreground),
          ),
          const SizedBox(height: 5),
          Text(feature.$4, style: TextStyle(color: secondary, height: 1.4)),
        ],
      ),
    );
  }
}
