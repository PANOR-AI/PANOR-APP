import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/patient_provider.dart';
import 'core/providers/ai_provider.dart';
import 'core/providers/doctor_provider.dart';
import 'core/providers/admin_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/appointment_provider.dart';
import 'core/services/websocket_service.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/secure_login_screen.dart';
import 'screens/patient/ai_assistant_screen.dart';
import 'screens/patient/medications_screen.dart';
import 'screens/doctor/consultation_screen.dart';
import 'screens/dashboards/patient_dashboard.dart';
import 'screens/dashboards/doctor_dashboard.dart';
import 'screens/dashboards/lab_dashboard.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => WebSocketService()),
        // NotificationProvider depends on WebSocketService, so use ProxyProvider to inject it.
        ProxyProvider<WebSocketService, NotificationProvider>(
          update: (_, wsService, __) => NotificationProvider()..listenToWebSocket(wsService),
        ),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: const PanorApp(),
    ),
  );
}

class PanorApp extends StatefulWidget {
  const PanorApp({super.key});

  @override
  State<PanorApp> createState() => _PanorAppState();
}

class _PanorAppState extends State<PanorApp> {
  @override
  void initState() {
    super.initState();
    // Initialize WebSocket connection and bind to NotificationProvider
    final wsService = Provider.of<WebSocketService>(context, listen: false);
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    wsService.connect();
    notifProvider.listenToWebSocket(wsService);
    notifProvider.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PANOR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF0066FF),
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/role-selection': (_) => const RoleSelectionScreen(),
        '/login': (_) => const SecureLoginScreen(),
        '/patient-dashboard': (_) => const PatientDashboard(),
        '/doctor-dashboard': (_) => const DoctorDashboard(),
        '/lab-dashboard': (_) => const LabDashboard(),
        '/ai-assistant': (_) => const AIAssistantScreen(),
        '/medication-reminders': (_) => const MedicationsScreen(),
      },
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        if (name.startsWith('/consultation/')) {
          return MaterialPageRoute(builder: (_) => const ConsultationScreen());
        }
        if (name.startsWith('/lab-processing/') || name.startsWith('/lab-report/')) {
          return MaterialPageRoute(builder: (_) => const LabDashboard());
        }
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      },
    );
  }
}
