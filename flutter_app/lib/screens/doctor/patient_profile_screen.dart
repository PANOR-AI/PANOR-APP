import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/doctor_provider.dart';

class PatientProfileScreen extends StatefulWidget {
  final String patientId;

  const PatientProfileScreen({super.key, required this.patientId});

  @override
  _PatientProfileScreenState createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorProvider>(context, listen: false).fetchPatientDetail(widget.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final docProv = Provider.of<DoctorProvider>(context);
    final detail = docProv.selectedPatientDetail;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Longitudinal Timeline',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
        ),
      ),
      body: docProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : detail == null
              ? Center(
                  child: Text(
                    'No records available',
                    style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853).withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Color(0xFF00C853), size: 36),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detail['full_name']?.toString() ?? 'Valued Patient',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0A1628),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    detail['email']?.toString() ?? '',
                                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Blood Group: ${detail['blood_group'] ?? 'N/A'}  |  Gender: ${detail['gender'] ?? 'N/A'}',
                                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Recent Prescriptions Section
                      Text(
                        'Prescription History',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
                      ),
                      const SizedBox(height: 12),
                      _buildPrescriptionsList(detail['recent_prescriptions'] as List? ?? []),
                      
                      const SizedBox(height: 32),

                      // Recent Lab Reports Section
                      Text(
                        'Lab Reports Order History',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
                      ),
                      const SizedBox(height: 12),
                      _buildLabsList(detail['recent_labs'] as List? ?? []),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPrescriptionsList(List list) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(
            'No records available',
            style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final rx = list[index] as Map;
        final meds = rx['medications'] as List? ?? [];
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
                    'Diagnosis: ${rx['diagnosis'] ?? 'N/A'}',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
                  ),
                  Text(
                    rx['created_at']?.toString().substring(0, 10) ?? '',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              ...meds.map((med) => Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text('- $med', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabsList(List list) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(
            'No records available',
            style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final lab = list[index] as Map;
        final priority = lab['priority']?.toString() ?? 'Routine';
        final priorityColor = priority == 'Urgent' ? Colors.red : const Color(0xFF00C853);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lab['test_name']?.toString() ?? 'Routine Count',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${lab['status'] ?? 'Ordered'}  |  Ordered: ${lab['created_at']?.toString().substring(0, 10) ?? ''}',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  priority,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: priorityColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
