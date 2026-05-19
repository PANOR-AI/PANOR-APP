import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_buttons.dart';
import '../../core/auth_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    int patientsToday = _dashboardData?['metrics']?['patients_today'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, Dr. Verma 🩺', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('You have $patientsToday patients today', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF00C853),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      int patientsToday = _dashboardData?['metrics']?['patients_today'] ?? 0;
      int aptCount = _dashboardData?['metrics']?['appointments'] ?? 0;
      var appointments = _dashboardData?['appointments'] as List? ?? [];

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: DashboardCard(title: 'Patients Today', value: '$patientsToday', icon: Icons.people_outline, color: const Color(0xFF00C853))),
              const SizedBox(width: 16),
              Expanded(child: DashboardCard(title: 'Appointments', value: '0$aptCount', icon: Icons.calendar_month, color: const Color(0xFF0066FF))),
            ],
          ),
          const SizedBox(height: 32),
          Text('Today\'s Appointments', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...appointments.map((apt) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildPatientCard(apt['name'], apt['time'], apt['type'], apt['image_url']),
          )).toList(),
        ],
      );
    }
    return Center(child: Text('Coming Soon', style: GoogleFonts.inter(fontSize: 20, color: Colors.grey)));
  }

  Widget _buildPatientCard(String name, String time, String type, String img) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(img), radius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(type, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF00C853))),
        ],
      ),
    );
  }
}
