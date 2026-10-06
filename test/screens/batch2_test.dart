import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:momucoo/core/storage.dart';
import 'package:momucoo/core/theme.dart';
import 'package:momucoo/screens/ai_analysis_screen.dart';
import 'package:momucoo/screens/batch2/ocr.dart';
import 'package:momucoo/screens/care_plan_screen.dart';
import 'package:momucoo/screens/cbc_analysis_screen.dart';
import 'package:momucoo/screens/health_check_screen.dart';
import 'package:momucoo/screens/health_journey_screen.dart';
import 'package:momucoo/screens/progress_tracking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeOcr implements OcrService {
  FakeOcr(this.text);
  final String text;
  @override
  Future<PickedImage?> pick(ImageSource source) async => const PickedImage('report.jpg', '/tmp/report.jpg');
  @override
  Future<String> recognize(String path) async => text;
}

Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(360 * 3, 740 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = GoRouter(initialLocation: '/x', routes: [
    GoRoute(path: '/x', builder: (_, _) => screen),
    GoRoute(path: '/:other', builder: (_, s) => Scaffold(body: Text('at ${s.uri.path}'))),
  ]);
  await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
  await tester.pumpAndSettle();
}

Future<void> pressButton(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(find.text(label), 200, scrollable: find.byType(Scrollable).first);
  final b = tester.widget<ButtonStyleButton>(find.ancestor(of: find.text(label), matching: find.bySubtype<ButtonStyleButton>()));
  b.onPressed!();
}

Map<String, dynamic> stored(String key) => jsonDecode(AppStorage.instance.getRaw(key)!) as Map<String, dynamic>;

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'momucooProfile': '{"name":"Priya Rao"}'});
    await AppStorage.init();
  });

  testWidgets('static screens render at 360dp without overflow', (tester) async {
    for (final s in const [CarePlanScreen(), HealthJourneyScreen(), ProgressTrackingScreen()]) {
      await pumpScreen(tester, s);
      expect(tester.takeException(), isNull);
    }
    expect(find.text('9.2 g/dL'), findsOneWidget);
  });

  testWidgets('CBC: OCR fills editable fields, saves web shapes, goes to /ai-analysis', (tester) async {
    await pumpScreen(tester, CBCAnalysisScreen(ocr: FakeOcr('Hemoglobin 9.8 g/dL MCV 76 fL')));
    await tester.ensureVisible(find.byKey(const Key('cbc-upload')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cbc-upload')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Copied 2 value(s)'), findsOneWidget);
    // User corrects an OCR value before saving.
    await tester.enterText(find.byKey(const Key('cbc-hb')), '10.2');
    await tester.enterText(find.byKey(const Key('cbc-rbc')), '3.9');
    await pressButton(tester, 'Analyze My CBC →');
    await tester.pumpAndSettle();
    expect(find.text('at /ai-analysis'), findsOneWidget);
    expect(stored('cbcData'), {'hb': '10.2', 'rbc': '3.9', 'mcv': '76', 'mch': '', 'mchc': '', 'hematocrit': '', 'rdw': ''});
    expect(stored('scanData')['uploaded'], false);
    expect(stored('pregnancyData'), {'week': '', 'symptoms': []});
  });

  testWidgets('AI analysis uses risk engine and saves aiResult', (tester) async {
    await AppStorage.instance.setRaw('cbcData', '{"hb":"9","mcv":"75"}');
    await pumpScreen(tester, const AIAnalysisScreen());
    expect(find.text('High Risk'), findsOneWidget);
    expect(find.text('Anemia likely'), findsOneWidget);
    expect(find.text('No pregnancy scan was uploaded.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(stored('aiResult')['score'], 55);
    await pressButton(tester, '← Review CBC');
    await tester.pumpAndSettle();
    expect(find.text('at /cbc-analysis'), findsOneWidget);
  });

  testWidgets('Health check chat stores pregnancyData', (tester) async {
    await pumpScreen(tester, const HealthCheckScreen());
    expect(find.textContaining('Hi Priya Rao'), findsOneWidget);
    Future<void> say(String t) async {
      await tester.enterText(find.byKey(const Key('chat-input')), t);
      await tester.ensureVisible(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat-send')));
      await tester.pumpAndSettle();
    }

    await say('I feel tired and dizzy');
    await tester.ensureVisible(find.text('Yes, quite often'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, quite often'));
    await tester.pumpAndSettle();
    await say('20 weeks');
    await tester.ensureVisible(find.text('Yes, regularly'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, regularly'));
    await tester.pumpAndSettle();
    expect(find.text('Continue to Blood & Scan Reports →'), findsOneWidget);
    final p = stored('pregnancyData');
    expect(p['week'], 20);
    expect(p['symptoms'], ['tired', 'dizzy', 'tired or dizzy']);
    expect((p['chatTranscript'] as List).last, {'from': 'user', 'text': 'Yes, regularly'});
    expect(tester.takeException(), isNull);
  });
}
