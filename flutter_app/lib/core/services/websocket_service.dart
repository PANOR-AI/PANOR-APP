import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../auth_service.dart';
import 'dart:io' show Platform;

/// Centralized WebSocket service for PANOR real-time communication.
///
/// Manages a single persistent connection to the backend, handles:
/// - JWT-authenticated connections
/// - Automatic reconnection with exponential backoff
/// - Heartbeat ping/pong keep-alive
/// - Stream-based event distribution to multiple listeners
class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  bool _isConnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  bool get isConnected => _isConnected;

  /// Stream controller for broadcasting incoming WS events to all listeners.
  final StreamController<Map<String, dynamic>> _eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Any provider or widget can listen to this stream for real-time events.
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  /// Resolves the correct WebSocket base URL for the current platform.
  static String get _wsBase {
    if (kIsWeb) {
      return 'ws://localhost:8000';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'ws://10.0.2.2:8000';
    }
    return 'ws://localhost:8000';
  }

  /// Connects to the notification WebSocket endpoint with the stored JWT.
  Future<void> connect() async {
    if (_isConnected) return;

    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('[WebSocketService] No JWT token found — skipping WS connect.');
      return;
    }

    final uri = Uri.parse('$_wsBase/ws/notifications?token=$token');
    debugPrint('[WebSocketService] Connecting to $uri');

    try {
      _channel = WebSocketChannel.connect(uri);

      // Wait for the connection to be established
      await _channel!.ready;

      _isConnected = true;
      _reconnectAttempts = 0;
      notifyListeners();
      debugPrint('[WebSocketService] Connected successfully.');

      _startHeartbeat();

      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          debugPrint('[WebSocketService] Connection closed.');
          _onDisconnected();
        },
        onError: (error) {
          debugPrint('[WebSocketService] Error: $error');
          _onDisconnected();
        },
      );
    } catch (e) {
      debugPrint('[WebSocketService] Connection failed: $e');
      _onDisconnected();
    }
  }

  void _handleMessage(dynamic rawMessage) {
    if (rawMessage is String) {
      // Ignore pong responses from heartbeat
      if (rawMessage == 'pong') return;

      try {
        final decoded = jsonDecode(rawMessage) as Map<String, dynamic>;
        _eventController.add(decoded);
      } catch (e) {
        debugPrint('[WebSocketService] Failed to decode message: $e');
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add('ping');
        } catch (e) {
          debugPrint('[WebSocketService] Heartbeat failed: $e');
          _onDisconnected();
        }
      }
    });
  }

  void _onDisconnected() {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _channel = null;
    notifyListeners();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[WebSocketService] Max reconnect attempts reached. Giving up.');
      return;
    }

    final delay = Duration(seconds: (1 << _reconnectAttempts).clamp(1, 60));
    _reconnectAttempts++;
    debugPrint('[WebSocketService] Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)...');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      connect();
    });
  }

  /// Gracefully disconnect (e.g., on logout).
  Future<void> disconnect() async {
    _reconnectAttempts = _maxReconnectAttempts; // Prevent auto-reconnect
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    notifyListeners();
    debugPrint('[WebSocketService] Disconnected manually.');
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _eventController.close();
    super.dispose();
  }
}
