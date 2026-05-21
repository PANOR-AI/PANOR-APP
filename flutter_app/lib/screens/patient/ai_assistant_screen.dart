import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/ai_provider.dart';
import '../../theme/app_colors.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  _AIAssistantScreenState createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    final aiProv = Provider.of<AIProvider>(context, listen: false);
    
    // Choose whether to trigger full Antigravity consultation or generic chat assistant
    if (text.toLowerCase().contains('consult') || text.toLowerCase().contains('symptom') || text.length > 30) {
      await aiProv.runClinicalConsultation(text);
    } else {
      await aiProv.sendChatMessage(text);
    }

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiProv = Provider.of<AIProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clinical AI Co-Pilot',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            Text(
              'Powered by Google Antigravity',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.patientPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () => aiProv.clearConversation(),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: aiProv.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: aiProv.messages.length,
                    itemBuilder: (context, index) {
                      final msg = aiProv.messages[index];
                      final isUser = msg['role'] == 'user';
                      
                      return Column(
                        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          _buildChatBubble(msg['content']?.toString() ?? '', isUser),
                          if (!isUser && msg['has_traces'] == true && aiProv.latestConsultation != null) ...[
                            const SizedBox(height: 16),
                            _buildClinicalOutcomesCard(context, aiProv.latestConsultation!),
                          ],
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
          
          if (aiProv.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.patientPrimary)),
                ),
              ),
            ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter clinical complaints or ask a question...',
                        hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.patientPrimary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.patientGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.patientPrimary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.patientGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.patientPrimary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.psychology_outlined, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              'How are you feeling today?',
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Describe your symptoms in detail below. Our multi-agent clinical co-pilot will perform structured diagnostic reasoning, drug-safety check, lab analysis, and generate a formal SOAP note.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 24),
            // Quick-start suggestion chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip("Severe migraine and nausea since morning"),
                _buildSuggestionChip("Mild chest pain and shortness of breath"),
                _buildSuggestionChip("Persistent fever and dry cough for 3 days"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
      ),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        _msgCtrl.text = text;
      },
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: isUser ? AppColors.patientGradient : null,
        color: isUser ? null : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 0),
          bottomRight: Radius.circular(isUser ? 0 : 16),
        ),
        border: isUser ? null : Border.all(color: AppColors.border),
        boxShadow: isUser
            ? [
                BoxShadow(
                  color: AppColors.patientPrimary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: Colors.white,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildClinicalOutcomesCard(BuildContext context, Map<String, dynamic> data) {
    final finalState = data['final_state'] as Map? ?? {};
    final soap = finalState['soap_note'] as Map? ?? {};
    final recommendedLabs = finalState['recommended_labs'] as List? ?? [];
    final prescriptions = finalState['prescriptions'] as List? ?? [];
    final traces = data['traces'] as List? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: AppColors.patientPrimary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Clinical SOAP Outcomes',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          
          if (soap.isNotEmpty) ...[
            _buildSOAPSection('Subjective Complaint', soap['subjective']?.toString() ?? 'N/A'),
            _buildSOAPSection('Objective History', soap['objective']?.toString() ?? 'N/A'),
            _buildSOAPSection('Clinical Assessment', soap['assessment']?.toString() ?? 'N/A'),
            _buildSOAPSection('Treatment Plan', soap['plan']?.toString() ?? 'N/A'),
          ],

          if (prescriptions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.medication_outlined, color: AppColors.success, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Medication Instructions',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...prescriptions.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          if (recommendedLabs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.science_outlined, color: AppColors.brandBlue, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Required Laboratory Tests',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...recommendedLabs.map((l) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.biotech, color: AppColors.brandBlue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          const Divider(height: 32, color: AppColors.border),

          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.patientPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sequential Agent Reasoning Traces',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (traces.isEmpty)
            Text(
              'No records available',
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: traces.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tr = traces[index] as Map;
                final double confidence = (tr['confidence'] as num? ?? 1.0).toDouble();
                final percentage = (confidence * 100).toInt();

                return Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    unselectedWidgetColor: AppColors.textSecondary,
                  ),
                  child: ExpansionTile(
                    backgroundColor: AppColors.surfaceVariant,
                    collapsedBackgroundColor: AppColors.surfaceVariant,
                    textColor: Colors.white,
                    collapsedTextColor: AppColors.textSecondary,
                    iconColor: AppColors.patientPrimary,
                    collapsedIconColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr['agent']?.toString() ?? 'Clinical Agent',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.patientPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.patientPrimary.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            '$percentage% Conf.',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.patientAccent),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reasoning Steps:',
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            ...((tr['reasoning'] as List? ?? []).map((step) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ', style: TextStyle(color: AppColors.patientAccent)),
                                      Expanded(
                                        child: Text(
                                          step,
                                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSOAPSection(String title, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

