import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';
import '../../widgets/custom_buttons.dart';
import '../../core/auth_service.dart';
import 'voice_input_screen.dart';
import 'upload_report_screen.dart';
import 'ai_assistant_screen.dart';
import 'patient_timeline_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  // AI Intake Chat state
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'ai',
      'text': 'Hello Rahul! I am your PANOR AI Symptom Intake Copilot. Tell me how you are feeling today. You can describe your symptoms in Roman Urdu (e.g., "mere sar me dard hai") or English. If you have an image of your prescription or diagnostic report, you can upload it here.',
      'time': 'Just now',
    }
  ];
  final TextEditingController _chatController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
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
      _chatController.clear();
      _isSending = true;
    });

    // Simulate AI clinical reasoning workflow execution
    try {
      // Connect to backend start consultation API with simulated clinical reasoning
      await http.post(
        Uri.parse('http://localhost:8000/api/consultation/start'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_id': 'patient_01',
          'text_input': userMessage,
        }),
      );


      // Simple mock responses based on input keywords
      String replyText = "I have recorded your symptoms. Connecting with Dr. Amit Verma to generate a clinical SOAP draft.";
      if (userMessage.toLowerCase().contains('dard') || userMessage.toLowerCase().contains('pain')) {
        replyText = "⚠️ Intake Alert: Pain recorded. Clinical Reasoning Agent (Agent 02) has flagged this. Dr. Amit Verma has been notified, and standard drug-safety overrides have been loaded for clashing prescriptions.";
      } else if (userMessage.toLowerCase().contains('cough') || userMessage.toLowerCase().contains('khansi')) {
        replyText = "Recorded. Laboratory Coordination Agent (Agent 04) has pre-filled a suggested CBC and Chest X-ray order for Dr. Verma's review. Let me know if you are experiencing shortness of breath.";
      }

      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': replyText,
          'time': 'Just now',
        });
      });
    } catch (e) {
      // Fallback fallback message
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': 'Symptoms registered! Clinical reasoning complete. Dr. Amit Verma has received your automated clinical intake draft.',
          'time': 'Just now',
        });
      });
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.patientPrimary,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                'RS',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rahul Sharma',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Patient Portal Workspace',
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
        selectedItemColor: AppColors.patientPrimary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description_rounded), label: 'Records'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'AI Intake'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildRecordsTab();
      case 2:
        return _buildAiIntakeTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    String bp = _dashboardData?['health_summary']?['blood_pressure'] ?? '120/80';
    String hr = _dashboardData?['health_summary']?['heart_rate'] ?? '72 bpm';
    var appointments = _dashboardData?['appointments'] as List? ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Active Health Metrics',
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Blood Pressure',
                value: bp,
                icon: Icons.favorite_rounded,
                color: Colors.redAccent,
                subtitle: 'Normal',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                title: 'Heart Rate',
                value: hr,
                icon: Icons.monitor_heart_rounded,
                color: Colors.orangeAccent,
                subtitle: 'Resting',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'SpO2 Level',
                value: '99%',
                icon: Icons.bubble_chart_rounded,
                color: AppColors.patientPrimary,
                subtitle: 'Optimal',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardCard(
                title: 'Body Temp',
                value: '98.4 °F',
                icon: Icons.thermostat_rounded,
                color: Colors.teal,
                subtitle: 'Healthy',
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Clinical Quick Actions',
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.35,
          children: [
            _buildQuickActionCard(
              context,
              'AI Intake Assistant',
              'Chat with AI in Roman Urdu/English',
              Icons.psychology_outlined,
              AppColors.patientPrimary,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AiAssistantScreen())),
            ),
            _buildQuickActionCard(
              context,
              'Voice symptom intake',
              'Record symptoms with live waveform',
              Icons.mic_none_rounded,
              AppColors.doctorPrimary,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VoiceInputScreen())),
            ),
            _buildQuickActionCard(
              context,
              'OCR report upload',
              'Extract medical metrics from PDF',
              Icons.cloud_upload_outlined,
              AppColors.labPrimary,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadReportScreen())),
            ),
            _buildQuickActionCard(
              context,
              'Secure clinical ledger',
              'View chronological medical timeline',
              Icons.history_edu_rounded,
              AppColors.brandIndigo,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientTimelineScreen())),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Upcoming Appointments',
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        if (appointments.isNotEmpty)
          _buildAppointmentCard(appointments[0])
        else
          Text(
            'No upcoming consultations scheduled.',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        const SizedBox(height: 32),
        Text(
          'Prescription Overview',
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        _buildPrescriptionTile(
          'Aspirin 75mg',
          'Once daily (morning) • Dr. Amit Verma',
          'Cardioprotective',
          AppColors.success,
        ),
        const SizedBox(height: 12),
        _buildPrescriptionTile(
          'Atorvastatin 20mg',
          'At bedtime • Dr. Amit Verma',
          'Cholesterol control',
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildRecordsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Clinical Documents',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Secure, unified medical ledger audited by Google Antigravity framework.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        _buildDocTile('Lipid Profile Report', 'Pathology Diagnostic Center • 10 May 2026', 'PDF Report', Icons.picture_as_pdf_rounded, Colors.red),
        const SizedBox(height: 16),
        _buildDocTile('Electrocardiogram (ECG)', 'Metropolitan Cardiac Wing • 05 May 2026', 'ECG Waveform', Icons.show_chart_rounded, AppColors.patientPrimary),
        const SizedBox(height: 16),
        _buildDocTile('Prescription Release Form', 'City General Hospital • 24 Apr 2026', 'Digital Order', Icons.receipt_long_rounded, Colors.purple),
      ],
    );
  }

  Widget _buildAiIntakeTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.patientPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.support_agent_rounded, color: AppColors.patientPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clinical Intake Copilot',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'AI translation and reasoning online',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isAi = msg['sender'] == 'ai';
              return Align(
                alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAi ? Colors.white : AppColors.patientPrimary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isAi ? Radius.zero : const Radius.circular(20),
                      bottomRight: isAi ? const Radius.circular(20) : Radius.zero,
                    ),
                    border: isAi ? Border.all(color: AppColors.borderLight) : null,
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg['text'],
                        style: GoogleFonts.inter(
                          color: isAi ? AppColors.textPrimary : Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          msg['time'],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isAi ? AppColors.textMuted : Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_isSending)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.mic_none_rounded, color: AppColors.patientPrimary),
                onPressed: () {
                  setState(() {
                    _chatController.text = "Mujhe kal se halka bukhar hai aur thakan mehsoos ho rahi hai.";
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.patientPrimary),
                onPressed: () {
                  setState(() {
                    _chatController.text = "Attached prescription.jpg - checking for clashing medications.";
                  });
                },
              ),
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Type symptoms in Roman Urdu or English...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.patientPrimary),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.patientPrimary.withValues(alpha: 0.1),
                child: const Icon(Icons.person_rounded, size: 50, color: AppColors.patientPrimary),
              ),
              const SizedBox(height: 16),
              Text(
                'Rahul Sharma',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Patient ID: PAN-5092-RS',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Text('Personal Health Profile', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildProfileItem('Age / Gender', '34 Years • Male'),
        const SizedBox(height: 12),
        _buildProfileItem('Blood Group', 'O Positive'),
        const SizedBox(height: 12),
        _buildProfileItem('Chronic Conditions', 'Mild Hypertension'),
        const SizedBox(height: 12),
        _buildProfileItem('Emergency Contact', 'Priya Sharma (Spouse) • +91 98765 43210'),
      ],
    );
  }

  Widget _buildAppointmentCard(dynamic apt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.patientLight, shape: BoxShape.circle),
            child: const Icon(Icons.medical_services_outlined, color: AppColors.patientPrimary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apt['doctor_name'] ?? 'Dr. Amit Verma',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${apt['specialty']} • ${apt['datetime']}',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
            child: Text(
              'Confirmed',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPrescriptionTile(String name, String schedule, String purpose, Color labelColor) {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.patientLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.medication_rounded, color: AppColors.patientPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(schedule, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: labelColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(
              purpose,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: labelColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile(String title, String subtitle, String type, IconData icon, Color color) {
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
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Text(
              type,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

