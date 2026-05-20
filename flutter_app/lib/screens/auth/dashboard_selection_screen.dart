import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../admin/admin_home_screen.dart';

class DashboardSelectionScreen extends StatelessWidget {
  const DashboardSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final role = authProv.role ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Choose Dashboard',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A1628),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your dashboard experience',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 48),

              if (role == 'Patient' || role.isEmpty)
                _buildDashboardCard(
                  context: context,
                  title: 'Patient Dashboard',
                  subtitle: 'Access health records, vitals, and book appointments.',
                  icon: Icons.person_outline,
                  color: const Color(0xFF0066FF),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => PatientHomeScreen()),
                      (r) => false,
                    );
                  },
                ),
              const SizedBox(height: 16),

              if (role == 'Doctor' || role.isEmpty)
                _buildDashboardCard(
                  context: context,
                  title: 'Doctor Dashboard',
                  subtitle: 'Manage patient consultation schedules and write SOAP notes.',
                  icon: Icons.medical_services_outlined,
                  color: const Color(0xFF00C853),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => DoctorHomeScreen()),
                      (r) => false,
                    );
                  },
                ),
              const SizedBox(height: 16),

              if (role == 'Administrator' || role.isEmpty)
                _buildDashboardCard(
                  context: context,
                  title: 'Admin Dashboard',
                  subtitle: 'Audit user activities and analyze system health metrics.',
                  icon: Icons.admin_panel_settings_outlined,
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => AdminHomeScreen()),
                      (r) => false,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
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
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A1628),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
