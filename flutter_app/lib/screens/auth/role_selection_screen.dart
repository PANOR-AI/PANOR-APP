import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_options_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  final List<_RoleOption> _roles = const [
    _RoleOption(
      role: 'Patient',
      icon: Icons.person_rounded,
      color: Color(0xFF0066FF),
      description: 'Track health, book appointments, access AI diagnostics',
    ),
    _RoleOption(
      role: 'Doctor',
      icon: Icons.medical_services_rounded,
      color: Color(0xFF00C853),
      description: 'Manage patients, review records, clinical AI support',
    ),
    _RoleOption(
      role: 'Administrator',
      icon: Icons.admin_panel_settings_rounded,
      color: Color(0xFF7C3AED),
      description: 'System administration, analytics, user management',
    ),
  ];

  void _onContinue() {
    if (_selectedRole == null) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginOptionsScreen(selectedRole: _selectedRole!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Select Your Role',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A1628),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to use PANOR',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final r = _roles[index];
                    final selected = _selectedRole == r.role;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRole = r.role),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? r.color : const Color(0xFFE2E8F0),
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: r.color.withValues(alpha: 0.15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: r.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(r.icon, color: r.color, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.role,
                                    style: GoogleFonts.inter(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0A1628),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    r.description,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              Icon(Icons.check_circle_rounded,
                                  color: r.color, size: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _selectedRole != null ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOption {
  final String role;
  final IconData icon;
  final Color color;
  final String description;

  const _RoleOption({
    required this.role,
    required this.icon,
    required this.color,
    required this.description,
  });
}
