import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_buttons.dart';
import '../../core/auth_service.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../admin/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  final Color color;

  const LoginScreen({required this.role, required this.color});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      // Mock fast path if they just click login for demo
      email = widget.role == 'Patient' ? 'patient@panor.com' : 
              widget.role == 'Doctor' ? 'doctor@panor.com' : 'admin@panor.com';
    }

    String? error = await AuthService.login(email, _passwordController.text.isEmpty ? 'password' : _passwordController.text);
    
    setState(() => _isLoading = false);

    if (error == null) {
      if (widget.role == 'Patient') {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => PatientHomeScreen()), (r) => false);
      } else if (widget.role == 'Doctor') {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => DoctorHomeScreen()), (r) => false);
      } else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => AdminHomeScreen()), (r) => false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Login', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Welcome back, ${widget.role}', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: '${widget.role.toLowerCase()}@panor.com',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : PrimaryButton(
                  text: 'Login',
                  color: widget.color,
                  onPressed: _login,
                ),
          ],
        ),
      ),
    );
  }
}
