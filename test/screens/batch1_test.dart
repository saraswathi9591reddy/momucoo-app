import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:momucoo/core/storage.dart';
import 'package:momucoo/core/theme.dart';
import 'package:momucoo/router.dart';
import 'package:momucoo/screens/dashboard_screen.dart';
import 'package:momucoo/screens/home_screen.dart';
import 'package:momucoo/screens/login_screen.dart';
import 'package:momucoo/screens/patient_profile_screen.dart';
import 'package:momucoo/screens/register_screen.dart';
import 'package:momucoo/screens/reports_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps [initial] at 360x800 with stub pages for other routes.
Future<void> pumpAt(WidgetTester tester, String initial, Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  await AppStorage.init();
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  Widget stub(String name) => Scaffold(body: Text('STUB $name'));
  final router = GoRouter(initialLocation: initial, routes: [
    GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
    GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
    GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
    GoRoute(path: Routes.dashboard, builder: (_, _) => const DashboardScreen()),
    GoRoute(path: Routes.profile, builder: (_, _) => const PatientProfileScreen()),
    GoRoute(path: Routes.reports, builder: (_, _) => const ReportsScreen()),
    for (final r in [Routes.healthCheck, Routes.cbcAnalysis, Routes.aiAnalysis])
      GoRoute(path: r, builder: (_, _) => stub(r)),
  ]);
  await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home shows hero and goes to register', (tester) async {
    await pumpAt(tester, Routes.home, {});
    expect(find.text('Pregnancy care, but make it simple.'), findsOneWidget);
    await tester.tap(find.text('Start my care era →'));
    await tester.pumpAndSettle();
    expect(find.text('Create Your Account'), findsOneWidget);
  });

  testWidgets('Register validates then saves account + profile', (tester) async {
    await pumpAt(tester, Routes.register, {});
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), ' Priya ');
    await tester.enterText(fields.at(1), 'P@X.com ');
    await tester.enterText(fields.at(2), '123');
    await tester.ensureVisible(find.text('Create Account →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Account →'));
    await tester.pump();
    expect(find.textContaining('at least 6 characters'), findsOneWidget);
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'secret2');
    await tester.tap(find.text('Create Account →'));
    await tester.pump();
    expect(find.text('Passwords do not match.'), findsOneWidget);
    await tester.enterText(fields.at(3), 'secret1');
    await tester.tap(find.text('Create Account →'));
    await tester.pumpAndSettle();
    final s = AppStorage.instance;
    expect(jsonDecode(s.getRaw('momucooAccount')!), {'name': 'Priya', 'email': 'p@x.com', 'password': 'secret1'});
    expect(s.profile!.pregnancyStatus, 'Pregnant');
    expect(find.text('Welcome Back 👋'), findsOneWidget);
  });

  testWidgets('Login rejects bad password, accepts good one', (tester) async {
    await pumpAt(tester, Routes.login, {
      'momucooAccount': jsonEncode({'name': 'Priya', 'email': 'p@x.com', 'password': 'secret1'}),
      'momucooProfile': jsonEncode({'name': 'Old', 'age': '25'}),
    });
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), ' P@X.COM ');
    await tester.enterText(fields.at(1), 'wrong');
    await tester.ensureVisible(find.text('Login as Patient →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login as Patient →'));
    await tester.pump();
    expect(find.textContaining('Account not found'), findsOneWidget);
    await tester.enterText(fields.at(1), 'secret1');
    await tester.tap(find.text('Login as Patient →'));
    await tester.pumpAndSettle();
    final s = AppStorage.instance;
    expect(s.getRaw('momucooSession'), 'true');
    expect(jsonDecode(s.getRaw('momucooProfile')!), {'name': 'Priya', 'age': '25'});
    expect(find.text('Completed health analysis'), findsOneWidget);
  });

  testWidgets('Dashboard shows history from storage', (tester) async {
    await pumpAt(tester, Routes.dashboard, {
      'momucooSession': 'true',
      'pregnancyData': jsonEncode({'week': 8, 'symptoms': ['fatigue', 'dizziness']}),
      'cbcData': jsonEncode({'hb': '10.2'}),
      'aiResult': jsonEncode({'score': 55, 'risk': 'Moderate', 'anemiaStatus': 'x', 'completedAt': ''}),
    });
    expect(find.text('Ananya Sharma'), findsWidgets);
    expect(find.text('Week 8 • 2 symptom(s)'), findsOneWidget);
    expect(find.text('Hemoglobin 10.2 g/dL • Latest report'), findsOneWidget);
    expect(find.text('Optional report not uploaded'), findsOneWidget);
    expect(find.text('Moderate risk • Score 55/100'), findsOneWidget);
    await tester.tap(find.text('Pregnancy symptom chat'));
    await tester.pumpAndSettle();
    expect(find.text('STUB ${Routes.healthCheck}'), findsOneWidget);
  });

  testWidgets('Profile edit saves profile and pregnancy week', (tester) async {
    await pumpAt(tester, Routes.profile, {
      'momucooProfile': jsonEncode({'name': 'Priya', 'pregnancyStatus': 'Pregnant'}),
      'momucooAccount': jsonEncode({'name': 'Priya', 'email': 'priya@example.com', 'password': 'secret1'}),
      'pregnancyData': jsonEncode({'week': 5, 'symptoms': ['fatigue']}),
    });
    expect(find.text('PATIENT ACCOUNT'), findsNothing);
    expect(find.text('priya@example.com'), findsOneWidget);
    await tester.tap(find.text('✎ Edit Profile'));
    await tester.pumpAndSettle();
    final week = find.byKey(const ValueKey('profile-pregnancyWeek'));
    await tester.scrollUntilVisible(week, 200, scrollable: find.byType(Scrollable).first);
    await tester.enterText(week, '12');
    await tester.scrollUntilVisible(find.text('Save Profile'), -200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Your profile was updated successfully.'), findsOneWidget);
    final s = AppStorage.instance;
    expect(s.profile!.pregnancyWeek, '12');
    expect(jsonDecode(s.getRaw('pregnancyData')!), {'week': 12, 'symptoms': ['fatigue']});
  });

  testWidgets('Reports renders values and copies summary', (tester) async {
    await pumpAt(tester, Routes.reports, {
      'momucooProfile': jsonEncode({'name': 'Priya'}),
      'cbcData': jsonEncode({'hb': '10.2', 'mcv': ''}),
    });
    expect(find.text('Priya'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('10.2 g/dL'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('10.2 g/dL'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Analysis pending'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Analysis pending'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Copy Report'), -200, scrollable: find.byType(Scrollable).first);
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    await tester.tap(find.text('Copy Report'));
    await tester.pumpAndSettle();
    expect(copied, contains('Hemoglobin: 10.2 g/dL'));
    expect(find.text('Report summary copied to clipboard.'), findsOneWidget);
  });
}
