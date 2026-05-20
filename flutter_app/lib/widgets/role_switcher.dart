import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// One-click role switcher for hackathon judge demo convenience.
/// Floats as a FAB or can be embedded in AppBar.
class RoleSwitcherButton extends StatelessWidget {
  const RoleSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20),
      ),
      tooltip: 'Switch Role (Demo)',
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      offset: const Offset(0, 48),
      onSelected: (role) {
        switch (role) {
          case 'patient':
            context.go('/patient/home');
            break;
          case 'doctor':
            context.go('/doctor/home');
            break;
          case 'lab':
            context.go('/lab/home');
            break;
          case 'admin':
            context.go('/admin/home');
            break;
        }
      },
      itemBuilder: (context) => [
        _buildRoleItem('patient', 'Patient Portal', 'Ahmed Raza', Icons.person_rounded, AppColors.patientPrimary),
        _buildRoleItem('doctor', 'Doctor Dashboard', 'Dr. Fatima Hassan', Icons.medical_services_rounded, AppColors.doctorPrimary),
        _buildRoleItem('lab', 'Lab Workspace', 'Sana Malik', Icons.science_rounded, AppColors.labPrimary),
        _buildRoleItem('admin', 'Admin Control', 'Noorullah Khan', Icons.shield_rounded, AppColors.adminPrimary),
      ],
    );
  }

  PopupMenuItem<String> _buildRoleItem(String value, String title, String name, IconData icon, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(name, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
