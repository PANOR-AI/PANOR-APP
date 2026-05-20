import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/patient_provider.dart';
import '../../core/providers/auth_provider.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientProv = Provider.of<PatientProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    
    final user = authProv.userProfile;
    final fullName = user != null ? user['full_name'] as String? ?? 'Valued Patient' : 'Valued Patient';
    final dash = patientProv.dashboardData;
    final healthSummary = dash != null ? dash['health_summary'] as Map? ?? {} : {};
    final appointments = dash != null ? dash['appointments'] as List? ?? [] : [];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'PANOR Clinical',
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: const Color(0xFF0066FF)),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: patientProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await patientProv.fetchDashboard();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Title
                    Text(
                      'Hello, $fullName',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A1628),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Today is 20 May 2026',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Health Summary Card
                    Text(
                      'Health Summary',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A1628),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildVitalIndicator(
                                label: 'Blood Pressure',
                                value: healthSummary['blood_pressure']?.toString() ?? '120/80 mmHg',
                                icon: Icons.favorite_outline,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 24),
                              _buildVitalIndicator(
                                label: 'Heart Rate',
                                value: healthSummary['heart_rate']?.toString() ?? '72 bpm',
                                icon: Icons.bloodtype_outlined,
                                color: const Color(0xFF0066FF),
                              ),
                            ],
                          ),
                          const Divider(height: 32, color: Color(0xFFF1F5F9)),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () => _showLogVitalsDialog(context, patientProv),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Log Vitals'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0066FF),
                                side: const BorderSide(color: Color(0xFF0066FF)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Upcoming Appointments Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Appointments',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A1628),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (appointments.isEmpty)
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
                        itemCount: appointments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final apt = appointments[index] as Map;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                  backgroundImage: NetworkImage(apt['image_url'] ?? 'https://i.pravatar.cc/150?img=33'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        apt['doctor_name']?.toString() ?? 'Dr. Amit Verma',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0A1628),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        apt['specialty']?.toString() ?? 'Cardiologist',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF94A3B8)),
                                          const SizedBox(width: 6),
                                          Text(
                                            apt['datetime']?.toString() ?? '24 May 2026, 10:00 AM',
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

  Widget _buildVitalIndicator({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0A1628),
                  ),
                ),
              ],
            ),
          )
        ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Log Today Vitals',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bpCtrl,
                decoration: const InputDecoration(labelText: 'Blood Pressure (e.g. 120/80)'),
              ),
              TextField(
                controller: hrCtrl,
                decoration: const InputDecoration(labelText: 'Heart Rate (bpm)'),
              ),
              TextField(
                controller: tempCtrl,
                decoration: const InputDecoration(labelText: 'Temperature (°F)'),
              ),
              TextField(
                controller: oxyCtrl,
                decoration: const InputDecoration(labelText: 'Oxygen Level (%)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.red)),
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
                      content: Text(success ? 'Vitals logged successfully' : 'Failed to log vitals'),
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
