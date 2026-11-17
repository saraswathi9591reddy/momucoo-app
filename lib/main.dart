import 'package:flutter/material.dart';

import 'core/localization.dart';
import 'core/storage.dart';
import 'core/theme.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  LocalizationService.init();
  runApp(const MomucooApp());
}

class MomucooApp extends StatefulWidget {
  const MomucooApp({super.key});

  @override
  State<MomucooApp> createState() => _MomucooAppState();
}

class _MomucooAppState extends State<MomucooApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AppLanguage>(
        valueListenable: LocalizationService.currentLanguage,
        builder: (context, currentLang, _) => MaterialApp.router(
          key: ValueKey(currentLang),
          title: 'Momucoo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          routerConfig: _router,
        ),
      );
}
