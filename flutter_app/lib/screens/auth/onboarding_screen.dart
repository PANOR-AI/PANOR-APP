import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_buttons.dart';
import 'role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.health_and_safety_rounded,
      'gradient': [const Color(0xFF6C63FF), const Color(0xFF3B82F6)],
      'title': 'Welcome to PANOR',
      'subtitle': 'The Future of Healthcare in Pakistan',
      'desc': 'A unified national AI-agentic healthcare ecosystem that connects every patient, doctor, lab and clinic under one secure platform.',
    },
    {
      'icon': Icons.fingerprint_rounded,
      'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      'title': 'Powered AI Insights',
      'subtitle': '7 Specialized Clinical AI Agents',
      'desc': 'Every consultation, diagnosis, drug safety check, and lab order is guided by specialized AI agents orchestrated by Google Antigravity.',
    },
    {
      'icon': Icons.shield_rounded,
      'gradient': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
      'title': 'One Record. Forever.',
      'subtitle': 'NADRA-Verified National Patient ID',
      'desc': 'Your P_ID connects your complete medical history — from multiple hospitals, labs, and clinics — into one immutable, secure timeline.',
    },
    {
      'icon': Icons.people_alt_rounded,
      'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      'title': 'Seamless Experience',
      'subtitle': 'Connect. Consult. Care.',
      'desc': 'Patients, Doctors, Labs, and Administrators work in perfect harmony through real-time AI coordination and role-based intelligence.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: page['gradient'] as List<Color>,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: (page['gradient'] as List<Color>)[0]
                                    .withValues(alpha: 0.35),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 68,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 56),
                        Text(
                          page['title'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page['subtitle'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: (page['gradient'] as List<Color>)[0],
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page['desc'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF8892A4),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFF2A3544),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageCtrl.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RoleSelectionScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RoleSelectionScreen()),
                        );
                      },
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8892A4),
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
