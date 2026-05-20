import 'package:flutter/material.dart';
import '../auth_service.dart';

class DoctorProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _patients = [];
  Map<String, dynamic>? _selectedPatientDetail;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get patients => _patients;
  Map<String, dynamic>? get selectedPatientDetail => _selectedPatientDetail;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    notifyListeners();
    final data = await AuthService.getDashboard('doctor');
    if (data != null) {
      _dashboardData = data;
    }
    _isLoading = false;
    notifyListeners();
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
