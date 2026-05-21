import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../admin/admin_home_screen.dart';
import '../../features/lab/lab_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  final Color color;
  final bool isPhoneMode;

  const LoginScreen({
    super.key,
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
  bool _obscurePassword = true;

  String _getHint() {
    if (widget.isPhoneMode) return '+92 3XX XXXXXXX';
    switch (widget.role) {
      case 'Doctor':
        return 'doctor@panor.com';
      case 'Lab':
        return 'lab@panor.com';
      case 'Administrator':
        return 'admin@panor.com';
      default:
        return 'patient@panor.com';
    }
  }

  void _login() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || (password.isEmpty && !widget.isPhoneMode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (widget.isPhoneMode) {
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

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProv.login(identifier, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Widget dest;
      // Route based on selected role (not just API role, since role might differ)
      final apiRole = authProv.role ?? widget.role;
      if (apiRole == 'Doctor') {
        dest = DoctorHomeScreen();
      } else if (apiRole == 'Administrator') {
        dest = AdminHomeScreen();
      } else if (apiRole == 'Lab') {
        dest = const LabHomeScreen();
      } else {
        dest = PatientHomeScreen();
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => dest),
        (r) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProv.errorMessage ?? 'Login failed — check credentials'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.role.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Secure Login',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isPhoneMode
                    ? 'Enter your phone number to receive OTP'
                    : 'Enter your credentials to access your portal',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF8892A4),
                ),
              ),
              const SizedBox(height: 40),

              // Identifier field
              Text(
                widget.isPhoneMode ? 'Phone Number' : 'Email Address',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8892A4),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _identifierController,
                keyboardType: widget.isPhoneMode
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _getHint(),
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF4A5568)),
                  prefixIcon: Icon(
                    widget.isPhoneMode ? Icons.phone_rounded : Icons.email_outlined,
                    color: const Color(0xFF8892A4),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF131929),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1E2A3A)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1E2A3A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: widget.color, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              if (!widget.isPhoneMode) ...[
                Text(
                  'Password',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8892A4),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF4A5568)),
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: Color(0xFF8892A4), size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF8892A4),
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF131929),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF1E2A3A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF1E2A3A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: widget.color, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ForgotPasswordScreen(color: widget.color),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                          strokeWidth: 2.5,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.isPhoneMode ? 'Send OTP' : 'Login Securely',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // Security note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131929),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2A3A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded,
                        size: 16, color: Color(0xFF8892A4)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Secured with end-to-end encryption. Your data is protected under HIPAA-grade protocols.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF8892A4),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
