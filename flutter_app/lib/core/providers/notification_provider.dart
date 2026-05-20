import 'package:flutter/material.dart';
import '../auth_service.dart';

class NotificationProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _notifications = [];

  bool get isLoading => _isLoading;
  List<dynamic> get notifications => _notifications;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    _notifications = await AuthService.getNotifications();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markNotificationRead(String id) async {
    final success = await AuthService.markNotificationRead(id);
    if (success) {
      await fetchNotifications();
    }
    return success;
  }
}
