# Momucoo: web to Flutter conversion map

Phase 1 scaffold. Each screen in `lib/screens/` is a placeholder. Phase 2 replaces its `build` and keeps the class name and file path.

## Shared building blocks (already in place)
- `lib/core/theme.dart`: `AppColors`, `AppTheme.light()`. The colors come from App.css: primary `#D52F68`, ink `#243F3B`, accent `#D87854`, peach `#FFB58D`, border `#EADED7`, success `#278052`. Body text uses Arial and display text uses Georgia.
- `lib/core/storage.dart`: `AppStorage.instance` and `StorageKeys`. The keys and JSON strings are identical to localStorage. `momucooSession` holds the raw string `"true"`. `AppStorage.profileChanged` replaces the `momucoo-profile-updated` window event.
- `lib/core/models/`: Profile, Account, Session, CbcData (string values), PregnancyData (`week` is dynamic), ScanData, AiResult. `jsNumber` and `jsTruthy` mimic JS coercion.
- `lib/core/risk_engine.dart`: `RiskEngine.evaluate(cbc:, pregnancy:, scan:, legacySymptoms:)` is an exact port of AIAnalysis.jsx. Tests are in `test/risk_engine_test.dart`.
- `lib/router.dart`: `Routes.*` constants and `sessionRedirect`. Protected routes need a session; `/`, `/login` and `/register` are public. Unknown routes fall back to Dashboard, as the web `*` route does.
- `lib/widgets/`: `PageLayout` is the port of PageLayout.jsx. The sidebar becomes a bottom NavigationBar for the 6 main items plus a drawer for Knowledge Hub, Feedback, Emergency and Logout. Also here: `MomucooAppBar` (initials avatar), `PrimaryButton`/`SecondaryButton` (`.primary-btn`/`.secondary-btn`), `ContentCard` (`.content-card` + kicker), `ListRow`, `StatusPill`.

## Pages

| JSX page | Dart screen | Route | Storage keys | Notes |
|---|---|---|---|---|
| Home.jsx | home_screen.dart `HomeScreen` | `/` | none | Responsive public landing page, no PageLayout. Uses a Flutter-built hero illustration and adapts the web hero for mobile. Buttons go to /register and /login. |
| Login.jsx | login_screen.dart `LoginScreen` | `/login` | R momucooAccount; RW momucooProfile (merges name); W momucooSession="true" | Match email case-insensitively and trim it; compare the password exactly. Use `Account.tryParse`. On success go to /dashboard. |
| Register.jsx | register_screen.dart `RegisterScreen` | `/register` | W momucooAccount {name,email,password}; W momucooProfile (blank fields, pregnancyStatus "Pregnant") | Go to /login afterward. |
| Dashboard.jsx | dashboard_screen.dart `DashboardScreen` | `/dashboard` | R momucooProfile (default name "Ananya Sharma"), pregnancyData, cbcData, scanData, aiResult | Quick-action tiles and a "Patient history" list (HistoryItem with done state). This is also the fallback route. Largest UI page. |
| PatientProfile.jsx | patient_profile_screen.dart `PatientProfileScreen` | `/profile` | R momucooAccount (login email); RW momucooProfile; RW pregnancyData (sets week from pregnancyWeek) | Show the saved sign-in email in Personal Information; do not hardcode an example address. Call `saveProfile` so `profileChanged` fires. |
| HealthCheck.jsx | health_check_screen.dart `HealthCheckScreen` | `/health-check` | R momucooProfile; W pregnancyData {week:int\|null, symptoms, chatTranscript[{from,text}], createdAt} | Scripted 4-question chatbot that uses regexes for positive answers. |
| CBCAnalysis.jsx | cbc_analysis_screen.dart `CBCAnalysisScreen` | `/cbc-analysis` | W cbcData, scanData {name,uploaded,values,uploadedAt}, pregnancyData {week from scan gestationalAge or "", symptoms: []} | **OCR**: replace tesseract.js with `google_mlkit_text_recognition` and pick images with `image_picker` (camera or gallery). Port `normalizeOcrText`, `extractNumber`, `extractCbcValues`, `extractScanValues` and `getGestationalWeek` (lines 211-300) into a pure Dart parser with tests. Web rejects PDFs. Saving overwrites pregnancyData, which wipes symptoms, as on web. Then go to /ai-analysis. |
| AIAnalysis.jsx | ai_analysis_screen.dart `AIAnalysisScreen` | `/ai-analysis` | R cbcData, pregnancyData, scanData, symptoms; W aiResult | Use `RiskEngine.evaluate` and then `saveAiResult(result.toAiResult(DateTime.now()))`. Show score, risk, factors and recommendations. Buttons: back to /cbc-analysis and on to next. |
| Reports.jsx | reports_screen.dart `ReportsScreen` | `/reports` | R momucooProfile, pregnancyData, cbcData, scanData, aiResult | Web uses `window.print()`; replace it with share/print (for example the `printing` or `share_plus` package) or leave a TODO. |
| CarePlan.jsx | care_plan_screen.dart `CarePlanScreen` | `/care-plan` | none | Static content in PageLayout. |
| EmergencyHelp.jsx | emergency_help_screen.dart `EmergencyHelpScreen` | `/emergency` | none | Static. Consider `url_launcher` for `tel:` links. |
| Feedback.jsx | feedback_screen.dart `FeedbackScreen` | `/feedback` | none | Static form. |
| KnowledgeHub.jsx | knowledge_hub_screen.dart `KnowledgeHubScreen` | `/knowledge-hub` | none | Static articles. |
| HealthQuiz.jsx | health_quiz_screen.dart `HealthQuizScreen` | `/health-quiz` | none | Static. |
| Reminders.jsx | reminders_screen.dart `RemindersScreen` | `/reminders` | none | Static. Local notifications are optional later. |
| HealthJourney.jsx | health_journey_screen.dart `HealthJourneyScreen` | `/health-journey` | none | Static. It had an import but no web route before. |
| ProgressTracking.jsx | progress_tracking_screen.dart `ProgressTrackingScreen` | `/progress-tracking` | none | New route (none on web). |
| Appointments.jsx | appointments_screen.dart `AppointmentsScreen` | `/appointments` | none | New route. Hardcoded demo list; links to /find-doctor. |
| Consultation.jsx | consultation_screen.dart `ConsultationScreen` | `/consultation` | none | New route. Links to /appointments. |
| FindDoctor.jsx | find_doctor_screen.dart `FindDoctorScreen` | `/find-doctor` | none | New route. Doctor list with filters (83 lines); "Book" goes to /appointments. |
| DoctorDashboard.jsx | doctor_dashboard_screen.dart `DoctorDashboardScreen` | `/doctor-dashboard` | none | New route. Links to /doctor-patients and /doctor-review. No doctor role exists, so it sits behind the same patient session. |
| DoctorPatients.jsx | doctor_patients_screen.dart `DoctorPatientsScreen` | `/doctor-patients` | none | New route. Static list. |
| DoctorReview.jsx | doctor_review_screen.dart `DoctorReviewScreen` | `/doctor-review` | none | New route. Static. |
| PageLayout.jsx | lib/widgets/page_layout.dart `PageLayout` | (layout) | R momucooProfile; logout removes momucooSession | Already ported. |

App.jsx has dead OTP/login code after its `return` ("AnemiaCare AI"). It is unreachable and not ported.

## Conventions for phase 2
- Wrap inner pages in `PageLayout(title:, eyebrow:, description:, activePath: Routes.x, children: [...])`.
- Navigate with `context.go(Routes.x)` and never hardcode route strings.
- Read and write only through `AppStorage.instance` so the data stays in the web shapes.
- Run `flutter analyze` and `flutter test` until both are clean.
