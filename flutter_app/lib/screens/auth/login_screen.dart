import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_buttons.dart';
import '../../core/providers/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';
import 'biometric_pin_screen.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../admin/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  final Color color;
  final bool isPhoneMode;

  const LoginScreen({super.key, 
    required this.role,
    required this.color,
    this.isPhoneMode = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || (password.isEmpty && !widget.isPhoneMode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Identifier and Password are required"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (widget.isPhoneMode) {
      // Phone mode routes directly to OTP Verification Screen
      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phone: identifier,
            role: widget.role,
            color: widget.color,
          ),
        ),
      );
      return;
    }

    // Email mode
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProv.login(identifier, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // If patient, doctor, or admin, route dynamically
      Widget dest;
      if (widget.role == 'Doctor') {
        dest = DoctorHomeScreen();
      } else if (widget.role == 'Administrator') {
        dest = AdminHomeScreen();
      } else {
        dest = PatientHomeScreen();
      }
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => dest), (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProv.errorMessage ?? "Login failed"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Login',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A1628),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back, ${widget.role}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 40),

              // Dynamic label based on input type
              TextField(
                controller: _identifierController,
                keyboardType: widget.isPhoneMode ? TextInputType.phone : TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: widget.isPhoneMode ? 'Phone Number' : 'Email Address',
                  hintText: widget.isPhoneMode ? '+1234567890' : '${widget.role.toLowerCase()}@panor.com',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (!widget.isPhoneMode) ...[
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordScreen(color: widget.color),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: widget.isPhoneMode ? 'Verify Phone' : 'Login',
                      color: widget.color,
                      onPressed: _login,
                    ),

              const SizedBox(height: 24),
              
              // Enter via PIN Option Link
              if (!widget.isPhoneMode)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BiometricPinScreen(
                            email: _identifierController.text.trim().isEmpty 
                              ? 'admin@panor.com' 
                              : _identifierController.text.trim(),
                            role: widget.role,
                            color: widget.color,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Or Authorize using PIN',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
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
