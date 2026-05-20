import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Emergency Banner — Sticky, animated, non-dismissible RED alert widget.
/// Auto-triggered by Agent 02 when cardiac/respiratory crisis detected.
class EmergencyBanner extends StatefulWidget {
  final String patientName;
  final String condition;
  final int confidencePercent;
  final String detectedAt;
  final String requiredAction;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onEscalate;

  const EmergencyBanner({
    super.key,
    required this.patientName,
    required this.condition,
    required this.confidencePercent,
    required this.detectedAt,
    required this.requiredAction,
    this.onAcknowledge,
    this.onEscalate,
  });

  @override
  State<EmergencyBanner> createState() => _EmergencyBannerState();
}

class _EmergencyBannerState extends State<EmergencyBanner> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.emergencyRed.withValues(alpha: 0.9 + (_pulseAnimation.value * 0.1)),
                AppColors.criticalPulse.withValues(alpha: 0.9 + (_pulseAnimation.value * 0.1)),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.emergencyRed.withValues(alpha: 0.3 + (_pulseAnimation.value * 0.2)),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMERGENCY: ${widget.condition}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.patientName} | ${widget.detectedAt} | Confidence: ${widget.confidencePercent}%',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              if (widget.onAcknowledge != null)
                GestureDetector(
                  onTap: widget.onAcknowledge,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ACK',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emergencyRed,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Masked National Patient ID Badge
class PIdBadge extends StatelessWidget {
  final String maskedPId;
  final bool isVerified;

  const PIdBadge({
    super.key,
    required this.maskedPId,
    this.isVerified = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isVerified 
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isVerified
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.pending_rounded,
            size: 14,
            color: isVerified ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 5),
          Text(
            maskedPId,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isVerified ? AppColors.success : AppColors.warning,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Before/After State Diff Widget for demo walkthrough
class BeforeAfterDiff extends StatelessWidget {
  final String beforeTitle;
  final String afterTitle;
  final Widget beforeContent;
  final Widget afterContent;

  const BeforeAfterDiff({
    super.key,
    this.beforeTitle = 'BEFORE',
    this.afterTitle = 'AFTER',
    required this.beforeContent,
    required this.afterContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Before panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.emergencyRed.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.emergencyRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        beforeTitle,
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.emergencyRed, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                beforeContent,
              ],
            ),
          ),
          // Divider with arrow
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.background,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.brandPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
          // After panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        afterTitle,
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                afterContent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
