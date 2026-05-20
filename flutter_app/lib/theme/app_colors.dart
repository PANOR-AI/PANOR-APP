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
  static const Color background = Color(0xFF070913); // Deep dark space-black background
  static const Color surface = Color(0xFF0E1326); // Translucent obsidian card surface
  static const Color surfaceVariant = Color(0xFF161C33);
  static const Color cardBackground = Color(0xFF0E1326);
  static const Color scaffoldDark = Color(0xFF070913);

  // ─── Text ─────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF); // Clean high-contrast white text
  static const Color textSecondary = Color(0xFF8C9BBE); // Futuristic slate-blue text
  static const Color textMuted = Color(0xFF5D6C8F);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ─── Borders & Dividers ───────────────────────────────────────
  static const Color border = Color(0xFF1E2640); // Elegant thin glowing card borders
  static const Color borderLight = Color(0xFF242E4F);
  static const Color divider = Color(0xFF1E2640);

  // ─── Semantic Colors ──────────────────────────────────────────
  static const Color success = Color(0xFF10B981); // Emerald green
  static const Color successLight = Color(0xFF064E3B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFF78350F);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFF7F1D1D);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF1E3A8A);

  // ─── Emergency & Clinical ─────────────────────────────────────
  static const Color emergencyRed = Color(0xFFDC2626);
  static const Color emergencyRedLight = Color(0xFFFECACA);
  static const Color statUrgent = Color(0xFFEA580C);
  static const Color criticalPulse = Color(0xFFB91C1C);

  // ─── Patient Role Colors (Purple Spectrum) ──────────────────────
  static const Color patientPrimary = Color(0xFF8B5CF6);
  static const Color patientLight = Color(0xFF1E1B4B);
  static const Color patientDark = Color(0xFF5B21B6);
  static const Color patientAccent = Color(0xFFA78BFA);

  // ─── Doctor Role Colors (Blue Spectrum) ────────────────────────
  static const Color doctorPrimary = Color(0xFF0072FF);
  static const Color doctorLight = Color(0xFF0C1B33);
  static const Color doctorDark = Color(0xFF0052D4);
  static const Color doctorAccent = Color(0xFF00C6FF);

  // ─── Lab Technician Role Colors (Teal/Cyan Spectrum) ──────────
  static const Color labPrimary = Color(0xFF00B4D8);
  static const Color labLight = Color(0xFF082F49);
  static const Color labDark = Color(0xFF0077B6);
  static const Color labAccent = Color(0xFF00F2FE);

  // ─── Admin Role Colors (Magenta Spectrum) ──────────────────────
  static const Color adminPrimary = Color(0xFFEC4899);
  static const Color adminLight = Color(0xFF3B0764);
  static const Color adminDark = Color(0xFF9D174D);
  static const Color adminAccent = Color(0xFFF472B6);

  // ─── Gradients ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF070913), Color(0xFF0A0F24), Color(0xFF0D1433)],
  );

  static const LinearGradient patientGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  );

  static const LinearGradient doctorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
  );

  static const LinearGradient labGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00F2FE), Color(0xFF0077B6)],
  );

  static const LinearGradient adminGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC4899), Color(0xFF7C3AED)],
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
  );

  static const LinearGradient cardShimmer = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [Color(0xFF0E1326), Color(0xFF1E2640), Color(0xFF0E1326)],
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
