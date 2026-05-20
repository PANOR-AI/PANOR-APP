/// PANOR Onboarding Screen
///
/// 3-step premium onboarding showcasing the platform's core value propositions:
/// 1. Multilingual Medical Intelligence
/// 2. Emergency Detection in Real Time
/// 3. AI-Powered Clinical Infrastructure
///
/// Design: Apple-level smoothness with animated hero illustrations,
/// gradient backgrounds, and a smooth dot-indicator page system.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // App Logo & Header from image
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.patientGradient,
                    ),
                    child: const Icon(
                      Icons.add_moderator_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'PANOR',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              // Title and Subtitle from image
              Text(
                'Welcome to\nPANOR',
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The Future of Healthcare in Pakistan',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              // Feature Cards list
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildFeatureCard(
                      icon: Icons.psychology_rounded,
                      iconColor: AppColors.patientPrimary,
                      title: 'AI-Powered Insights',
                      subtitle: '24/7 intelligent, clinical health assistance',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      icon: Icons.hub_rounded,
                      iconColor: AppColors.doctorPrimary,
                      title: 'Unified Healthcare',
                      subtitle: 'One ID. One Record. Nationwide.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      icon: Icons.security_rounded,
                      iconColor: Colors.tealAccent,
                      title: 'Secure & Private',
                      subtitle: 'Your data is encrypted and protected',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      icon: Icons.sync_rounded,
                      iconColor: AppColors.adminPrimary,
                      title: 'Seamless Experience',
                      subtitle: 'Connect with doctors, labs & hospitals',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Step Indicators from image (5 dots, 2nd is active)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == 1 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == 1
                          ? AppColors.patientAccent
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Beautiful Gradient Next button from image
              GestureDetector(
                onTap: () => context.go('/role-selection'),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.patientGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.patientPrimary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Next',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          // Icon Container with elegant circular background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
