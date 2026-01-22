import '../api/auth_api.dart';
import '../model/auth_request.dart';
import '../model/auth_response.dart';

class AuthRepository {
  final AuthApi _authApi = AuthApi();

  Future<AuthResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    return await _authApi.login(request);
  }

  Future<void> register(String username, String email, String password) async {
    final request = RegisterRequest(
      username: username, 
      email: email, 
      password: password
    );
    return await _authApi.register(request);
  }

  Future<void> logout() async {
    return await _authApi.logout();
  }
  Future<void> sendResetPasswordOtp(String email) async {
    final request = SendOtpRequest(email: email);
    return await _authApi.sendResetPasswordOtp(request);
  }
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    final request = ResetPasswordRequest(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
    return await _authApi.resetPassword(request);
  }
  Future<AuthResponse> refreshToken() async {
    
    return await _authApi.refreshToken();
  }
}