import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_buttons.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../admin/admin_home_screen.dart';

class LoginScreen extends StatelessWidget {
  final String role;
  final Color color;

  const LoginScreen({required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: BackButton(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Login', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Welcome back, $role', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Login',
              color: color,
              onPressed: () {
                if (role == 'Patient') {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => PatientHomeScreen()), (r) => false);
                } else if (role == 'Doctor') {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => DoctorHomeScreen()), (r) => false);
                } else {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => AdminHomeScreen()), (r) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
