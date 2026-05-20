import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app/core/constants/app_constants.dart';

class AuthService {
  static String get baseUrl => AppConstants.apiBase;
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // ── Helper: Authenticated Headers ──────────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: _tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── REGISTRATION ──────────────────────────────────────────────────────────
  /// Register new user with email, full name, role, phone, and password
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

  // ── LOGIN ─────────────────────────────────────────────────────────────────
  /// Login with email and password
  static Future<String?> login(String email, String password) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/login'));
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
  /// Invalidate refresh token on server and clear local session
  static Future<void> logout() async {
    try {
      final headers = await _headers();
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
      );
    } catch (_) {}
    
    // Clear local secure storage regardless
    await _storage.deleteAll();
  }

  // ── REFRESH TOKEN ─────────────────────────────────────────────────────────
  /// Get new access token using refresh token
  static Future<String?> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null) {
        return 'No refresh token available';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': refreshToken}),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final newToken = decoded['access_token'] as String;
        await prefs.setString(_tokenKey, newToken);
        return null;
      } else {
        return decoded['detail'] ?? 'Token refresh failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── REQUEST OTP ───────────────────────────────────────────────────────────
  /// Request OTP for phone number verification
  static Future<(String?, String?)> requestOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/request-otp?phone=$phone'),
        headers: {'Content-Type': 'application/json'},
      );
      
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        final otp = decoded['data']['otp_for_testing'] as String?;
        return (null, otp?.toString());
      } else {
        return (
          (decoded['message'] ?? 'OTP request failed').toString(),
          null
        );
      }
    } catch (e) {
      return ('Network error: $e'.toString(), null);
    }
  }

  // ── VERIFY OTP ────────────────────────────────────────────────────────────
  /// Verify OTP and login
  static Future<String?> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp?phone=$phone&otp=$otp'),
        headers: {'Content-Type': 'application/json'},
      );
      
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        final token = decoded['data']['access_token'] as String;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        return null;
      } else {
        return decoded['message'] ?? 'OTP verification failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── SET PIN ───────────────────────────────────────────────────────────────
  /// Set or update user PIN (4-6 digits)
  static Future<String?> setPin(String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/set-pin'),
        headers: await _headers(),
        body: jsonEncode({'pin': pin}),
      );
      
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        return null;
      } else {
        return decoded['message'] ?? 'PIN setup failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── VERIFY PIN ────────────────────────────────────────────────────────────
  /// Verify PIN and login
  static Future<String?> verifyPin(String email, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-pin?email=$email&pin=$pin'),
        headers: {'Content-Type': 'application/json'},
      );
      
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        final token = decoded['data']['access_token'] as String;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        return null;
      } else {
        return decoded['message'] ?? 'PIN verification failed';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // ── FORGOT PASSWORD ───────────────────────────────────────────────────────
  /// Request password reset link
  static Future<(String?, String?)> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );
      
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['success'] == true) {
        final resetToken = decoded['data']['reset_token_for_testing'] as String?;
        return (null, resetToken?.toString());
      } else {
        return (
          (decoded['message'] ?? 'Forgot password request failed').toString(),
          null
        );
      }
    } catch (e) {
      return ('Network error: $e'.toString(), null);
    }
  }

  // ── RESET PASSWORD ────────────────────────────────────────────────────────
  /// Reset password with reset token
  static Future<String?> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'reset_token': resetToken,
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

  // ── GET CURRENT USER ──────────────────────────────────────────────────────
  /// Fetch current user profile
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _headers(),
      );
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return decoded['data'] as Map<String, dynamic>;
        }
      }
    } catch (_) {}
    return null;
  }

  // ── SESSION MANAGEMENT ────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_roleKey);
  }

  // ── DASHBOARD ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getDashboard(String role) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/${role.toLowerCase()}/dashboard'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded;
        }
      }
    } catch (_) {}
    return null;
  }

  // ── VITALS ────────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getVitalsHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health-records/vitals'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as List? ?? [];
        }
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
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> && decoded['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // ── CLINICAL HISTORY ──────────────────────────────────────────────────────
  static Future<List<dynamic>> getPrescriptions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patients/prescriptions'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as List? ?? [];
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getLabReports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patients/lab-reports'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as List? ?? [];
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getMedications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patients/medications'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as List? ?? [];
        }
      }
    } catch (_) {}
    return [];
  }

  // ── APPOINTMENTS ──────────────────────────────────────────────────────────
  static Future<List<dynamic>> getAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as List? ?? [];
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getDoctorsList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctors/list'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as List? ?? [];
        }
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
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> && decoded['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // ── NOTIFICATIONS ─────────────────────────────────────────────────────────
  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as List? ?? [];
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> markNotificationRead(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> && decoded['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // ── AI ASSISTANT ──────────────────────────────────────────────────────────
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
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as Map<String, dynamic>?;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> runAIConsultation(String narration) async {
    try {
      final headers = await _headers();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ai-assistant/consultation'),
      );
      
      request.headers.addAll(headers);
      request.fields['text_input'] = narration;
      
      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        var responseBody = await streamedResponse.stream.bytesToString();
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as Map<String, dynamic>?;
        }
      }
    } catch (_) {}
    return null;
  }

  // ── CLINICIAN PORTALS ─────────────────────────────────────────────────────
  static Future<List<dynamic>> getDoctorPatients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctors/patients'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as List? ?? [];
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getPatientDetail(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctors/patients/$patientId'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as Map<String, dynamic>?;
        }
      }
    } catch (_) {}
    return null;
  }

  // ── ADMIN PORTALS ─────────────────────────────────────────────────────────
  static Future<List<dynamic>> adminGetUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as List? ?? [];
        }
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
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> && decoded['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  static Future<List<dynamic>> adminGetAuditLogs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/audit-logs'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as List? ?? [];
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> adminGetAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/analytics'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return decoded['data'] as Map<String, dynamic>?;
        }
      }
    } catch (_) {}
    return null;
  }
}
