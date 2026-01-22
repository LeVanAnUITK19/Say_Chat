// lib/core/api/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      // Sử dụng environment-based URL
      baseUrl: _getBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Quan trọng cho production
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));

    // Chỉ add logger trong development
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
      ));
    }

    // Add error handling interceptor
    _dio.interceptors.add(ErrorInterceptor());
    
    // Add auth interceptor
    _dio.interceptors.add(AuthInterceptor());
  }

  // Environment-based URL configuration
  String _getBaseUrl() {
    if (kDebugMode) {
      // Check if running on web
      if (kIsWeb) {
        print('🌐 Running on Web - Using: http://localhost:5001');
        return 'http://localhost:5001'; // Web development
      } else {
        print('📱 Running on Mobile - Using: http://10.0.2.2:5001');
        // Mobile development
        return 'http://10.0.2.2:5001'; // Android emulator
      }
    } else {
      // Production - server URL
      return 'https://your-production-server.com';
    }
  }

  Dio get dio => _dio;
}

// Error handling interceptor
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Kết nối timeout. Vui lòng thử lại.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleHttpError(err.response?.statusCode, err.response?.data);
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Không thể kết nối đến server. Kiểm tra kết nối mạng.';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request đã bị hủy.';
        break;
      default:
        errorMessage = 'Đã xảy ra lỗi không xác định.';
    }

    // Create custom exception với message rõ ràng
    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
    );

    handler.next(customError);
  }

  String _handleHttpError(int? statusCode, dynamic responseData) {
    switch (statusCode) {
      case 400:
        return responseData?['message'] ?? 'Dữ liệu không hợp lệ';
      case 401:
        return 'Phiên đăng nhập đã hết hạn';
      case 403:
        return 'Không có quyền truy cập';
      case 404:
        return 'Không tìm thấy dữ liệu';
      case 422:
        return responseData?['message'] ?? 'Dữ liệu không hợp lệ';
      case 500:
        return 'Lỗi server. Vui lòng thử lại sau.';
      default:
        return responseData?['message'] ?? 'Đã xảy ra lỗi ($statusCode)';
    }
  }
}

// Auth interceptor để handle token
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add token nếu có (từ SharedPreferences hoặc secure storage)
    try {
      final token = await _getStoredToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token: $e');
      }
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token expired
    if (err.response?.statusCode == 401) {
      await _handleTokenExpired();
    }
    handler.next(err);
  }

  Future<String?> _getStoredToken() async {
    // Implement token retrieval logic
    // Có thể dùng SharedPreferences hoặc FlutterSecureStorage
    return null; // Placeholder
  }

  Future<void> _handleTokenExpired() async {
    // Clear token và redirect về login
    // Implement logout logic
  }
}
