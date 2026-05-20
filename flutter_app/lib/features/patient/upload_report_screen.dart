import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../core/widgets/panor_widgets.dart';

class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({super.key});

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  bool _isUploading = false;
  double _progress = 0.0;
  bool _parseComplete = false;
  String? _selectedFileName;
  Timer? _uploadTimer;

  // Extracted Data Mock
  final Map<String, dynamic> _extractedReport = {
    'patient': 'Ahmed Raza',
    'lab': 'PANOR Central Pathology Lab, Lahore',
    'date': 'May 19, 2026',
    'parameters': [
      {'name': 'Serum Troponin I', 'value': '0.08 ng/mL', 'reference': '< 0.04 ng/mL', 'status': 'HIGH', 'color': AppColors.emergencyRed},
      {'name': 'Total Cholesterol', 'value': '245 mg/dL', 'reference': '< 200 mg/dL', 'status': 'ELEVATED', 'color': AppColors.warning},
      {'name': 'Hemoglobin (Hb)', 'value': '14.2 g/dL', 'reference': '13.5 - 17.5 g/dL', 'status': 'NORMAL', 'color': AppColors.success},
    ],
    'confidence': '98.5%',
  };

  void _simulateUpload() {
    setState(() {
      _selectedFileName = 'Serum_Lipid_STAT_10928.pdf';
      _isUploading = true;
      _progress = 0.0;
      _parseComplete = false;
    });

    _uploadTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.05;
        } else {
          _isUploading = false;
          _parseComplete = true;
          _uploadTimer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _uploadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Clinical OCR Report Parse',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Pathology Records',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Google Antigravity automatically extracts quantitative vitals, diagnostic values, and maps clinical history.',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 28),
              
              // Drop Zone / Upload Area
              GestureDetector(
                onTap: _isUploading ? null : _simulateUpload,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isUploading ? AppColors.patientPrimary : AppColors.border,
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.patientPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _parseComplete
                              ? Icons.check_circle_rounded
                              : Icons.cloud_upload_outlined,
                          color: _parseComplete ? AppColors.success : AppColors.patientPrimary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFileName ?? 'Drag & Drop PDF or Image Report',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isUploading
                            ? 'AI Agent 01 running clinical tokenization...'
                            : (_parseComplete ? 'Extraction Complete!' : 'Supports PDF, JPEG, PNG up to 15MB'),
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      if (_isUploading) ...[
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.patientPrimary),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Extraction Output Panel
              if (_parseComplete) ...[
                Text(
                  'Extracted Ledger Tokens',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _extractedReport['lab'],
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sample ID: LAB-STAT-772 • ${_extractedReport['date']}',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Confidence: ${_extractedReport['confidence']}',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Loop through extracted parameters
                      ...(_extractedReport['parameters'] as List).map((param) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      param['name'],
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                    Text(
                                      'Reference: ${param['reference']}',
                                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  param['value'],
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (param['color'] as Color).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  param['status'],
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: param['color'] as Color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ClinicalButton(
                  label: 'Commit to Health Ledger & Notify Doctor',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report successfully tokenized, committed to Ledger, and matched with Dr. Fatima Hassan.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
