import 'package:flutter/material.dart';
import '../auth_service.dart';

class DoctorProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _patients = [];
  Map<String, dynamic>? _selectedPatientDetail;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get patients => _patients;
  Map<String, dynamic>? get selectedPatientDetail => _selectedPatientDetail;

  // Compatibility alias
  Future<void> fetchDashboard() async {
    await fetchDoctorDashboard(forceRefresh: true);
  }

  // Phase D required function with cache and state management
  Future<void> fetchDoctorDashboard({bool forceRefresh = false}) async {
    if (_dashboardData != null && !forceRefresh) {
      _fetchDashboardInBackground();
      return;
    }
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await AuthService.getDashboard('doctor');
      if (res != null && res['success'] == true) {
        _dashboardData = res['data'];
      } else {
        _hasError = true;
        _errorMessage = res?['message'] ?? 'Failed to fetch doctor dashboard';
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
      final res = await AuthService.getDashboard('doctor');
      if (res != null && res['success'] == true) {
        _dashboardData = res['data'];
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchPatients() async {
    _patients = await AuthService.getDoctorPatients();
    notifyListeners();
  }

  Future<void> fetchPatientDetail(String patientId) async {
    _isLoading = true;
    _selectedPatientDetail = null;
    notifyListeners();
    final data = await AuthService.getPatientDetail(patientId);
    if (data != null) {
      _selectedPatientDetail = data;
    }
    _isLoading = false;
    notifyListeners();
  }
}
