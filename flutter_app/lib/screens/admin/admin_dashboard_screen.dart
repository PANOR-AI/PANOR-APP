import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'user_management_screen.dart';
import 'epidemiology_screen.dart';
import 'audit_logs_screen.dart';
import 'analytics_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color cardBg = Color(0xFF131929);
  static const Color borderColor = Color(0xFF1E2A3A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color adminPurple = Color(0xFF8B5CF6);
  static const Color emergencyRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color primaryBlue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAdminDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);

    final user = authProv.userProfile;
    final adminName =
        user != null ? user['full_name'] as String? ?? 'Administrator' : 'Administrator';

    final dash = adminProv.dashboardData;
    final totalUsers = dash != null ? dash['total_users'] as int? ?? 0 : 0;
    final totalPatients = dash != null ? dash['patients'] as int? ?? 0 : 0;
    final totalDoctors = dash != null ? dash['doctors'] as int? ?? 0 : 0;
    final totalLabs = dash != null ? dash['laboratories'] as int? ?? 0 : 0;
    final appointmentsToday =
        dash != null ? dash['appointments_today'] as int? ?? 0 : 0;
    final activeSessions =
        dash != null ? dash['active_sessions'] as int? ?? 0 : 0;
    final systemActivity =
        dash != null ? dash['system_activity'] as List? ?? [] : [];
    final auditSummary =
        dash != null ? dash['audit_summary'] as List? ?? [] : [];

    return Scaffold(
      backgroundColor: darkBg,
      body: adminProv.isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(adminPurple),
                strokeWidth: 2.5,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async =>
                  adminProv.fetchAdminDashboard(forceRefresh: true),
              color: adminPurple,
              backgroundColor: cardBg,
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    expandedHeight: 210,
                    backgroundColor: darkBg,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF16082B), Color(0xFF0A0E1A)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.admin_panel_settings_rounded,
                                          color: Colors.white,
                                          size: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PANOR',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: adminPurple.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'ADMIN',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: adminPurple,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.settings_rounded,
                                        color: Colors.white, size: 22),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'System Control Room',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Welcome, $adminName — All systems operational',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: adminPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // System status pill
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: successGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$activeSessions Active Sessions',
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: successGreen),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.calendar_today_rounded,
                                    size: 12, color: Color(0xFF8892A4)),
                                const SizedBox(width: 4),
                                Text(
                                  '$appointmentsToday Today\'s Appointments',
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Network stats grid
                        _sectionHeader('National Health Network'),
                        const SizedBox(height: 14),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _buildMetricCard('Total Users', '$totalUsers',
                                Icons.people_rounded, adminPurple, '+12% MTD'),
                            _buildMetricCard('Patients', '$totalPatients',
                                Icons.person_rounded, primaryBlue, 'Active P_IDs'),
                            _buildMetricCard('Doctors', '$totalDoctors',
                                Icons.medical_services_rounded, successGreen, 'Verified'),
                            _buildMetricCard('Labs', '$totalLabs',
                                Icons.biotech_rounded, warningAmber, 'Accredited'),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Admin Quick Actions
                        _sectionHeader('System Management'),
                        const SizedBox(height: 14),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 2.2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _buildAdminAction(
                              context,
                              'User Management',
                              Icons.manage_accounts_rounded,
                              adminPurple,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const UserManagementScreen())),
                            ),
                            _buildAdminAction(
                              context,
                              'Epidemiology Map',
                              Icons.map_rounded,
                              emergencyRed,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const EpidemiologyScreen())),
                            ),
                            _buildAdminAction(
                              context,
                              'Analytics',
                              Icons.analytics_rounded,
                              primaryBlue,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AnalyticsScreen())),
                            ),
                            _buildAdminAction(
                              context,
                              'Audit Logs',
                              Icons.history_rounded,
                              successGreen,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AuditLogsScreen())),
                            ),
                            _buildAdminAction(
                              context,
                              'Pricing Manager',
                              Icons.price_change_rounded,
                              warningAmber,
                              () => _showPricingDialog(context),
                            ),
                            _buildAdminAction(
                              context,
                              'Welfare Scores',
                              Icons.shield_rounded,
                              const Color(0xFF06B6D4),
                              () => _showWelfareDialog(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // System Activity Feed
                        _sectionHeader('Live System Activity'),
                        const SizedBox(height: 12),
                        systemActivity.isEmpty
                            ? _buildEmptyCard(
                                'No recent system activity', Icons.timeline_rounded)
                            : Column(
                                children: systemActivity
                                    .take(5)
                                    .map((a) => _buildActivityItem(a as Map))
                                    .toList(),
                              ),
                        const SizedBox(height: 28),

                        // Audit Summary
                        _sectionHeader('Security Audit Trail'),
                        const SizedBox(height: 12),
                        auditSummary.isEmpty
                            ? _buildEmptyCard(
                                'No recent audit events', Icons.security_rounded)
                            : Column(
                                children: auditSummary
                                    .take(4)
                                    .map((a) => _buildAuditItem(a as Map))
                                    .toList(),
                              ),

                        // Welfare Score Engine Banner
                        const SizedBox(height: 28),
                        _buildWelfareBanner(),

                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon,
      Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAction(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: Color(0xFF4A5568)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: successGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action']?.toString() ?? 'System Event',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  activity['timestamp']?.toString() ?? 'Just now',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditItem(Map audit) {
    final severity = audit['severity']?.toString() ?? 'INFO';
    Color severityColor;
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        severityColor = emergencyRed;
        break;
      case 'WARNING':
        severityColor = warningAmber;
        break;
      default:
        severityColor = successGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              severity,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: severityColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audit['event']?.toString() ?? 'Audit Event',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  audit['user']?.toString() ?? 'System',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            audit['time']?.toString() ?? '',
            style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildWelfareBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Welfare Engine',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-computed social health scores for subsidized care access',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => _showWelfareDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              'Configure',
              style: GoogleFonts.inter(
                color: adminPurple,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2A3544), size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.inter(color: textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showPricingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Pricing Manager',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: textPrimary)),
        content: Text(
          'Configure lab test pricing, doctor consultation fees, and welfare discounts in the full Pricing Manager module.',
          style: GoogleFonts.inter(fontSize: 13, color: textSecondary, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: adminPurple),
            child: Text('OK',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showWelfareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Welfare Score Engine',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWelfareTier('Platinum (80-100)', '100% lab discount', adminPurple),
            _buildWelfareTier('Gold (60-79)', '50% lab discount', warningAmber),
            _buildWelfareTier('Silver (40-59)', '25% discount', primaryBlue),
            _buildWelfareTier('Basic (0-39)', 'Standard pricing', textSecondary),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: adminPurple),
            child: Text('Close',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildWelfareTier(String tier, String benefit, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tier,
              style: GoogleFonts.inter(
                  fontSize: 13, color: textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            benefit,
            style: GoogleFonts.inter(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}
