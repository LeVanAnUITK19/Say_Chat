import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/heartbeat_service.dart';
import '../services/socket_service.dart';
import '../../features/call/views/incoming_call_page.dart';
import '../../main.dart';
import '../api/dio_client.dart';

class AuthProvider extends ChangeNotifier with WidgetsBindingObserver {
  bool _isAuthenticated = false;
  final HeartbeatService _heartbeatService = HeartbeatService();
  final SocketService _socketService = SocketService();
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;

  AuthProvider() {
    WidgetsBinding.instance.addObserver(this);
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      // Thử fetch user info mới nhất từ API, fallback về SharedPreferences
      try {
        final response = await DioClient().dio.get('/api/user/me');
        _user = Map<String, dynamic>.from(response.data as Map);
        await prefs.setString('user_info', json.encode(_user));
      } catch (_) {
        // Token hết hạn hoặc lỗi mạng → đọc cache
        await loadUserInfo();
      }
      _heartbeatService.start();
      _socketService.connect();
      _listenForIncomingCalls();
      notifyListeners();
    }
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_info');
    if (userJson != null) {
      _user = json.decode(userJson);
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isAuthenticated) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        _heartbeatService.stop();
      } else if (state == AppLifecycleState.resumed) {
        _heartbeatService.start();
      }
    }
  }

  Future<void> onLogin([Map<String, dynamic>? userData]) async {
    _isAuthenticated = true;
    if (userData != null) {
      _user = userData;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_info', json.encode(userData));
    }
    _heartbeatService.start();
    _socketService.connect();
    _listenForIncomingCalls();
    notifyListeners();
  }

  void _listenForIncomingCalls() {
    _socketService.onCallOffer((data) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => IncomingCallPage(
            callerId: data['from'].toString(),
            callerName: data['fromUsername']?.toString() ?? 'Unknown',
            callType: data['callType']?.toString() ?? 'audio',
            offer: Map<String, dynamic>.from(data['offer'] as Map),
          ),
        ),
      );
    });
  }

  Future<void> updateUserAvatar(String avatarUrl) async {
    if (_user != null) {
      _user = {..._user!, 'avatarUrl': avatarUrl};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_info', json.encode(_user));
      notifyListeners();
    }
  }

  Future<void> onLogout() async {
    _isAuthenticated = false;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_info');
    _heartbeatService.stop();
    _socketService.disconnect();
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatService.stop();
    super.dispose();
  }
}
