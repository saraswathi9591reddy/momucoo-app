import 'package:go_router/go_router.dart';

import 'core/storage.dart';
import 'screens/ai_analysis_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/care_plan_screen.dart';
import 'screens/cbc_analysis_screen.dart';
import 'screens/consultation_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'screens/doctor_patients_screen.dart';
import 'screens/doctor_review_screen.dart';
import 'screens/emergency_help_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/find_doctor_screen.dart';
import 'screens/health_check_screen.dart';
import 'screens/health_journey_screen.dart';
import 'screens/health_quiz_screen.dart';
import 'screens/home_screen.dart';
import 'screens/knowledge_hub_screen.dart';
import 'screens/login_screen.dart';
import 'screens/patient_profile_screen.dart';
import 'screens/progress_tracking_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/reports_screen.dart';

/// Route paths. Same paths as the web app (App.jsx); the 6 unrouted web pages
/// (Appointments, Consultation, FindDoctor, ProgressTracking, Doctor*) get paths
/// matching the links already used in the JSX (e.g. navigate("/doctor-patients")).
class Routes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const aiAnalysis = '/ai-analysis';
  static const cbcAnalysis = '/cbc-analysis';
  static const carePlan = '/care-plan';
  static const emergency = '/emergency';
  static const feedback = '/feedback';
  static const healthCheck = '/health-check';
  static const healthJourney = '/health-journey';
  static const healthQuiz = '/health-quiz';
  static const knowledgeHub = '/knowledge-hub';
  static const profile = '/profile';
  static const reminders = '/reminders';
  static const reports = '/reports';
  static const appointments = '/appointments';
  static const consultation = '/consultation';
  static const findDoctor = '/find-doctor';
  static const progressTracking = '/progress-tracking';
  static const doctorDashboard = '/doctor-dashboard';
  static const doctorPatients = '/doctor-patients';
  static const doctorReview = '/doctor-review';

  /// Reachable without a session.
  static const public = {Routes.home, Routes.login, Routes.register};
}

/// Session redirect. The web app only sets/removes `momucooSession` (no guard);
/// mobile enforces it: protected routes need a session, and a logged-in user
/// opening /login or /register goes to /dashboard. Home ("/") stays public.
String? sessionRedirect(String location, bool loggedIn) {
  final isPublic = Routes.public.contains(location);
  if (!loggedIn && !isPublic) return Routes.login;
  if (loggedIn && (location == Routes.login || location == Routes.register)) return Routes.dashboard;
  return null;
}

GoRouter buildRouter() => GoRouter(
      initialLocation: Routes.home,
      redirect: (context, state) => sessionRedirect(state.matchedLocation, AppStorage.instance.isLoggedIn),
      // Web: <Route path="*" element={<Dashboard />} />
      errorBuilder: (_, _) => const DashboardScreen(),
      routes: [
    GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
    GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
    GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
    GoRoute(path: Routes.dashboard, builder: (_, _) => const DashboardScreen()),
    GoRoute(path: Routes.aiAnalysis, builder: (_, _) => const AIAnalysisScreen()),
    GoRoute(path: Routes.cbcAnalysis, builder: (_, _) => const CBCAnalysisScreen()),
    GoRoute(path: Routes.carePlan, builder: (_, _) => const CarePlanScreen()),
    GoRoute(path: Routes.emergency, builder: (_, _) => const EmergencyHelpScreen()),
    GoRoute(path: Routes.feedback, builder: (_, _) => const FeedbackScreen()),
    GoRoute(path: Routes.healthCheck, builder: (_, _) => const HealthCheckScreen()),
    GoRoute(path: Routes.healthJourney, builder: (_, _) => const HealthJourneyScreen()),
    GoRoute(path: Routes.healthQuiz, builder: (_, _) => const HealthQuizScreen()),
    GoRoute(path: Routes.knowledgeHub, builder: (_, _) => const KnowledgeHubScreen()),
    GoRoute(path: Routes.profile, builder: (_, _) => const PatientProfileScreen()),
    GoRoute(path: Routes.reminders, builder: (_, _) => const RemindersScreen()),
    GoRoute(path: Routes.reports, builder: (_, _) => const ReportsScreen()),
    GoRoute(path: Routes.appointments, builder: (_, _) => const AppointmentsScreen()),
    GoRoute(path: Routes.consultation, builder: (_, _) => const ConsultationScreen()),
    GoRoute(path: Routes.findDoctor, builder: (_, _) => const FindDoctorScreen()),
    GoRoute(path: Routes.progressTracking, builder: (_, _) => const ProgressTrackingScreen()),
    GoRoute(path: Routes.doctorDashboard, builder: (_, _) => const DoctorDashboardScreen()),
    GoRoute(path: Routes.doctorPatients, builder: (_, _) => const DoctorPatientsScreen()),
    GoRoute(path: Routes.doctorReview, builder: (_, _) => const DoctorReviewScreen()),
      ],
    );
