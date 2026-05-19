import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_buttons.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.role == 'Patient'
                            ? Icons.person_rounded
                            : widget.role == 'Doctor'
                                ? Icons.medical_services_rounded
                                : widget.role == 'Lab Technician'
                                    ? Icons.biotech_rounded
                                    : Icons.admin_panel_settings_rounded,
                        color: widget.color,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Welcome to PANOR',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Login to your ${widget.role} Workspace',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email is required';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: widget.color, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password is required';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: widget.color, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push('/forgot-password?role=${widget.role}');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          color: widget.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(
                          text: 'Log In',
                          color: widget.color,
                          onPressed: _login,
                        ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.inter(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/register?role=${widget.role}');
                        },
                        child: Text(
                          'Register',
                          style: GoogleFonts.inter(
                            color: widget.color,
                            fontWeight: FontWeight.bold,
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
