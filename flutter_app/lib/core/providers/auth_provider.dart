import 'package:flutter/material.dart';
import '../auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile;
  String? _role;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get role => _role;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await AuthService.login(email, password);
    if (error == null) {
      _role = await AuthService.getRole();
      await fetchProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String fullName,
    required String role,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await AuthService.register(
      email: email,
      fullName: fullName,
      role: role,
      phone: phone,
      password: password,
    );

    _isLoading = false;
    if (error == null) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchProfile() async {
    final data = await AuthService.getPatientProfile() ?? await AuthService.getDoctorProfile();
    if (data != null) {
      _userProfile = data;
      _role = data['role'] ?? _role;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    _userProfile = null;
    _role = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> checkSession() async {
    final logged = await AuthService.isLoggedIn();
    if (logged) {
      _role = await AuthService.getRole();
      await fetchProfile();
    }
    notifyListeners();
  }
}
