import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/role_selection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final user = authProv.userProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Personal Profile',
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
                  // User Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0066FF).withValues(alpha: 0.08),
                    ),
                    child: const CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 64, color: Color(0xFF0066FF)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?['full_name']?.toString() ?? 'Valued Patient',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A1628),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?['email']?.toString() ?? 'patient@panor.com',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Detail Cards
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildProfileRow('Phone', user?['phone']?.toString() ?? 'Not provided'),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _buildProfileRow('Blood Group', user?['blood_group']?.toString() ?? 'Not provided'),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _buildProfileRow('Gender', user?['gender']?.toString() ?? 'Not provided'),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _buildProfileRow('Date of Birth', user?['date_of_birth']?.toString() ?? 'Not provided'),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _buildProfileRow('Emergency Contact', user?['emergency_contact']?.toString() ?? 'Not provided'),
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
                        backgroundColor: const Color(0xFF0066FF),
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

  Widget _buildProfileRow(String label, String value) {
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
