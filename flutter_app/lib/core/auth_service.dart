import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/core/constants/app_constants.dart';

class AuthService {
  static String get baseUrl => AppConstants.apiBase;
  static String? _sessionToken;
  static String? _sessionRole;

  // ── Helper: Authenticated Headers ──────────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    return {
      'Content-Type': 'application/json',
      if (_sessionToken != null) 'Authorization': 'Bearer $_sessionToken',
    };
  }

  // ── Authentication ────────────────────────────────────────────────────────
  static Future<String?> login(String email, String password) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/login'));
      request.fields.addAll({'username': email, 'password': password});
      var response = await request.send();

      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();
        var json = jsonDecode(body);
        final token = json['access_token'] as String;
        final role = json['role'] as String? ?? '';

        setDemoSession(token: token, role: role);
        return null;
      } else {
        var body = await response.stream.bytesToString();
        final detail = jsonDecode(body)['detail'] ?? 'Invalid credentials';
        return detail.toString();
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  static Future<String?> register({
    required String email,
    required String fullName,
    required String role,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'full_name': fullName,
          'role': role,
          'phone': phone.isEmpty ? null : phone,
          'password': password,
        }),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        return null;
      } else {
        final errors = decoded['errors'] as List? ?? [];
        return errors.isNotEmpty ? errors.join(', ') : decoded['message'] ?? 'Registration failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  static Future<String?> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp?phone=$phone&otp=$otp'),
        headers: {'Content-Type': 'application/json'},
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        final token = decoded['data']['access_token'];
        setDemoSession(token: token, role: _sessionRole ?? 'Patient');
        return null;
      } else {
        return decoded['message'] ?? 'OTP verification failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  static Future<String?> verifyPin(String email, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-pin?email=$email&pin=$pin'),
        headers: {'Content-Type': 'application/json'},
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        final token = decoded['data']['access_token'];
        setDemoSession(token: token, role: _sessionRole ?? 'Patient');
        return null;
      } else {
        return decoded['message'] ?? 'PIN verification failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── Dashboards & Timelines ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getDashboard(String rolePath) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$rolePath/dashboard'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // ── Patient Endpoints ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getPatientProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patients/profile'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] : null;
      }
    } catch (_) {}
    return null;
  }

  static Future<List<dynamic>> getVitalsHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health-records/vitals'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] as List : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> logVitals({
    required String bp,
    required String hr,
    required double temp,
    required int oxygen,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/health-records/vitals'),
        headers: await _headers(),
        body: jsonEncode({
          'blood_pressure': bp,
          'heart_rate': hr,
          'temperature': temp,
          'oxygen_level': oxygen,
        }),
      );
      final decoded = jsonDecode(response.body);
      return response.statusCode == 200 && decoded['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<dynamic>> getPrescriptions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/patients/prescriptions'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] as List : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getLabReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/patients/lab-reports'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] as List : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getMedications() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/patients/medications'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] as List : [];
      }
    } catch (_) {}
    return [];
  }

  // ── Appointment Operations ────────────────────────────────────────────────
  static Future<List<dynamic>> getAppointments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/appointments'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] as List : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> bookAppointment({
    required String doctorId,
    required String datetime,
    required String specialty,
    required String type,
    required String notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: await _headers(),
        body: jsonEncode({
          'doctor_id': doctorId,
          'datetime': datetime,
          'specialty': specialty,
          'type': type,
          'notes': notes,
        }),
      );
      final decoded = jsonDecode(response.body);
      return response.statusCode == 200 && decoded['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notifications'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] as List : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> markNotificationRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: await _headers(),
      );
      final decoded = jsonDecode(response.body);
      return response.statusCode == 200 && decoded['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> markAllNotificationsRead() async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: await _headers(),
      );
      final decoded = jsonDecode(response.body);
      return response.statusCode == 200 && decoded['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // ── AI Assistant Multi-Agent Clinical Consultation ──────────────────────
  static Future<Map<String, dynamic>?> runAIConsultation(String textInput) async {
    try {
      final headers = await _headers();
      headers.remove('Content-Type'); // Let http client auto-boundary multipart
      
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ai-assistant/consultation'));
      request.headers.addAll(headers);
      request.fields.addAll({'text_input': textInput});

      var response = await request.send();
      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();
        final decoded = jsonDecode(body);
        return decoded['success'] == true ? decoded['data'] : null;
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> runAIChat(String message, {String? sessionId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai-assistant/chat'),
        headers: await _headers(),
        body: jsonEncode({
          'message': message,
          if (sessionId != null) 'session_id': sessionId,
        }),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] : null;
      }
    } catch (_) {}
    return null;
  }

  // ── Doctor Endpoints ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getDoctorProfile() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/doctors/profile'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] : null;
      }
    } catch (_) {}
    return null;
  }

  static Future<List<dynamic>> getDoctorPatients() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/doctors/patients'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] as List : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getPatientDetail(String patientId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/doctors/patients/$patientId'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] : null;
      }
    } catch (_) {}
    return null;
  }

  static Future<List<dynamic>> getDoctorsList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/doctors/list'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] as List : [];
      }
    } catch (_) {}
    return [];
  }

  // ── Admin Operations ───────────────────────────────────────────────────────
  static Future<List<dynamic>> adminGetUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/users'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] as List : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> adminDeactivateUser(String userId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/deactivate'),
        headers: await _headers(),
      );
      final decoded = jsonDecode(response.body);
      return response.statusCode == 200 && decoded['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<dynamic>> adminGetAuditLogs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/audit-logs'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] as List : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> adminGetAnalytics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/analytics'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true ? decoded['data'] : null;
      }
    } catch (_) {}
    return null;
  }

  // ── Session ────────────────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    return _sessionToken;
  }

  static Future<String?> getRole() async {
    return _sessionRole;
  }

  static Future<void> logout() async {
    _sessionToken = null;
    _sessionRole = null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static void setDemoSession({required String token, required String role}) {
    _sessionToken = token;
    _sessionRole = role;
  }
}
