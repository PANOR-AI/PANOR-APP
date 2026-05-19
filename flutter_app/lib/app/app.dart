import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/routing/router.dart';
import '../theme/app_colors.dart';

/// The central entry point of the PANOR Application.
/// Configures high-trust colors, typography, and GoRouter.
class PanorApp extends StatelessWidget {
  const PanorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PANOR - Clinical Intelligence Platform',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.brandIndigo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brandIndigo,
          primary: AppColors.brandIndigo,
          secondary: AppColors.brandPurple,
          error: AppColors.emergencyRed,
          surface: AppColors.surface,
          outline: AppColors.border,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}
