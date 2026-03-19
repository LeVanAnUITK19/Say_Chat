import 'dart:async';
import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../api/api_endpoints.dart';

class HeartbeatService {
  static final HeartbeatService _instance = HeartbeatService._internal();
  factory HeartbeatService() => _instance;
  HeartbeatService._internal();

  final Dio _dio = DioClient().dio;
  Timer? _timer;
  bool _isRunning = false;

  // Gửi heartbeat mỗi 2 phút
  static const Duration _heartbeatInterval = Duration(minutes: 2);

  /// Bắt đầu gửi heartbeat định kỳ
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    
    // Gửi heartbeat ngay lập tức
    _sendHeartbeat();

    // Sau đó gửi định kỳ
    _timer = Timer.periodic(_heartbeatInterval, (_) {
      _sendHeartbeat();
    });
  }

  /// Dừng gửi heartbeat
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  /// Gửi một heartbeat request
  Future<void> _sendHeartbeat() async {
    try {
      await _dio.post(ApiEndpoints.heartbeat);
    } catch (e) {
      // Không cần xử lý lỗi, chỉ log để debug
      print('Heartbeat failed: $e');
    }
  }

  bool get isRunning => _isRunning;
}
