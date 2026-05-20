import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/auth_service.dart';
import '../patient/patient_home_screen.dart';
import '../doctor/doctor_home_screen.dart';
import '../admin/admin_home_screen.dart';

class BiometricPinScreen extends StatefulWidget {
  final String email;
  final String role;
  final Color color;

  const BiometricPinScreen({
    required this.email,
    required this.role,
    required this.color,
  });

  @override
  _BiometricPinScreenState createState() => _BiometricPinScreenState();
}

class _BiometricPinScreenState extends State<BiometricPinScreen> {
  String _pin = '';
  bool _isLoading = false;

  void _keypadTap(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin += value;
      });
      if (_pin.length == 4) {
        _verify();
      }
    }
  }

  void _backspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _verify() async {
    setState(() => _isLoading = true);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProv.verifyPin(widget.email, _pin);
    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
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
      setState(() {
        _pin = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProv.error ?? 'Verification failed'), backgroundColor: Colors.red),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Enter PIN',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A1628),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your 4-digit PIN to authorize',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 40),
              
              // Dots representation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  bool filled = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? widget.color : Colors.transparent,
                      border: Border.all(color: widget.color, width: 2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
              const Spacer(),
              
              // Custom Numeric Keypad
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 40,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  if (index == 9) {
                    return const SizedBox.shrink(); // empty bottom-left slot
                  }
                  if (index == 11) {
                    return IconButton(
                      icon: const Icon(Icons.backspace_outlined, size: 28),
                      onPressed: _backspace,
                    );
                  }
                  String label = index == 10 ? '0' : '${index + 1}';
                  return InkWell(
                    onTap: () => _keypadTap(label),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A1628),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
