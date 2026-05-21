import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_options_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // PANOR logo header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.health_and_safety_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'PANOR',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                'Choose Your\nPortal',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select the portal that matches your role',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF8892A4),
                ),
              ),
              const SizedBox(height: 40),
              _buildRoleCard(
                context,
                role: 'Patient',
                subtitle: 'Access your health records and appointments',
                icon: Icons.person_rounded,
                gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                role: 'Doctor',
                subtitle: 'Manage patients, consultations and prescriptions',
                icon: Icons.medical_services_rounded,
                gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                role: 'Lab',
                subtitle: 'Process lab requests and upload test results',
                icon: Icons.biotech_rounded,
                gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                role: 'Administrator',
                subtitle: 'System control, analytics and governance',
                icon: Icons.admin_panel_settings_rounded,
                gradient: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String role,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginOptionsScreen(role: role, color: color),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E2A3A), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role == 'Lab' ? 'Lab Assistant Portal' : '$role Portal',
                    style: GoogleFonts.inter(
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
                      color: const Color(0xFF8892A4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
