import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/ai_provider.dart';

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
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Clinical SOAP Consultation',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Clinical History & Complaints',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _complaintCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter complete objective narratives, somatic pain locations, durations, and vitals updates...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
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
                    : const Icon(Icons.psychology),
                label: Text(
                  aiProv.isLoading ? 'Antigravity Reasoning Active...' : 'Generate SOAP differential',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 32),

            if (consultation != null) ...[
              _buildClinicalSOAPOutcomes(consultation),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No consultation outcomes generated yet.',
                    style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: Color(0xFF00C853), size: 22),
              const SizedBox(width: 8),
              Text(
                'Antigravity Consultation Output',
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          if (soap.isNotEmpty) ...[
            _soapItem('Subjective Summary', soap['subjective']?.toString() ?? 'N/A'),
            _soapItem('Objective History Summary', soap['objective']?.toString() ?? 'N/A'),
            _soapItem('Clinical Assessment', soap['assessment']?.toString() ?? 'N/A'),
            _soapItem('Treatment Plan', soap['plan']?.toString() ?? 'N/A'),
          ],

          if (prescriptions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Prescriptions Approved:',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
            ),
            const SizedBox(height: 6),
            ...prescriptions.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('- $m', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                )),
          ],

          if (recommendedLabs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Recommended Lab Work:',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
            ),
            const SizedBox(height: 6),
            ...recommendedLabs.map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('- $l', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                )),
          ],

          const Divider(height: 32, color: Color(0xFFF1F5F9)),

          Text(
            'Google Antigravity Traces Logs',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
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

              return ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr['agent']?.toString() ?? 'Agent',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0A1628)),
                    ),
                    Text(
                      '$percentage% confidence',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF00C853), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reasoning Steps:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        ...((tr['reasoning'] as List? ?? []).map((e) => Text('- $e', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))))),
                      ],
                    ),
                  )
                ],
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
          Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628))),
          const SizedBox(height: 4),
          Text(val, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.4)),
        ],
      ),
    );
  }
}
