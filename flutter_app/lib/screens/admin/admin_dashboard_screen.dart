import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/role_selection_screen.dart';
import 'audit_logs_screen.dart';
import 'user_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Proactively fetch all admin stats at initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<AdminProvider>(context, listen: false);
      prov.fetchAdminDashboard(forceRefresh: true);
      prov.fetchAnalytics();
      prov.fetchSystemMetrics();
      prov.fetchEpidemiology();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    final prov = Provider.of<AdminProvider>(context, listen: false);
    await Future.wait([
      prov.fetchAdminDashboard(forceRefresh: true),
      prov.fetchAnalytics(),
      prov.fetchSystemMetrics(),
      prov.fetchEpidemiology(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);

    final user = authProv.userProfile;
    final fullName = user != null
        ? user['full_name'] as String? ?? 'Administrator'
        : 'Administrator';
    final dash = adminProv.dashboardData;

    // Overview tab metrics
    final metrics = dash != null ? dash['data'] as Map? ?? {} : {};
    final totalUsers = metrics['total_users'] ?? 0;
    final patientsCount = metrics['patients'] ?? 0;
    final doctorsCount = metrics['doctors'] ?? 0;
    final activeSessions = metrics['active_sessions'] ?? 0;
    final auditSummary = metrics['audit_summary'] as List? ?? [];

    const royalPurple = Color(0xFF7C3AED);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: royalPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.dashboard_customize_outlined,
                  color: royalPurple, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'PANOR CommandCenter',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                color: royalPurple,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF64748B)),
            onPressed: () async {
              await authProv.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RoleSelectionScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: royalPurple,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: royalPurple,
          indicatorWeight: 3,
          labelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(
                text: 'Overview',
                icon: Icon(Icons.analytics_outlined, size: 20)),
            Tab(
                text: 'Analytics',
                icon: Icon(Icons.bar_chart_rounded, size: 20)),
            Tab(
                text: 'System Health',
                icon: Icon(Icons.dns_outlined, size: 20)),
            Tab(
                text: 'Epidemiology',
                icon: Icon(Icons.bug_report_outlined, size: 20)),
          ],
        ),
      ),
      body: adminProv.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(royalPurple)))
          : RefreshIndicator(
              onRefresh: _refreshAll,
              color: royalPurple,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: Overview
                  _buildOverviewTab(context, fullName, totalUsers, patientsCount,
                      doctorsCount, activeSessions, auditSummary, royalPurple),

                  // TAB 2: Analytics
                  _buildAnalyticsTab(context, adminProv.analytics, royalPurple),

                  // TAB 3: System Metrics
                  _buildSystemHealthTab(
                      context, adminProv.systemMetrics, royalPurple),

                  // TAB 4: Epidemiology
                  _buildEpidemiologyTab(
                      context, adminProv.epidemiology, royalPurple),
                ],
              ),
            ),
    );
  }

  // ── TAB 1: Overview ────────────────────────────────────────────────────────
  Widget _buildOverviewTab(
    BuildContext context,
    String fullName,
    dynamic totalUsers,
    dynamic patients,
    dynamic doctors,
    dynamic sessions,
    List<dynamic> logs,
    Color themeColor,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeColor, themeColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $fullName',
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unified national healthcare operational command center. Operational status active.',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'Core Infrastructure Metrics',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),

          // Metrics list
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildMetricCard('Total Users', '$totalUsers',
                  Icons.group_outlined, themeColor),
              _buildMetricCard('Registered Patients', '$patients',
                  Icons.personal_injury_outlined, const Color(0xFF0066FF)),
              _buildMetricCard('Active Doctors', '$doctors',
                  Icons.medical_services_outlined, const Color(0xFF00C853)),
              _buildMetricCard('Active Sessions', '$sessions',
                  Icons.online_prediction_outlined, Colors.amber),
            ],
          ),
          const SizedBox(height: 32),

          // Shortcut Actions
          Text(
            'Quick Shortcuts',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionShortcut(context, 'User Management',
                  Icons.manage_accounts_outlined, themeColor, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UserManagementScreen()));
              }),
              const SizedBox(width: 16),
              _buildActionShortcut(context, 'Audit Logs',
                  Icons.admin_panel_settings_outlined, Colors.blueGrey, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AuditLogsScreen()));
              }),
            ],
          ),
          const SizedBox(height: 32),

          // Audit Overview Logs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Audit Overview',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AuditLogsScreen()));
                },
                child: Text('See All',
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (logs.isEmpty)
            _buildEmptyState('No audit event logs recorded')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length > 5 ? 5 : logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = logs[index] as Map;
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_person_outlined,
                            color: Colors.blueGrey, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log['action']?.toString() ?? 'Action',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'By: ${log['user_name']} • ${log['details']}',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── TAB 2: Analytics ───────────────────────────────────────────────────────
  Widget _buildAnalyticsTab(
      BuildContext context, Map<String, dynamic>? analytics, Color themeColor) {
    if (analytics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userGrowth = analytics['user_growth'] as List? ?? [];
    final apptTrends = analytics['appointment_trends'] as List? ?? [];
    final topDiagnoses = analytics['top_diagnoses'] as List? ?? [];
    final stats = analytics['consultation_statistics'] as Map? ?? {};

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Growth Graph section
          Text(
            'User Growth Trends',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          _buildBarChart(userGrowth, themeColor),
          const SizedBox(height: 32),

          // Appointment Trends
          Text(
            'Appointment Volume Trends',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          _buildBarChart(apptTrends, const Color(0xFF0066FF)),
          const SizedBox(height: 32),

          // Top Diagnoses distribution list
          Text(
            'Top Diagnosed Conditions Distribution',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: topDiagnoses.map<Widget>((item) {
                final condition = item['condition']?.toString() ?? 'N/A';
                final count = item['count'] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(condition,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count cases',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: themeColor),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),

          // Consultation Statistics Summary
          Text(
            'Consultation Statistics',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatSummaryItem('Completed', '${stats['completed'] ?? 0}',
                    const Color(0xFF00C853)),
                _buildStatSummaryItem('Scheduled', '${stats['scheduled'] ?? 0}',
                    const Color(0xFF0066FF)),
                _buildStatSummaryItem('Cancelled', '${stats['cancelled'] ?? 0}',
                    Colors.redAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 3: System Health ───────────────────────────────────────────────────
  Widget _buildSystemHealthTab(
      BuildContext context, Map<String, dynamic>? metrics, Color themeColor) {
    if (metrics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final uptimeSecs = metrics['uptime_seconds'] as int? ?? 0;
    final uptimeHrs = uptimeSecs ~/ 3600;
    final uptimeMins = (uptimeSecs % 3600) ~/ 60;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF00C853).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: Color(0xFF00C853), size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Systems Operational',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A)),
                      ),
                      Text(
                        'Database status: ${metrics['database_status']} • API Uptime: $uptimeHrs hrs $uptimeMins mins',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'Compute & DB Health Indicators',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildVitalHealthMetric(
                  'CPU Usage',
                  '${metrics['cpu_usage_pct']}%',
                  Icons.developer_board_outlined,
                  Colors.amber),
              _buildVitalHealthMetric(
                  'Memory Allocated',
                  '${metrics['memory_usage_mb']} MB',
                  Icons.memory_outlined,
                  const Color(0xFF0066FF)),
              _buildVitalHealthMetric(
                  'DB Active Connections',
                  '${metrics['active_connections']}',
                  Icons.hub_outlined,
                  themeColor),
              _buildVitalHealthMetric(
                  'API Latency',
                  '${metrics['api_response_time_ms']} ms',
                  Icons.speed_outlined,
                  const Color(0xFF00C853)),
            ],
          ),
          const SizedBox(height: 32),

          Text(
            'Registered Table Size Summaries',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildTableSizeItem('Users Database Table',
                    '${metrics['total_users']} rows', themeColor),
                _buildTableSizeItem(
                    'Appointments Table',
                    '${metrics['total_appointments']} rows',
                    const Color(0xFF0066FF)),
                _buildTableSizeItem('Audit Logs Table',
                    '${metrics['total_audit_logs']} rows', Colors.blueGrey),
                _buildTableSizeItem('Analytics Events Table',
                    '${metrics['total_analytics_events']} rows', Colors.teal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 4: Epidemiology ────────────────────────────────────────────────────
  Widget _buildEpidemiologyTab(
      BuildContext context, Map<String, dynamic>? data, Color themeColor) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final alertsCount = data['active_alerts'] ?? 0;
    final totalCases = data['total_monitored_cases'] ?? 0;
    final alerts = data['alerts'] as List? ?? [];
    final conditions = data['tracked_conditions'] as List? ?? [];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Epidemiology Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: alertsCount > 0
                  ? Colors.redAccent.withValues(alpha: 0.08)
                  : const Color(0xFF00C853).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: alertsCount > 0
                      ? Colors.redAccent.withValues(alpha: 0.3)
                      : const Color(0xFF00C853).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  alertsCount > 0
                      ? Icons.warning_amber_rounded
                      : Icons.shield_outlined,
                  color: alertsCount > 0
                      ? Colors.redAccent
                      : const Color(0xFF00C853),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alertsCount > 0
                            ? 'Active Epidemiology Alerts!'
                            : 'Epidemiology Level Normal',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A)),
                      ),
                      Text(
                        'Active alerts: $alertsCount • Tracked cases nationwide: $totalCases',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Tracked diseases distribution percentages
          Text(
            'Tracked Disease Case Percentages',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: conditions.map<Widget>((item) {
                final condition = item['condition']?.toString() ?? 'N/A';
                final cases = item['cases'] ?? 0;
                final percentage = item['percentage'] ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(condition,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A))),
                          Text('$cases cases ($percentage%)',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100.0,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation(themeColor),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),

          // Epidemiology Alerts Panel
          Text(
            'Epidemiology Alerts Panel',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          if (alerts.isEmpty)
            _buildEmptyState('No active alerts monitored')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alert = alerts[index] as Map;
                final risk =
                    alert['risk_level']?.toString().toUpperCase() ?? 'GREEN';
                final isRed = risk == 'RED';
                final isYellow = risk == 'YELLOW';
                final riskColor = isRed
                    ? Colors.redAccent
                    : (isYellow
                        ? Colors.orangeAccent
                        : const Color(0xFF00C853));

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
                          color: riskColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.coronavirus_outlined,
                            color: riskColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  alert['condition']?.toString() ?? 'Condition',
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: riskColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    risk,
                                    style: TextStyle(
                                        color: riskColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alert['details']?.toString() ?? '',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Shared Helper Components ───────────────────────────────────────────────
  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionShortcut(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A)),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVitalHealthMetric(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSizeItem(String title, String rowCount, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.table_chart_outlined, color: iconColor, size: 18),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A)),
              ),
            ],
          ),
          Text(
            rowCount,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatSummaryItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.inter(
              fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<dynamic> data, Color barColor) {
    if (data.isEmpty) {
      return _buildEmptyState('No tracked data recorded');
    }

    int maxVal = 1;
    for (var item in data) {
      final val = item['count'] as int? ?? 0;
      if (val > maxVal) maxVal = val;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map<Widget>((item) {
          final month = item['month']?.toString() ?? '';
          final count = item['count'] as int? ?? 0;
          final pct = count / maxVal;
          final barHeight = pct * 80 + 10;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 6),
              Container(
                width: 24,
                height: barHeight,
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                month,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Text(
          msg,
          style:
              GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
        ),
      ),
    );
  }
}
