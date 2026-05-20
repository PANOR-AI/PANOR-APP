import 'package:flutter/material.dart';
import '../auth_service.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _users = [];
  List<dynamic> _auditLogs = [];
  Map<String, dynamic>? _analytics;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get users => _users;
  List<dynamic> get auditLogs => _auditLogs;
  Map<String, dynamic>? get analytics => _analytics;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    notifyListeners();
    final data = await AuthService.getDashboard('admin');
    if (data != null) {
      _dashboardData = data;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    _users = await AuthService.adminGetUsers();
    notifyListeners();
  }

  Future<bool> deactivateUser(String userId) async {
    final success = await AuthService.adminDeactivateUser(userId);
    if (success) {
      await fetchUsers();
      await fetchDashboard();
    }
    return success;
  }

  Future<void> fetchAuditLogs() async {
    _auditLogs = await AuthService.adminGetAuditLogs();
    notifyListeners();
  }

  Future<void> fetchAnalytics() async {
    _analytics = await AuthService.adminGetAnalytics();
    notifyListeners();
  }
}
