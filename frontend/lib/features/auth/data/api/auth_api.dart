import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../model/auth_request.dart';
import '../model/auth_response.dart';

class AuthApi {
  final Dio _dio = DioClient().dio;

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(ApiEndpoints.signIn, data: request.toJson());
    return AuthResponse.fromJson(response.data);
  }

  Future<void> register(RegisterRequest request) async {
    await _dio.post(ApiEndpoints.signUp, data: request.toJson());
  }

  Future<void> logout() async {
    await _dio.post(ApiEndpoints.signOut);
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
}