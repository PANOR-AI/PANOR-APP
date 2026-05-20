import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth_service.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  final Color color;

  const LoginScreen({super.key, required this.role, required this.color});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill demo emails to make it extremely easy to test!
    if (widget.role == 'Patient') {
      _emailController.text = 'patient@panor.com';
    } else if (widget.role == 'Doctor') {
      _emailController.text = 'doctor@panor.com';
    } else if (widget.role == 'Administrator') {
      _emailController.text = 'admin@panor.com';
    } else if (widget.role == 'Lab Technician') {
      _emailController.text = 'lab@panor.com';
    }
    _passwordController.text = 'password';
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // Use actual AuthService login
    String? error = await AuthService.login(email, password);
    
    setState(() => _isLoading = false);

    if (error == null) {
      if (!mounted) return;
      
      // Successfully authenticated
      if (widget.role == 'Patient') {
        context.go('/patient/home');
      } else if (widget.role == 'Doctor') {
        context.go('/doctor/home');
      } else if (widget.role == 'Lab Technician') {
        context.go('/lab/home');
      } else {
        context.go('/admin/home');
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error), 
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color roleColor = widget.color;
    final LinearGradient buttonGradient = AppColors.gradientForRole(widget.role);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Biometric Fingerprint/Lock Visual matching Screen 4 Mockup
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: roleColor.withValues(alpha: 0.1),
                        border: Border.all(color: roleColor.withValues(alpha: 0.25), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: roleColor.withValues(alpha: 0.15),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.fingerprint_rounded,
                        color: roleColor,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Welcome Headers
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Please login to continue',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Email Input Field
                  TextFormField(
                    controller: _emailController,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email or Patient ID is required';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email or Patient ID',
                      labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      errorStyle: GoogleFonts.inter(color: AppColors.error),
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
                        borderSide: BorderSide(color: roleColor, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password Input Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password is required';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                      prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      errorStyle: GoogleFonts.inter(color: AppColors.error),
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
                        borderSide: BorderSide(color: roleColor, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push('/forgot-password?role=${widget.role}');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Login CTA Button with Glowing Role Gradient
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                          decoration: BoxDecoration(
                            gradient: buttonGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: roleColor.withValues(alpha: 0.35),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  // Login with Biometrics Button matching Mockup Screen 4
                  OutlinedButton.icon(
                    onPressed: () {
                      // Simulated biometric tap
                      _emailController.text = widget.role == 'Patient'
                          ? 'patient@panor.com'
                          : widget.role == 'Doctor'
                              ? 'doctor@panor.com'
                              : widget.role == 'Lab Technician'
                                  ? 'lab@panor.com'
                                  : 'admin@panor.com';
                      _passwordController.text = 'password';
                      _login();
                    },
                    icon: Icon(Icons.fingerprint_rounded, color: Colors.white, size: 20),
                    label: Text(
                      'Login with Biometrics',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.border, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Secure encrypted connection footer matching Mockup Screen 4
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        'Secure-encrypted connection',
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/register?role=${widget.role}');
                        },
                        child: Text(
                          'Register',
                          style: GoogleFonts.inter(
                            color: roleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
