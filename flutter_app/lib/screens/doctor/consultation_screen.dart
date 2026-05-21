import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/ai_provider.dart';
import '../../theme/app_colors.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  _ConsultationScreenState createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final TextEditingController _complaintCtrl = TextEditingController();

  void _runConsultation() async {
    final complaint = _complaintCtrl.text.trim();
    if (complaint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter patient complaints or diagnostic narrations')),
      );
      return;
    }

    final aiProv = Provider.of<AIProvider>(context, listen: false);
    await aiProv.runClinicalConsultation(complaint);
    _complaintCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final aiProv = Provider.of<AIProvider>(context);
    final consultation = aiProv.latestConsultation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Clinical SOAP Consultation',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Clinical History & Complaints',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _complaintCtrl,
              maxLines: 5,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter complete objective narratives, somatic pain locations, durations, and vitals updates...',
                hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.doctorPrimary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.doctorGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.primaryButtonShadow(AppColors.doctorPrimary),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: aiProv.isLoading ? null : _runConsultation,
                  icon: aiProv.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : const Icon(Icons.psychology, color: Colors.white),
                  label: Text(
                    aiProv.isLoading ? 'Antigravity Reasoning Active...' : 'Generate SOAP Differential',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            if (consultation != null) ...[
              _buildClinicalSOAPOutcomes(consultation),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No consultation outcomes generated yet.',
                        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalSOAPOutcomes(Map<String, dynamic> data) {
    final finalState = data['final_state'] as Map? ?? {};
    final soap = finalState['soap_note'] as Map? ?? {};
    final recommendedLabs = finalState['recommended_labs'] as List? ?? [];
    final prescriptions = finalState['prescriptions'] as List? ?? [];
    final traces = data['traces'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.doctorAccent, size: 22),
              const SizedBox(width: 8),
              Text(
                'Antigravity Consultation Output',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),

          if (soap.isNotEmpty) ...[
            _soapItem('Subjective Summary', soap['subjective']?.toString() ?? 'N/A'),
            _soapItem('Objective History Summary', soap['objective']?.toString() ?? 'N/A'),
            _soapItem('Clinical Assessment', soap['assessment']?.toString() ?? 'N/A'),
            _soapItem('Treatment Plan', soap['plan']?.toString() ?? 'N/A'),
          ],

          if (prescriptions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.medication_outlined, color: AppColors.success, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Prescriptions Approved:',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...prescriptions.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          if (recommendedLabs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.biotech_outlined, color: AppColors.doctorAccent, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Recommended Lab Work:',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...recommendedLabs.map((l) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.science_outlined, color: AppColors.doctorAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          const Divider(height: 32, color: AppColors.border),

          Text(
            'Google Antigravity Traces Logs',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: traces.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tr = traces[index] as Map;
              final double confidence = (tr['confidence'] as num? ?? 1.0).toDouble();
              final percentage = (confidence * 100).toInt();

              return Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  unselectedWidgetColor: AppColors.textSecondary,
                ),
                child: ExpansionTile(
                  backgroundColor: AppColors.surfaceVariant,
                  collapsedBackgroundColor: AppColors.surfaceVariant,
                  textColor: Colors.white,
                  collapsedTextColor: AppColors.textSecondary,
                  iconColor: AppColors.doctorAccent,
                  collapsedIconColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr['agent']?.toString() ?? 'Agent',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.doctorAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.doctorAccent.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '$percentage% Conf.',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.doctorAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reasoning Steps:',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          ...((tr['reasoning'] as List? ?? []).map((step) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(color: AppColors.doctorAccent)),
                                    Expanded(
                                      child: Text(
                                        step,
                                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ))),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _soapItem(String title, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
