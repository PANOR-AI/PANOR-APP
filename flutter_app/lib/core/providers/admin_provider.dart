import 'package:flutter/material.dart';
import '../auth_service.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _users = [];
  List<dynamic> _auditLogs = [];
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _systemMetrics;
  Map<String, dynamic>? _epidemiology;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get users => _users;
  List<dynamic> get auditLogs => _auditLogs;
  Map<String, dynamic>? get analytics => _analytics;
  Map<String, dynamic>? get systemMetrics => _systemMetrics;
  Map<String, dynamic>? get epidemiology => _epidemiology;

  // Compatibility alias
  Future<void> fetchDashboard() async {
    await fetchAdminDashboard(forceRefresh: true);
  }

  // Phase D: fetchAdminDashboard
  Future<void> fetchAdminDashboard({bool forceRefresh = false}) async {
    if (_dashboardData != null && !forceRefresh) {
      _fetchDashboardInBackground();
      return;
    }
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await AuthService.getDashboard('admin');
      if (res != null && res['success'] == true) {
        _dashboardData = res['data'];
      } else {
        _hasError = true;
        _errorMessage = res?['message'] ?? 'Failed to fetch admin dashboard';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchDashboardInBackground() async {
    try {
      final res = await AuthService.getDashboard('admin');
      if (res != null && res['success'] == true) {
        _dashboardData = res['data'];
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchUsers() async {
    _users = await AuthService.adminGetUsers();
    notifyListeners();
  }

  Future<bool> deactivateUser(String userId) async {
    final success = await AuthService.adminDeactivateUser(userId);
    if (success) {
      await fetchUsers();
      await fetchAdminDashboard(forceRefresh: true);
    }
    return success;
  }

  Future<void> fetchAuditLogs() async {
    _auditLogs = await AuthService.adminGetAuditLogs();
    notifyListeners();
  }

  // Phase D: fetchAnalytics
  Future<void> fetchAnalytics() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await AuthService.adminGetAnalytics();
      if (data != null) {
        _analytics = data;
      } else {
        _hasError = true;
        _errorMessage = 'Failed to fetch analytics';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Phase D: fetchSystemMetrics
  Future<void> fetchSystemMetrics() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await AuthService.adminGetSystemMetrics();
      if (data != null) {
        _systemMetrics = data;
      } else {
        _hasError = true;
        _errorMessage = 'Failed to fetch system metrics';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Phase D: fetchEpidemiology
  Future<void> fetchEpidemiology() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await AuthService.adminGetEpidemiology();
      if (data != null) {
        _epidemiology = data;
      } else {
        _hasError = true;
        _errorMessage = 'Failed to fetch epidemiology';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
