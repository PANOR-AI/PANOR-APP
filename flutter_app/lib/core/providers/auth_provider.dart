import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _token;
  UserModel? _user;
  String? _error;

  bool get isLoading => _isLoading;
  String? get token => _token;
  UserModel? get user => _user;
  Map<String, dynamic>? get userProfile => _user?.toJson();
  String? get error => _error;
  String? get role => _user?.role;
  bool get isAuthenticated => _token != null && _user != null;

  // ── LOGIN ─────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final err = await AuthService.login(email, password);
    if (err == null) {
      _token = await AuthService.getToken();
      await fetchProfile();
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } else {
      _error = err;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── REGISTER ──────────────────────────────────────────────────────────────
  Future<bool> register({
    required String email,
    required String fullName,
    required String role,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final err = await AuthService.register(
      email: email,
      fullName: fullName,
      role: role,
      phone: phone,
      password: password,
    );

    _isLoading = false;
    if (err == null) {
      notifyListeners();
      return true;
    } else {
      _error = err;
      notifyListeners();
      return false;
    }
  }

  // ── FETCH PROFILE (GET /api/auth/me) ──────────────────────────────────────
  Future<void> fetchProfile() async {
    try {
      final data = await AuthService.getCurrentUser();
      if (data != null) {
        _user = UserModel.fromJson(data);
        _token = await AuthService.getToken();
      } else {
        _user = null;
        _token = null;
      }
    } catch (_) {
      _user = null;
      _token = null;
    }
    notifyListeners();
  }

  // ── CHECK SESSION (splash) ────────────────────────────────────────────────
  Future<void> checkSession() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) {
      _token = await AuthService.getToken();
      await fetchProfile();
    } else {
      _token = null;
      _user = null;
    }
    notifyListeners();
  }

  // ── FORGOT PASSWORD ───────────────────────────────────────────────────────
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final err = await AuthService.forgotPassword(email);
    _isLoading = false;
    if (err == null) {
      notifyListeners();
      return true;
    } else {
      _error = err;
      notifyListeners();
      return false;
    }
  }

  // ── RESET PASSWORD WITH OTP ───────────────────────────────────────────────
  Future<bool> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final err = await AuthService.resetPasswordWithOtp(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );

    _isLoading = false;
    if (err == null) {
      notifyListeners();
      return true;
    } else {
      _error = err;
      notifyListeners();
      return false;
    }
  }

  // ── VERIFY OTP ────────────────────────────────────────────────────────────
  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final err = await AuthService.verifyOtp(phone, otp);
    _isLoading = false;
    if (err == null) {
      _token = await AuthService.getToken();
      await fetchProfile();
      notifyListeners();
      return true;
    } else {
      _error = err;
      notifyListeners();
      return false;
    }
  }

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.logout();
    _token = null;
    _user = null;
    _error = null;

    _isLoading = false;
    notifyListeners();
  }

  // ── CLEAR ERROR ───────────────────────────────────────────────────────────
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
