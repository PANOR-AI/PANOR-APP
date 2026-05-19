import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/core/constants/app_constants.dart';

class AuthService {
  static String get baseUrl => AppConstants.apiBase;

  static Future<String?> login(String email, String password) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/login'));
      request.fields.addAll({
        'username': email,
        'password': password
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        String token = jsonResponse['access_token'];
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return null; // Null means success
      } else {
        return "Invalid email or password";
      }
    } catch (e) {
      return "Network error: $e";
    }
  }

  static Future<Map<String, dynamic>?> getDashboard(String rolePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if (token == null) return null;

    var response = await http.get(
      Uri.parse('$baseUrl/$rolePath/dashboard'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }
}
