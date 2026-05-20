import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/role_switcher.dart';
import '../../core/auth_service.dart';

class LabHomeScreen extends StatefulWidget {
  const LabHomeScreen({super.key});

  @override
  State<LabHomeScreen> createState() => _LabHomeScreenState();
}

class _LabHomeScreenState extends State<LabHomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _pendingTests = [
    {'test': 'ECG (12-Lead)', 'patient': 'Ahmed Raza', 'pid': 'PAK-****-0001', 'doctor': 'Dr. Fatima Hassan', 'priority': 'STAT', 'ordered': '20 May 2026, 10:15 AM', 'intent': 'Rule out acute coronary syndrome. ST changes on prior ECG.', 'deadline': '30 min'},
    {'test': 'Troponin-I (Serial x3)', 'patient': 'Ahmed Raza', 'pid': 'PAK-****-0001', 'doctor': 'Dr. Fatima Hassan', 'priority': 'STAT', 'ordered': '20 May 2026, 10:15 AM', 'intent': 'Serial troponin trend at 0h, 3h, 6h. Detect myocardial injury.', 'deadline': '45 min'},
    {'test': 'CBC + BMP', 'patient': 'Ahmed Raza', 'pid': 'PAK-****-0001', 'doctor': 'Dr. Fatima Hassan', 'priority': 'URGENT', 'ordered': '20 May 2026, 10:16 AM', 'intent': 'Baseline metabolic panel. Check renal function for Metformin safety.', 'deadline': '2 hrs'},
    {'test': 'HbA1c', 'patient': 'Zara Tariq', 'pid': 'PAK-****-0072', 'doctor': 'Dr. Usman Ali', 'priority': 'ROUTINE', 'ordered': '19 May 2026', 'intent': 'Quarterly diabetes monitoring. Previous: 7.2%.', 'deadline': '24 hrs'},
    {'test': 'TSH', 'patient': 'Sadia Akhtar', 'pid': 'PAK-****-0103', 'doctor': 'Dr. Ayesha Siddiqui', 'priority': 'ROUTINE', 'ordered': '19 May 2026', 'intent': 'Annual thyroid screening. No prior results.', 'deadline': '24 hrs'},
  ];

  final List<Map<String, dynamic>> _completedTests = [
    {'test': 'Lipid Panel', 'patient': 'Ahmed Raza', 'result': 'TC: 240 (H), LDL: 148 (H), HDL: 42 (L), TG: 190 (H)', 'date': '10 May 2026', 'flagged': true, 'critical': false},
    {'test': 'HbA1c', 'patient': 'Bilal Hussain', 'result': '6.4% (Normal)', 'date': '8 May 2026', 'flagged': false, 'critical': false},
    {'test': 'CBC', 'patient': 'Imran Shah', 'result': 'WBC: 11.2 (H), Hb: 12.8, Plt: 245', 'date': '7 May 2026', 'flagged': true, 'critical': false},
    {'test': 'Troponin-I', 'patient': 'Farhan Malik', 'result': '0.04 ng/mL (Normal)', 'date': '5 May 2026', 'flagged': false, 'critical': false},
    {'test': 'CRP', 'patient': 'Ahmed Raza', 'result': '15.8 mg/L (HIGH)', 'date': '3 May 2026', 'flagged': true, 'critical': true},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.labPrimary.withValues(alpha: 0.3), width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.labPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_rounded, color: AppColors.labPrimary),
              ),
              const SizedBox(width: 12),
              Text(
                'Workspace Settings',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PANOR Laboratory Diagnostics Space',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSettingToggle('Auto-Analyzer Sync', true, 'Synchronize diagnostic machines directly with patient records'),
                _buildSettingToggle('Critical High Flags', true, 'Auto-notify doctor if Troponin or glucose exceeds limits'),
                _buildSettingToggle('Biometric Access Control', true, 'Require biometrics for unlocking toxicological inputs'),
                _buildSettingToggle('STAT Sound Alerts', true, 'Play distinct emergency alert when high-priority test arrives'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.surface,
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text('Lab workspace settings updated successfully', style: GoogleFonts.inter(color: Colors.white)),
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.labPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Save Changes',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.emergencyRed, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emergencyRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.emergencyRed),
              ),
              const SizedBox(width: 12),
              Text(
                'Confirm Secure Logout',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to end this clinical session? To access this medical timeline or other roles again, you must perform a secure authentication.',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/role-selection');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Secure Logout',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingToggle(String title, bool val, String description) {
    bool localVal = val;
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(description, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              Switch(
                value: localVal,
                activeThumbColor: AppColors.labPrimary,
                onChanged: (newVal) {
                  setDialogState(() {
                    localVal = newVal;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.labGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.labPrimary.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.labPrimary.withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(child: Text('SM', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sana Malik', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                  Row(
                    children: [
                      Icon(Icons.verified_rounded, color: AppColors.success, size: 12),
                      const SizedBox(width: 4),
                      Text('Lab Assistant | PANOR Central Lab', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.white), onPressed: () {}),
              Positioned(right: 8, top: 8, child: Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppColors.emergencyRed, shape: BoxShape.circle), child: Center(child: Text('2', style: GoogleFonts.inter(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold))))),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildBody(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppColors.labPrimary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.pending_actions_outlined), activeIcon: Icon(Icons.pending_actions), label: 'Pending'),
            BottomNavigationBarItem(icon: Icon(Icons.upload_file_outlined), activeIcon: Icon(Icons.upload_file), label: 'Input'),
            BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), activeIcon: Icon(Icons.check_circle), label: 'Completed'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildPendingTab();
      case 1: return _buildInputTab();
      case 2: return _buildCompletedTab();
      case 3: return _buildLabProfileTab();
      default: return _buildPendingTab();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: PENDING — Lab Requests from Doctors
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPendingTab() {
    final statTests = _pendingTests.where((t) => t['priority'] == 'STAT').toList();
    final urgentTests = _pendingTests.where((t) => t['priority'] == 'URGENT').toList();
    final routineTests = _pendingTests.where((t) => t['priority'] == 'ROUTINE').toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Stats summary
        Row(
          children: [
            _buildLabStat('STAT', '${statTests.length}', AppColors.emergencyRed),
            const SizedBox(width: 10),
            _buildLabStat('URGENT', '${urgentTests.length}', AppColors.warning),
            const SizedBox(width: 10),
            _buildLabStat('ROUTINE', '${routineTests.length}', AppColors.success),
            const SizedBox(width: 10),
            _buildLabStat('Total', '${_pendingTests.length}', AppColors.labPrimary),
          ],
        ),
        const SizedBox(height: 24),

        if (statTests.isNotEmpty) ...[
          _buildPriorityHeader('STAT — Immediate', AppColors.emergencyRed),
          ...statTests.map((t) => _buildTestRequestCard(t)),
          const SizedBox(height: 16),
        ],
        if (urgentTests.isNotEmpty) ...[
          _buildPriorityHeader('URGENT — 2 Hours', AppColors.warning),
          ...urgentTests.map((t) => _buildTestRequestCard(t)),
          const SizedBox(height: 16),
        ],
        if (routineTests.isNotEmpty) ...[
          _buildPriorityHeader('ROUTINE — 24 Hours', AppColors.success),
          ...routineTests.map((t) => _buildTestRequestCard(t)),
        ],
      ],
    );
  }

  Widget _buildLabStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityHeader(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTestRequestCard(Map<String, dynamic> t) {
    Color prioColor;
    switch (t['priority']) {
      case 'STAT': prioColor = AppColors.emergencyRed; break;
      case 'URGENT': prioColor = AppColors.warning; break;
      default: prioColor = AppColors.success;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: prioColor, width: 3.5),
          top: const BorderSide(color: AppColors.border, width: 1),
          right: const BorderSide(color: AppColors.border, width: 1),
          bottom: const BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: prioColor.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(t['test'], style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: prioColor, borderRadius: BorderRadius.circular(5)),
                child: Text(t['priority'], style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_rounded, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${t['patient']} (${t['pid']})', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.medical_services_rounded, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('Ordered by: ${t['doctor']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          // Clinical Intent from Agent 04
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brandPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.brandPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Clinical Intent (Agent 04)', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.brandPurple, letterSpacing: 0.3)),
                      Text(t['intent'], style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.timer_rounded, size: 14, color: prioColor),
              const SizedBox(width: 4),
              Text('Deadline: ${t['deadline']}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: prioColor)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.labGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: AppColors.primaryButtonShadow(AppColors.labPrimary),
                  ),
                  child: Text('Process', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: INPUT — Enter Results
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInputTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Enter Lab Results', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('AI will auto-detect abnormal ranges and flag critical values.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        // Selected test info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.labPrimary.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: AppColors.labPrimary.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.emergencyRed, borderRadius: BorderRadius.circular(5)),
                    child: Text('STAT', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  Text('Troponin-I (Serial)', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Patient: Ahmed Raza (PAK-****-0001)', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              Text('Ordered by: Dr. Fatima Hassan', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Result input fields
        _buildResultField('Troponin-I (0h)', 'ng/mL', 'Normal: < 0.04', _troponinController0h),
        _buildResultField('Troponin-I (3h)', 'ng/mL', 'Normal: < 0.04', _troponinController3h),
        _buildResultField('Troponin-I (6h)', 'ng/mL', 'Normal: < 0.04', _troponinController6h),
        const SizedBox(height: 12),
        _buildResultField('Specimen Quality', '', 'Select', _specimenController, isDropdown: true),
        const SizedBox(height: 20),

        // Critical value alert
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.emergencyRed.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_rounded, color: AppColors.emergencyRed, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto-Escalation Rule', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.emergencyRed)),
                    Text('If Troponin-I > 0.04 ng/mL, Agent 04 will immediately notify Dr. Fatima Hassan and flag RED cardiac alert.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Results submitted. Syncing to Doctor + Patient records via Agent 04.'),
                backgroundColor: AppColors.success,
              ));
              setState(() => _currentIndex = 2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.labPrimary,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ).copyWith(
              backgroundColor: WidgetStateProperty.all(AppColors.labPrimary),
            ),
            child: Text('Submit & Verify Results', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  final _troponinController0h = TextEditingController();
  final _troponinController3h = TextEditingController();
  final _troponinController6h = TextEditingController();
  final _specimenController = TextEditingController(text: 'Satisfactory');

  Widget _buildResultField(String label, String unit, String hint, TextEditingController controller, {bool isDropdown = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          if (isDropdown)
            DropdownButton<String>(
              value: controller.text,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: AppColors.surface,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              items: ['Satisfactory', 'Hemolyzed', 'Lipemic', 'Insufficient'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => controller.text = v!),
            )
          else
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                suffixText: unit,
                suffixStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: COMPLETED — Test History
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCompletedTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Completed Tests', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('All verified and synced to patient timelines.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        ..._completedTests.map((t) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t['critical'] ? AppColors.emergencyRed.withValues(alpha: 0.3) : AppColors.border),
            boxShadow: [
              BoxShadow(
                color: (t['critical'] ? AppColors.emergencyRed : AppColors.success).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(t['critical'] ? Icons.emergency_rounded : Icons.check_circle_rounded, color: t['critical'] ? AppColors.emergencyRed : AppColors.success, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(t['test'], style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))),
                  if (t['flagged']) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text('FLAGGED', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.warning)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Patient: ${t['patient']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                child: Text(t['result'], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(t['date'], style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                  const Spacer(),
                  const Icon(Icons.lock_rounded, size: 11, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('Verified & Locked', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 4: LAB PROFILE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLabProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.labGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.labPrimary.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white38, width: 2)),
                child: Center(child: Text('SM', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
              const SizedBox(height: 12),
              Text('Sana Malik', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Senior Lab Technician', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 4),
              Text('PANOR Central Pathology Lab, Lahore', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            _buildLabProfileStat('Tests Today', '12'),
            const SizedBox(width: 12),
            _buildLabProfileStat('Completed', '${_completedTests.length}'),
            const SizedBox(width: 12),
            _buildLabProfileStat('Pending', '${_pendingTests.length}'),
          ],
        ),
        const SizedBox(height: 20),

        _buildLabProfileRow(Icons.school_rounded, 'Qualification', 'BSc MLT (Lahore College)'),
        _buildLabProfileRow(Icons.badge_rounded, 'Employee ID', 'PANOR-LAB-0042'),
        _buildLabProfileRow(Icons.access_time_rounded, 'Shift', 'Morning: 8:00 AM - 4:00 PM'),
        _buildLabProfileRow(Icons.local_hospital_rounded, 'Facility', 'PANOR Central Pathology Lab'),
        _buildLabProfileRow(Icons.location_on_rounded, 'Location', 'Johar Town, Lahore'),
        _buildLabProfileRow(Icons.science_rounded, 'Specialization', 'Clinical Biochemistry'),
        _buildLabProfileRow(Icons.calendar_today_rounded, 'Joined', '15 March 2025'),
      ],
    );
  }

  Widget _buildLabProfileStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.labPrimary)),
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabProfileRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.labPrimary),
          const SizedBox(width: 14),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
