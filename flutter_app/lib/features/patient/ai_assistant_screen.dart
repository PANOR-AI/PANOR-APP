import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class AiAssistantScreen extends StatefulWidget {
  final String? initialText;
  const AiAssistantScreen({super.key, this.initialText});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'ai',
      'text': "Salam! I am the PANOR clinical intake agent. I can assist you in English, Urdu, or Roman Urdu. Please describe what you are experiencing today.",
      'time': 'Just now',
    });

    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      // Simulate receipt of speech input
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSendMessage(widget.initialText!);
      });
    }
  }

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': 'Just now',
      });
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI clinical analysis
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        
        bool isCardiacSuspicion = text.toLowerCase().contains('dard') || text.toLowerCase().contains('chest') || text.toLowerCase().contains('pain');
        
        if (isCardiacSuspicion) {
          _messages.add({
            'sender': 'ai',
            'text': "⚠️ **CRITICAL CLINICAL OBSERVATION DETECTED**\n\nI have detected symptoms matching potential cardiovascular distress (Chest discomfort/pain). \n\n**Action Taken:**\n- Alerted **Dr. Amit Verma** via STAT emergency pipeline.\n- Order pre-authorized: **Lipid Profile STAT & ECG**.\n\n*Please remain seated and avoid physical strain. A clinical member has been notified.*",
            'time': 'Just now',
            'isAlert': true,
            'confidence': '96.2%',
          });
        } else {
          _messages.add({
            'sender': 'ai',
            'text': "I have logged your symptoms of mild discomfort and fatigue. \n\n**Analysis (Agent 02):**\n- Core translation: 'Patient experiencing exhaustion over 24-hour cycle.'\n- Clinical index: Outbreak baseline matching viral trends is low (2.4%).\n\nWould you like me to book a general checkup consultation with Dr. Amit Verma?",
            'time': 'Just now',
            'confidence': '91.8%',
          });
        }
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.patientPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: AppColors.patientPrimary, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PANOR Clinical AI',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                ),
                Text(
                  'Active Intake Terminal',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['sender'] == 'user';
                  final isAlert = msg['isAlert'] == true;

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.patientPrimary
                            : (isAlert ? AppColors.error.withValues(alpha: 0.05) : Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                        border: Border.all(
                          color: isUser
                              ? Colors.transparent
                              : (isAlert ? AppColors.error.withValues(alpha: 0.2) : AppColors.border),
                        ),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser && msg['confidence'] != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isAlert ? AppColors.error.withValues(alpha: 0.1) : AppColors.patientPrimary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'AI AGENT 02',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isAlert ? AppColors.error : AppColors.patientPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Confidence: ${msg['confidence']}',
                                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            msg['text'],
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              color: isUser ? Colors.white : (isAlert ? AppColors.error : AppColors.textPrimary),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.patientPrimary)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Google Antigravity reasoning in progress...',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask or type symptoms (e.g. Roman Urdu: "sar me dard hai")...',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      style: GoogleFonts.inter(fontSize: 14),
                      onSubmitted: (val) => _handleSendMessage(val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: AppColors.patientPrimary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: () => _handleSendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
