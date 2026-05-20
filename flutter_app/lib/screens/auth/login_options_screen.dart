import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class LoginOptionsScreen extends StatelessWidget {
  final String selectedRole;

  const LoginOptionsScreen({super.key, required this.selectedRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0066FF).withValues(alpha: 0.08),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  size: 56,
                  color: Color(0xFF0066FF),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to PANOR',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A1628),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in or create an account to continue',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              // Login button
              _buildButton(
                context,
                label: 'Login',
                icon: Icons.login_rounded,
                filled: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(selectedRole: selectedRole),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Create Account button
              _buildButton(
                context,
                label: 'Create Account',
                icon: Icons.person_add_rounded,
                filled: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterScreen(defaultRole: selectedRole),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or continue with',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                ],
              ),
              const SizedBox(height: 24),
              // Social buttons row
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      label: 'Phone',
                      icon: Icons.phone_android_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Phone login coming soon')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSocialButton(
                      label: 'Google',
                      icon: Icons.g_mobiledata_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google login coming soon')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSocialButton(
                      label: 'Apple',
                      icon: Icons.apple_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Apple login coming soon')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? const Color(0xFF0066FF) : Colors.white,
          foregroundColor: filled ? Colors.white : const Color(0xFF0A1628),
          elevation: 0,
          side: filled
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: const Color(0xFF475569)),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
