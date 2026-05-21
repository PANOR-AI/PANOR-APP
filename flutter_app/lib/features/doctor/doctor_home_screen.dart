import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/emergency_banner.dart';
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
  bool _onboardSearching = false;
  final TextEditingController _pidController = TextEditingController();
  String? _selectedPatientId;

  // Patient Queue
  final List<Map<String, dynamic>> _patientQueue = [
    {'name': 'Ahmed Raza', 'pid': 'PAK-HEALTH-2026-0001', 'age': '52M', 'risk': 'CRITICAL', 'chief': 'Chest pain + fever + dyspnea', 'conditions': ['T2DM', 'HTN'], 'waiting': '12 min', 'status': 'In Queue'},
    {'name': 'Bilal Hussain', 'pid': 'PAK-HEALTH-2026-0034', 'age': '38M', 'risk': 'MODERATE', 'chief': 'Persistent cough x 2 weeks', 'conditions': ['Asthma'], 'waiting': '25 min', 'status': 'In Queue'},
    {'name': 'Zara Tariq', 'pid': 'PAK-HEALTH-2026-0072', 'age': '29F', 'risk': 'LOW', 'chief': 'Routine diabetes follow-up', 'conditions': ['T1DM'], 'waiting': '40 min', 'status': 'Scheduled'},
    {'name': 'Imran Shah', 'pid': 'PAK-HEALTH-2026-0088', 'age': '65M', 'risk': 'HIGH', 'chief': 'Uncontrolled BP + dizziness', 'conditions': ['HTN', 'CKD Stage 3'], 'waiting': '5 min', 'status': 'In Queue'},
  ];

  // Schedule
  final List<Map<String, dynamic>> _schedule = [
    {'time': '09:00 AM', 'patient': 'Imran Shah', 'type': 'Follow-Up', 'status': 'Completed'},
    {'time': '10:00 AM', 'patient': 'Ahmed Raza', 'type': 'Emergency', 'status': 'In Progress'},
    {'time': '11:30 AM', 'patient': 'Bilal Hussain', 'type': 'New Visit', 'status': 'Upcoming'},
    {'time': '02:00 PM', 'patient': 'Zara Tariq', 'type': 'Follow-Up', 'status': 'Upcoming'},
    {'time': '03:30 PM', 'patient': 'Sadia Akhtar', 'type': 'New Visit', 'status': 'Upcoming'},
    {'time': '04:30 PM', 'patient': 'Farhan Malik', 'type': 'Follow-Up', 'status': 'Upcoming'},
  ];

  // Agent traces for AI Copilot
  final List<Map<String, dynamic>> _agentTraces = [
    {'agent': 'Agent 01: Intake Intelligence', 'status': 'COMPLETED', 'time': '0.8s', 'result': 'Extracted 3 symptoms from Roman Urdu. Language: ur-PK. Entities: chest_pain, fever, dyspnea.'},
    {'agent': 'Agent 02: Clinical Reasoning', 'status': 'COMPLETED', 'time': '2.3s', 'result': 'Differential: Acute Coronary Syndrome (94%), Unstable Angina (78%), Myocarditis (34%). RED Flag: Cardiac ischemia risk.'},
    {'agent': 'Agent 03: Drug Safety', 'status': 'ALERT', 'time': '0.4s', 'result': 'BLOCKED: NSAIDs contraindicated with Metformin. ALLOW: Paracetamol, Nitroglycerin. WARN: Aspirin dose adjustment.'},
    {'agent': 'Agent 04: Lab Coordination', 'status': 'COMPLETED', 'time': '0.6s', 'result': 'Ordered: STAT ECG, Troponin-I (serial), CBC, BMP, Lipid Panel. Priority: STAT.'},
    {'agent': 'Agent 05: Epidemiology', 'status': 'COMPLETED', 'time': '1.1s', 'result': 'No regional cardiac cluster detected. Dengue activity in Lahore South (low relevance to case).'},
    {'agent': 'Agent 06: Follow-Up', 'status': 'PENDING', 'time': '--', 'result': 'Awaiting lab results for activation. Will monitor troponin trend at 3h and 6h.'},
    {'agent': 'Agent 07: Verification', 'status': 'COMPLETED', 'time': '0.9s', 'result': 'Confidence: 94%. No contradictions. SOAP notes generated. Human review recommended for prescription.'},
  ];

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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.doctorPrimary.withValues(alpha: 0.3), width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.doctorPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_rounded, color: AppColors.doctorPrimary),
              ),
              const SizedBox(width: 12),
              Text(
                'Clinical Settings',
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
                  'PANOR Clinical Intelligence Space',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSettingToggle('Differential Diagnoses', true, 'Enable live multi-agent differential suggestions'),
                _buildSettingToggle('Drug-Drug Interactions', true, 'Enforce real-time contraindication validation'),
                _buildSettingToggle('Auto SOAP Notes', true, 'Generate structured summaries from voice/Urdu input'),
                _buildSettingToggle('Priority STAT Routing', true, 'Automatically elevate critical ECG/Troponin tests'),
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
                        Text('Clinical settings updated successfully', style: GoogleFonts.inter(color: Colors.white)),
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.doctorPrimary,
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
                activeThumbColor: AppColors.doctorPrimary,
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
                gradient: AppColors.doctorGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.doctorPrimary.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.doctorPrimary.withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(child: Text('FH', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dr. Fatima Hassan', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                  Row(
                    children: [
                      Icon(Icons.verified_rounded, color: AppColors.success, size: 12),
                      const SizedBox(width: 4),
                      Text('Cardiologist | PMDC #42891', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
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
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          // Emergency banner
          EmergencyBanner(
            patientName: 'Ahmed Raza',
            condition: 'Acute Cardiac Risk — RED Alert',
            confidencePercent: 94,
            detectedAt: '10 mins ago',
            requiredAction: 'Immediate ECG and Troponin T lab workup',
            onAcknowledge: () {},
          ),
          Expanded(child: _buildBody()),
        ],
      ),
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
          selectedItemColor: AppColors.doctorPrimary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), activeIcon: Icon(Icons.people_rounded), label: 'Patients'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), activeIcon: Icon(Icons.psychology), label: 'AI Copilot'),
            BottomNavigationBarItem(icon: Icon(Icons.science_outlined), activeIcon: Icon(Icons.science), label: 'Labs'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildPatientsTab();
      case 1: return _buildScheduleTab();
      case 2: return _buildAiCopilotTab();
      case 3: return _buildLabsTab();
      case 4: return _buildDoctorProfileTab();
      default: return _buildPatientsTab();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: PATIENTS — Queue + Onboarding
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPatientsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Onboard patient by P_ID
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.doctorPrimary.withValues(alpha: 0.08), AppColors.doctorPrimary.withValues(alpha: 0.02)]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.doctorPrimary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_add_rounded, color: AppColors.doctorPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text('Onboard Patient by P_ID', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.doctorPrimary.withValues(alpha: 0.3)),
                      ),
                      child: TextField(
                        controller: _pidController,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Enter Patient ID (e.g., PAK-HEALTH-2026-XXXX)',
                          hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      if (_pidController.text.isEmpty) return;
                      setState(() => _onboardSearching = true);
                      await Future.delayed(const Duration(milliseconds: 1500));
                      setState(() => _onboardSearching = false);
                      _showOnboardConfirmation(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.doctorPrimary, borderRadius: BorderRadius.circular(12)),
                      child: _onboardSearching
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Patient must approve access via their PANOR app notification.', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Stats row
        Row(
          children: [
            _buildStatCard('Queue', '${_patientQueue.length}', Icons.people_rounded, AppColors.doctorPrimary),
            const SizedBox(width: 12),
            _buildStatCard('Critical', '1', Icons.emergency_rounded, AppColors.emergencyRed),
            const SizedBox(width: 12),
            _buildStatCard('Today', '${_schedule.length}', Icons.calendar_today_rounded, AppColors.brandPurple),
          ],
        ),
        const SizedBox(height: 24),

        // Patient Queue
        Text('Patient Queue', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._patientQueue.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPatientCard(p),
        )),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> p) {
    final risk = p['risk'] as String;
    Color riskColor;
    switch (risk) {
      case 'CRITICAL': riskColor = AppColors.emergencyRed; break;
      case 'HIGH': riskColor = AppColors.warning; break;
      case 'MODERATE': riskColor = Colors.orange; break;
      default: riskColor = AppColors.success;
    }

    return GestureDetector(
      onTap: () => _showPatientDetail(context, p),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: riskColor.withValues(alpha: 0.3), width: 1.5),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: riskColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Center(child: Text(p['name'].split(' ').map((w) => w[0]).take(2).join(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: riskColor, fontSize: 14))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'], style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${p['age']} | ${p['pid']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: riskColor, borderRadius: BorderRadius.circular(6)),
                  child: Text(risk, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chief Complaint', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(p['chief'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...(p['conditions'] as List).map((c) => Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(c, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.warning)),
                )),
                const Spacer(),
                Icon(Icons.timer_outlined, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('Waiting: ${p['waiting']}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: SCHEDULE — Today's Consultations
  // ═══════════════════════════════════════════════════════════════
  Widget _buildScheduleTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Today\'s Schedule', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('May 20, 2026 — 6 consultations', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        ..._schedule.map((s) {
          Color statusColor;
          IconData statusIcon;
          switch (s['status']) {
            case 'Completed': statusColor = AppColors.success; statusIcon = Icons.check_circle_rounded; break;
            case 'In Progress': statusColor = AppColors.doctorPrimary; statusIcon = Icons.play_circle_rounded; break;
            default: statusColor = AppColors.textMuted; statusIcon = Icons.schedule_rounded;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 65,
                    child: Column(
                      children: [
                        Text(s['time'], style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                        const SizedBox(height: 4),
                        Icon(statusIcon, color: statusColor, size: 18),
                        Expanded(child: Container(width: 2, color: AppColors.borderLight)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: s['status'] == 'In Progress' ? statusColor.withValues(alpha: 0.1) : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: s['status'] == 'In Progress' ? statusColor.withValues(alpha: 0.4) : AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s['patient'], style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text(s['type'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(s['status'], style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: AI COPILOT — Clinical Reasoning + SOAP + Agent Traces
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAiCopilotTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(child: Text('AI Clinical Copilot', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
              child: Text('7 Agents', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Active patient: Ahmed Raza (PAK-****-0001)', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        // AI Summary Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.doctorPrimary.withValues(alpha: 0.15), AppColors.surface]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.doctorPrimary.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.doctorPrimary, const Color(0xFF34D399)]), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('AI Patient Summary', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                  Text('2.3s', style: GoogleFonts.inter(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 14),
              Text('52-year-old male presenting with acute chest pain, fever (99.1F), and exertional dyspnea. Known T2DM on Metformin 500mg BD, HTN on Amlodipine 5mg OD. BMI 28.4 kg/m2. Previous ECG showed non-specific ST-T changes. Current episode represents new-onset cardiac symptoms requiring urgent workup.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildDxChip('ACS', '94%', AppColors.emergencyRed),
                  const SizedBox(width: 8),
                  _buildDxChip('Unstable Angina', '78%', AppColors.warning),
                  const SizedBox(width: 8),
                  _buildDxChip('Myocarditis', '34%', AppColors.textMuted),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // SOAP Notes
        Text('Auto-Generated SOAP Notes', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildSoapSection('S', 'Subjective', 'Patient reports acute onset chest pain radiating to left arm, accompanied by low-grade fever and exertional dyspnea x 2 days. History of T2DM and HTN. On Metformin, Amlodipine, Aspirin. Describes pain as "seene mein dard, saans phoolna."'),
        _buildSoapSection('O', 'Objective', 'BP 130/85 mmHg | HR 78 bpm | SpO2 97% | Temp 99.1F | BMI 28.4\nPrior ECG: Non-specific ST-T changes V4-V6\nLipid Panel: TC 240 (H), LDL 148 (H), HDL 42 (L)'),
        _buildSoapSection('A', 'Assessment', 'Acute Coronary Syndrome vs Unstable Angina. RED cardiac risk. Multiple comorbidities (T2DM, HTN, dyslipidemia) compound cardiovascular risk.'),
        _buildSoapSection('P', 'Plan', '1. STAT ECG + Serial Troponin-I (0h, 3h, 6h)\n2. Continue Aspirin 75mg, consider dose escalation\n3. Nitrate PRN for chest pain\n4. BLOCK NSAIDs (Metformin interaction)\n5. Cardiology consult if troponin elevated\n6. Follow-up 48h'),
        const SizedBox(height: 20),

        // Drug Safety
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.emergencyRed.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_rounded, color: AppColors.emergencyRed, size: 20),
                  const SizedBox(width: 8),
                  Text('Drug Safety Guardian (Agent 03)', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.emergencyRed)),
                ],
              ),
              const SizedBox(height: 12),
              _buildDrugRow('Ibuprofen', 'BLOCKED', 'NSAIDs + Metformin = renal risk + lactic acidosis', AppColors.emergencyRed),
              _buildDrugRow('Diclofenac', 'BLOCKED', 'NSAIDs contraindicated with current regimen', AppColors.emergencyRed),
              _buildDrugRow('Aspirin 75mg', 'WARN', 'Review dose — consider escalation to 150mg for ACS', AppColors.warning),
              _buildDrugRow('Nitroglycerin', 'ALLOW', 'Safe for PRN chest pain relief', AppColors.success),
              _buildDrugRow('Paracetamol', 'ALLOW', 'Safe antipyretic with current medications', AppColors.success),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Agent Traces
        Text('7-Agent Orchestration Trace', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._agentTraces.map((a) => _buildAgentTraceCard(a)),
      ],
    );
  }

  Widget _buildDxChip(String label, String pct, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text('$label $pct', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildSoapSection(String letter, String title, String content) {
    Color color;
    switch (letter) {
      case 'S': color = AppColors.patientPrimary; break;
      case 'O': color = AppColors.doctorPrimary; break;
      case 'A': color = AppColors.warning; break;
      default: color = AppColors.brandPurple;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(letter, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(content, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugRow(String drug, String status, String reason, Color color) {
    IconData icon;
    switch (status) {
      case 'BLOCKED': icon = Icons.block_rounded; break;
      case 'WARN': icon = Icons.warning_rounded; break;
      default: icon = Icons.check_circle_rounded;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(drug, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                      child: Text(status, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                ),
                Text(reason, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentTraceCard(Map<String, dynamic> a) {
    Color statusColor;
    switch (a['status']) {
      case 'COMPLETED': statusColor = AppColors.success; break;
      case 'ALERT': statusColor = AppColors.emergencyRed; break;
      default: statusColor = AppColors.warning;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(a['agent'], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700))),
              Text(a['time'], style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(a['result'], style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 4: LABS — Assignment + Results
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLabsTab() {
    final labOrders = [
      {'test': 'ECG (12-Lead)', 'patient': 'Ahmed Raza', 'priority': 'STAT', 'status': 'Pending', 'ordered': '20 May 2026, 10:15 AM'},
      {'test': 'Troponin-I (Serial)', 'patient': 'Ahmed Raza', 'priority': 'STAT', 'status': 'In Progress', 'ordered': '20 May 2026, 10:15 AM'},
      {'test': 'CBC + BMP', 'patient': 'Ahmed Raza', 'priority': 'URGENT', 'status': 'Pending', 'ordered': '20 May 2026, 10:16 AM'},
      {'test': 'HbA1c', 'patient': 'Zara Tariq', 'priority': 'ROUTINE', 'status': 'Completed', 'ordered': '18 May 2026', 'result': '6.8%'},
      {'test': 'Lipid Panel', 'patient': 'Imran Shah', 'priority': 'ROUTINE', 'status': 'Completed', 'ordered': '17 May 2026', 'result': 'TC: 210, LDL: 130'},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(child: Text('Laboratory Orders', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold))),
            GestureDetector(
              onTap: () => _showAssignLabSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.labPrimary, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('Assign Lab', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...labOrders.map((l) {
          Color prioColor;
          switch (l['priority']) {
            case 'STAT': prioColor = AppColors.emergencyRed; break;
            case 'URGENT': prioColor = AppColors.warning; break;
            default: prioColor = AppColors.success;
          }
          final isCompleted = l['status'] == 'Completed';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isCompleted ? AppColors.success.withValues(alpha: 0.3) : prioColor.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(isCompleted ? Icons.check_circle_rounded : Icons.science_rounded, color: isCompleted ? AppColors.success : prioColor, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l['test']!, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: prioColor, borderRadius: BorderRadius.circular(4)),
                      child: Text(l['priority']!, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('Patient: ${l['patient']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                    const Spacer(),
                    Text(l['status']!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: isCompleted ? AppColors.success : AppColors.textMuted)),
                  ],
                ),
                if (isCompleted && l['result'] != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                    child: Text('Result: ${l['result']}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 5: DOCTOR PROFILE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDoctorProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Profile card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.doctorPrimary, const Color(0xFF34D399)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white38, width: 2)),
                child: Center(child: Text('FH', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
              const SizedBox(height: 12),
              Text('Dr. Fatima Hassan', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('MBBS, FCPS (Cardiology)', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_rounded, color: Colors.greenAccent.shade200, size: 14),
                  const SizedBox(width: 4),
                  Text('PMDC #42891 | Verified', style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Stats
        Row(
          children: [
            _buildProfileStat('Patients', '1,247'),
            const SizedBox(width: 12),
            _buildProfileStat('Consults', '3,892'),
            const SizedBox(width: 12),
            _buildProfileStat('Rating', '4.9'),
          ],
        ),
        const SizedBox(height: 20),

        _buildProfileRow(Icons.location_on_rounded, 'Clinic', 'PANOR Cardiac Centre, Johar Town, Lahore'),
        _buildProfileRow(Icons.access_time_rounded, 'Hours', 'Mon-Sat: 9:00 AM - 5:00 PM'),
        _buildProfileRow(Icons.monetization_on_rounded, 'Consultation Fee', 'Rs. 2,500'),
        _buildProfileRow(Icons.phone_rounded, 'Contact', '+92 321 *** 4567'),
        _buildProfileRow(Icons.school_rounded, 'Education', 'King Edward Medical University, Lahore'),
        _buildProfileRow(Icons.work_rounded, 'Experience', '18 years'),
        _buildProfileRow(Icons.local_hospital_rounded, 'Affiliation', 'Jinnah Hospital, PANOR Network'),
      ],
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.doctorPrimary)),
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.doctorPrimary),
          const SizedBox(width: 14),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DIALOGS & SHEETS
  // ═══════════════════════════════════════════════════════════════
  void _showOnboardConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.doctorPrimary, width: 1.5)),
        title: Row(
          children: [
            const Icon(Icons.person_add_rounded, color: AppColors.doctorPrimary),
            const SizedBox(width: 8),
            Text('Patient Found', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: Ahmed Raza', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            Text('P_ID: ${_pidController.text}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            Text('Age: 52M | Blood Group: B+', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text('A consent notification will be sent to the patient. You will gain access only after patient approval.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.warning)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Consent request sent to Ahmed Raza'), backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.doctorPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Send Request', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPatientDetail(BuildContext context, Map<String, dynamic> p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: AppColors.doctorPrimary, width: 2))),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(p['name'], style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${p['pid']} | ${p['age']}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Text('Chief Complaint', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(p['chief'], style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, height: 1.4)),
            const SizedBox(height: 16),
            Text('Known Conditions', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Wrap(
              spacing: 8,
              children: (p['conditions'] as List).map((c) => Chip(
                label: Text(c, style: GoogleFonts.inter(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600)),
                backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                side: BorderSide(color: AppColors.warning.withValues(alpha: 0.2)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); setState(() => _currentIndex = 2); },
                    icon: const Icon(Icons.psychology_rounded, size: 18),
                    label: Text('AI Copilot', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.doctorPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); _showAssignLabSheet(context); },
                    icon: const Icon(Icons.science_rounded, size: 18),
                    label: Text('Assign Labs', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.labPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignLabSheet(BuildContext context) {
    final labs = [
      {'name': 'ECG (12-Lead)', 'selected': false},
      {'name': 'Troponin-I (Serial)', 'selected': false},
      {'name': 'CBC (Complete Blood Count)', 'selected': false},
      {'name': 'BMP (Basic Metabolic Panel)', 'selected': false},
      {'name': 'Lipid Panel', 'selected': false},
      {'name': 'HbA1c', 'selected': false},
      {'name': 'CRP (C-Reactive Protein)', 'selected': false},
      {'name': 'D-Dimer', 'selected': false},
      {'name': 'TSH (Thyroid)', 'selected': false},
      {'name': 'Urinalysis', 'selected': false},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: AppColors.labPrimary, width: 2))),
          child: Column(
            children: [
              Center(child: Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Assign Laboratory Tests', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: labs.length,
                  itemBuilder: (context, i) => CheckboxListTile(
                    value: labs[i]['selected'] as bool,
                    onChanged: (v) => setSheetState(() => labs[i]['selected'] = v!),
                    title: Text(labs[i]['name'] as String, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                    activeColor: AppColors.labPrimary,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lab tests assigned. Routing to Lab portal via Agent 04.'), backgroundColor: AppColors.success));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.labPrimary, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: Text('Assign Selected Tests (STAT)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
