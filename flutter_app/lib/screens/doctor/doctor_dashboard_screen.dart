import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/doctor_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/role_selection_screen.dart';
import 'patient_profile_screen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final docProv = Provider.of<DoctorProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    
    final user = authProv.userProfile;
    final fullName = user != null ? user['full_name'] as String? ?? 'Dr. Fatima Hassan' : 'Dr. Fatima Hassan';
    final dash = docProv.dashboardData;
    
    // Dyn DB values
    final todayPatientsCount = dash != null ? dash['today_patients'] as int? ?? 0 : 0;
    final todayAptsCount = dash != null ? dash['today_appointments'] as int? ?? 0 : 0;
    final pendingConsultsCount = dash != null ? dash['pending_consultations'] as int? ?? 0 : 0;
    final recentPatients = dash != null ? dash['recent_patients'] as List? ?? [] : [];
    final schedule = dash != null ? dash['schedule'] as List? ?? [] : [];
    final analytics = dash != null ? dash['analytics'] as Map? ?? {} : {};
    final weeklyConsults = analytics['weekly_consultations'] as List? ?? [];
    final topConditions = analytics['top_conditions'] as List? ?? [];

    const clinicalGreen = Color(0xFF00C853);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: clinicalGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medical_services_outlined, color: clinicalGreen, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'PANOR Clinician Portal',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900, 
                color: clinicalGreen,
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
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: docProv.isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(clinicalGreen)))
          : RefreshIndicator(
              onRefresh: () async {
                await docProv.fetchDoctorDashboard(forceRefresh: true);
              },
              color: clinicalGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    Text(
                      'Welcome, $fullName',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Operational Overview • Clinic Status Active',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Metrics Grid (Patients Count, Pending Consultations, Scheduled Appointments)
                    Row(
                      children: [
                        _buildMetricCard(
                          label: 'Daily Patients',
                          value: '$todayPatientsCount',
                          icon: Icons.people_outline_rounded,
                          color: clinicalGreen,
                        ),
                        const SizedBox(width: 16),
                        _buildMetricCard(
                          label: 'Pending Consults',
                          value: '$pendingConsultsCount',
                          icon: Icons.pending_actions_rounded,
                          color: Colors.orangeAccent,
                        ),
                        const SizedBox(width: 16),
                        _buildMetricCard(
                          label: 'Total Today',
                          value: '$todayAptsCount',
                          icon: Icons.calendar_month_outlined,
                          color: const Color(0xFF0066FF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Weekly Analytics Graphs
                    Text(
                      'Weekly Consultation Analytics',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildWeeklyChart(weeklyConsults, clinicalGreen),
                    const SizedBox(height: 32),

                    // Top Diagnosed Conditions list
                    if (topConditions.isNotEmpty) ...[
                      Text(
                        'Top Monitored Diagnoses',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: topConditions.map<Widget>((item) {
                            final cond = item['condition']?.toString() ?? 'N/A';
                            final count = item['count'] ?? 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    cond,
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: clinicalGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$count cases',
                                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: clinicalGreen),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Appointment Schedule
                    Text(
                      "Today's Appointment Schedule",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (schedule.isEmpty)
                      _buildEmptyState('No scheduled appointments for today')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: schedule.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final apt = schedule[index] as Map;
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
                                    color: clinicalGreen.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.alarm_outlined, color: clinicalGreen, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        apt['patient_name']?.toString() ?? 'Patient',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        apt['type']?.toString() ?? 'Regular Consult',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: clinicalGreen.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    apt['time']?.toString() ?? '10:00 AM',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: clinicalGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 32),

                    // Recent Patients List
                    Text(
                      'Recent Patient Encounters',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (recentPatients.isEmpty)
                      _buildEmptyState('No recent patients records')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentPatients.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final pat = recentPatients[index] as Map;
                          final gender = pat['gender']?.toString() ?? 'N/A';
                          final bloodGroup = pat['blood_group']?.toString() ?? 'N/A';
                          final pId = pat['id']?.toString() ?? '';
                          return Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                if (pId.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PatientProfileScreen(patientId: pId),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: clinicalGreen.withValues(alpha: 0.1),
                                      child: const Icon(Icons.person_outline, color: clinicalGreen),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pat['full_name']?.toString() ?? 'Valued Patient',
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Gender: $gender • Blood: $bloodGroup',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
                                  ],
                                ),
                              ),
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
        padding: const EdgeInsets.all(16),
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
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<dynamic> data, Color barColor) {
    if (data.isEmpty) {
      return _buildEmptyState('No analytics data recorded for this week');
    }
    
    // Find max value for scaling
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map<Widget>((item) {
              final day = item['day']?.toString() ?? '';
              final count = item['count'] as int? ?? 0;
              final pct = count / maxVal;
              final barHeight = pct * 100 + 10;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$count',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
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
                    day,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                ],
              );
            }).toList(),
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
          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
        ),
      ),
    );
  }
}
