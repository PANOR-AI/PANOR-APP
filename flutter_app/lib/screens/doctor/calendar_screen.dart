import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Clinic Calendar Slots',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Slot Date',
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
              child: CalendarDatePicker(
                initialDate: DateTime(2026, 5, 20),
                firstDate: DateTime(2026, 1, 1),
                lastDate: DateTime(2027, 1, 1),
                onDateChanged: (date) {},
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Consultation Slots Today',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
            ),
            const SizedBox(height: 12),
            _buildSlotTile('10:00 AM — 10:30 AM', 'Rahul Sharma', 'Cardiology Checkup', true),
            const SizedBox(height: 12),
            _buildSlotTile('11:15 AM — 11:45 AM', 'Priya Patel', 'Post-Op Follow-up', true),
            const SizedBox(height: 12),
            _buildSlotTile('02:00 PM — 02:30 PM', 'Available', 'Free Slot', false),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotTile(String time, String patient, String purpose, bool occupied) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
              ),
              const SizedBox(height: 4),
              Text(
                '$patient — $purpose',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (occupied ? const Color(0xFF00C853) : const Color(0xFF94A3B8)).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              occupied ? 'Booked' : 'Available',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: occupied ? const Color(0xFF00C853) : const Color(0xFF64748B),
              ),
            ),
          )
        ],
      ),
    );
  }
}
