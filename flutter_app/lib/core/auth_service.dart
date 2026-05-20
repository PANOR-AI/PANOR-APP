import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app/core/constants/app_constants.dart';

class AuthService {
  static String get baseUrl => AppConstants.apiBase;
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // ── SECURE STORAGE HELPERS ────────────────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: _tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> getToken() async =>
      await _storage.read(key: _tokenKey);

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ── REGISTRATION ──────────────────────────────────────────────────────────
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
        return errors.isNotEmpty
            ? errors.join(', ')
            : decoded['message'] ?? 'Registration failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── LOGIN ─────────────────────────────────────────────────────────────────
  static Future<String?> login(String email, String password) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/login'));
      request.fields.addAll({'username': email, 'password': password});
      var response = await request.send();

      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();
        var json = jsonDecode(body);
        final token = json['access_token'] as String;
        final refreshToken = json['refresh_token'] as String?;

        await _storage.write(key: _tokenKey, value: token);
        if (refreshToken != null) {
          await _storage.write(key: _refreshTokenKey, value: refreshToken);
        }
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

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    try {
      final headers = await _headers();
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
      );
    } catch (_) {}
    await _storage.deleteAll();
  }

  // ── REFRESH TOKEN ─────────────────────────────────────────────────────────
  static Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return 'No refresh token available';

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh?token=${Uri.encodeQueryComponent(refreshToken)}'),
        headers: {'Content-Type': 'application/json'},
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final newToken = decoded['access_token'] as String;
        await _storage.write(key: _tokenKey, value: newToken);
        return null;
      } else {
        return decoded['detail'] ?? 'Token refresh failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── GET CURRENT USER (GET /api/auth/me) ───────────────────────────────────
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return decoded['data'] as Map<String, dynamic>?;
        }
      }
    } catch (_) {}
    return null;
  }

  // ── FORGOT PASSWORD ───────────────────────────────────────────────────────
  static Future<String?> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        return null;
      } else {
        return decoded['message'] ?? 'Request failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── RESET PASSWORD WITH OTP ────────────────────────────────────────────────
  static Future<String?> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        }),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        return null;
      } else {
        return decoded['message'] ?? 'Password reset failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── REQUEST OTP (phone login) ──────────────────────────────────────────────
  static Future<(String?, String?)> requestOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/request-otp?phone=${Uri.encodeQueryComponent(phone)}'),
        headers: {'Content-Type': 'application/json'},
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        final otp = decoded['data']?['otp_for_testing']?.toString();
        return (null, otp);
      } else {
        return ((decoded['message'] ?? 'OTP request failed').toString(), null);
      }
    } catch (e) {
      return ('Network error: $e', null);
    }
  }

  // ── VERIFY OTP ────────────────────────────────────────────────────────────
  static Future<String?> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp?phone=${Uri.encodeQueryComponent(phone)}&otp=$otp'),
        headers: {'Content-Type': 'application/json'},
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        final token = decoded['data']?['access_token'] as String?;
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
        }
        return null;
      } else {
        return decoded['message'] ?? 'OTP verification failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── SET PIN ───────────────────────────────────────────────────────────────
  static Future<String?> setPin(String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/set-pin?pin=$pin'),
        headers: await _headers(),
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        return null;
      }
      return decoded['message'] ?? 'PIN setup failed';
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── VERIFY PIN ────────────────────────────────────────────────────────────
  static Future<String?> verifyPin(String email, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-pin?email=${Uri.encodeQueryComponent(email)}&pin=$pin'),
        headers: {'Content-Type': 'application/json'},
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        final token = decoded['data']?['access_token'] as String?;
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
        }
        return null;
      }
      return decoded['message'] ?? 'PIN verification failed';
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── DASHBOARDS ────────────────────────────────────────────────────────────
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

  // ── PATIENT ENDPOINTS ─────────────────────────────────────────────────────
  static Future<List<dynamic>> getVitalsHistory() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/health-records/vitals'), headers: await _headers());
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body);
        return d['success'] == true ? (d['data'] as List? ?? []) : [];
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> logVitals({required String bp, required String hr, required double temp, required int oxygen}) async {
    try {
      final r = await http.post(Uri.parse('$baseUrl/health-records/vitals'), headers: await _headers(),
          body: jsonEncode({'blood_pressure': bp, 'heart_rate': hr, 'temperature': temp, 'oxygen_level': oxygen}));
      final d = jsonDecode(r.body);
      return r.statusCode == 200 && d['success'] == true;
    } catch (_) { return false; }
  }

  static Future<List<dynamic>> getPrescriptions() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/patients/prescriptions'), headers: await _headers());
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? (d['data'] as List? ?? []) : []; }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getLabReports() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/patients/lab-reports'), headers: await _headers());
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? (d['data'] as List? ?? []) : []; }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getMedications() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/patients/medications'), headers: await _headers());
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? (d['data'] as List? ?? []) : []; }
    } catch (_) {}
    return [];
  }

  // ── APPOINTMENTS ──────────────────────────────────────────────────────────
  static Future<List<dynamic>> getAppointments() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/appointments'), headers: await _headers());
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? (d['data'] as List? ?? []) : []; }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getDoctorsList() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/doctors/list'), headers: await _headers());
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? (d['data'] as List? ?? []) : []; }
    } catch (_) {}
    return [];
  }

  static Future<bool> bookAppointment({required String doctorId, required String datetime, required String specialty, required String type, required String notes}) async {
    try {
      final r = await http.post(Uri.parse('$baseUrl/appointments'), headers: await _headers(),
          body: jsonEncode({'doctor_id': doctorId, 'datetime': datetime, 'specialty': specialty, 'type': type, 'notes': notes}));
      final d = jsonDecode(r.body);
      return r.statusCode == 200 && d['success'] == true;
    } catch (_) { return false; }
  }

  // ── NOTIFICATIONS ─────────────────────────────────────────────────────────
  static Future<List<dynamic>> getNotifications() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/notifications'), headers: await _headers());
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? (d['data'] as List? ?? []) : []; }
    } catch (_) {}
    return [];
  }

  static Future<bool> markNotificationRead(String id) async {
    try {
      final r = await http.patch(Uri.parse('$baseUrl/notifications/$id/read'), headers: await _headers());
      final d = jsonDecode(r.body);
      return r.statusCode == 200 && d['success'] == true;
    } catch (_) { return false; }
  }

  // ── AI ASSISTANT ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> runAIConsultation(String textInput) async {
    try {
      final headers = await _headers();
      headers.remove('Content-Type');
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ai-assistant/consultation'));
      request.headers.addAll(headers);
      request.fields['text_input'] = textInput;
      var response = await request.send();
      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();
        final decoded = jsonDecode(body);
        return decoded['success'] == true ? decoded['data'] as Map<String, dynamic>? : null;
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> runAIChat(String message, {String? sessionId}) async {
    try {
      final r = await http.post(Uri.parse('$baseUrl/ai-assistant/chat'), headers: await _headers(),
          body: jsonEncode({'message': message, if (sessionId != null) 'session_id': sessionId}));
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? d['data'] as Map<String, dynamic>? : null; }
    } catch (_) {}
    return null;
  }

  // ── DOCTOR ENDPOINTS ──────────────────────────────────────────────────────
  static Future<List<dynamic>> getDoctorPatients() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/doctors/patients'), headers: await _headers());
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? (d['data'] as List? ?? []) : []; }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getPatientDetail(String patientId) async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/doctors/patients/$patientId'), headers: await _headers());
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? d['data'] as Map<String, dynamic>? : null; }
    } catch (_) {}
    return null;
  }

  // ── ADMIN OPERATIONS ──────────────────────────────────────────────────────
  static Future<List<dynamic>> adminGetUsers() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/admin/users'), headers: await _headers());
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? (d['data'] as List? ?? []) : []; }
    } catch (_) {}
    return [];
  }

  static Future<bool> adminDeactivateUser(String userId) async {
    try {
      final r = await http.patch(Uri.parse('$baseUrl/admin/users/$userId/deactivate'), headers: await _headers());
      final d = jsonDecode(r.body);
      return r.statusCode == 200 && d['success'] == true;
    } catch (_) { return false; }
  }

  static Future<List<dynamic>> adminGetAuditLogs() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/admin/audit-logs'), headers: await _headers());
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? (d['data'] as List? ?? []) : []; }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> adminGetAnalytics() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/admin/analytics'), headers: await _headers());
      if (r.statusCode == 200) { final d = jsonDecode(r.body); return d['success'] == true ? d['data'] as Map<String, dynamic>? : null; }
    } catch (_) {}
    return null;
  }
}
