import 'package:flutter/material.dart';
import '../auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile;
  String? _role;
  bool _isAuthenticated = false;
  
  // For password reset flow
  String? _resetToken;
  String? _tempEmail;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get role => _role;
  bool get isAuthenticated => _isAuthenticated;
  String? get resetToken => _resetToken;
  String? get tempEmail => _tempEmail;

  // ── REGISTRATION ────────────────────────────────────────────────────────
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
      _isAuthenticated = false; // User needs to login after registration
      _role = role;
      _tempEmail = email;
      notifyListeners();
      return true;
    } else {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
  }

  // ── LOGIN ────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await AuthService.login(email, password);
    if (error == null) {
      _isAuthenticated = true;
      _role = await AuthService.getRole();
      await fetchProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = error;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── LOGOUT ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await AuthService.logout();
    _userProfile = null;
    _role = null;
    _isAuthenticated = false;
    _errorMessage = null;
    _resetToken = null;
    _tempEmail = null;
    
    _isLoading = false;
    notifyListeners();
  }

  // ── FETCH PROFILE ────────────────────────────────────────────────────────
  Future<void> fetchProfile() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        _userProfile = user;
        _role = user['role'] ?? _role;
      }
    } catch (_) {}
    notifyListeners();
  }

  // ── CHECK SESSION ────────────────────────────────────────────────────────
  Future<void> checkSession() async {
    final logged = await AuthService.isLoggedIn();
    if (logged) {
      _isAuthenticated = true;
      _role = await AuthService.getRole();
      await fetchProfile();
    } else {
      _isAuthenticated = false;
      _role = null;
      _userProfile = null;
    }
    notifyListeners();
  }

  // ── REQUEST OTP ──────────────────────────────────────────────────────────
  Future<bool> requestOtp(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final (error, otp) = await AuthService.requestOtp(phone);
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

  // ── VERIFY OTP ───────────────────────────────────────────────────────────
  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await AuthService.verifyOtp(phone, otp);
    _isLoading = false;
    if (error == null) {
      _isAuthenticated = true;
      _role = await AuthService.getRole();
      await fetchProfile();
      notifyListeners();
      return true;
    } else {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
  }

  // ── SET PIN ──────────────────────────────────────────────────────────────
  Future<bool> setPin(String pin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await AuthService.setPin(pin);
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

  // ── VERIFY PIN ───────────────────────────────────────────────────────────
  Future<bool> verifyPin(String email, String pin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await AuthService.verifyPin(email, pin);
    _isLoading = false;
    if (error == null) {
      _isAuthenticated = true;
      _role = await AuthService.getRole();
      await fetchProfile();
      notifyListeners();
      return true;
    } else {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
  }

  // ── REQUEST PASSWORD RESET ───────────────────────────────────────────────
  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _tempEmail = email;
    notifyListeners();

    final (error, token) = await AuthService.requestPasswordReset(email);
    _isLoading = false;
    if (error == null) {
      _resetToken = token;
      notifyListeners();
      return true;
    } else {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
  }

  // ── RESET PASSWORD ───────────────────────────────────────────────────────
  Future<bool> resetPassword(String newPassword) async {
    if (_tempEmail == null || _resetToken == null) {
      _errorMessage = 'Missing reset information';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await AuthService.resetPassword(
      email: _tempEmail!,
      resetToken: _resetToken!,
      newPassword: newPassword,
    );

    _isLoading = false;
    if (error == null) {
      _resetToken = null;
      _tempEmail = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
  }

  // ── REFRESH TOKEN ────────────────────────────────────────────────────────
  Future<bool> refreshToken() async {
    final error = await AuthService.refreshAccessToken();
    if (error == null) {
      return true;
    } else {
      _errorMessage = error;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  // ── CLEAR ERROR ──────────────────────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

