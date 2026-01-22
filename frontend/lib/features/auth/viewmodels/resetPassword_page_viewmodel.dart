import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';

class ResetPasswordPageViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool isPasswordReset = false;

  Future<void> resetPassword() async {
    // Validate inputs
    if (!_validateInputs()) {
      print(' Validation failed');
      return;
    }

    print(' Validation passed');
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print(' Calling reset password API...');
      await _authRepository.resetPassword(
        emailController.text.trim(),
        otpController.text.trim(),
        newPasswordController.text,
      );

      print(' Reset password API success');
      isPasswordReset = true;
      isLoading = false;
      emailController.clear();
      otpController.clear();
      newPasswordController.clear();
      confirmNewPasswordController.clear();
      notifyListeners();
    } catch (e) {
      print(' Reset password API error: $e');
      errorMessage = _handleError(e);
      isLoading = false;
      notifyListeners();
    }
  }

  bool _validateInputs() {
    if (emailController.text.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập email';
      notifyListeners();
      return false;
    }
    if (otpController.text.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập mã OTP';
      notifyListeners();
      return false;
    }
    if (newPasswordController.text.isEmpty) {
      errorMessage = 'Vui lòng nhập mật khẩu mới';
      notifyListeners();
      return false;
    }
    if (newPasswordController.text != confirmNewPasswordController.text) {
      errorMessage = 'Mật khẩu xác nhận không khớp';
      notifyListeners();
      return false;
    }
    return true;
  }

  String _handleError(Object e) {
    // Xử lý lỗi và trả về thông điệp phù hợp
    return 'Đã có lỗi xảy ra: $e';
  }
}
