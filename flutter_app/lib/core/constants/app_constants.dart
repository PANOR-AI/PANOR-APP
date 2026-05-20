import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// PANOR Design System — Application-Wide Constants
/// Centralizes all magic numbers, spacing values, animation durations,
/// and configuration strings to prevent hardcoding throughout the codebase.

class AppConstants {
  AppConstants._();

  // ─── Spacing Scale ─────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ─── Border Radius Scale ───────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 999.0;

  // ─── Icon Sizes ────────────────────────────────────────────────
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;

  // ─── Font Sizes ────────────────────────────────────────────────
  static const double fontXS = 11.0;
  static const double fontSM = 13.0;
  static const double fontMD = 15.0;
  static const double fontLG = 17.0;
  static const double fontXL = 22.0;
  static const double fontXXL = 28.0;
  static const double fontDisplay = 36.0;

  // ─── Animation Durations ───────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(milliseconds: 2500);

  // ─── Component Heights ─────────────────────────────────────────
  static const double buttonHeight = 54.0;
  static const double inputHeight = 54.0;
  static const double appBarHeight = 60.0;
  static const double bottomNavHeight = 70.0;
  static const double cardMinHeight = 80.0;

  // ─── Page Padding ──────────────────────────────────────────────
  static const double pagePadding = 20.0;
  static const double cardPadding = 16.0;

  // ─── Backend API ───────────────────────────────────────────────
  /// Primary API base URL — dynamically pointed to 10.0.2.2 on Android emulator, or localhost.
  static String get apiBase {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  // ─── Pre-seeded Demo Credentials ──────────────────────────────
  static const Map<String, String> demoCredentials = {
    'patient': 'patient@panor.com',
    'doctor': 'doctor@panor.com',
    'lab': 'lab@panor.com',
    'admin': 'admin@panor.com',
  };
}
