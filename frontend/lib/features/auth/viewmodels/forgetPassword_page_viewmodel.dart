import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';

class ForgetPasswordPageViewModel extends ChangeNotifier {
  final emailController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool goToResetPassword = false;

  Future<void> forgetPassword() async {
    isLoading = true;
    notifyListeners();

    try {
      if (emailController.text.isEmpty) {
        errorMessage = 'Vui lòng nhập email';
        isLoading = false;
        notifyListeners();
        return;
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
        errorMessage = 'Vui lòng nhập email hợp lệ';
        isLoading = false;
        notifyListeners();
        return;
      }

      await AuthRepository().sendResetPasswordOtp(emailController.text.trim());
      errorMessage = null;
      emailController.clear();
      goToResetPassword = true;

      // Xử lý thành công (ví dụ: hiển thị thông báo đã gửi OTP)
    } catch (e) {
      errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }

    isLoading = false;
    notifyListeners();
  }

  void onResetPasswordNavigated() {
    goToResetPassword = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }
}
