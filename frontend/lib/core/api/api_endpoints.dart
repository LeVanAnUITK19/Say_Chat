class ApiEndpoints {
  // Auth endpoints
  static const String signIn = '/api/auth/signin';
  static const String signUp = '/api/auth/signup';
  static const String signOut = '/api/auth/signout';
  static const String resetPassword = '/api/auth/reset-password';
  static const String sendResetPasswordOtp = '/api/auth/send-otp';
  
  // User endpoints
  static const String profile = '/api/user/profile';
  static const String updateProfile = '/api/user/profile';
  
  // Chat endpoints (for future)
  static const String conversations = '/api/chat/conversations';
  static const String messages = '/api/chat/messages';
}