// lib/core/api/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';


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
      // KHÔNG set default Content-Type ở đây để cho phép override
      headers: {
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
        requestHeader: true,
        responseHeader: true,
        error: true,
      ));
    }

    // Add error handling interceptor
    _dio.interceptors.add(ErrorInterceptor());
    
    // Add auth interceptor
    _dio.interceptors.add(AuthInterceptor());
    
    // Add cookie manager chỉ trên mobile (KHÔNG dùng trên web)
    if (!kIsWeb) {
      try {
        final cookieJar = CookieJar();
        _dio.interceptors.add(CookieManager(cookieJar));
        if (kDebugMode) {
          print('✅ CookieManager initialized for mobile');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error initializing CookieManager: $e');
        }
      }
    }
  }

  // Environment-based URL configuration
  String _getBaseUrl() {
    if (kDebugMode) {
      // Check if running on web
      if (kIsWeb) {
        print('🌐 Running on Web - Using: http://localhost:5001');
        return 'http://localhost:5001'; // Web development
      } else {
        print('📱 Running on Mobile - Using: http://10.0.2.2:5001 || 192.168.15.31' );
        // Mobile development
        return 'http://192.168.15.31:5001'; // Android emulator
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
    // Set default Content-Type nếu chưa có (trừ FormData)
    if (options.data is! FormData && !options.headers.containsKey('Content-Type')) {
      options.headers['Content-Type'] = 'application/json';
    }
    
    // Add token nếu có (từ SharedPreferences hoặc secure storage)
    try {
      final token = await _getStoredToken();
      if (kDebugMode) {
        print('🔑 Token for ${options.path}: ${token != null ? "Found" : "Not found"}');
      }
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting token: $e');
      }
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token expired
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        print('⚠️ 401 Unauthorized - Token expired or invalid');
      }
      await _handleTokenExpired();
    }
    handler.next(err);
  }

  Future<String?> _getStoredToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (kDebugMode && token != null) {
      print('📦 Retrieved token: ${token.substring(0, 20)}...');
    }
    return token;
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error getting token: $e');
    }
    return null;
  }
}


  Future<void> _handleTokenExpired() async {
    // Clear token và redirect về login
    // Implement logout logic
  }
}
