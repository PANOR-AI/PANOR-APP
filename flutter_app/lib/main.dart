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
import 'screens/auth/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: const PanorApp(),
    ),
  );
}

class PanorApp extends StatelessWidget {
  const PanorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PANOR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066FF),
          primary: const Color(0xFF0066FF),
          surface: const Color(0xFFFAFAFA),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
