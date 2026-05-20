import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../core/widgets/panor_widgets.dart';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> with SingleTickerProviderStateMixin {
  late AnimationController _waveformController;
  final List<double> _waveformHeights = List.generate(24, (index) => 4.0);
  bool _isListening = false;
  String _transcription = 'Tap the microphone to start clinical intake reasoning...';
  String _detectedLanguage = 'None';
  bool _emergencyDetected = false;
  Timer? _transcriptionTimer;
  Timer? _waveformTimer;
  int _speechTick = 0;

  final List<String> _simulatedSpeechStepsUrdu = [
    "Mujhe...",
    "Mujhe kal se...",
    "Mujhe kal se halka bukhar hai...",
    "Mujhe kal se halka bukhar hai aur thakan mehsoos...",
    "Mujhe kal se halka bukhar hai aur thakan mehsoos ho rahi hai aur seene me dard...",
    "⚠️ ALERT: Mujhe kal se halka bukhar hai aur thakan mehsoos ho rahi hai aur seene me dard hai."
  ];

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveformController.dispose();
    _transcriptionTimer?.cancel();
    _waveformTimer?.cancel();
    super.dispose();
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _transcription = 'Listening... Speak now.';
      _detectedLanguage = 'Detecting...';
      _emergencyDetected = false;
      _speechTick = 0;
    });

    // Animate waveform
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _waveformHeights.length; i++) {
          _waveformHeights[i] = 10 + (30 * (1.0 + (_waveformController.value * (i % 3 - 1).abs())) * (i % 2 == 0 ? 0.8 : 1.2)).clamp(5, 50);
        }
      });
    });

    // Simulate speech transcription steps
    _transcriptionTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) return;
      if (_speechTick < _simulatedSpeechStepsUrdu.length) {
        setState(() {
          _transcription = _simulatedSpeechStepsUrdu[_speechTick];
          _detectedLanguage = 'Roman Urdu (ur-PK)';
          
          // Emergency trigger terms
          if (_transcription.contains('seene me dard') || _transcription.contains('seene mein dard')) {
            _emergencyDetected = true;
          }
          _speechTick++;
        });
      } else {
        _stopListening();
      }
    });
  }

  void _stopListening() {
    _transcriptionTimer?.cancel();
    _waveformTimer?.cancel();
    setState(() {
      _isListening = false;
      if (_speechTick == 0) {
        _transcription = 'Tap the microphone to start clinical intake reasoning...';
        _detectedLanguage = 'None';
      }
      for (int i = 0; i < _waveformHeights.length; i++) {
        _waveformHeights[i] = 4.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Multilingual Voice Symptom Intake',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isListening ? Colors.red : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isListening ? 'LIVE TRANSCRIBING' : 'READY TO RECORD',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _isListening ? Colors.red : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          if (_detectedLanguage != 'None')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.patientPrimary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _detectedLanguage,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.patientPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _transcription,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              color: _emergencyDetected ? AppColors.emergencyRed : AppColors.textPrimary,
                              fontWeight: _isListening ? FontWeight.w500 : FontWeight.w400,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                      if (_emergencyDetected) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.emergencyRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.emergency_rounded, color: AppColors.emergencyRed, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Critical Emergency Trigger Detected',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.emergencyRed,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Terms matching cardiac event ("seene me dard") will instantly alert Doctor Triage queues.',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Waveform Display
              SizedBox(
                height: 60,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _waveformController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: MedicalWavePainter(
                        animationValue: _isListening ? _waveformController.value : 0.0,
                        isListening: _isListening,
                        isEmergency: _emergencyDetected,
                        waveColor: _emergencyDetected ? AppColors.emergencyRed : AppColors.patientPrimary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Mic Button
              Center(
                child: GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? (_emergencyDetected ? AppColors.emergencyRed : AppColors.patientPrimary)
                          : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppColors.elevatedShadow,
                      border: Border.all(
                        color: _isListening ? Colors.transparent : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic_none_rounded,
                        color: _isListening ? Colors.white : AppColors.patientPrimary,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!_isListening && _speechTick > 0)
                ClinicalButton(
                  label: 'Transmit Intake to Clinical Copilot',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _emergencyDetected
                              ? 'Urgent Intake flagged! Dr. Fatima Hassan has been alerted STAT.'
                              : 'Intake transmitted successfully to clinical copilot!',
                        ),
                        backgroundColor: _emergencyDetected ? AppColors.emergencyRed : AppColors.success,
                      ),
                    );
                    Navigator.pop(context, _transcription);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicalWavePainter extends CustomPainter {
  final double animationValue;
  final bool isListening;
  final bool isEmergency;
  final Color waveColor;

  MedicalWavePainter({
    required this.animationValue,
    required this.isListening,
    required this.isEmergency,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isListening) {
      // Draw a flat baseline
      final paint = Paint()
        ..color = waveColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
      return;
    }

    final int waveCount = 3;
    final List<double> phaseShifts = [0.0, 1.2, 2.4];
    final List<double> amplitudes = [size.height * 0.4, size.height * 0.25, size.height * 0.15];
    final List<double> opacities = [0.8, 0.4, 0.2];

    for (int w = 0; w < waveCount; w++) {
      final paint = Paint()
        ..color = waveColor.withValues(alpha: opacities[w])
        ..style = PaintingStyle.stroke
        ..strokeWidth = w == 0 ? 3.0 : 1.5;

      final path = Path();
      path.moveTo(0, size.height / 2);

      for (double x = 0; x <= size.width; x += 2) {
        final double normalizedX = x / size.width;
        // Dampen waves at ends
        final double dampening = 1.0 - (2.0 * normalizedX - 1.0).abs();
        final double phase = animationValue * 2 * math.pi * 2 - phaseShifts[w];
        final double angle = normalizedX * 2 * math.pi * 2.5 + phase;
        final double y = size.height / 2 + math.sin(angle) * amplitudes[w] * dampening;
        
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MedicalWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isListening != isListening ||
        oldDelegate.isEmergency != isEmergency;
  }
}
