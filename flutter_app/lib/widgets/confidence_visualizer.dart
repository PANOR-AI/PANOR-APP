import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Confidence Visualizer — Shows AI agent confidence as animated progress bar
/// with color coding and expandable "Why?" reasoning tooltip.
class ConfidenceBar extends StatelessWidget {
  final String label;
  final double confidence; // 0.0 - 1.0
  final String? reasoning;
  final String? agentName;

  const ConfidenceBar({
    super.key,
    required this.label,
    required this.confidence,
    this.reasoning,
    this.agentName,
  });

  Color get _barColor {
    if (confidence >= 0.9) return AppColors.success;
    if (confidence >= 0.7) return AppColors.warning;
    return AppColors.emergencyRed;
  }

  String get _confidenceLabel {
    if (confidence >= 0.9) return 'HIGH';
    if (confidence >= 0.7) return 'MODERATE';
    return 'LOW';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(confidence * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: _barColor),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _barColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _confidenceLabel,
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: _barColor),
                    ),
                  ),
                  if (reasoning != null) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _showReasoningDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.brandPurple.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search_rounded, size: 12, color: AppColors.brandPurple),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: confidence),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: _barColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                  minHeight: 6,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showReasoningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.psychology_rounded, color: AppColors.brandPurple, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                agentName ?? 'AI Reasoning',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          reasoning ?? '',
          style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.brandPurple)),
          ),
        ],
      ),
    );
  }
}

/// Compact agent trace row with confidence bar for use in trace panels.
class AgentTraceWithConfidence extends StatelessWidget {
  final String agentName;
  final String action;
  final String status;
  final double confidence;
  final int latencyMs;
  final String? reasoning;

  const AgentTraceWithConfidence({
    super.key,
    required this.agentName,
    required this.action,
    required this.status,
    required this.confidence,
    required this.latencyMs,
    this.reasoning,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'COMPLETED';
    final isActionRequired = status == 'ACTION_REQUIRED';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActionRequired 
            ? AppColors.warning.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActionRequired 
              ? AppColors.warning.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: isCompleted ? AppColors.success : AppColors.warning,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  agentName,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Text(
                '${latencyMs}ms',
                style: GoogleFonts.inter(fontSize: 10, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            action,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, height: 1.3),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: confidence),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          confidence >= 0.9 ? AppColors.success : AppColors.warning,
                        ),
                        minHeight: 4,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(confidence * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (reasoning != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text(agentName, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                        content: Text(reasoning!, style: GoogleFonts.inter(fontSize: 13, height: 1.5)),
                        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.brandPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Why?', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandPurple)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
