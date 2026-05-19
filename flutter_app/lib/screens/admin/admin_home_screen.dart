import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_buttons.dart';
import '../../core/auth_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    var data = await AuthService.getDashboard('admin');
    setState(() {
      _dashboardData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.adminPrimary,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                'AD',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Workspace 🛡️',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'System Control Center',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.adminPrimary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Epidemiology'),
          BottomNavigationBarItem(icon: Icon(Icons.history_edu_outlined), activeIcon: Icon(Icons.history_edu), label: 'Audit Logs'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), activeIcon: Icon(Icons.psychology), label: 'Agent Health'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildEpidemiologyTab();
      case 2:
        return _buildAuditTab();
      case 3:
        return _buildAgentTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    int totalPatients = _dashboardData?['metrics']?['total_patients'] ?? 50;
    int activeDoctors = _dashboardData?['metrics']?['active_doctors'] ?? 8;
    var activities = _dashboardData?['recent_activities'] as List? ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Total Patients',
                value: '$totalPatients',
                icon: Icons.local_hospital_rounded,
                color: AppColors.patientPrimary,
                subtitle: '+12 this week',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                title: 'Active Doctors',
                value: '$activeDoctors',
                icon: Icons.medical_services_rounded,
                color: AppColors.doctorPrimary,
                subtitle: 'Fully staffed',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Active Nodes',
                value: '7/7',
                icon: Icons.dns_rounded,
                color: AppColors.adminPrimary,
                subtitle: 'Operational',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                title: 'DB Commits',
                value: '142',
                icon: Icons.storage_rounded,
                color: AppColors.labPrimary,
                subtitle: 'SQLite secure',
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Operational Activity Stream',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        ...activities.map((act) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildActivityRow(act['title'], act['desc'], act['time']),
            )).toList(),
      ],
    );
  }

  Widget _buildEpidemiologyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Epidemiology Outbreak Intelligence',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Spatial-temporal disease clustering compiled by Epidemiology Agent (Agent 05).',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppColors.cardShadow,
          ),
          child: Stack(
            children: [
              // Heatmap representation background
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.emergencyRed, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '01 Active Outbreak Cluster (Dengue)',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Spatial radius: 2.4 km • Confidence: 94%',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Cluster Telemetry Logs', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildClusterTile('Cluster D-01: Lahore North-East', 'Dengue Outbreak Risk high. 12 localized symptoms matching.', AppColors.emergencyRed),
        const SizedBox(height: 12),
        _buildClusterTile('Cluster W-02: Islamabad Sector G', 'Mild Gastroenteritis clusters detected. Normal status.', AppColors.success),
      ],
    );
  }

  Widget _buildAuditTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Security Audit Ledger',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Unified append-only immutable transactions.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        _buildAuditTile('POST /api/auth/login', 'Authorized token granted to doctor@panor.com. Session expires in 7 days.', '10:48 AM', AppColors.success),
        const SizedBox(height: 12),
        _buildAuditTile('POST /api/consultation/start', 'Patient Rahul Sharma registered voice symptom input. Triggered Agent 01.', '10:46 AM', AppColors.brandPurple),
        const SizedBox(height: 12),
        _buildAuditTile('DB WRITE /users/users', 'Committed row data patient Rahul Sharma. SQLite secure.', '10:40 AM', AppColors.labPrimary),
      ],
    );
  }

  Widget _buildAgentTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Antigravity Node Performance',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Live orchestration latency metrics for PANOR specialized agents.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        _buildAgentStatRow('Intake Intelligence Agent (Agent 01)', '1.4s average latency', '98.6% accuracy', AppColors.success),
        const SizedBox(height: 12),
        _buildAgentStatRow('Clinical Reasoning Agent (Agent 02)', '2.1s average latency', '94.2% diagnostic accuracy', AppColors.success),
        const SizedBox(height: 12),
        _buildAgentStatRow('Drug Safety Guardian (Agent 03)', '0.8s average latency', '100.0% accuracy', AppColors.success),
        const SizedBox(height: 12),
        _buildAgentStatRow('Verification Agent (Agent 07)', '0.5s average latency', '99.1% draft accuracy', AppColors.success),
      ],
    );
  }

  Widget _buildActivityRow(String title, String desc, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.adminPrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildClusterTile(String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(desc, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAuditTile(String action, String desc, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(
              action,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          Text(time, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildAgentStatRow(String name, String latency, String accuracy, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.memory_rounded, color: AppColors.adminPrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('$latency • $accuracy', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.check_circle_outline_rounded, color: color),
        ],
      ),
    );
  }
}

