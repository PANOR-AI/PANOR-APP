import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';
import 'biometric_pin_screen.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../admin/admin_home_screen.dart';
import '../dashboards/lab_dashboard.dart';

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
  _LoginScreenState createState() => _LoginScreenState();
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
          backgroundColor: AppColors.emergencyRed,
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
    
    setState(() => _isLoading = false);

    if (success) {
      // If patient, doctor, or admin, route dynamically
      Widget dest;
      if (widget.role == 'Doctor') {
        dest = DoctorHomeScreen();
      } else if (widget.role == 'Administrator') {
        dest = AdminHomeScreen();
      } else if (widget.role == 'Lab Assistant') {
        dest = const LabDashboard();
      } else {
        dest = PatientHomeScreen();
      }
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => dest), (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProv.errorMessage ?? "Login failed"), backgroundColor: AppColors.emergencyRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: widget.color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  widget.role.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: widget.color,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Access Portal',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your credentials to securely access the PANOR intelligence network.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // Dynamic label based on input type
              TextField(
                controller: _identifierController,
                keyboardType: widget.isPhoneMode ? TextInputType.phone : TextInputType.emailAddress,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  labelText: widget.isPhoneMode ? 'Mobile Number' : 'Operational Email',
                  labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
                  hintText: widget.isPhoneMode ? '+92 3XX XXXXXXX' : '${widget.role.toLowerCase()}@panor.pk',
                  hintStyle: GoogleFonts.inter(color: AppColors.textMuted.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: widget.color, width: 2),
                  ),
                  prefixIcon: Icon(
                    widget.isPhoneMode ? Icons.phone_android_rounded : Icons.email_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (!widget.isPhoneMode) ...[
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Secure Passphrase',
                    labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: widget.color, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.textMuted),
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
                      'Forgot Passphrase?',
                      style: GoogleFonts.inter(
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),
              
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: widget.color))
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.color,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.isPhoneMode ? 'Send Verification OTP' : 'Authorize & Enter',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
                      'Or Authorize using secure PIN',
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
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
