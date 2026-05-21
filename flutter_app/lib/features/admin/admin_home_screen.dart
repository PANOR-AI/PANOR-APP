import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.adminPrimary.withValues(alpha: 0.3), width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.adminPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_rounded, color: AppColors.adminAccent),
              ),
              const SizedBox(width: 12),
              Text(
                'System Settings',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PANOR Administrative Infrastructure Space',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSettingToggle('Verbose System Auditing', true, 'Log detailed cryptographic trace of every record append'),
                _buildSettingToggle('API Rate Limiting', true, 'Limit consumer requests to prevent potential DDoS on endpoints'),
                _buildSettingToggle('Auto Database Backup', true, 'Hourly replication of SQLite local database to cloud vault'),
                _buildSettingToggle('Emergency Broadcasts', true, 'Push RED alerts instantly to provincial emergency taskforce'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.surface,
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text('System settings updated successfully', style: GoogleFonts.inter(color: Colors.white)),
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.adminPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Save Changes',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.emergencyRed, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emergencyRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.emergencyRed),
              ),
              const SizedBox(width: 12),
              Text(
                'Confirm Secure Logout',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to end this clinical session? To access this medical timeline or other roles again, you must perform a secure authentication.',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/role-selection');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Secure Logout',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingToggle(String title, bool val, String description) {
    bool localVal = val;
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(description, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              Switch(
                value: localVal,
                activeThumbColor: AppColors.adminAccent,
                onChanged: (newVal) {
                  setDialogState(() {
                    localVal = newVal;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: AppColors.adminPrimary.withValues(alpha: 0.3), height: 1.5),
        ),
        title: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.adminGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.adminAccent.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.adminPrimary.withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(child: Text('NK', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Noorullah Khan', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                  Row(
                    children: [
                      const Icon(Icons.admin_panel_settings_rounded, color: AppColors.adminAccent, size: 12),
                      const SizedBox(width: 4),
                      Text('System Administrator | Punjab Region', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildBody(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppColors.adminPrimary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.public_outlined), activeIcon: Icon(Icons.public), label: 'Epidemiology'),
            BottomNavigationBarItem(icon: Icon(Icons.monetization_on_outlined), activeIcon: Icon(Icons.monetization_on), label: 'Pricing'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: 'Audit'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildDashboardTab();
      case 1: return _buildEpidemiologyTab();
      case 2: return _buildPricingTab();
      case 3: return _buildUsersTab();
      case 4: return _buildAuditTab();
      default: return _buildDashboardTab();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: DASHBOARD — System Analytics
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDashboardTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('System Overview', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Punjab Region — Real-time healthcare intelligence', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        // Core metrics
        Row(
          children: [
            _buildMetricCard('Total Patients', '14,892', Icons.people_rounded, AppColors.patientPrimary, '+127 today'),
            const SizedBox(width: 12),
            _buildMetricCard('Active Doctors', '342', Icons.medical_services_rounded, AppColors.doctorPrimary, '+3 today'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetricCard('Lab Facilities', '48', Icons.science_rounded, AppColors.labPrimary, 'All online'),
            const SizedBox(width: 12),
            _buildMetricCard('Consultations', '1,247', Icons.calendar_month_rounded, AppColors.brandPurple, 'Today'),
          ],
        ),
        const SizedBox(height: 24),

        // Emergency status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.emergencyRed.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emergency_rounded, color: AppColors.emergencyRed, size: 20),
                  const SizedBox(width: 8),
                  Text('Active Emergencies', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.emergencyRed)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.emergencyRed, borderRadius: BorderRadius.circular(6)),
                    child: Text('7 Active', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildEmergencyRow('Ahmed Raza', 'Cardiac — Acute chest pain', 'Dr. Fatima Hassan', 'Lahore'),
              _buildEmergencyRow('Khalid Mehmood', 'Respiratory — Severe dyspnea', 'Dr. Usman Ali', 'Lahore'),
              _buildEmergencyRow('Nasreen Bibi', 'Diabetes — Hypoglycemic episode', 'Dr. Ayesha Siddiqui', 'Islamabad'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Agent Performance
        Text('AI Agent Performance', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _buildAgentPerfRow('Agent 01: Intake', 'Online', '0.8s avg', '99.7%', AppColors.success),
        _buildAgentPerfRow('Agent 02: Reasoning', 'Online', '2.3s avg', '94.2%', AppColors.success),
        _buildAgentPerfRow('Agent 03: Drug Safety', 'Online', '0.4s avg', '99.9%', AppColors.success),
        _buildAgentPerfRow('Agent 04: Lab Coord', 'Online', '0.6s avg', '98.1%', AppColors.success),
        _buildAgentPerfRow('Agent 05: Epidemiology', 'Online', '1.1s avg', '97.5%', AppColors.success),
        _buildAgentPerfRow('Agent 06: Follow-Up', 'Online', '0.3s avg', '96.8%', AppColors.success),
        _buildAgentPerfRow('Agent 07: Verification', 'Online', '0.9s avg', '99.4%', AppColors.success),
        const SizedBox(height: 24),

        // Revenue summary
        Text('Revenue Summary (May 2026)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRevenueCard('Consultations', 'Rs. 3,117,500', '+12%'),
            const SizedBox(width: 12),
            _buildRevenueCard('Lab Tests', 'Rs. 1,892,400', '+8%'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRevenueCard('Welfare Discounts', 'Rs. 487,200', 'Given'),
            const SizedBox(width: 12),
            _buildRevenueCard('Net Revenue', 'Rs. 4,522,700', '+10%'),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyRow(String patient, String condition, String doctor, String city) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.emergencyRed, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('$condition | $doctor | $city', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentPerfRow(String name, String status, String latency, String accuracy, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
          Text(latency, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Text(accuracy, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(String label, String value, String change) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(change, style: GoogleFonts.inter(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: EPIDEMIOLOGY — Disease Intelligence
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEpidemiologyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Epidemiology Intelligence', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Agent 05 — Real-time disease surveillance across Pakistan', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        // Active clusters
        _buildClusterCard('Lahore South', 'Dengue Cluster', 47, 'HIGH', 'NS1 positivity rate 34%. Vector density increasing. 12 new cases in 48 hours.', AppColors.emergencyRed),
        _buildClusterCard('Islamabad F-8', 'Respiratory Infections', 23, 'MODERATE', 'Influenza-like illness cluster. 23 cases in schools. Air quality index: 180 (Unhealthy).', AppColors.warning),
        _buildClusterCard('Karachi Clifton', 'Gastroenteritis', 31, 'MODERATE', 'Waterborne outbreak suspected. 31 cases linked to common water supply. WASA notified.', AppColors.warning),
        _buildClusterCard('Rawalpindi Cantt', 'Cardiac Events', 8, 'LOW', '8 ACS presentations in 72 hours. Age group: 45-65M. No environmental correlate found.', AppColors.success),

        const SizedBox(height: 24),
        Text('Regional Health Metrics', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _buildRegionRow('Punjab', '8,420 patients', '189 doctors', '24 labs', AppColors.patientPrimary),
        _buildRegionRow('Sindh', '3,892 patients', '87 doctors', '12 labs', AppColors.doctorPrimary),
        _buildRegionRow('KPK', '1,540 patients', '42 doctors', '8 labs', AppColors.labPrimary),
        _buildRegionRow('Balochistan', '680 patients', '18 doctors', '4 labs', AppColors.warning),
        _buildRegionRow('ICT', '360 patients', '6 doctors', '2 labs', AppColors.brandPurple),
      ],
    );
  }

  Widget _buildClusterCard(String location, String disease, int cases, String severity, String details, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: BorderSide(color: AppColors.border, width: 1.5),
          right: BorderSide(color: AppColors.border, width: 1.5),
          bottom: BorderSide(color: AppColors.border, width: 1.5),
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(disease, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(location, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$cases cases', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                    child: Text(severity, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(details, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildRegionRow(String region, String patients, String doctors, String labs, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(child: Text(region, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))),
          Text(patients, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(width: 10),
          Text(doctors, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(width: 10),
          Text(labs, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: PRICING — Lab Tests + Consultation Fees + Welfare
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPricingTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Pricing Management', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Set lab test and consultation pricing. Manage welfare discounts.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        // Lab test pricing
        Text('Laboratory Test Pricing', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _buildPricingRow('CBC (Complete Blood Count)', 'Rs. 800', true),
        _buildPricingRow('Lipid Panel', 'Rs. 1,200', true),
        _buildPricingRow('HbA1c', 'Rs. 1,500', true),
        _buildPricingRow('Troponin-I', 'Rs. 2,500', true),
        _buildPricingRow('ECG (12-Lead)', 'Rs. 1,000', true),
        _buildPricingRow('D-Dimer', 'Rs. 2,000', true),
        _buildPricingRow('TSH (Thyroid)', 'Rs. 1,800', true),
        _buildPricingRow('CRP', 'Rs. 900', true),
        _buildPricingRow('Urinalysis', 'Rs. 500', true),
        _buildPricingRow('BMP', 'Rs. 1,100', true),
        const SizedBox(height: 24),

        // Consultation pricing
        Text('Consultation Fee Schedule', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _buildPricingRow('General Physician', 'Rs. 1,500', false),
        _buildPricingRow('Cardiologist', 'Rs. 2,500', false),
        _buildPricingRow('Endocrinologist', 'Rs. 2,000', false),
        _buildPricingRow('Neurologist', 'Rs. 2,500', false),
        _buildPricingRow('Pulmonologist', 'Rs. 2,000', false),
        _buildPricingRow('Oncologist', 'Rs. 3,500', false),
        const SizedBox(height: 24),

        // Welfare discount tiers
        Text('Welfare Social Score Discounts', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _buildWelfareTierCard('Gold Tier', 'Score 0 - 40', '50% discount', 'Extremely vulnerable — below poverty line, chronic disease, elderly, disabled', const Color(0xFFD97706)),
        _buildWelfareTierCard('Silver Tier', 'Score 41 - 70', '30% discount', 'Moderate vulnerability — low income, chronic conditions, rural area', const Color(0xFF6B7280)),
        _buildWelfareTierCard('Bronze Tier', 'Score 71 - 85', '15% discount', 'Mild vulnerability — single income, 2+ dependents, known chronic condition', const Color(0xFFB45309)),
        _buildWelfareTierCard('Standard', 'Score 86+', 'No discount', 'Standard rate — stable income, no vulnerability markers', AppColors.textSecondary),
      ],
    );
  }

  Widget _buildPricingRow(String item, String price, bool isLab) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(isLab ? Icons.science_rounded : Icons.medical_services_rounded, size: 16, color: isLab ? AppColors.labPrimary : AppColors.doctorPrimary),
          const SizedBox(width: 12),
          Expanded(child: Text(item, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white))),
          Text(price, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showEditPriceDialog(context, item, price),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.adminPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.edit_rounded, size: 14, color: AppColors.adminPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelfareTierCard(String tier, String range, String discount, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: BorderSide(color: AppColors.border, width: 1.5),
          right: BorderSide(color: AppColors.border, width: 1.5),
          bottom: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Icon(Icons.stars_rounded, color: color, size: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(tier, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(discount, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                    ),
                  ],
                ),
                Text(range, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                Text(desc, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 4: USERS — User Management
  // ═══════════════════════════════════════════════════════════════
  Widget _buildUsersTab() {
    final users = [
      {'name': 'Ahmed Raza', 'role': 'Patient', 'pid': 'PAK-HEALTH-2026-0001', 'status': 'Active', 'city': 'Lahore', 'welfare': '72 (Silver)'},
      {'name': 'Dr. Fatima Hassan', 'role': 'Doctor', 'pid': 'PMDC #42891', 'status': 'Active', 'city': 'Lahore', 'welfare': '--'},
      {'name': 'Sana Malik', 'role': 'Lab Tech', 'pid': 'PANOR-LAB-0042', 'status': 'Active', 'city': 'Lahore', 'welfare': '--'},
      {'name': 'Bilal Hussain', 'role': 'Patient', 'pid': 'PAK-HEALTH-2026-0034', 'status': 'Active', 'city': 'Islamabad', 'welfare': '58 (Silver)'},
      {'name': 'Dr. Usman Ali', 'role': 'Doctor', 'pid': 'PMDC #51203', 'status': 'Pending', 'city': 'Lahore', 'welfare': '--'},
      {'name': 'Zara Tariq', 'role': 'Patient', 'pid': 'PAK-HEALTH-2026-0072', 'status': 'Active', 'city': 'Karachi', 'welfare': '35 (Gold)'},
      {'name': 'Imran Shah', 'role': 'Patient', 'pid': 'PAK-HEALTH-2026-0088', 'status': 'Active', 'city': 'Rawalpindi', 'welfare': '82 (Bronze)'},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('User Management', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('View and manage all registered users.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 16),

        // Role filters
        Row(
          children: [
            _buildFilterChip('All', true),
            _buildFilterChip('Patients', false),
            _buildFilterChip('Doctors', false),
            _buildFilterChip('Lab Staff', false),
          ],
        ),
        const SizedBox(height: 16),

        // Pending approvals
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.pending_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('1 doctor pending verification approval', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.warning))),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(8)),
                  child: Text('Review', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ...users.map((u) {
          Color roleColor;
          IconData roleIcon;
          switch (u['role']) {
            case 'Doctor': roleColor = AppColors.doctorPrimary; roleIcon = Icons.medical_services_rounded; break;
            case 'Lab Tech': roleColor = AppColors.labPrimary; roleIcon = Icons.science_rounded; break;
            default: roleColor = AppColors.patientPrimary; roleIcon = Icons.person_rounded;
          }
          final isPending = u['status'] == 'Pending';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isPending ? AppColors.warning.withValues(alpha: 0.3) : AppColors.border, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(roleIcon, color: roleColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u['name']!, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${u['pid']} | ${u['city']}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPending ? AppColors.warning.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(u['status']!, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: isPending ? AppColors.warning : AppColors.success)),
                    ),
                    if (u['welfare'] != '--') Text(u['welfare']!, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? AppColors.adminPrimary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppColors.adminPrimary : AppColors.border, width: 1.5),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 5: AUDIT — Immutable Logs
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAuditTab() {
    final logs = [
      {'action': 'PATIENT_ONBOARD', 'user': 'Dr. Fatima Hassan', 'target': 'Ahmed Raza', 'time': '10:22 AM', 'detail': 'Consent granted. Full record access activated.'},
      {'action': 'DRUG_BLOCKED', 'user': 'Agent 03', 'target': 'Ahmed Raza', 'time': '10:25 AM', 'detail': 'Ibuprofen BLOCKED — NSAIDs + Metformin = renal risk.'},
      {'action': 'LAB_ORDERED', 'user': 'Dr. Fatima Hassan', 'target': 'Ahmed Raza', 'time': '10:28 AM', 'detail': 'STAT ECG + Troponin-I ordered. Agent 04 routed to Lab.'},
      {'action': 'EMERGENCY_FLAG', 'user': 'Agent 02', 'target': 'Ahmed Raza', 'time': '10:30 AM', 'detail': 'RED cardiac alert raised. Confidence: 94%.'},
      {'action': 'SOAP_GENERATED', 'user': 'Agent 07', 'target': 'Ahmed Raza', 'time': '10:32 AM', 'detail': 'Auto-SOAP notes generated in 2.3s. Pending doctor review.'},
      {'action': 'LOGIN', 'user': 'Sana Malik', 'target': 'Lab Portal', 'time': '10:35 AM', 'detail': 'Lab technician authenticated. Session started.'},
      {'action': 'RESULT_SUBMITTED', 'user': 'Sana Malik', 'target': 'Lipid Panel', 'time': '10:40 AM', 'detail': 'Results verified and locked. Synced to patient timeline.'},
      {'action': 'PRICING_UPDATED', 'user': 'Noorullah Khan', 'target': 'Troponin-I', 'time': '09:15 AM', 'detail': 'Price updated: Rs. 2,300 -> Rs. 2,500.'},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(child: Text('Audit Trail', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, size: 12, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text('Immutable', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                ],
              ),
            ),
          ],
        ),
        Text('Every action is logged, timestamped, and traceable. Cannot be deleted.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        ...logs.map((l) {
          Color actionColor;
          IconData actionIcon;
          switch (l['action']) {
            case 'DRUG_BLOCKED': actionColor = AppColors.emergencyRed; actionIcon = Icons.block_rounded; break;
            case 'EMERGENCY_FLAG': actionColor = AppColors.emergencyRed; actionIcon = Icons.emergency_rounded; break;
            case 'LAB_ORDERED': actionColor = AppColors.labPrimary; actionIcon = Icons.science_rounded; break;
            case 'RESULT_SUBMITTED': actionColor = AppColors.success; actionIcon = Icons.check_circle_rounded; break;
            case 'PRICING_UPDATED': actionColor = AppColors.warning; actionIcon = Icons.monetization_on_rounded; break;
            default: actionColor = AppColors.brandPurple; actionIcon = Icons.receipt_long_rounded;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: actionColor.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: actionColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(actionIcon, color: actionColor, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(color: actionColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                            child: Text(l['action']!, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: actionColor, letterSpacing: 0.3)),
                          ),
                          const SizedBox(width: 6),
                          Text(l['time']!, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${l['user']} -> ${l['target']}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text(l['detail']!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════════
  void _showEditPriceDialog(BuildContext context, String item, String currentPrice) {
    final controller = TextEditingController(text: currentPrice.replaceAll('Rs. ', '').replaceAll(',', ''));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border, width: 1.5)),
        title: Text('Update Price', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Rs. ',
                prefixStyle: const TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.adminPrimary, width: 1.5),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Price updated for $item. Audit log created.'),
                backgroundColor: AppColors.success,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Update', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
