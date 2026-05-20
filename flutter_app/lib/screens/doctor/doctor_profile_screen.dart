import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/role_selection_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final user = authProv.userProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Doctor Settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
        ),
      ),
      body: authProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00C853).withValues(alpha: 0.08),
                    ),
                    child: const CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 64, color: Color(0xFF00C853)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?['full_name']?.toString() ?? 'Valued Doctor',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A1628),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?['email']?.toString() ?? 'doctor@panor.com',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Detail Row Cards
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildRow('Specialty Field', user?['specialty']?.toString() ?? 'General Medicine'),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _buildRow('Consultation Fee', '\$${user?['consultation_fee']?.toString() ?? '100.0'}'),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _buildRow('License Number', user?['license_number']?.toString() ?? 'N/A'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        await authProv.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: Text(
                        'Logout',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0A1628), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
