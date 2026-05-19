import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandIndigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      color: AppColors.brandIndigo,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PANOR',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandIndigo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                'Who are you?',
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your operational workspace role to begin authenticating into PANOR.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),
              _buildRoleCard(
                context,
                'Patient',
                'Access your personal medical record history, track lab statuses, submit symptoms via voice, and communicate with clinical AI copilots.',
                Icons.person_outline_rounded,
                AppColors.patientPrimary,
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                'Doctor',
                'Review patient charts, utilize 7-agent medical diagnostics reasoning, write automated SOAP clinical notes, and handle STAT laboratory orders.',
                Icons.medical_services_outlined,
                AppColors.doctorPrimary,
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                'Lab Technician',
                'Manage incoming pathology orders, process critical specimen tests, input quantitative reports, and execute STAT alert escalations.',
                Icons.biotech_outlined,
                AppColors.labPrimary,
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                'Administrator',
                'Supervise regional outbreak telemetry, monitor real-time spatial clinical reasoning performance, review logs, and manage user assets.',
                Icons.admin_panel_settings_outlined,
                AppColors.adminPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(role: title, color: color),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
