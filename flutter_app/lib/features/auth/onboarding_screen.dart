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
import '../../core/constants/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// The three onboarding step data definitions
  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.translate_rounded,
      iconColor: AppColors.brandPurple,
      gradient: AppColors.primaryGradient,
      badge: 'Agent 01 — Intake Intelligence',
      title: 'Multilingual\nMedical Intelligence',
      subtitle:
          'Speak in Urdu, Punjabi, or English. Submit prescription photos, PDF reports, or voice notes. PANOR understands everything.',
      features: [
        (Icons.mic_rounded, 'Voice Symptom Recording'),
        (Icons.image_rounded, 'Prescription Photo Scanning'),
        (Icons.picture_as_pdf_rounded, 'PDF Medical Report Parsing'),
      ],
    ),
    _OnboardingData(
      icon: Icons.emergency_rounded,
      iconColor: AppColors.emergencyRed,
      gradient: AppColors.emergencyGradient,
      badge: 'Agent 02 & 03 — Emergency Core',
      title: 'Emergency Detection\nin Real Time',
      subtitle:
          'Our clinical reasoning agents silently screen every consultation for cardiac, respiratory, and neurological emergencies — before symptoms escalate.',
      features: [
        (Icons.favorite_rounded, 'Silent Cardiac Screening'),
        (Icons.shield_rounded, 'Drug Safety Hard Blocks'),
        (Icons.warning_amber_rounded, 'Instant RED Alert Triggers'),
      ],
    ),
    _OnboardingData(
      icon: Icons.hub_rounded,
      iconColor: AppColors.success,
      gradient: AppColors.doctorGradient,
      badge: '7-Agent Antigravity Orchestration',
      title: 'AI-Powered Clinical\nInfrastructure',
      subtitle:
          'Seven specialized AI agents working in coordination — from intake to verification — creating a seamless, safe, and trustworthy care ecosystem.',
      features: [
        (Icons.science_rounded, 'Smart Lab Order Routing'),
        (Icons.bar_chart_rounded, 'Regional Outbreak Forecasting'),
        (Icons.verified_rounded, 'AI-Generated SOAP Notes'),
      ],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToRoleSelection();
    }
  }

  void _navigateToRoleSelection() {
    context.go('/role-selection');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                child: TextButton(
                  onPressed: _navigateToRoleSelection,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              child: Column(
                children: [
                  // Page indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: AppConstants.animFast,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.brandIndigo
                              : AppColors.border,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusFull),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLG),
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    height: AppConstants.buttonHeight,
                    child: FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandIndigo,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusLG),
                        ),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Continue'
                            : 'Get Started',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: AppConstants.fontMD,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Single Onboarding Page Widget ───────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePadding),
      child: Column(
        children: [
          const SizedBox(height: AppConstants.spaceLG),
          // Hero illustration
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: data.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: data.iconColor.withValues(alpha: 0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(data.icon, color: Colors.white, size: 72),
          ),
          const SizedBox(height: AppConstants.spaceLG),
          // Agent badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: data.iconColor.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusFull),
              border: Border.all(color: data.iconColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              data.badge,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontXS,
                fontWeight: FontWeight.w700,
                color: data.iconColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMD),
          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: AppConstants.fontXXL,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMD),
          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontMD,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXL),
          // Feature list
          ...data.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spaceSM),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: data.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(f.$1, color: data.iconColor, size: 16),
                  ),
                  const SizedBox(width: AppConstants.spaceMD),
                  Text(
                    f.$2,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontMD,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data Class ─────────────────────────────────────────────────────────────

class _OnboardingData {
  final IconData icon;
  final Color iconColor;
  final LinearGradient gradient;
  final String badge;
  final String title;
  final String subtitle;
  final List<(IconData, String)> features;

  const _OnboardingData({
    required this.icon,
    required this.iconColor,
    required this.gradient,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.features,
  });
}
