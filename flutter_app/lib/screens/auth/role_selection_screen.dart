import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_options_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('I am a', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Select your role to continue', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            _buildRoleCard(context, 'Patient', Icons.person_outline, Color(0xFF0066FF)),
            const SizedBox(height: 16),
            _buildRoleCard(context, 'Doctor', Icons.medical_services_outlined, Color(0xFF00C853)),
            const SizedBox(height: 16),
            _buildRoleCard(context, 'Administrator', Icons.admin_panel_settings_outlined, Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginOptionsScreen(role: title, color: color)));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
