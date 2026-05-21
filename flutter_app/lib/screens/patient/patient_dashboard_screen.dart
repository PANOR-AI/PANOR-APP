import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/patient_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'ai_assistant_screen.dart';
import 'appointments_screen.dart';
import 'medications_screen.dart';
import 'health_records_screen.dart';
import 'notifications_screen.dart';
import '../../features/patient/upload_report_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  // Premium PANOR color palette
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color cardBg = Color(0xFF131929);
  static const Color borderColor = Color(0xFF1E2A3A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color emergencyRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color purpleAccent = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatientProvider>(context, listen: false)
          .fetchPatientDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientProv = Provider.of<PatientProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);

    final user = authProv.userProfile;
    final fullName =
        user != null ? user['full_name'] as String? ?? 'Ahmed Raza' : 'Ahmed Raza';
    final pid = user != null ? user['patient_id'] as String? ?? 'PAK-HEALTH-****-0001' : 'PAK-HEALTH-****-0001';

    final dash = patientProv.dashboardData;
    final healthSummary = dash != null ? dash['health_summary'] as Map? ?? {} : {};
    final appointments =
        dash != null ? dash['upcoming_appointments'] as List? ?? [] : [];
    final medications =
        dash != null ? dash['active_medications'] as List? ?? [] : [];
    final labReports =
        dash != null ? dash['recent_lab_reports'] as List? ?? [] : [];
    final notificationsCount =
        dash != null ? dash['notifications_count'] as int? ?? 0 : 0;

    return Scaffold(
      backgroundColor: darkBg,
      body: patientProv.isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                strokeWidth: 2.5,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await patientProv.fetchPatientDashboard(forceRefresh: true);
              },
              color: primaryBlue,
              backgroundColor: cardBg,
              child: CustomScrollView(
                slivers: [
                  // Sticky header
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    expandedHeight: 180,
                    backgroundColor: darkBg,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A2035), Color(0xFF0A0E1A)],
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
                                          colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.health_and_safety_rounded,
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
                                  ],
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                            Icons.notifications_outlined,
                                            color: Colors.white,
                                            size: 22),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const NotificationsScreen()),
                                        ),
                                      ),
                                    ),
                                    if (notificationsCount > 0)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: emergencyRed,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Good Morning, ${fullName.split(' ').first} 👋',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'P.ID: $pid',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: const [],
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Quick stats row
                        Row(
                          children: [
                            _buildStatChip(
                              '${appointments.length}',
                              'Upcoming',
                              Icons.calendar_today_rounded,
                              primaryBlue,
                            ),
                            const SizedBox(width: 12),
                            _buildStatChip(
                              '${medications.length}',
                              'Medications',
                              Icons.medication_rounded,
                              successGreen,
                            ),
                            const SizedBox(width: 12),
                            _buildStatChip(
                              '${labReports.length}',
                              'Lab Reports',
                              Icons.biotech_rounded,
                              purpleAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Quick Actions
                        _sectionHeader('Quick Actions'),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _buildActionButton(
                              context,
                              icon: Icons.record_voice_over_rounded,
                              label: 'AI\nAssistant',
                              gradient: const [Color(0xFF6C63FF), Color(0xFF3B82F6)],
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const AIAssistantScreen())),
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              context,
                              icon: Icons.upload_file_rounded,
                              label: 'Upload\nRecord',
                              gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const UploadReportScreen())),
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              context,
                              icon: Icons.calendar_month_rounded,
                              label: 'Book\nConsult',
                              gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const AppointmentsScreen())),
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              context,
                              icon: Icons.monitor_heart_rounded,
                              label: 'Log\nVitals',
                              gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                              onTap: () =>
                                  _showLogVitalsDialog(context, patientProv),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Health Vitals
                        _sectionHeader('Health Vitals'),
                        const SizedBox(height: 14),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1.6,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _buildVitalCard(
                              label: 'Blood Pressure',
                              value: healthSummary['blood_pressure']
                                      ?.toString() ??
                                  '120/80',
                              unit: 'mmHg',
                              icon: Icons.favorite_rounded,
                              color: emergencyRed,
                              status: 'Normal',
                            ),
                            _buildVitalCard(
                              label: 'Heart Rate',
                              value: healthSummary['heart_rate']?.toString() ??
                                  '72',
                              unit: 'bpm',
                              icon: Icons.monitor_heart_rounded,
                              color: warningAmber,
                              status: 'Normal',
                            ),
                            _buildVitalCard(
                              label: 'Temperature',
                              value:
                                  healthSummary['temperature']?.toString() ??
                                      '98.6',
                              unit: '°F',
                              icon: Icons.thermostat_rounded,
                              color: successGreen,
                              status: 'Normal',
                            ),
                            _buildVitalCard(
                              label: 'Oxygen Level',
                              value:
                                  healthSummary['oxygen_level']?.toString() ??
                                      '98',
                              unit: '%',
                              icon: Icons.air_rounded,
                              color: primaryBlue,
                              status: 'Excellent',
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Active Medications
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionHeader('Active Medications'),
                            TextButton(
                              onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const MedicationsScreen())),
                              child: Text('View All',
                                  style: GoogleFonts.inter(
                                      color: primaryBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        medications.isEmpty
                            ? _buildEmptyCard(
                                'No active medications prescribed',
                                Icons.medication_rounded,
                              )
                            : Column(
                                children: medications
                                    .take(2)
                                    .map((m) => _buildMedCard(m as Map))
                                    .toList(),
                              ),
                        const SizedBox(height: 28),

                        // Recent Lab Reports
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionHeader('Lab Reports'),
                            TextButton(
                              onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const HealthRecordsScreen())),
                              child: Text('View All',
                                  style: GoogleFonts.inter(
                                      color: primaryBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        labReports.isEmpty
                            ? _buildEmptyCard(
                                'No lab reports available',
                                Icons.biotech_rounded,
                              )
                            : Column(
                                children: labReports
                                    .take(2)
                                    .map((l) => _buildLabCard(l as Map))
                                    .toList(),
                              ),
                        const SizedBox(height: 28),

                        // Upcoming Appointments
                        _sectionHeader('Upcoming Appointments'),
                        const SizedBox(height: 12),
                        appointments.isEmpty
                            ? _buildEmptyCard(
                                'No upcoming appointments',
                                Icons.calendar_today_rounded,
                              )
                            : Column(
                                children: appointments
                                    .take(3)
                                    .map((a) => _buildAppointmentCard(a as Map))
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

  Widget _buildStatChip(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 22,
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
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Icon(icon, color: color, size: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: successGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: successGreen,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.inter(fontSize: 11, color: color),
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
    );
  }

  Widget _buildMedCard(Map med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: successGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medication_rounded,
                color: successGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med['name']?.toString() ?? 'Medication',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${med['dosage'] ?? ''} • ${med['frequency'] ?? ''}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: successGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Active',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: successGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabCard(Map lab) {
    final priority = lab['priority']?.toString().toUpperCase() ?? 'ROUTINE';
    final isStat = priority == 'STAT';
    final priorityColor = isStat ? emergencyRed : primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: purpleAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.biotech_rounded, color: purpleAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lab['test_name']?.toString() ?? 'Lab Test',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Status: ${lab['status'] ?? 'Pending'}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              priority,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: priorityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map apt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryBlue.withValues(alpha: 0.15),
            child: Text(
              (apt['doctor_name']?.toString() ?? 'D')[0],
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, color: primaryBlue),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apt['doctor_name']?.toString() ?? 'Dr. Ahmed',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  apt['specialty']?.toString() ?? 'Specialist',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: Color(0xFF8892A4)),
                    const SizedBox(width: 4),
                    Text(
                      apt['datetime']?.toString() ?? 'Scheduled',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Confirmed',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
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

  void _showLogVitalsDialog(BuildContext context, PatientProvider prov) {
    final bpCtrl = TextEditingController(text: '120/80');
    final hrCtrl = TextEditingController(text: '72');
    final tempCtrl = TextEditingController(text: '98.6');
    final oxyCtrl = TextEditingController(text: '98');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Vitals',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _vitalInput(bpCtrl, 'Blood Pressure', 'mmHg'),
            const SizedBox(height: 12),
            _vitalInput(hrCtrl, 'Heart Rate', 'bpm'),
            const SizedBox(height: 12),
            _vitalInput(tempCtrl, 'Temperature', '°F'),
            const SizedBox(height: 12),
            _vitalInput(oxyCtrl, 'Oxygen Level', '%'),
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
              final success = await prov.logVitals(
                bp: bpCtrl.text,
                hr: hrCtrl.text,
                temp: double.tryParse(tempCtrl.text) ?? 98.6,
                oxygen: int.tryParse(oxyCtrl.text) ?? 98,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Vitals logged successfully'
                        : 'Failed to log vitals'),
                    backgroundColor: success ? successGreen : emergencyRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: Text('Save',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _vitalInput(TextEditingController ctrl, String label, String unit) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 13),
        suffixText: unit,
        suffixStyle: GoogleFonts.inter(color: textSecondary),
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
          borderSide: const BorderSide(color: primaryBlue),
        ),
      ),
    );
  }
}
