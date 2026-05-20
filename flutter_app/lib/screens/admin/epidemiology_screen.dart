import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EpidemiologyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Epidemiology Monitoring',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regional Outbreak Risk',
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
                  _buildRiskRow('Influenza Outbreak Risk', 'Low (12% index)', Colors.green),
                  const Divider(height: 32),
                  _buildRiskRow('COVID-19 Surveillance', 'Moderate (35% index)', Colors.orange),
                  const Divider(height: 32),
                  _buildRiskRow('Dengue Alert Level', 'Minimal (4% index)', Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Active Outbreak Surveillance',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'No active clinical outbreaks detected in local regional patient networks.',
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskRow(String disease, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          disease,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Text(
          status,
          style: GoogleFonts.inter(fontSize: 14, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
