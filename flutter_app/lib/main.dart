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
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066FF),
          primary: const Color(0xFF0066FF),
          background: const Color(0xFFFAFAFA),
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
