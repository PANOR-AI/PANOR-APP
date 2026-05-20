import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/patient_provider.dart';

class HealthRecordsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final patientProv = Provider.of<PatientProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: Text(
            'Health Records',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF0066FF),
            unselectedLabelColor: const Color(0xFF94A3B8),
            indicatorColor: const Color(0xFF0066FF),
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.inter(),
            tabs: const [
              Tab(text: 'Vitals Log'),
              Tab(text: 'Prescriptions'),
              Tab(text: 'Lab Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Vitals Log
            _buildVitalsTab(context, patientProv),
            // Tab 2: Prescriptions
            _buildPrescriptionsTab(context, patientProv),
            // Tab 3: Lab Reports
            _buildLabsTab(context, patientProv),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsTab(BuildContext context, PatientProvider prov) {
    final list = prov.vitalsList;
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No records available',
          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = list[index] as Map;
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
                    'Recorded At',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                  ),
                  Text(
                    item['recorded_at']?.toString().substring(0, 16).replaceAll('T', ' ') ?? 'Just now',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _vitalItem('BP', item['blood_pressure']?.toString() ?? 'N/A'),
                  _vitalItem('Heart Rate', '${item['heart_rate'] ?? 'N/A'} bpm'),
                  _vitalItem('Temp', '${item['temperature'] ?? 'N/A'} °F'),
                  _vitalItem('O2', '${item['oxygen_level'] ?? 'N/A'}%'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _vitalItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628))),
      ],
    );
  }

  Widget _buildPrescriptionsTab(BuildContext context, PatientProvider prov) {
    final list = prov.prescriptions;
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No records available',
          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = list[index] as Map;
        final meds = item['medications'] as List? ?? [];

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
                    item['doctor_name']?.toString() ?? 'Dr. Amit Verma',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
                  ),
                  Text(
                    item['created_at']?.toString().substring(0, 10) ?? '',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Diagnosis: ${item['diagnosis'] ?? 'Differential differential'}',
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              Text(
                'Medications:',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
              ),
              const SizedBox(height: 6),
              ...meds.map((med) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    '- $med',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabsTab(BuildContext context, PatientProvider prov) {
    final list = prov.labReports;
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No records available',
          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = list[index] as Map;
        final priority = item['priority']?.toString() ?? 'Routine';
        final priorityColor = priority == 'Urgent' ? Colors.red : const Color(0xFF0066FF);

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
                    item['test_name']?.toString() ?? 'Blood Count',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      priority,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: priorityColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status: ${item['status'] ?? 'Completed'}',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                  ),
                  Text(
                    item['created_at']?.toString().substring(0, 10) ?? '',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              Text(
                'Results details:',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
              ),
              const SizedBox(height: 4),
              Text(
                item['results']?.toString() ?? 'Result parameters pending clinician review.',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        );
      },
    );
  }
}
