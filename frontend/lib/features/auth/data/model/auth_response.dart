// lib/features/auth/data/model/auth_response.dart
class AuthResponse {
  final String message;
  final String accessToken;
  final String? refreshToken;

  AuthResponse({
    required this.message,
    required this.accessToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? '',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }
}

// Response cho register (không có accessToken)
class RegisterResponse {
  final String message;

  RegisterResponse({required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? 'Đăng ký thành công',
    );
  }
}

// Base response class (optional - cho các response chung)
class BaseResponse {
  final bool success;
  final String message;
  final dynamic data;

  BaseResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
class SendOtpResponse {
  final String message;

  SendOtpResponse({required this.message});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      message: json['message'] ?? 'OTP sent successfully',
    );
  }
}

class ResetPasswordResponse {
  final String message;

  ResetPasswordResponse({required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      message: json['message'] ?? 'Password reset successfully',
    );
  }
}

