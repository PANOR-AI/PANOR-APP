import 'package:flutter/material.dart';
import '../auth_service.dart';

class AppointmentProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _appointments = [];
  List<dynamic> _doctorsList = [];

  bool get isLoading => _isLoading;
  List<dynamic> get appointments => _appointments;
  List<dynamic> get doctorsList => _doctorsList;

  Future<void> fetchAppointments() async {
    _isLoading = true;
    notifyListeners();
    _appointments = await AuthService.getAppointments();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDoctors() async {
    _isLoading = true;
    notifyListeners();
    _doctorsList = await AuthService.getDoctorsList();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> bookAppointment({
    required String doctorId,
    required String datetime,
    required String specialty,
    required String type,
    required String notes,
  }) async {
    _isLoading = true;
    notifyListeners();
    final success = await AuthService.bookAppointment(
      doctorId: doctorId,
      datetime: datetime,
      specialty: specialty,
      type: type,
      notes: notes,
    );
    if (success) {
      _appointments = await AuthService.getAppointments();
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
