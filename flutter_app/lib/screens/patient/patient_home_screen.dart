import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_buttons.dart';
import '../../core/auth_service.dart';

class PatientHomeScreen extends StatefulWidget {
  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, Rahul 👋', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('How are you feeling today?', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF0066FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Records'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'AI Assistant'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      String bp = _dashboardData?['health_summary']?['blood_pressure'] ?? 'N/A';
      String hr = _dashboardData?['health_summary']?['heart_rate'] ?? 'N/A';
      var appointments = _dashboardData?['appointments'] as List? ?? [];

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Health Summary', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: DashboardCard(title: 'Blood Pressure', value: bp, icon: Icons.favorite, color: Colors.red)),
              const SizedBox(width: 16),
              Expanded(child: DashboardCard(title: 'Heart Rate', value: hr, icon: Icons.monitor_heart, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 32),
          Text('Upcoming Appointments', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (appointments.isNotEmpty)
            _buildAppointmentCard(appointments[0])
          else
            Text('No appointments scheduled.', style: GoogleFonts.inter(color: Colors.grey)),
        ],
      );
    }
    return Center(child: Text('Coming Soon', style: GoogleFonts.inter(fontSize: 20, color: Colors.grey)));
  }

  Widget _buildAppointmentCard(dynamic apt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(apt['image_url'] ?? ''), radius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt['doctor_name'] ?? '', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${apt['specialty']} • ${apt['datetime']}', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}
