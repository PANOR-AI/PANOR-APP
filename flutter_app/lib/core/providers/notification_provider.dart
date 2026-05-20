import 'dart:async';
import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../services/websocket_service.dart';

class NotificationProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _notifications = [];
  int _unreadCount = 0;
  StreamSubscription? _wsSub;

  bool get isLoading => _isLoading;
  List<dynamic> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  /// Initializes real-time listening on the WebSocket event stream.
  void listenToWebSocket(WebSocketService wsService) {
    _wsSub?.cancel();
    _wsSub = wsService.eventStream.listen((event) {
      if (event['event'] == 'notification') {
        final data = event['data'];
        if (data != null) {
          // Prepend to the top of the list for newest-first ordering
          _notifications.insert(0, data);
          _recalculateUnread();
          notifyListeners();
        }
      }
    });
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    _notifications = await AuthService.getNotifications();
    _recalculateUnread();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markNotificationRead(String id) async {
    final success = await AuthService.markNotificationRead(id);
    if (success) {
      // Optimistic local update — avoids full refetch
      final idx = _notifications.indexWhere((n) => n['id'] == id);
      if (idx != -1) {
        _notifications[idx]['is_read'] = true;
        _recalculateUnread();
        notifyListeners();
      }
    }
    return success;
  }

  Future<void> markAllRead() async {
    await AuthService.markAllNotificationsRead();
    for (var n in _notifications) {
      n['is_read'] = true;
    }
    _unreadCount = 0;
    notifyListeners();
  }

  void _recalculateUnread() {
    _unreadCount = _notifications.where((n) => n['is_read'] == false).length;
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }
}
