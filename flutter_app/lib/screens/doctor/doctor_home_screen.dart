import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_buttons.dart';
import '../../core/auth_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  // Active Consult State
  bool _isCopilotExpanded = true;
  bool _showRedAlert = false;
  String _selectedPatient = "Rahul Sharma";
  
  // SOAP Draft Editing State
  final TextEditingController _subjectiveController = TextEditingController(
    text: "Patient presents with mild chest discomfort and fatigue. Describes symptom onset as gradual over the past 24 hours. Admits to slight dyspnea during moderate physical exertion. Speaks Roman Urdu: 'Mujhe kal se halka bukhar hai aur thakan mehsoos ho rahi hai.'",
  );
  final TextEditingController _objectiveController = TextEditingController(
    text: "BP: 120/80 mmHg | HR: 72 bpm (Resting) | SpO2: 99% | Temp: 98.4 °F | ECG: Sinus rhythm with mild non-specific ST changes.",
  );
  final TextEditingController _assessmentController = TextEditingController(
    text: "1. Mild atypical chest pain - rule out cardiac etiology.\n2. Chronic hypertension - controlled.\n3. Clinical confidence score: 92% (Agent 07 verified).",
  );
  final TextEditingController _planController = TextEditingController(
    text: "1. Laboratory ordered: Lipid Profile STAT, CBC.\n2. Cardiology follow-up in 48 hours (automated Agent 06 reminder enabled).\n3. Maintain current Atorvastatin 20mg and Aspirin 75mg regimen.",
  );

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    var data = await AuthService.getDashboard('doctor');
    setState(() {
      _dashboardData = data;
      _isLoading = false;
    });
  }

  void _triggerEmergencyTriage() {
    setState(() {
      _showRedAlert = !_showRedAlert;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.doctorPrimary,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                'AV',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Amit Verma 🩺',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Clinical Copilot Workspace',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency_rounded, color: Colors.white),
            tooltip: 'Simulate Emergency STAT Trigger',
            onPressed: _triggerEmergencyTriage,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          _isLoading ? const Center(child: CircularProgressIndicator()) : _buildBody(),
          if (_showRedAlert) _buildRedAlertOverlay(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.doctorPrimary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), activeIcon: Icon(Icons.psychology_rounded), label: 'AI Copilot'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.mark_email_unread_outlined), activeIcon: Icon(Icons.mark_email_unread), label: 'Alerts'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildCopilotTab();
      case 2:
        return _buildScheduleTab();
      case 3:
        return _buildAlertsTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    int patientsToday = _dashboardData?['metrics']?['patients_today'] ?? 12;
    var appointments = _dashboardData?['appointments'] as List? ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Patients Today',
                value: '$patientsToday',
                icon: Icons.people_outline_rounded,
                color: AppColors.doctorPrimary,
                subtitle: '+3 remaining',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                title: 'STAT Labs Queue',
                value: '02',
                icon: Icons.biotech_rounded,
                color: AppColors.labPrimary,
                subtitle: 'Urgent Action',
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Appointment Queue",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: Text('Launch AI Intake', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.doctorPrimary)),
            )
          ],
        ),
        const SizedBox(height: 16),
        ...appointments.map((apt) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildPatientQueueCard(apt['name'], apt['time'], apt['type'], apt['image_url']),
            )).toList(),
      ],
    );
  }

  Widget _buildCopilotTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clinical Diagnostics Workspace',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              IconButton(
                icon: Icon(_isCopilotExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                onPressed: () => setState(() => _isCopilotExpanded = !_isCopilotExpanded),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Active Patient: $_selectedPatient (Symptom Translation Complete)',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          if (_isCopilotExpanded) ...[
            _buildAgentTracePanel(),
            const SizedBox(height: 24),
          ],
          Text(
            'Interactive SOAP Draft Document',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Subject to physician digital signature before committing to health ledger.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _buildSoapField('Subjective (Patient Narrative & Translation)', _subjectiveController),
          const SizedBox(height: 16),
          _buildSoapField('Objective (Vitals & Document OCR Extracted)', _objectiveController),
          const SizedBox(height: 16),
          _buildSoapField('Assessment (Differential Diagnoses)', _assessmentController),
          const SizedBox(height: 16),
          _buildSoapField('Plan (Actionable Prescriptions & Lab tests)', _planController),
          const SizedBox(height: 32),
          _buildSafetyOverrideCard(),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Sign & Lock SOAP Ledger',
            color: AppColors.doctorPrimary,
            icon: Icons.draw_rounded,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOAP draft successfully locked and appended to patient record timeline!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgentTracePanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brandIndigo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Google Antigravity 7-Agent Traces',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          _buildAgentTraceStep('Agent 01: Intake Translation', 'Translated Roman Urdu to structured English summary.', 'COMPLETED', true),
          _buildAgentTraceStep('Agent 02: Clinical Reasoning', 'Flagged non-specific ECG ST changes. Risk score high.', 'COMPLETED', true),
          _buildAgentTraceStep('Agent 03: Drug Safety Guardian', 'Checked clashing meds. Hard-block triggered for NSAID.', 'ACTION REQUIRED', false),
          _buildAgentTraceStep('Agent 04: Lab Coordinator', 'Pre-filled Lipid Profile STAT and basic blood panel orders.', 'COMPLETED', true),
          _buildAgentTraceStep('Agent 05: Epidemiology Agent', 'Monitored regional cardiovascular telemetry levels.', 'COMPLETED', true),
          _buildAgentTraceStep('Agent 06: Follow-Up Monitoring', 'Configured recovery text reminders in 48h.', 'COMPLETED', true),
          _buildAgentTraceStep('Agent 07: Verification & Safety', 'Assembled consolidated clinical SOAP Note draft.', 'COMPLETED', true),
        ],
      ),
    );
  }

  Widget _buildAgentTraceStep(String name, String action, String status, bool success) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            success ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: success ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  action,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: success ? Colors.white12 : AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: success ? Colors.white : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoapField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.inter(fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildSafetyOverrideCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gpp_maybe_rounded, color: AppColors.warning, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drug Safety Interlock Triggered',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Agent 03 has flagged potential interaction between newly drafted pain suppressants and existing Cardioprotective Aspirin regimen. A formal override justification is required to publish.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Physician digital override verified.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.lock_open_rounded, size: 18),
                  label: const Text('Publish Safety Override Reason'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_rounded, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('Clinical Scheduler Offline', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Connect to local clinical registry.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Emergency Workspace Alerts',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildAlertTile('EMERGENCY RED ALERT', 'Rahul Sharma submitted symptoms matching cardiac crisis: Chest pain & shortness of breath.', '1 min ago', AppColors.error),
        const SizedBox(height: 12),
        _buildAlertTile('Pathology Update STAT', 'Lipid Profile STAT results processed for Patient Priya Patel.', '12 mins ago', AppColors.warning),
      ],
    );
  }

  Widget _buildAlertTile(String title, String desc, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: color)),
                Text(desc, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildPatientQueueCard(String name, String time, String type, String img) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(img), radius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(type, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedPatient = name;
                _currentIndex = 1; // Launch AI Copilot view
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.doctorLight,
              foregroundColor: AppColors.doctorPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Inspect', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRedAlertOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.emergencyRed, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.report_problem_rounded, color: AppColors.emergencyRed, size: 64),
              const SizedBox(height: 16),
              Text(
                'CRITICAL EMERGENCY STAT',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.emergencyRed),
              ),
              const SizedBox(height: 12),
              Text(
                'Intake Agent 01 detected cardiac crisis trigger terms ("chest pain", "shortness of breath") from Patient Rahul Sharma.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.textPrimary, height: 1.4),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Acknowledge & Launch Triage',
                color: AppColors.emergencyRed,
                onPressed: () {
                  setState(() {
                    _showRedAlert = false;
                    _currentIndex = 1; // Direct to AI Copilot
                  });
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Dismiss Alert',
                color: AppColors.textSecondary,
                onPressed: () => setState(() => _showRedAlert = false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

