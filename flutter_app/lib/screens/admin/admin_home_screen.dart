import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_buttons.dart';
import '../../core/auth_service.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    var data = await AuthService.getDashboard('admin');
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
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, Admin 🛡️', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('System Overview', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      int totalPatients = _dashboardData?['metrics']?['total_patients'] ?? 0;
      int activeDoctors = _dashboardData?['metrics']?['active_doctors'] ?? 0;
      var activities = _dashboardData?['recent_activities'] as List? ?? [];

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: DashboardCard(title: 'Total Patients', value: '$totalPatients', icon: Icons.local_hospital, color: const Color(0xFF0066FF))),
              const SizedBox(width: 16),
              Expanded(child: DashboardCard(title: 'Active Doctors', value: '$activeDoctors', icon: Icons.medical_services, color: const Color(0xFF00C853))),
            ],
          ),
          const SizedBox(height: 32),
          Text('Recent Activities', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...activities.map((act) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildActivityRow(act['title'], act['desc'], act['time']),
          )).toList(),
        ],
      );
    }
    return Center(child: Text('Coming Soon', style: GoogleFonts.inter(fontSize: 20, color: Colors.grey)));
  }

  Widget _buildActivityRow(String title, String desc, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF7C3AED)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(desc, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
