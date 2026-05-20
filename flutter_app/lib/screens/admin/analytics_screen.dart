import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/admin_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);
    final analytics = adminProv.analytics;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'System Analytics Summary',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
        ),
      ),
      body: adminProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform Overview',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
                  ),
                  const SizedBox(height: 12),
                  if (analytics == null)
                    Center(
                      child: Text(
                        'No records available',
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildRow('Platform Engine', analytics['platform']?.toString() ?? 'PANOR Platform'),
                          const Divider(height: 32),
                          _buildRow('Total Account Registrations', analytics['total_users']?.toString() ?? '0'),
                          const Divider(height: 32),
                          _buildRow('Registered Patients Count', analytics['total_patients']?.toString() ?? '0'),
                          const Divider(height: 32),
                          _buildRow('Active Physicians Count', analytics['total_doctors']?.toString() ?? '0'),
                          const Divider(height: 32),
                          _buildRow('Active Administrators Count', analytics['total_admins']?.toString() ?? '0'),
                          const Divider(height: 32),
                          _buildRow('PANOR Version', analytics['version']?.toString() ?? '1.0.0'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF7C3AED), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
