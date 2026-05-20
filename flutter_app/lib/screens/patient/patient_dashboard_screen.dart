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

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientProv = Provider.of<PatientProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);

    final user = authProv.userProfile;
    final fullName = user != null
        ? user['full_name'] as String? ?? 'Ahmed Raza'
        : 'Ahmed Raza';
    final dash = patientProv.dashboardData;
    final healthSummary =
        dash != null ? dash['health_summary'] as Map? ?? {} : {};
    final appointments =
        dash != null ? dash['upcoming_appointments'] as List? ?? [] : [];
    final medications =
        dash != null ? dash['active_medications'] as List? ?? [] : [];
    final labReports =
        dash != null ? dash['recent_lab_reports'] as List? ?? [] : [];
    final notificationsCount =
        dash != null ? dash['notifications_count'] as int? ?? 0 : 0;

    const clinicalBlue = Color(0xFF0066FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: clinicalBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.healing_outlined,
                  color: clinicalBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'PANOR Clinical',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                color: clinicalBlue,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Notification Badge Widget
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined,
                    color: Color(0xFF64748B), size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              if (notificationsCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$notificationsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: patientProv.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(clinicalBlue)))
          : RefreshIndicator(
              onRefresh: () async {
                await patientProv.fetchPatientDashboard(forceRefresh: true);
              },
              color: clinicalBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome & Date Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $fullName',
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pakistan National Health Portal',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Quick Actions Row
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildQuickActionCard(
                          context,
                          label: 'Consult AI',
                          icon: Icons.chat_bubble_outline_rounded,
                          color: clinicalBlue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AIAssistantScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildQuickActionCard(
                          context,
                          label: 'Book Consult',
                          icon: Icons.calendar_today_outlined,
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AppointmentsScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildQuickActionCard(
                          context,
                          label: 'Log Vitals',
                          icon: Icons.add_circle_outline_rounded,
                          color: Colors.redAccent,
                          onTap: () =>
                              _showLogVitalsDialog(context, patientProv),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Health Summary Vitals Cards Grid
                    Text(
                      'Health Vitals',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
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
                        _buildVitalCard(
                          label: 'Blood Pressure',
                          value: healthSummary['blood_pressure']?.toString() ??
                              '120/80 mmHg',
                          icon: Icons.favorite_outline,
                          color: Colors.redAccent,
                        ),
                        _buildVitalCard(
                          label: 'Heart Rate',
                          value: healthSummary['heart_rate']?.toString() ??
                              '72 bpm',
                          icon: Icons.monitor_heart_outlined,
                          color: Colors.orangeAccent,
                        ),
                        _buildVitalCard(
                          label: 'Temperature',
                          value: healthSummary['temperature']?.toString() ??
                              '98.6 °F',
                          icon: Icons.thermostat_outlined,
                          color: Colors.amber,
                        ),
                        _buildVitalCard(
                          label: 'Oxygen Level',
                          value: healthSummary['oxygen_level']?.toString() ??
                              '98%',
                          icon: Icons.bloodtype_outlined,
                          color: clinicalBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Active Medications
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Medications',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MedicationsScreen()),
                            );
                          },
                          child: const Text('View All',
                              style: TextStyle(
                                  color: clinicalBlue,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (medications.isEmpty)
                      _buildEmptyState('No active medications prescribed')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            medications.length > 2 ? 2 : medications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final med = medications[index] as Map;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: clinicalBlue.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.medication_liquid_outlined,
                                      color: clinicalBlue,
                                      size: 22),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        med['name']?.toString() ?? 'Medicine',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Dosage: ${med['dosage']} • Frequency: ${med['frequency']}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 32),

                    // Recent Lab Reports
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Lab Reports',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HealthRecordsScreen()),
                            );
                          },
                          child: const Text('View All',
                              style: TextStyle(
                                  color: clinicalBlue,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (labReports.isEmpty)
                      _buildEmptyState('No lab records available')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            labReports.length > 2 ? 2 : labReports.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final lab = labReports[index] as Map;
                          final priority =
                              lab['priority']?.toString().toUpperCase() ??
                                  'ROUTINE';
                          final isStat = priority == 'STAT';
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.purple.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.biotech_outlined,
                                      color: Colors.purple, size: 22),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lab['test_name']?.toString() ??
                                            'Lab Test',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            'Status: ${lab['status']}',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isStat
                                                  ? Colors.redAccent
                                                      .withValues(alpha: 0.1)
                                                  : Colors.blueGrey
                                                      .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              priority,
                                              style: TextStyle(
                                                  color: isStat
                                                      ? Colors.redAccent
                                                      : const Color(0xFF64748B),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 32),

                    // Upcoming Appointments Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Appointments',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (appointments.isEmpty)
                      _buildEmptyState('No upcoming appointments scheduled')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: appointments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final apt = appointments[index] as Map;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.01),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(
                                      apt['image_url'] ??
                                          'https://i.pravatar.cc/150?img=33'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        apt['doctor_name']?.toString() ??
                                            'Dr. Amit Verma',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        apt['specialty']?.toString() ??
                                            'Cardiologist',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 14,
                                              color: Color(0xFF94A3B8)),
                                          const SizedBox(width: 6),
                                          Text(
                                            apt['datetime']?.toString() ??
                                                '24 May 2026, 10:00 AM',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: const Color(0xFF64748B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
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
              ),
            ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVitalCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
              Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500),
              ),
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
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
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

  void _showLogVitalsDialog(BuildContext context, PatientProvider prov) {
    final bpCtrl = TextEditingController(text: '120/80');
    final hrCtrl = TextEditingController(text: '72');
    final tempCtrl = TextEditingController(text: '98.6');
    final oxyCtrl = TextEditingController(text: '98');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Log Today Vitals',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bpCtrl,
                decoration: const InputDecoration(
                    labelText: 'Blood Pressure (e.g. 120/80)'),
              ),
              TextField(
                controller: hrCtrl,
                decoration:
                    const InputDecoration(labelText: 'Heart Rate (bpm)'),
              ),
              TextField(
                controller: tempCtrl,
                decoration:
                    const InputDecoration(labelText: 'Temperature (°F)'),
              ),
              TextField(
                controller: oxyCtrl,
                decoration:
                    const InputDecoration(labelText: 'Oxygen Level (%)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text('Cancel', style: GoogleFonts.inter(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await prov.logVitals(
                  bp: bpCtrl.text,
                  hr: hrCtrl.text,
                  temp: double.tryParse(tempCtrl.text) ?? 98.6,
                  oxygen: int.tryParse(oxyCtrl.text) ?? 98,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Vitals logged successfully'
                          : 'Failed to log vitals'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
