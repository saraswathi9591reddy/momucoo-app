import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:momucoo/core/storage.dart';
import 'package:momucoo/router.dart';
import 'package:momucoo/screens/appointments_screen.dart';
import 'package:momucoo/screens/consultation_screen.dart';
import 'package:momucoo/screens/doctor_dashboard_screen.dart';
import 'package:momucoo/screens/doctor_patients_screen.dart';
import 'package:momucoo/screens/doctor_review_screen.dart';
import 'package:momucoo/screens/find_doctor_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpAt(WidgetTester tester, String initial) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'momucooSession': 'true'});
  await AppStorage.init();
  final router = GoRouter(initialLocation: initial, routes: [
    GoRoute(path: Routes.doctorDashboard, builder: (_, _) => const DoctorDashboardScreen()),
    GoRoute(path: Routes.doctorPatients, builder: (_, _) => const DoctorPatientsScreen()),
    GoRoute(path: Routes.doctorReview, builder: (_, _) => const DoctorReviewScreen()),
    GoRoute(path: Routes.findDoctor, builder: (_, _) => const FindDoctorScreen()),
    GoRoute(path: Routes.appointments, builder: (_, _) => const AppointmentsScreen()),
    GoRoute(path: Routes.consultation, builder: (_, _) => const ConsultationScreen()),
  ]);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  // Centre it so the bottom NavigationBar does not cover the target.
  final ctx = tester.element(find.text(text));
  if (Scrollable.maybeOf(ctx) != null) {
    await Scrollable.ensureVisible(ctx, alignment: 0.5);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('doctor dashboard stats and navigation', (t) async {
    await pumpAt(t, Routes.doctorDashboard);
    expect(find.text('24'), findsOneWidget);
    expect(find.text("Today's appointments"), findsOneWidget);
    await tapText(t, 'View Patients');
    expect(find.text('PATIENT DIRECTORY'), findsOneWidget);
  });

  testWidgets('doctor dashboard goes to review', (t) async {
    await pumpAt(t, Routes.doctorDashboard);
    await tapText(t, 'Review Reports');
    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('Hemoglobin 9.2 g/dL • Moderate risk'), findsOneWidget);
  });

  testWidgets('doctor patients search filters', (t) async {
    await pumpAt(t, Routes.doctorPatients);
    expect(find.text('Open record'), findsNWidgets(3));
    await t.enterText(find.byType(TextField), 'MEERA');
    await t.pump();
    expect(find.text('Meera Patel'), findsOneWidget);
    expect(find.text('Kavya Nair'), findsNothing);
  });

  testWidgets('find doctor filters by specialty, empty state, books', (t) async {
    await pumpAt(t, Routes.findDoctor);
    await t.enterText(find.byType(TextField), 'hemat');
    await t.pump();
    expect(find.text('Dr. Rahul Sharma'), findsOneWidget);
    expect(find.text('Dr. Ananya Rao'), findsNothing);
    await t.enterText(find.byType(TextField), 'zzz');
    await t.pump();
    expect(find.text('No doctors found'), findsOneWidget);
    await t.enterText(find.byType(TextField), '');
    await t.pump();
    final book = find.text('Book Appointment →').first;
    await t.ensureVisible(book);
    await t.tap(book);
    await t.pumpAndSettle();
    expect(find.text('Confirmed'), findsOneWidget);
  });

  testWidgets('appointments reschedule and navigation', (t) async {
    await pumpAt(t, Routes.appointments);
    expect(find.text('Confirmed'), findsOneWidget);
    await tapText(t, 'Reschedule');
    expect(find.text('Rescheduling options will be sent to your registered contact.'), findsOneWidget);
    await tapText(t, 'Find a Doctor →');
    expect(find.text('Find the right doctor'), findsWidgets);
  });

  testWidgets('consultation join dialog and back to appointments', (t) async {
    await pumpAt(t, Routes.consultation);
    await tapText(t, 'Join Consultation');
    expect(find.text(ConsultationScreen.joinMessage), findsOneWidget);
    await tapText(t, 'OK');
    await tapText(t, 'View Appointments');
    expect(find.text('Need a new appointment?'), findsOneWidget);
  });
}
