import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

// Import all screens
import '../../features/auth/splash_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/otp_verification_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/role_selection_screen.dart';

import '../../features/patient/patient_home_screen.dart';
import '../../features/patient/voice_input_screen.dart';
import '../../features/patient/upload_report_screen.dart';
import '../../features/patient/ai_assistant_screen.dart';
import '../../features/patient/patient_timeline_screen.dart';

import '../../features/doctor/doctor_home_screen.dart';
import '../../features/lab/lab_home_screen.dart';
import '../../features/admin/admin_home_screen.dart';

/// Centralized application router using GoRouter.
/// Supports clean deep-linking and state-preservation where appropriate.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    // Splash Route
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    // Onboarding Route
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    // Authentication Routes
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'Patient';
        final color = AppColors.primaryForRole(role);
        return LoginScreen(role: role, color: color);
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'Patient';
        final color = AppColors.primaryForRole(role);
        return RegisterScreen(role: role, color: color);
      },
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        final role = state.uri.queryParameters['role'] ?? 'Patient';
        final color = AppColors.primaryForRole(role);
        return OtpVerificationScreen(email: email, role: role, color: color);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'Patient';
        final color = AppColors.primaryForRole(role);
        return ForgotPasswordScreen(color: color);
      },
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    // Patient Dashboard & Features
    GoRoute(
      path: '/patient/home',
      builder: (context, state) => const PatientHomeScreen(),
    ),
    GoRoute(
      path: '/patient/voice-input',
      builder: (context, state) => const VoiceInputScreen(),
    ),
    GoRoute(
      path: '/patient/upload-report',
      builder: (context, state) => const UploadReportScreen(),
    ),
    GoRoute(
      path: '/patient/ai-assistant',
      builder: (context, state) => const AiAssistantScreen(),
    ),
    GoRoute(
      path: '/patient/timeline',
      builder: (context, state) => const PatientTimelineScreen(),
    ),

    // Doctor Dashboard
    GoRoute(
      path: '/doctor/home',
      builder: (context, state) => const DoctorHomeScreen(),
    ),

    // Lab Dashboard
    GoRoute(
      path: '/lab/home',
      builder: (context, state) => const LabHomeScreen(),
    ),

    // Admin Dashboard
    GoRoute(
      path: '/admin/home',
      builder: (context, state) => const AdminHomeScreen(),
    ),
  ],
);
