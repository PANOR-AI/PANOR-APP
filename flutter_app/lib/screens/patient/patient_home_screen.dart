import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_buttons.dart';

class PatientHomeScreen extends StatefulWidget {
  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

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
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
          const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), radius: 18),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody(),
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
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Health Summary', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: DashboardCard(title: 'Blood Pressure', value: '120/80', icon: Icons.favorite, color: Colors.red)),
              SizedBox(width: 16),
              Expanded(child: DashboardCard(title: 'Heart Rate', value: '72 bpm', icon: Icons.monitor_heart, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 32),
          Text('Upcoming Appointments', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAppointmentCard(),
        ],
      );
    }
    return Center(child: Text('Coming Soon', style: GoogleFonts.inter(fontSize: 20, color: Colors.grey)));
  }

  Widget _buildAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33'), radius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dr. Amit Verma', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Cardiologist • 24 May 2024, 10:00 AM', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}
