import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/ai_provider.dart';

class AIAssistantScreen extends StatefulWidget {
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
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clinical AI Co-Pilot',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0A1628)),
            ),
            Text(
              'Powered by Google Antigravity',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF0066FF), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
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
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0066FF))),
                ),
              ),
            ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Enter clinical complaints or ask a question...',
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0066FF),
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
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0066FF).withOpacity(0.05),
              ),
              child: const Icon(Icons.psychology_outlined, size: 64, color: Color(0xFF0066FF)),
            ),
            const SizedBox(height: 24),
            Text(
              'How are you feeling today?',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
            ),
            const SizedBox(height: 8),
            Text(
              'Describe your symptoms in detail below. Our multi-agent clinical co-pilot will perform structured diagnostic reasoning, drug-safety check, lab analysis, and generate a formal SOAP note.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF0066FF) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 0),
          bottomRight: Radius.circular(isUser ? 0 : 16),
        ),
        border: isUser ? null : Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: isUser
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: isUser ? Colors.white : const Color(0xFF0A1628),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: Color(0xFF0066FF), size: 22),
              const SizedBox(width: 8),
              Text(
                'Clinical SOAP Outcomes',
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          
          if (soap.isNotEmpty) ...[
            _buildSOAPSection('Subjective Complaint', soap['subjective']?.toString() ?? 'N/A'),
            _buildSOAPSection('Objective History', soap['objective']?.toString() ?? 'N/A'),
            _buildSOAPSection('Clinical Assessment', soap['assessment']?.toString() ?? 'N/A'),
            _buildSOAPSection('Treatment Plan', soap['plan']?.toString() ?? 'N/A'),
          ],

          if (prescriptions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Medication Instructions',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
            ),
            const SizedBox(height: 6),
            ...prescriptions.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('- $m', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                )),
          ],

          if (recommendedLabs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Required Laboratory Tests',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
            ),
            const SizedBox(height: 6),
            ...recommendedLabs.map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('- $l', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                )),
          ],

          const Divider(height: 32, color: Color(0xFFF1F5F9)),

          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: Color(0xFF0066FF), size: 20),
              const SizedBox(width: 8),
              Text(
                'Sequential Agent Reasoning Traces',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (traces.isEmpty)
            Text(
              'No records available',
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
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

                return ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr['agent']?.toString() ?? 'Clinical Agent',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0A1628)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$percentage% Conf.',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0066FF)),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reasoning Steps:',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
                          ),
                          const SizedBox(height: 4),
                          ...((tr['reasoning'] as List? ?? []).map((step) => Padding(
                                padding: const EdgeInsets.only(bottom: 2.0),
                                child: Text('- $step', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                              ))),
                        ],
                      ),
                    ),
                  ],
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
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0A1628)),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.4),
          ),
        ],
      ),
    );
  }
}
