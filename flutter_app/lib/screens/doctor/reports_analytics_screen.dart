import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsAnalyticsScreen extends StatelessWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Clinical Reports & Analytics',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consultation Overview',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildAnalyticsRow('Total Consultations', '24 completed', const Color(0xFF00C853)),
                  const Divider(height: 32),
                  _buildAnalyticsRow('Differential Diagnoses Generated', '48 diffs', const Color(0xFF0066FF)),
                  const Divider(height: 32),
                  _buildAnalyticsRow('Antigravity Reasoning Accuracy', '98.4%', const Color(0xFF7C3AED)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Top Clinic Diagnoses',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
            ),
            const SizedBox(height: 12),
            _buildDiagnosisProgress('Hypertension', 0.75, '75% of patients', const Color(0xFF00C853)),
            const SizedBox(height: 12),
            _buildDiagnosisProgress('Type 2 Diabetes', 0.50, '50% of patients', const Color(0xFF0066FF)),
            const SizedBox(height: 12),
            _buildDiagnosisProgress('Hyperlipidemia', 0.35, '35% of patients', const Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 15, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDiagnosisProgress(String label, double value, String percentage, Color color) {
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
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
              ),
              Text(
                percentage,
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: value,
            backgroundColor: color.withValues(alpha: 0.08),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
