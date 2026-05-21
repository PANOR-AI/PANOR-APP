import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/providers/auth_provider.dart';
import 'onboarding_screen.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../admin/admin_home_screen.dart';
import '../../features/lab/lab_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut),
    );
    _animCtrl.forward();
    Timer(const Duration(seconds: 3), _navigate);
  }

  Future<void> _navigate() async {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    await authProv.checkSession();
    if (!mounted) return;

    if (authProv.role != null) {
      Widget dest;
      if (authProv.role == 'Doctor') {
        dest = DoctorHomeScreen();
      } else if (authProv.role == 'Administrator') {
        dest = AdminHomeScreen();
      } else if (authProv.role == 'Lab') {
        dest = const LabHomeScreen();
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
      backgroundColor: const Color(0xFF0A0E1A),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 8,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Text(
                'PANOR',
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Health. Our Intelligence.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8892A4),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Pakistan's First AI-Agentic Healthcare Platform",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF6C63FF).withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Initializing secure health session...',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF8892A4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
