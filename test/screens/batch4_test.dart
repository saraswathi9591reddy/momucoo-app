import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momucoo/core/storage.dart';
import 'package:momucoo/core/theme.dart';
import 'package:momucoo/screens/batch4/content.dart';
import 'package:momucoo/screens/emergency_help_screen.dart';
import 'package:momucoo/screens/feedback_screen.dart';
import 'package:momucoo/screens/health_quiz_screen.dart';
import 'package:momucoo/screens/knowledge_hub_screen.dart';
import 'package:momucoo/screens/reminders_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(360, 780);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: AppTheme.light(), home: w));
  await t.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppStorage.init();
  });

  test('quiz scoring', () {
    expect(quizFeedback(''), isNull);
    expect(quizFeedback('Iron'), 'Correct. Iron is essential for hemoglobin production.');
    expect(quizFeedback('Calcium'), 'Not quite. Try reviewing the Knowledge Hub.');
    expect(quizFeedback('Vitamin D'), 'Not quite. Try reviewing the Knowledge Hub.');
  });

  testWidgets('quiz shows feedback per option', (t) async {
    await pump(t, const HealthQuizScreen());
    expect(find.text('QUESTION 1 OF 3'), findsOneWidget);
    expect(find.text('Correct. Iron is essential for hemoglobin production.'), findsNothing);
    await t.tap(find.text('Calcium'));
    await t.pump();
    expect(find.text('Not quite. Try reviewing the Knowledge Hub.'), findsOneWidget);
    await t.tap(find.text('Iron'));
    await t.pump();
    expect(find.text('Correct. Iron is essential for hemoglobin production.'), findsOneWidget);
  });

  testWidgets('knowledge hub expands and collapses one guide', (t) async {
    await pump(t, const KnowledgeHubScreen());
    final full = knowledgeTopics[0].$3;
    expect(find.text(knowledgePreview(full)), findsOneWidget);
    await t.ensureVisible(find.text('Read guide →').first);
    await t.pumpAndSettle();
    await t.tap(find.text('Read guide →').first);
    await t.pump();
    expect(find.text(full), findsOneWidget);
    await t.ensureVisible(find.text('Close guide ↑'));
    await t.pumpAndSettle();
    await t.tap(find.text('Close guide ↑'));
    await t.pump();
    expect(find.text('Close guide ↑'), findsNothing);
  });

  testWidgets('reminders toggle', (t) async {
    await pump(t, const RemindersScreen());
    expect(find.text('✓'), findsOneWidget);
    await t.tap(find.text('Take iron supplement'));
    await t.pump();
    expect(find.text('✓'), findsNWidgets(2));
  });

  testWidgets('feedback submit shows thanks', (t) async {
    await pump(t, const FeedbackScreen());
    await t.ensureVisible(find.text('Submit Feedback'));
    await t.tap(find.text('Submit Feedback'));
    await t.pump();
    expect(find.text('Thank you for your feedback.'), findsOneWidget);
  });

  testWidgets('emergency call button gives fallback', (t) async {
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (call) async => false,
    );
    addTearDown(() => t.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/url_launcher'), null));
    await pump(t, const EmergencyHelpScreen());
    await t.ensureVisible(find.text('Call 112'));
    await t.pumpAndSettle();
    await t.tap(find.text('Call 112'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Dial 112'), findsOneWidget);
  });
}
