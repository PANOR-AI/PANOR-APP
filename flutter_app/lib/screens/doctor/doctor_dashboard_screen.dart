import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/doctor_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'patient_list_screen.dart';
import 'consultation_screen.dart';
import 'calendar_screen.dart';
import 'reports_analytics_screen.dart';
import 'patient_profile_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color cardBg = Color(0xFF131929);
  static const Color borderColor = Color(0xFF1E2A3A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color doctorGreen = Color(0xFF10B981);
  static const Color emergencyRed = Color(0xFFEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color purpleAccent = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorProvider>(context, listen: false).fetchDoctorDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorProv = Provider.of<DoctorProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);

    final user = authProv.userProfile;
    final doctorName = user != null
        ? user['full_name'] as String? ?? 'Dr. Ahmad'
        : 'Dr. Ahmad';

    final dash = doctorProv.dashboardData;
    final todayPatients = dash != null ? dash['today_patients'] as int? ?? 0 : 0;
    final todayAppointments =
        dash != null ? dash['today_appointments'] as int? ?? 0 : 0;
    final pendingConsultations =
        dash != null ? dash['pending_consultations'] as int? ?? 0 : 0;
    final recentPatients =
        dash != null ? dash['recent_patients'] as List? ?? [] : [];
    final schedule = dash != null ? dash['schedule'] as List? ?? [] : [];

    return Scaffold(
      backgroundColor: darkBg,
      body: doctorProv.isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(doctorGreen),
                strokeWidth: 2.5,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async =>
                  doctorProv.fetchDoctorDashboard(forceRefresh: true),
              color: doctorGreen,
              backgroundColor: cardBg,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    expandedHeight: 200,
                    backgroundColor: darkBg,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0D2318), Color(0xFF0A0E1A)],
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
                                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.medical_services_rounded,
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
                                        color: doctorGreen.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'DOCTOR',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: doctorGreen,
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
                                    icon: const Icon(Icons.notifications_outlined,
                                        color: Colors.white, size: 22),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Good Morning, ${doctorName.split(' ').first} 👨‍⚕️',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your Clinical Co-Pilot is ready',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: doctorGreen,
                                fontWeight: FontWeight.w500,
                              ),
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
                        // EMERGENCY ALERT if pending > 0
                        if (pendingConsultations > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: emergencyRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: emergencyRed.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: emergencyRed,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.warning_rounded,
                                      color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$pendingConsultations Pending Consultations',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: emergencyRed,
                                        ),
                                      ),
                                      Text(
                                        'Requires immediate clinical attention',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: emergencyRed.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (_) => const PatientListScreen())),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: emergencyRed,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  child: Text('View',
                                      style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Today Stats
                        Row(
                          children: [
                            _buildStatCard('Today\'s Patients', '$todayPatients',
                                Icons.people_rounded, doctorGreen),
                            const SizedBox(width: 12),
                            _buildStatCard('Appointments', '$todayAppointments',
                                Icons.calendar_today_rounded, primaryBlue),
                            const SizedBox(width: 12),
                            _buildStatCard('Pending', '$pendingConsultations',
                                Icons.pending_actions_rounded, warningAmber),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Quick Actions
                        _sectionHeader('Clinical Actions'),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _buildActionTile(
                              context,
                              icon: Icons.person_add_rounded,
                              label: 'Onboard Patient',
                              color: doctorGreen,
                              onTap: () => _showOnboardPatientDialog(context, doctorProv),
                            ),
                            const SizedBox(width: 12),
                            _buildActionTile(
                              context,
                              icon: Icons.people_rounded,
                              label: 'Patient List',
                              color: primaryBlue,
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const PatientListScreen())),
                            ),
                            const SizedBox(width: 12),
                            _buildActionTile(
                              context,
                              icon: Icons.bar_chart_rounded,
                              label: 'Analytics',
                              color: purpleAccent,
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ReportsAnalyticsScreen())),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Today's Schedule
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionHeader('Today\'s Schedule'),
                            TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const CalendarScreen())),
                              child: Text('Full Calendar',
                                  style: GoogleFonts.inter(
                                      color: doctorGreen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        schedule.isEmpty
                            ? _buildEmptyCard(
                                'No appointments scheduled today',
                                Icons.calendar_today_rounded)
                            : Column(
                                children: schedule
                                    .take(4)
                                    .map((s) => _buildScheduleCard(context, s as Map))
                                    .toList(),
                              ),
                        const SizedBox(height: 28),

                        // Recent Patients
                        _sectionHeader('Recent Patients'),
                        const SizedBox(height: 12),
                        recentPatients.isEmpty
                            ? _buildEmptyCard(
                                'No recent patients', Icons.people_rounded)
                            : Column(
                                children: recentPatients
                                    .take(4)
                                    .map((p) => _buildPatientCard(context, p as Map))
                                    .toList(),
                              ),
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

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, Map schedule) {
    final status = schedule['status']?.toString() ?? 'Scheduled';
    final isActive = status.toLowerCase() == 'in_progress';
    Color statusColor = primaryBlue;
    if (isActive) statusColor = doctorGreen;
    if (status.toLowerCase() == 'completed') statusColor = textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? doctorGreen.withValues(alpha: 0.05) : cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isActive ? doctorGreen.withValues(alpha: 0.3) : borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule['patient_name']?.toString() ?? 'Patient',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  schedule['type']?.toString() ?? 'Consultation',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                schedule['time']?.toString() ?? '',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, Map patient) {
    final risk = patient['risk_level']?.toString() ?? 'GREEN';
    Color riskColor;
    switch (risk.toUpperCase()) {
      case 'RED':
        riskColor = emergencyRed;
        break;
      case 'YELLOW':
        riskColor = warningAmber;
        break;
      case 'ORANGE':
        riskColor = const Color(0xFFF97316);
        break;
      default:
        riskColor = doctorGreen;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientProfileScreen(
            patientId: patient['patient_id']?.toString() ?? '',
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: doctorGreen.withValues(alpha: 0.12),
                  child: Text(
                    (patient['full_name']?.toString() ?? 'P')[0],
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, color: doctorGreen),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: riskColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardBg, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['full_name']?.toString() ?? 'Patient Name',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    patient['last_diagnosis']?.toString() ??
                        'Last consultation',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                risk,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),
            ),
          ],
        ),
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

  void _showOnboardPatientDialog(BuildContext context, DoctorProvider prov) {
    final pidCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Onboard Patient',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the patient\'s national P_ID to request access. The patient will receive a consent notification.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pidCtrl,
              style: GoogleFonts.inter(color: textPrimary),
              decoration: InputDecoration(
                labelText: 'Patient ID (P_ID)',
                hintText: 'PAK-HEALTH-2026-XXXX',
                labelStyle: GoogleFonts.inter(color: textSecondary),
                hintStyle: GoogleFonts.inter(color: const Color(0xFF4A5568)),
                filled: true,
                fillColor: const Color(0xFF0A0E1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: doctorGreen, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pidCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Consent request sent to patient ${pidCtrl.text}'),
                  backgroundColor: doctorGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: doctorGreen),
            child: Text('Send Request',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
