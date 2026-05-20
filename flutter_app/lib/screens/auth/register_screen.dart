import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/custom_buttons.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  final Color color;

  const RegisterScreen({super.key, required this.role, required this.color});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  
  bool _isLoading = false;
  String? _serverError;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _serverError = null;
    });

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProv.register(
      email: _emailCtrl.text.trim(),
      fullName: _fullNameCtrl.text.trim(),
      role: widget.role,
      phone: _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login to continue.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to login
    } else {
      setState(() {
        _serverError = authProv.errorMessage;
      });
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Register',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0A1628),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account as a ${widget.role}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 32),

                if (_serverError != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _serverError!,
                      style: GoogleFonts.inter(color: Colors.red, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Full Name
                TextFormField(
                  controller: _fullNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'John Doe',
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
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Full name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'example@panor.com',
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
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!val.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    hintText: '+1234567890',
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

                // Password
                TextFormField(
                  controller: _passwordCtrl,
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
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Password is required';
                    if (val.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        text: 'Register',
                        color: widget.color,
                        onPressed: _register,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
