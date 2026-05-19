import 'package:flutter/material.dart';

/// PANOR Design System — Premium Medical Color Palette
/// 
/// Inspired by Apple Health + Linear + Stripe Dashboard aesthetics.
/// Every color is carefully chosen for clinical clarity and visual elegance.
class AppColors {
  AppColors._();

  // ─── Brand Colors ──────────────────────────────────────────────
  static const Color brandIndigo = Color(0xFF312E81);
  static const Color brandPurple = Color(0xFF7C3AED);
  static const Color brandBlue = Color(0xFF3B82F6);
  static const Color brandViolet = Color(0xFF8B5CF6);

  // ─── Surface & Background ─────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffoldDark = Color(0xFF0F172A);

  // ─── Text ─────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF8FAFC);

  // ─── Borders & Dividers ───────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // ─── Semantic Colors ──────────────────────────────────────────
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─── Emergency & Clinical ─────────────────────────────────────
  static const Color emergencyRed = Color(0xFFDC2626);
  static const Color emergencyRedLight = Color(0xFFFECACA);
  static const Color statUrgent = Color(0xFFEA580C);
  static const Color criticalPulse = Color(0xFFB91C1C);

  // ─── Patient Role Colors (Blue Spectrum) ──────────────────────
  static const Color patientPrimary = Color(0xFF3B82F6);
  static const Color patientLight = Color(0xFFEFF6FF);
  static const Color patientDark = Color(0xFF1D4ED8);
  static const Color patientAccent = Color(0xFF60A5FA);

  // ─── Doctor Role Colors (Emerald Spectrum) ────────────────────
  static const Color doctorPrimary = Color(0xFF10B981);
  static const Color doctorLight = Color(0xFFD1FAE5);
  static const Color doctorDark = Color(0xFF059669);
  static const Color doctorAccent = Color(0xFF34D399);

  // ─── Lab Technician Role Colors (Amber Spectrum) ──────────────
  static const Color labPrimary = Color(0xFFF59E0B);
  static const Color labLight = Color(0xFFFEF3C7);
  static const Color labDark = Color(0xFFD97706);
  static const Color labAccent = Color(0xFFFBBF24);

  // ─── Admin Role Colors (Purple Spectrum) ──────────────────────
  static const Color adminPrimary = Color(0xFF7C3AED);
  static const Color adminLight = Color(0xFFF5F3FF);
  static const Color adminDark = Color(0xFF6D28D9);
  static const Color adminAccent = Color(0xFFA78BFA);

  // ─── Gradients ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandIndigo, brandPurple],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4C1D95)],
  );

  static const LinearGradient patientGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
  );

  static const LinearGradient doctorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF10B981)],
  );

  static const LinearGradient labGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
  );

  static const LinearGradient adminGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D28D9), Color(0xFF7C3AED)],
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
  );

  static const LinearGradient cardShimmer = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
  );

  // ─── Shadows ──────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> primaryButtonShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ─── Role Color Resolver ──────────────────────────────────────
  static Color primaryForRole(String role) {
    switch (role.toLowerCase()) {
      case 'patient': return patientPrimary;
      case 'doctor': return doctorPrimary;
      case 'lab':
      case 'lab technician': return labPrimary;
      case 'administrator':
      case 'admin': return adminPrimary;
      default: return brandPurple;
    }
  }

  static Color lightForRole(String role) {
    switch (role.toLowerCase()) {
      case 'patient': return patientLight;
      case 'doctor': return doctorLight;
      case 'lab':
      case 'lab technician': return labLight;
      case 'administrator':
      case 'admin': return adminLight;
      default: return adminLight;
    }
  }

  static LinearGradient gradientForRole(String role) {
    switch (role.toLowerCase()) {
      case 'patient': return patientGradient;
      case 'doctor': return doctorGradient;
      case 'lab':
      case 'lab technician': return labGradient;
      case 'administrator':
      case 'admin': return adminGradient;
      default: return primaryGradient;
    }
  }
}
