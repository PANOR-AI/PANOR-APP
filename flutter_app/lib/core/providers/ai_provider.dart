import 'package:flutter/material.dart';
import '../auth_service.dart';

class AIProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _latestConsultation;
  String? _sessionId;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get messages => _messages;
  Map<String, dynamic>? get latestConsultation => _latestConsultation;
  String? get sessionId => _sessionId;

  Future<void> sendChatMessage(String message) async {
    _messages.add({'role': 'user', 'content': message});
    _isLoading = true;
    notifyListeners();

    final response = await AuthService.runAIChat(message, sessionId: _sessionId);
    if (response != null) {
      _sessionId = response['session_id'];
      final history = response['history'] as List? ?? [];
      _messages = history.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      _messages.add({
        'role': 'assistant',
        'content': 'I encountered a connection error while trying to process your message.'
      });
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> runClinicalConsultation(String narration) async {
    _messages.add({
      'role': 'user',
      'content': 'Please run a full multi-agent clinical reasoning co-pilot over my complaint:\n"$narration"'
    });
    _isLoading = true;
    _latestConsultation = null;
    notifyListeners();

    final data = await AuthService.runAIConsultation(narration);
    _isLoading = false;
    if (data != null) {
      _latestConsultation = data;
      _sessionId = data['conversation_id'];
      
      final finalState = data['final_state'] as Map? ?? {};
      final soap = finalState['soap_note'] as Map? ?? {};
      
      String responseContent = "### Clinical Consultation Complete\n\n";
      if (soap.isNotEmpty) {
        responseContent += "**SOAP Note Summary**:\n"
            "- **Subjective**: ${soap['subjective'] ?? 'N/A'}\n"
            "- **Objective**: ${soap['objective'] ?? 'N/A'}\n"
            "- **Assessment**: ${soap['assessment'] ?? 'N/A'}\n"
            "- **Plan**: ${soap['plan'] ?? 'N/A'}\n\n";
      }
      
      final diagnoses = finalState['differential_diagnosis'] as List? ?? [];
      if (diagnoses.isNotEmpty) {
        responseContent += "**Differential Diagnoses**: ${diagnoses.join(', ')}\n\n";
      }

      final labs = finalState['recommended_labs'] as List? ?? [];
      if (labs.isNotEmpty) {
        responseContent += "**Recommended Lab Tests**: ${labs.join(', ')}\n\n";
      }
      
      final meds = finalState['prescriptions'] as List? ?? [];
      if (meds.isNotEmpty) {
        responseContent += "**Medications Issued**: ${meds.join(', ')}\n\n";
      }

      _messages.add({
        'role': 'assistant',
        'content': responseContent,
        'has_traces': true,
      });
    } else {
      _messages.add({
        'role': 'assistant',
        'content': 'Clinical consultation pipeline failed. Please check Gemini API Key quotas or connection statuses.'
      });
    }
    notifyListeners();
  }

  void clearConversation() {
    _messages.clear();
    _latestConsultation = null;
    _sessionId = null;
    notifyListeners();
  }
}
