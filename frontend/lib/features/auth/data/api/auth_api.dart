import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../model/auth_request.dart';
import '../model/auth_response.dart';

class AuthApi {
  final Dio _dio = DioClient().dio;

  static final _googleSignIn = GoogleSignIn(
    serverClientId: '194201037468-2rv9b4lvdvlbs2048m36d6h6keg9bbpi.apps.googleusercontent.com',
  );

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(ApiEndpoints.signIn, data: request.toJson());
    final authResponse = AuthResponse.fromJson(response.data);
    // Lưu cả access token và refresh token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', authResponse.accessToken);
    if (authResponse.refreshToken != null) {
      await prefs.setString('refresh_token', authResponse.refreshToken!);
    }
    return authResponse;
  }

  Future<void> register(RegisterRequest request) async {
    await _dio.post(ApiEndpoints.signUp, data: request.toJson());
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    try {
      // Gửi refreshToken trong body để backend xác định session và set offline
      await _dio.post(ApiEndpoints.signOut, data: {
        if (refreshToken != null) 'refreshToken': refreshToken,
      });
    } finally {
      // Luôn xóa token local dù API có lỗi hay không
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    }
  }
  Future<void> sendResetPasswordOtp(SendOtpRequest request) async {
    await _dio.post(ApiEndpoints.sendResetPasswordOtp, data: request.toJson());
  }
  Future<void> resetPassword(ResetPasswordRequest request) async {
    await _dio.post(ApiEndpoints.resetPassword, data: request.toJson());
  }
  Future<AuthResponse> refreshToken() async {
    final response = await _dio.post('/api/auth/refresh');
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> googleSignIn() async {
    // Mở Google Sign-In picker
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Đăng nhập Google bị hủy');

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('Không lấy được idToken');

    // Gửi idToken lên backend
    final response = await _dio.post('/api/auth/google', data: {'idToken': idToken});
    final authResponse = AuthResponse.fromJson(response.data);

    // Lưu tokens
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', authResponse.accessToken);
    if (authResponse.refreshToken != null) {
      await prefs.setString('refresh_token', authResponse.refreshToken!);
    }
    return authResponse;
  }

  Future<AuthResponse> getCurrentUser() async {
    final response = await _dio.get(ApiEndpoints.authMe);
    return AuthResponse.fromJson(response.data);
  }

  /// Lấy user info dưới dạng Map để lưu vào AuthProvider
  Future<Map<String, dynamic>> fetchUserInfo() async {
    final response = await _dio.get(ApiEndpoints.authMe);
    return Map<String, dynamic>.from(response.data as Map);
  }
}