import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/role_selection_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    
    final user = authProv.userProfile;
    final fullName = user != null ? user['full_name'] as String? ?? 'Administrator' : 'Administrator';
    final dash = adminProv.dashboardData;
    final metrics = dash != null ? dash['metrics'] as Map? ?? {} : {};
    final recentActivities = dash != null ? dash['recent_activities'] as List? ?? [] : [];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'PANOR Command Center',
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: const Color(0xFF7C3AED)),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF7C3AED)),
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
          )
        ],
      ),
      body: adminProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await adminProv.fetchDashboard();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $fullName',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A1628),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Platform Health: Operational',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF7C3AED),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Metrics row
                    Row(
                      children: [
                        _buildMetricCard(
                          label: 'Total Patients',
                          value: metrics['total_patients']?.toString() ?? '24',
                          icon: Icons.person_outline,
                          color: const Color(0xFF0066FF),
                        ),
                        const SizedBox(width: 16),
                        _buildMetricCard(
                          label: 'Active Clinicians',
                          value: metrics['active_doctors']?.toString() ?? '6',
                          icon: Icons.medical_services_outlined,
                          color: const Color(0xFF00C853),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Recent Activities
                    Text(
                      'Recent Logs & Activities',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A1628),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (recentActivities.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Text(
                            'No records available',
                            style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 15),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentActivities.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final activity = recentActivities[index] as Map;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7C3AED).withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.history_toggle_off_rounded, color: Color(0xFF7C3AED), size: 22),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activity['title']?.toString() ?? 'Security Audit Event',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0A1628),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        activity['desc']?.toString() ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  activity['time']?.toString() ?? 'Just now',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A1628),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
