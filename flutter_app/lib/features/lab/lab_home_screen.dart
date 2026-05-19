import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_buttons.dart';

class LabHomeScreen extends StatefulWidget {
  const LabHomeScreen({super.key});

  @override
  State<LabHomeScreen> createState() => _LabHomeScreenState();
}

class _LabHomeScreenState extends State<LabHomeScreen> {
  int _currentIndex = 0;
  final bool _isLoading = false;

  // Lab Queue state
  final List<Map<String, dynamic>> _labTests = [
    {
      'id': 'LAB-4029',
      'patient': 'Rahul Sharma',
      'test_name': 'Lipid Profile STAT',
      'priority': 'STAT',
      'status': 'Pending Specimen',
      'ordered_by': 'Dr. Amit Verma',
      'time': '10 mins ago',
    },
    {
      'id': 'LAB-4030',
      'patient': 'Priya Patel',
      'test_name': 'Complete Blood Count (CBC)',
      'priority': 'Routine',
      'status': 'Specimen Collected',
      'ordered_by': 'Dr. Amit Verma',
      'time': '30 mins ago',
    }
  ];

  // Upload state variables
  final _cholesterolController = TextEditingController(text: '240'); // Borderline high
  final _hdlController = TextEditingController(text: '45');
  final _ldlController = TextEditingController(text: '160');
  final _triglyceridesController = TextEditingController(text: '175');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.labPrimary,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                'LT',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lab Workspace 🧪',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Pathology Operations',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () {
              context.go('/role-selection');
            },
          )
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.labPrimary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.queue_outlined), activeIcon: Icon(Icons.queue), label: 'Test Queue'),
          BottomNavigationBarItem(icon: Icon(Icons.science_outlined), activeIcon: Icon(Icons.science), label: 'Specimen'),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file_outlined), activeIcon: Icon(Icons.upload_file), label: 'Upload Results'),
          BottomNavigationBarItem(icon: Icon(Icons.notification_important_outlined), activeIcon: Icon(Icons.notification_important), label: 'Escalations'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildQueueTab();
      case 1:
        return _buildSpecimenTab();
      case 2:
        return _buildUploadTab();
      case 3:
        return _buildEscalationsTab();
      default:
        return _buildQueueTab();
    }
  }

  Widget _buildQueueTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Operational Laboratory Queue',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Dispatched by Agent 04. STAT orders require instantaneous processing.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        ..._labTests.map((test) => _buildTestQueueCard(test)),
      ],
    );
  }

  Widget _buildSpecimenTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Specimen Accessioning', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Scan, verify, and register patient blood specimens.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          _buildSpecimenStepCard('1. Verify Identity', 'Verify patient barcode match: Rahul Sharma (PAN-5092-RS).', Icons.verified_user_rounded),
          const SizedBox(height: 16),
          _buildSpecimenStepCard('2. Tube Selection', 'Select SST Amber Gold gel separator tube.', Icons.opacity_rounded),
          const SizedBox(height: 16),
          _buildSpecimenStepCard('3. Accession Specimen', 'Scan specimen tube barcode to bind with order LAB-4029.', Icons.qr_code_scanner_rounded),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Accession & Collect Complete',
            color: AppColors.labPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Specimen registered in digital ledger! Dispatched to testing pool.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Input Diagnostic Metrics', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Active Order: LAB-4029 (Lipid Profile STAT) • Rahul Sharma', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          _buildNumericField('Total Cholesterol (mg/dL)', _cholesterolController),
          const SizedBox(height: 16),
          _buildNumericField('HDL Cholesterol (mg/dL)', _hdlController),
          const SizedBox(height: 16),
          _buildNumericField('LDL Cholesterol (mg/dL)', _ldlController),
          const SizedBox(height: 16),
          _buildNumericField('Triglycerides (mg/dL)', _triglyceridesController),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Verify & Release Report',
            color: AppColors.labPrimary,
            onPressed: () {
              // Analyze inputs
              final chol = double.tryParse(_cholesterolController.text) ?? 0;
              if (chol > 200) {
                // Out of bound warning
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Alert: High cholesterol detected. Agent 02 & Doctor Amit Verma auto-notified!'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Diagnostic report successfully released to patient clinical ledger!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Critical Alert Escalations',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.emergencyRedLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emergency_rounded, color: AppColors.emergencyRed),
                  const SizedBox(width: 12),
                  Text(
                    'CRITICAL OUT-OF-BOUNDS',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.emergencyRed),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Patient Rahul Sharma: Lipid Cholesterol checked at 240 mg/dL (STAT Threshold limit breached). Automated routing completed.',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'Dispatched to Doctor Amit Verma dashboard queue.',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emergencyRed),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestQueueCard(Map<String, dynamic> test) {
    final isStat = test['priority'] == 'STAT';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(test['id'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isStat ? AppColors.warningLight : AppColors.patientLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  test['priority'],
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isStat ? AppColors.warning : AppColors.patientPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(test['test_name'], style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Patient: ${test['patient']} • Ordered by: ${test['ordered_by']}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(test['status'], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 2; // Route to upload results page
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.labLight,
                  foregroundColor: AppColors.labPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Process Specimen', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecimenStepCard(String step, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.labLight, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.labPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(desc, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNumericField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

