import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/patient_provider.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<PatientProvider>(context, listen: false);
      prov.fetchAppointments();
      prov.fetchDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientProv = Provider.of<PatientProvider>(context);
    final appointments = patientProv.appointments;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Appointments',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF0066FF)),
            onPressed: () => _showBookDialog(context, patientProv),
          )
        ],
      ),
      body: patientProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await patientProv.fetchAppointments();
              },
              child: appointments.isEmpty
                  ? Center(
                      child: Text(
                        'No records available',
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
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
                                radius: 26,
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
                                      apt['specialty']?.toString() ?? 'General Medicine',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: Color(0xFF94A3B8)),
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
            ),
    );
  }

  void _showBookDialog(BuildContext context, PatientProvider prov) {
    if (prov.doctorsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active doctors available in clinic database')),
      );
      return;
    }

    String selectedDocId = prov.doctorsList.first['id'].toString();
    final specialtyCtrl = TextEditingController(text: prov.doctorsList.first['specialty'] ?? 'Cardiology');
    final noteCtrl = TextEditingController(text: 'Routine clinical consultation checkup.');
    final dateCtrl = TextEditingController(text: '2026-05-24 10:00:00');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Book Appointment',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedDocId,
                      decoration: const InputDecoration(labelText: 'Select Physician'),
                      items: prov.doctorsList.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc['id'].toString(),
                          child: Text(doc['full_name']?.toString() ?? 'Dr. Amit Verma'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedDocId = val;
                            final docObj = prov.doctorsList.firstWhere((element) => element['id'].toString() == val);
                            specialtyCtrl.text = docObj['specialty'] ?? 'General Medicine';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: specialtyCtrl,
                      decoration: const InputDecoration(labelText: 'Specialty Requirement'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dateCtrl,
                      decoration: const InputDecoration(labelText: 'Date & Time (YYYY-MM-DD HH:MM:SS)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(labelText: 'Consultation Complaint Notes'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.inter(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final success = await prov.bookAppointment(
                      doctorId: selectedDocId,
                      datetime: dateCtrl.text,
                      specialty: specialtyCtrl.text,
                      type: 'In-Clinic',
                      notes: noteCtrl.text,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Consultation booked successfully' : 'Failed to book appointment'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Book'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
