import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class PatientTimelineScreen extends StatelessWidget {
  const PatientTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated Timeline Events matching PANOR multi-agent clinical flow
    final List<Map<String, dynamic>> timelineEvents = [
      {
        'date': 'May 19, 2026',
        'time': '12:45 PM',
        'title': 'Emergency Cardiac Alert STAT',
        'category': 'EMERGENCY',
        'color': AppColors.emergencyRed,
        'icon': Icons.report_problem_rounded,
        'description': 'Intake translation flagged chest pain and shortness of breath (Roman Urdu: "seene me dard aur thakan"). Triggered automatic doctor triage and order authorize.',
        'doctor': 'Dr. Amit Verma',
      },
      {
        'date': 'May 18, 2026',
        'time': '03:15 PM',
        'title': 'Pathology Specimen Completed',
        'category': 'LAB REPORT',
        'color': AppColors.labPrimary,
        'icon': Icons.biotech_rounded,
        'description': 'Serum Troponin I (0.08 ng/mL - HIGH) and Lipid Panel processed and synced to ledger. Flagged for physician signature.',
        'doctor': 'Lab Tech Workspace',
      },
      {
        'date': 'May 17, 2026',
        'time': '10:00 AM',
        'title': 'Drug Safety Ledger Clearance',
        'category': 'PRESCRIPTION',
        'color': AppColors.success,
        'icon': Icons.gpp_good_rounded,
        'description': 'Agent 03 completed safety verification. Overruled conflict between pain suppressants and cardioprotective aspirin regimen. Verified by Dr. Amit Verma.',
        'doctor': 'Dr. Amit Verma',
      },
      {
        'date': 'May 12, 2026',
        'time': '09:00 AM',
        'title': 'Clinical SOAP Note Locked',
        'category': 'CONSULTATION',
        'color': AppColors.brandIndigo,
        'icon': Icons.history_edu_rounded,
        'description': 'Routine hypertension checkup completed. Digital signature applied. SOAP ledger block: #SOAP-1092-A.',
        'doctor': 'Dr. Amit Verma',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Chronological Medical Ledger',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: timelineEvents.length,
          itemBuilder: (context, index) {
            final event = timelineEvents[index];
            final bool isLast = index == timelineEvents.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon column with lines
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (event['color'] as Color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: (event['color'] as Color).withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: Icon(
                          event['icon'] as IconData,
                          color: event['color'] as Color,
                          size: 20,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: AppColors.border,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Content Card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (event['color'] as Color).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    event['category'],
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: event['color'] as Color,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${event['date']} • ${event['time']}',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event['title'],
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event['description'],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  'Authorized by: ${event['doctor']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
}
