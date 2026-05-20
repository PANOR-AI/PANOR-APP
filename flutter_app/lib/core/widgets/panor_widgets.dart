/// PANOR Shared Widget Library — Production-Grade Medical UI Components
///
/// Every widget in this file is:
/// - const-safe for maximum performance
/// - Themed via AppColors tokens
/// - Self-contained and reusable across all features
/// - Accessible with proper semantics
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../constants/app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1: Emergency & Status Banners
// ─────────────────────────────────────────────────────────────────────────────

/// Full-width emergency alert banner shown at the top of clinical screens.
/// Severity: CRITICAL (red), WARNING (amber), INFO (blue)
class EmergencyBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmergencyLevel level;

  const EmergencyBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.level = EmergencyLevel.critical,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      EmergencyLevel.critical => AppColors.emergencyRed,
      EmergencyLevel.warning => AppColors.warning,
      EmergencyLevel.info => AppColors.info,
    };

    final icon = switch (level) {
      EmergencyLevel.critical => Icons.emergency_rounded,
      EmergencyLevel.warning => Icons.warning_amber_rounded,
      EmergencyLevel.info => Icons.info_rounded,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.pagePadding,
        vertical: AppConstants.spaceMD,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.3), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppConstants.iconMD),
          ),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSM,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: AppConstants.spaceSM),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontXS,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum EmergencyLevel { critical, warning, info }

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2: Confidence & Priority Chips
// ─────────────────────────────────────────────────────────────────────────────

/// Pill-shaped confidence indicator chip used in AI diagnostic panels.
class ConfidenceChip extends StatelessWidget {
  final double confidence; // 0.0 - 1.0
  final String? label;

  const ConfidenceChip({super.key, required this.confidence, this.label});

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).round();
    final color = pct >= 80
        ? AppColors.emergencyRed
        : pct >= 60
            ? AppColors.warning
            : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label ?? '$pct%',
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontXS,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Priority label chip: STAT / URGENT / ROUTINE
class PriorityChip extends StatelessWidget {
  final String priority; // 'STAT', 'URGENT', 'ROUTINE'

  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (priority.toUpperCase()) {
      'STAT' => (AppColors.emergencyRed, Icons.flash_on_rounded),
      'URGENT' => (AppColors.warning, Icons.priority_high_rounded),
      _ => (AppColors.success, Icons.check_circle_outline_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            priority.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3: Clinical Cards
// ─────────────────────────────────────────────────────────────────────────────

/// Standard medical information card with optional accent left border.
class ClinicalCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const ClinicalCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppConstants.cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: accentColor != null
            ? IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMD),
                    Expanded(child: child),
                  ],
                ),
              )
            : child,
      ),
    );
  }
}

/// Vital sign card: shows a metric, value, unit, and trend indicator.
class VitalCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isAlert;
  final String? trend; // '↑' '↓' '→'

  const VitalCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.isAlert = false,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isAlert ? AppColors.emergencyRed : color;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAlert
            ? AppColors.emergencyRed.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: isAlert
              ? AppColors.emergencyRed.withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
          width: isAlert ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: effectiveColor, size: AppConstants.iconMD),
              if (trend != null)
                Text(trend!, style: TextStyle(color: effectiveColor, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppConstants.spaceXS),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontXS,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontXL,
                  fontWeight: FontWeight.w800,
                  color: effectiveColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontXS,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 4: AI Reasoning Block
// ─────────────────────────────────────────────────────────────────────────────

/// Displays an AI agent's reasoning result with diagnosis, confidence, risk.
class DiagnosisCard extends StatelessWidget {
  final String diagnosis;
  final double confidence;
  final String risk; // 'High', 'Moderate', 'Low'
  final String evidence;
  final int rank;

  const DiagnosisCard({
    super.key,
    required this.diagnosis,
    required this.confidence,
    required this.risk,
    required this.evidence,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = switch (risk.toLowerCase()) {
      'high' => AppColors.emergencyRed,
      'moderate' => AppColors.warning,
      _ => AppColors.success,
    };

    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.brandIndigo,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spaceSM),
              Expanded(
                child: Text(
                  diagnosis,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontMD,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ConfidenceChip(confidence: confidence),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSM),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  '${risk.toUpperCase()} RISK',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: riskColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceXS),
          Text(
            evidence,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontXS,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 5: Timeline Tile
// ─────────────────────────────────────────────────────────────────────────────

/// A single entry in the patient medical timeline / health ledger.
class TimelineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color color;
  final bool isLast;
  final VoidCallback? onTap;

  const TimelineTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spaceMD),
          // Content
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : AppConstants.spaceLG),
                padding: const EdgeInsets.all(AppConstants.cardPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontMD,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          date,
                          style: GoogleFonts.inter(
                            fontSize: AppConstants.fontXS,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSM,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 6: Section Header
// ─────────────────────────────────────────────────────────────────────────────

/// Standardized section divider with title and optional action button.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: AppConstants.fontLG,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A1628),
            letterSpacing: -0.3,
          ),
        ),
        trailing ??
            (actionLabel != null
                ? GestureDetector(
                    onTap: onAction,
                    child: Text(
                      actionLabel!,
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPurple,
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 7: Loading States
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton shimmer loader card for list items
class SkeletonCard extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 80,
    this.width,
    this.borderRadius = AppConstants.radiusLG,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF1F5F9),
              Color.lerp(const Color(0xFFF1F5F9), const Color(0xFFE2E8F0), _anim.value) ??
                  const Color(0xFFF1F5F9),
              const Color(0xFFF1F5F9),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen AI processing state overlay
class ProcessingOverlay extends StatelessWidget {
  final String message;
  final String? agentName;

  const ProcessingOverlay({super.key, required this.message, this.agentName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.brandIndigo.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandIndigo),
            ),
          ),
          const SizedBox(height: AppConstants.spaceLG),
          if (agentName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.brandPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                agentName!,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontXS,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandPurple,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceMD),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontMD,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 8: Primary Action Button
// ─────────────────────────────────────────────────────────────────────────────

/// Full-width primary clinical action button with loading state support.
class ClinicalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final IconData? icon;
  final bool outlined;

  const ClinicalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.brandIndigo;

    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? const SizedBox.shrink()
                  : Icon(icon ?? Icons.arrow_forward_rounded, size: AppConstants.iconMD),
              label: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: effectiveColor,
                side: BorderSide(color: effectiveColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                ),
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: AppConstants.fontMD),
              ),
            )
          : FilledButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? const SizedBox.shrink()
                  : Icon(icon ?? Icons.arrow_forward_rounded, size: AppConstants.iconMD),
              label: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: effectiveColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                ),
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: AppConstants.fontMD),
              ),
            ),
    );
  }
}
