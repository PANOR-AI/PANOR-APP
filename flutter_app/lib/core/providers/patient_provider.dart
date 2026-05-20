import 'package:flutter/material.dart';
import '../auth_service.dart';

class PatientProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _vitalsList = [];
  List<dynamic> _prescriptions = [];
  List<dynamic> _labReports = [];
  List<dynamic> _medications = [];
  List<dynamic> _appointments = [];
  List<dynamic> _notifications = [];
  List<dynamic> _doctorsList = [];

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get vitalsList => _vitalsList;
  List<dynamic> get prescriptions => _prescriptions;
  List<dynamic> get labReports => _labReports;
  List<dynamic> get medications => _medications;
  List<dynamic> get appointments => _appointments;
  List<dynamic> get notifications => _notifications;
  List<dynamic> get doctorsList => _doctorsList;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    notifyListeners();
    final data = await AuthService.getDashboard('patient');
    if (data != null) {
      _dashboardData = data;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchVitals() async {
    _vitalsList = await AuthService.getVitalsHistory();
    notifyListeners();
  }

  Future<bool> logVitals({
    required String bp,
    required String hr,
    required double temp,
    required int oxygen,
  }) async {
    final success = await AuthService.logVitals(bp: bp, hr: hr, temp: temp, oxygen: oxygen);
    if (success) {
      await fetchVitals();
      await fetchDashboard();
    }
    return success;
  }

  Future<void> fetchPrescriptions() async {
    _prescriptions = await AuthService.getPrescriptions();
    notifyListeners();
  }

  Future<void> fetchLabReports() async {
    _labReports = await AuthService.getLabReports();
    notifyListeners();
  }

  Future<void> fetchMedications() async {
    _medications = await AuthService.getMedications();
    notifyListeners();
  }

  Future<void> fetchAppointments() async {
    _appointments = await AuthService.getAppointments();
    notifyListeners();
  }

  Future<void> fetchDoctors() async {
    _doctorsList = await AuthService.getDoctorsList();
    notifyListeners();
  }

  Future<bool> bookAppointment({
    required String doctorId,
    required String datetime,
    required String specialty,
    required String type,
    required String notes,
  }) async {
    final success = await AuthService.bookAppointment(
      doctorId: doctorId,
      datetime: datetime,
      specialty: specialty,
      type: type,
      notes: notes,
    );
    if (success) {
      await fetchAppointments();
      await fetchDashboard();
    }
    return success;
  }

  Future<void> fetchNotifications() async {
    _notifications = await AuthService.getNotifications();
    notifyListeners();
  }

  Future<void> markNotificationRead(String id) async {
    final success = await AuthService.markNotificationRead(id);
    if (success) {
      await fetchNotifications();
    }
  }
}
