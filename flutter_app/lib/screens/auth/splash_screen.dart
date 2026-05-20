import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/providers/auth_provider.dart';
import 'onboarding_screen.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../admin/admin_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();

    Timer(const Duration(seconds: 2), _navigate);
  }

  Future<void> _navigate() async {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    await authProv.checkSession();
    if (!mounted) return;

    if (authProv.isAuthenticated && authProv.user != null) {
      final role = authProv.user!.role;
      Widget dest;
      if (role == 'Doctor') {
        dest = DoctorHomeScreen();
      } else if (role == 'Administrator') {
        dest = AdminHomeScreen();
      } else {
        dest = PatientHomeScreen();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => dest),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0066FF).withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0066FF).withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  size: 80,
                  color: Color(0xFF0066FF),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'PANOR',
                style: GoogleFonts.inter(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0A1628),
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Patient-Augmented Network\nfor Operational Reasoning',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF0066FF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
