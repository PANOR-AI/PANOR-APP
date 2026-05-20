import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/role_switcher.dart';
import '../../widgets/emergency_banner.dart';
import '../../core/auth_service.dart';
import '../../core/constants/app_constants.dart';
import 'voice_input_screen.dart';
import 'upload_report_screen.dart';
import 'ai_assistant_screen.dart';
import 'patient_timeline_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  late AnimationController _pulseController;

  // AI Intake Chat state
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'ai',
      'text': 'Assalam-o-Alaikum Ahmed Bhai! I am your PANOR AI Health Copilot. Tell me how you are feeling today in any language — Roman Urdu, English, Sindhi, Punjabi, Pashto — I understand them all.\n\nYou can also:\n- Upload a prescription photo\n- Describe symptoms by voice\n- Ask about your medications\n- Request a doctor consultation',
      'time': 'Just now',
    }
  ];
  final TextEditingController _chatController = TextEditingController();
  bool _isSending = false;
  bool _showDoctorRecommendation = false;

  // Demographics
  final Map<String, dynamic> _demographics = {
    'p_id': 'PAK-HEALTH-2026-0001',
    'full_name': 'Ahmed Raza',
    'father_name': 'Muhammad Raza',
    'cnic': '35202-*******-1',
    'gender': 'Male',
    'dob': '15 March 1974',
    'age': '52 years',
    'blood_group': 'B+',
    'city': 'Lahore, Punjab',
    'address': 'House 42, Block F, Johar Town, Lahore',
    'phone': '+92 300 *** 4521',
    'emergency_contact': 'Fatima Raza (Wife) — +92 301 *** 8877',
    'chronic_diseases': ['Type 2 Diabetes Mellitus', 'Essential Hypertension'],
    'allergies': ['Sulfonamides', 'Penicillin (Mild)'],
    'disability': 'None',
    'insurance': 'Sehat Sahulat Card (Active)',
    'welfare_score': 72,
    'welfare_tier': 'Silver',
    'registration_date': '10 Jan 2026',
    'last_visit': '18 May 2026',
    'nadra_verified': true,
    'biometric_verified': true,
  };

  // Medications with schedule
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Metformin 500mg',
      'purpose': 'Blood Sugar Control',
      'doctor': 'Dr. Fatima Hassan',
      'schedule': [
        {'time': '08:00 AM', 'label': 'Morning', 'taken': true},
        {'time': '08:00 PM', 'label': 'Evening', 'taken': false},
      ],
      'color': AppColors.patientPrimary,
      'icon': Icons.bloodtype_rounded,
      'started': '15 Jan 2026',
      'refill_date': '25 May 2026',
    },
    {
      'name': 'Amlodipine 5mg',
      'purpose': 'Blood Pressure Control',
      'doctor': 'Dr. Fatima Hassan',
      'schedule': [
        {'time': '08:00 AM', 'label': 'Morning', 'taken': true},
      ],
      'color': AppColors.success,
      'icon': Icons.favorite_rounded,
      'started': '20 Feb 2026',
      'refill_date': '28 May 2026',
    },
    {
      'name': 'Aspirin 75mg',
      'purpose': 'Cardioprotective',
      'doctor': 'Dr. Fatima Hassan',
      'schedule': [
        {'time': '08:00 AM', 'label': 'Morning', 'taken': true},
      ],
      'color': AppColors.doctorPrimary,
      'icon': Icons.shield_rounded,
      'started': '01 Mar 2026',
      'refill_date': '01 Jun 2026',
    },
  ];

  // Follow-up consultations
  final List<Map<String, dynamic>> _followUps = [
    {
      'doctor': 'Dr. Fatima Hassan',
      'specialty': 'Cardiologist',
      'date': '22 May 2026',
      'time': '10:30 AM',
      'type': 'Follow-Up',
      'purpose': 'Post-cardiac workup review. ECG + Troponin results.',
      'location': 'PANOR Cardiac Centre, Lahore',
      'status': 'Confirmed',
    },
    {
      'doctor': 'Dr. Usman Ali',
      'specialty': 'Endocrinologist',
      'date': '28 May 2026',
      'time': '02:00 PM',
      'type': 'Routine',
      'purpose': 'Quarterly diabetes review. HbA1c check.',
      'location': 'Jinnah Hospital, Lahore',
      'status': 'Pending Confirmation',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _fetchData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _fetchData() async {
    var data = await AuthService.getDashboard('patient');
    setState(() {
      _dashboardData = data;
      _isLoading = false;
    });
  }

  void _sendMessage() async {
    if (_chatController.text.trim().isEmpty) return;

    final userMessage = _chatController.text.trim();
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': userMessage,
        'time': 'Just now',
      });
      _isSending = true;
      _chatController.clear();
    });

    await Future.delayed(const Duration(milliseconds: 1800));

    String replyText;
    bool showDoctorRec = false;

    if (userMessage.toLowerCase().contains('dard') || userMessage.toLowerCase().contains('pain') || userMessage.toLowerCase().contains('seene')) {
      replyText = "EMERGENCY DETECTION: I have analyzed your symptoms against your complete medical history.\n\nFindings:\n- Chest pain in 52-year-old male\n- Known T2DM (Metformin 500mg) + HTN (Amlodipine 5mg)\n- BMI: 28.4 kg/m2 (Overweight)\n- Previous ECG: Normal (6 months ago)\n\nRisk Assessment: RED — Cardiac ischemia risk\nConfidence: 94%\n\nRecommendation: Immediate cardiology consultation required. I have identified the best specialists for your case:";
      showDoctorRec = true;
    } else if (userMessage.toLowerCase().contains('bukhar') || userMessage.toLowerCase().contains('fever')) {
      replyText = "I have noted your fever symptom. Based on your medical history:\n\nAnalysis:\n- Fever combined with your cardiac risk profile requires monitoring\n- Your diabetes may mask infection symptoms\n- Current medications: No conflict with antipyretics\n\nSafe Action: Paracetamol 500mg is safe with your current medications.\nBlocked: NSAIDs (Ibuprofen) — conflicts with Metformin.\n\nShall I book a consultation with Dr. Fatima Hassan for evaluation?";
      showDoctorRec = true;
    } else if (userMessage.toLowerCase().contains('dawai') || userMessage.toLowerCase().contains('medicine') || userMessage.toLowerCase().contains('medication')) {
      replyText = "Your current active medications:\n\n1. Metformin 500mg — Morning + Evening (Diabetes)\n   Next dose: 8:00 PM today\n\n2. Amlodipine 5mg — Morning only (BP Control)\n   Next dose: Tomorrow 8:00 AM\n\n3. Aspirin 75mg — Morning only (Cardioprotective)\n   Next dose: Tomorrow 8:00 AM\n\nCompliance Rate: 87% (Good)\nRefill Alert: Metformin needs refill by May 25.";
    } else if (userMessage.toLowerCase().contains('doctor') || userMessage.toLowerCase().contains('consult') || userMessage.toLowerCase().contains('book')) {
      replyText = "I can help you book a consultation. Based on your medical profile, here are the most relevant specialists:";
      showDoctorRec = true;
    } else {
      replyText = "I have recorded your input. Let me analyze this against your complete medical profile.\n\nPatient Profile Summary:\n- Ahmed Raza, 52M, Lahore\n- Known: T2DM + Hypertension\n- Active Medications: 3\n- Last Visit: 18 May 2026\n\nBased on your description, I recommend discussing this with your cardiologist Dr. Fatima Hassan during your upcoming follow-up on May 22.\n\nWould you like me to book an earlier consultation?";
    }

    setState(() {
      _isSending = false;
      _messages.add({
        'sender': 'ai',
        'text': replyText,
        'time': 'Just now',
      });
      if (showDoctorRec) _showDoctorRecommendation = true;
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
            side: BorderSide(color: AppColors.patientPrimary.withValues(alpha: 0.3), width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.patientPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_rounded, color: AppColors.patientPrimary),
              ),
              const SizedBox(width: 12),
              Text(
                'Portal Settings',
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
                  'PANOR Secure Patient Space',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSettingToggle('AI Companion Voice', true, 'Enable live voice interaction with AI copilot'),
                _buildSettingToggle('Urgent Heart Alerts', true, 'Get notified for active cardiac risk indicators'),
                _buildSettingToggle('Multilingual OCR', true, 'Process handwritten prescriptions in regional scripts'),
                _buildSettingToggle('Data Sync', true, 'Automatically synchronize local medical records securely'),
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
                        Text('Settings updated successfully', style: GoogleFonts.inter(color: Colors.white)),
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.patientPrimary,
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
                activeColor: AppColors.patientPrimary,
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
                gradient: AppColors.patientGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.patientPrimary.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.patientPrimary.withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text('AR', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ahmed Raza', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Row(
                    children: [
                      Icon(Icons.verified_rounded, color: AppColors.success, size: 13),
                      const SizedBox(width: 4),
                      Text('P_ID: PAK-1234-5678-9012', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.2), width: 0.5),
                        ),
                        child: Text('NADRA Verified', style: GoogleFonts.inter(fontSize: 8, color: AppColors.success, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Notification bell
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                onPressed: () => _showNotifications(context),
              ),
              Positioned(
                right: 8, top: 8,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: AppColors.emergencyRed, shape: BoxShape.circle),
                  child: Center(child: Text('3', style: GoogleFonts.inter(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
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
          selectedItemColor: AppColors.patientPrimary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.history_edu_outlined), activeIcon: Icon(Icons.history_edu), label: 'Timeline'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), activeIcon: Icon(Icons.psychology), label: 'AI Copilot'),
            BottomNavigationBarItem(icon: Icon(Icons.medication_outlined), activeIcon: Icon(Icons.medication), label: 'Medications'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildDashboardTab();
      case 1: return _buildTimelineTab();
      case 2: return _buildAiCopilotTab();
      case 3: return _buildMedicationsTab();
      case 4: return _buildProfileTab();
      default: return _buildDashboardTab();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: DASHBOARD — Health Metrics + Quick Actions + Appointments
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDashboardTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        // Chronic condition monitoring banner
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.warning.withValues(alpha: 0.1), AppColors.warning.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.monitor_heart_rounded, color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Chronic Monitoring', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.warning)),
                    Text('T2DM + Hypertension. Report chest discomfort immediately.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Health vitals
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Health Vitals', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildVitalCard('Blood Pressure', '130/85', 'mmHg', Icons.favorite_rounded, const Color(0xFFEF4444), 'Borderline'),
              _buildVitalCard('Heart Rate', '78', 'bpm', Icons.monitor_heart_rounded, const Color(0xFFF59E0B), 'Normal'),
              _buildVitalCard('SpO2', '97', '%', Icons.bubble_chart_rounded, const Color(0xFF3B82F6), 'Normal'),
              _buildVitalCard('Temperature', '99.1', 'F', Icons.thermostat_rounded, const Color(0xFFEA580C), 'Low Fever'),
              _buildVitalCard('BMI', '28.4', 'kg/m2', Icons.accessibility_rounded, const Color(0xFF8B5CF6), 'Overweight'),
              _buildVitalCard('HbA1c', '7.8', '%', Icons.science_rounded, const Color(0xFFDC2626), 'Above Target'),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Quick Actions Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard('AI Health Chat', 'Describe symptoms in any language', Icons.psychology_rounded, AppColors.patientPrimary, () => setState(() => _currentIndex = 2)),
              _buildActionCard('Voice Intake', 'Record symptoms with live waveform', Icons.mic_rounded, AppColors.doctorPrimary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceInputScreen()))),
              _buildActionCard('Upload Records', 'Scan prescriptions & reports', Icons.document_scanner_rounded, AppColors.labPrimary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadReportScreen()))),
              _buildActionCard('Book Consultation', 'Find & book specialist doctors', Icons.calendar_month_rounded, AppColors.brandPurple, () => _showBookingSheet(context)),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Upcoming Appointments
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text('Upcoming Consultations', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              Text('${_followUps.length} scheduled', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._followUps.map((f) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: _buildConsultationCard(f),
        )),
        const SizedBox(height: 28),

        // Active Medications Summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text('Active Medications', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 3),
                child: Text('View All', style: GoogleFonts.inter(fontSize: 13, color: AppColors.patientPrimary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._medications.map((m) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: _buildMedSummaryCard(m),
        )),
      ],
    );
  }

  Widget _buildVitalCard(String label, String value, String unit, IconData icon, Color color, String status) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
                ),
                child: Text(status, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(children: [
              TextSpan(text: value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              TextSpan(text: ' $unit', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
            ]),
          ),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> f) {
    final isConfirmed = f['status'] == 'Confirmed';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.doctorPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.doctorPrimary.withValues(alpha: 0.15), AppColors.doctorPrimary.withValues(alpha: 0.05)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.doctorPrimary.withValues(alpha: 0.2), width: 1),
                ),
                child: const Icon(Icons.medical_services_rounded, color: AppColors.doctorPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f['doctor'], style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(f['specialty'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isConfirmed ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isConfirmed ? AppColors.success.withValues(alpha: 0.2) : AppColors.warning.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  f['status'],
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: isConfirmed ? AppColors.success : AppColors.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                _buildInfoChip(Icons.calendar_today_rounded, f['date']),
                const SizedBox(width: 16),
                _buildInfoChip(Icons.access_time_rounded, f['time']),
                const SizedBox(width: 16),
                _buildInfoChip(Icons.local_hospital_rounded, f['type']),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(f['purpose'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMedSummaryCard(Map<String, dynamic> m) {
    final color = m['color'] as Color;
    final schedules = m['schedule'] as List;
    final nextDose = schedules.where((s) => s['taken'] == false).toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(m['icon'] as IconData, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['name'], style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(m['purpose'], style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (nextDose.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2), width: 0.5),
              ),
              child: Text('Next: ${nextDose[0]['time']}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('All Taken', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: TIMELINE — Immutable Medical History
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTimelineTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(child: Text('Medical Timeline', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, size: 12, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text('Append-Only', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Immutable longitudinal health record. Cannot be modified after verification.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        // Upload historical records CTA
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadReportScreen())),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.patientGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Upload Historical Records', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Scan PDFs, prescriptions, lab reports via OCR', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Timeline entries
        _buildTimelineEntry('20 May 2026', 'Emergency Consultation', 'Chest pain + fever + exertional dyspnea. RED cardiac risk flagged by Agent 02. STAT ECG + Troponin ordered.', 'Dr. Fatima Hassan', AppColors.emergencyRed, Icons.emergency_rounded),
        _buildTimelineEntry('18 May 2026', 'AI Symptom Intake', 'Patient reported "seene mein dard, bukhar, saans phoolna" in Roman Urdu. Agent 01 extracted 3 clinical entities. Language: ur-PK.', 'Agent 01: Intake Intelligence', AppColors.brandPurple, Icons.psychology_rounded),
        _buildTimelineEntry('10 May 2026', 'Laboratory Results', 'Lipid Profile: Total Cholesterol 240 mg/dL (HIGH), LDL 148 mg/dL (HIGH), HDL 42 mg/dL (LOW). Troponin-I: 0.02 ng/mL (Normal).', 'PANOR Central Lab', AppColors.labPrimary, Icons.science_rounded),
        _buildTimelineEntry('05 May 2026', 'ECG Report', 'Sinus rhythm. Non-specific ST-T wave changes V4-V6. No prior comparison available. Recommend follow-up.', 'PANOR Cardiac Centre', AppColors.doctorPrimary, Icons.show_chart_rounded),
        _buildTimelineEntry('01 Mar 2026', 'Prescription Update', 'Aspirin 75mg OD added to regimen. Purpose: Cardioprotective prophylaxis. Agent 03 verified no conflicts.', 'Dr. Fatima Hassan', AppColors.success, Icons.medication_rounded),
        _buildTimelineEntry('20 Feb 2026', 'Prescription Update', 'Amlodipine 5mg OD prescribed. BP readings: 145/92 average over 2 weeks. Target: <130/80.', 'Dr. Fatima Hassan', AppColors.patientPrimary, Icons.medication_rounded),
        _buildTimelineEntry('15 Jan 2026', 'Initial Registration', 'Account created. NADRA identity verified. P_ID assigned: PAK-HEALTH-2026-0001. Demographics locked.', 'PANOR System', AppColors.brandIndigo, Icons.verified_rounded),
      ],
    );
  }

  Widget _buildTimelineEntry(String date, String title, String description, String source, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line + dot
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  Expanded(child: Container(width: 2, color: AppColors.borderLight)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(date, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.textMuted),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 4),
                    Text(description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                    const SizedBox(height: 8),
                    Text('Source: $source', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: AI COPILOT — Chat + Doctor Recommendations
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAiCopilotTab() {
    return Column(
      children: [
        // AI header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PANOR AI Health Copilot', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('7 Agents Online | Multi-Language Active', style: GoogleFonts.inter(fontSize: 11, color: AppColors.success)),
                      ],
                    ),
                  ],
                ),
              ),
              // Input mode toggles
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    _buildInputModeIcon(Icons.keyboard_rounded, true),
                    _buildInputModeIcon(Icons.mic_rounded, false),
                    _buildInputModeIcon(Icons.camera_alt_rounded, false),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Chat messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_showDoctorRecommendation ? 1 : 0),
            itemBuilder: (context, index) {
              if (_showDoctorRecommendation && index == _messages.length) {
                return _buildDoctorRecommendationCard();
              }
              final msg = _messages[index];
              final isAi = msg['sender'] == 'ai';
              return Align(
                alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isAi ? Colors.white : AppColors.patientPrimary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isAi ? const Radius.circular(4) : const Radius.circular(18),
                      bottomRight: isAi ? const Radius.circular(18) : const Radius.circular(4),
                    ),
                    border: isAi ? Border.all(color: AppColors.borderLight) : null,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAi)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.brandPurple),
                              const SizedBox(width: 4),
                              Text('PANOR AI', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.brandPurple)),
                            ],
                          ),
                        ),
                      Text(
                        msg['text'],
                        style: GoogleFonts.inter(
                          color: isAi ? AppColors.textPrimary : Colors.white,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Chat input
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _chatController,
                    onSubmitted: (_) => _sendMessage(),
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Describe symptoms in any language...',
                      hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isSending ? null : _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.patientGradient,
                    shape: BoxShape.circle,
                  ),
                  child: _isSending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputModeIcon(IconData icon, bool active) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: active ? AppColors.patientPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: active ? Colors.white : AppColors.textMuted),
    );
  }

  Widget _buildDoctorRecommendationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.doctorPrimary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.brandPurple),
              const SizedBox(width: 6),
              Text('AI Recommended Specialists', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.brandPurple)),
            ],
          ),
          const SizedBox(height: 12),
          _buildDoctorRec('Dr. Fatima Hassan', 'Cardiologist', 4.9, 'PANOR Cardiac Centre', 'Rs. 2,500', true),
          Divider(height: 20, color: AppColors.borderLight),
          _buildDoctorRec('Dr. Usman Ali', 'Endocrinologist', 4.7, 'Jinnah Hospital', 'Rs. 2,000', false),
          Divider(height: 20, color: AppColors.borderLight),
          _buildDoctorRec('Dr. Ayesha Siddiqui', 'General Physician', 4.5, 'Shaukat Khanum', 'Rs. 1,500', false),
        ],
      ),
    );
  }

  Widget _buildDoctorRec(String name, String specialty, double rating, String location, String fee, bool recommended) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.doctorPrimary.withValues(alpha: 0.1),
          radius: 20,
          child: Text(name.split(' ').map((w) => w[0]).take(2).join(), style: GoogleFonts.outfit(color: AppColors.doctorPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (recommended) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text('Best Match', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.success)),
                    ),
                  ],
                ],
              ),
              Text('$specialty | $location', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(children: [
              const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
              Text(' $rating', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
            Text(fee, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showBookingSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.doctorPrimary, borderRadius: BorderRadius.circular(8)),
            child: Text('Book', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 4: MEDICATIONS — Full Schedule + Compliance + Reminders
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMedicationsTab() {
    int totalDoses = 0;
    int takenDoses = 0;
    for (var med in _medications) {
      for (var s in med['schedule'] as List) {
        totalDoses++;
        if (s['taken'] == true) takenDoses++;
      }
    }
    double compliance = totalDoses > 0 ? takenDoses / totalDoses : 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Medication Management', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('AI Follow-Up Agent (Agent 06) monitors your compliance and recovery.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        // Compliance card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70, height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: compliance,
                      strokeWidth: 6,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Text('${(compliance * 100).round()}%', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Compliance', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('$takenDoses of $totalDoses doses taken', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('Agent 06 is tracking your recovery', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Medication cards with full schedule
        ..._medications.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildFullMedCard(m),
        )),

        const SizedBox(height: 16),
        // Drug safety alert
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.emergencyRed.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.block_rounded, color: AppColors.emergencyRed, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Blocked Medications (Agent 03)', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.emergencyRed)),
                    Text('NSAIDs (Ibuprofen, Diclofenac) blocked due to Metformin interaction. Use Paracetamol instead.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullMedCard(Map<String, dynamic> m) {
    final color = m['color'] as Color;
    final schedules = m['schedule'] as List;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(m['icon'] as IconData, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m['name'], style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(m['purpose'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Schedule rows
          ...schedules.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: s['taken'] ? AppColors.success.withValues(alpha: 0.05) : AppColors.warning.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: s['taken'] ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(
                    s['taken'] ? Icons.check_circle_rounded : Icons.schedule_rounded,
                    color: s['taken'] ? AppColors.success : AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(s['label'], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  const Spacer(),
                  Text(s['time'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: s['taken'] ? AppColors.success : AppColors.warning,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      s['taken'] ? 'Taken' : 'Pending',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Prescribed by: ${m['doctor']}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
              const Spacer(),
              Text('Refill: ${m['refill_date']}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 5: PROFILE — Complete Demographics + Identity
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Identity card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 2),
                    ),
                    child: Center(child: Text('AR', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_demographics['full_name'], style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('S/O ${_demographics['father_name']}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.verified_rounded, color: Colors.greenAccent.shade200, size: 14),
                            const SizedBox(width: 4),
                            Text(_demographics['p_id'], style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIdChip(Icons.fingerprint_rounded, 'NADRA', _demographics['nadra_verified']),
                    Container(width: 1, height: 20, color: Colors.white24),
                    _buildIdChip(Icons.face_rounded, 'Biometric', _demographics['biometric_verified']),
                    Container(width: 1, height: 20, color: Colors.white24),
                    _buildIdChip(Icons.shield_rounded, 'Immutable', true),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Welfare Score
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.warning, AppColors.labPrimary]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text('${_demographics['welfare_score']}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Social Healthcare Score', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('${_demographics['welfare_tier']} Tier — 30% discount on consultations', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Demographics Grid
        Text('Demographics', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDemoRow(Icons.badge_rounded, 'CNIC', _demographics['cnic']),
        _buildDemoRow(Icons.person_rounded, 'Gender', _demographics['gender']),
        _buildDemoRow(Icons.cake_rounded, 'Date of Birth', '${_demographics['dob']} (${_demographics['age']})'),
        _buildDemoRow(Icons.bloodtype_rounded, 'Blood Group', _demographics['blood_group']),
        _buildDemoRow(Icons.location_on_rounded, 'City', _demographics['city']),
        _buildDemoRow(Icons.home_rounded, 'Address', _demographics['address']),
        _buildDemoRow(Icons.phone_rounded, 'Phone', _demographics['phone']),
        _buildDemoRow(Icons.emergency_rounded, 'Emergency Contact', _demographics['emergency_contact']),
        _buildDemoRow(Icons.health_and_safety_rounded, 'Insurance', _demographics['insurance']),
        _buildDemoRow(Icons.accessibility_rounded, 'Disability', _demographics['disability']),
        _buildDemoRow(Icons.calendar_today_rounded, 'Registered', _demographics['registration_date']),
        _buildDemoRow(Icons.update_rounded, 'Last Visit', _demographics['last_visit']),

        const SizedBox(height: 20),
        Text('Chronic Conditions', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...(_demographics['chronic_diseases'] as List).map((d) => _buildTagRow(d, AppColors.emergencyRed, Icons.monitor_heart_rounded)),

        const SizedBox(height: 20),
        Text('Known Allergies', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...(_demographics['allergies'] as List).map((a) => _buildTagRow(a, AppColors.warning, Icons.warning_rounded)),
      ],
    );
  }

  Widget _buildIdChip(IconData icon, String label, bool verified) {
    return Row(
      children: [
        Icon(icon, size: 14, color: verified ? Colors.greenAccent.shade200 : Colors.white54),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDemoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.patientPrimary),
          const SizedBox(width: 14),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildTagRow(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTTOM SHEETS & DIALOGS
  // ═══════════════════════════════════════════════════════════════
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text('Notifications', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  Text('3 new', style: GoogleFonts.inter(fontSize: 12, color: AppColors.patientPrimary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildNotifTile('Medication Reminder', 'Time for Metformin 500mg (Evening dose)', '2 mins ago', AppColors.warning, Icons.medication_rounded),
                  _buildNotifTile('Lab Results Ready', 'Your Lipid Profile results are available', '1 hour ago', AppColors.labPrimary, Icons.science_rounded),
                  _buildNotifTile('Consultation Confirmed', 'Dr. Fatima Hassan confirmed your May 22 appointment', '3 hours ago', AppColors.success, Icons.check_circle_rounded),
                  _buildNotifTile('Doctor Access Request', 'Dr. Usman Ali requests access to your records', 'Yesterday', AppColors.doctorPrimary, Icons.security_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifTile(String title, String desc, String time, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(desc, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Book Consultation', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildBookableDoctorCard('Dr. Fatima Hassan', 'Cardiologist', 'PANOR Cardiac Centre, Lahore', 'Rs. 2,500', 4.9, ['10:30 AM', '2:00 PM', '4:30 PM']),
                  const SizedBox(height: 12),
                  _buildBookableDoctorCard('Dr. Usman Ali', 'Endocrinologist', 'Jinnah Hospital, Lahore', 'Rs. 2,000', 4.7, ['9:00 AM', '11:30 AM', '3:00 PM']),
                  const SizedBox(height: 12),
                  _buildBookableDoctorCard('Dr. Ayesha Siddiqui', 'General Physician', 'Shaukat Khanum, Lahore', 'Rs. 1,500', 4.5, ['10:00 AM', '1:00 PM']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookableDoctorCard(String name, String specialty, String location, String fee, double rating, List<String> slots) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.doctorPrimary.withValues(alpha: 0.1),
                child: Text(name.split(' ').last[0], style: GoogleFonts.outfit(color: AppColors.doctorPrimary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('$specialty | $location', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(children: [const Icon(Icons.star_rounded, size: 14, color: AppColors.warning), Text(' $rating', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold))]),
                  Text(fee, style: GoogleFonts.inter(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Available Slots (May 22)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: slots.map((s) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Consultation booked with $name at $s on May 22. Awaiting doctor confirmation.'),
                  backgroundColor: AppColors.success,
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.doctorPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.doctorPrimary.withValues(alpha: 0.2)),
                ),
                child: Text(s, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.doctorPrimary)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
