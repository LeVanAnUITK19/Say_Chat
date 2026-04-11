import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';

class SendOTPChangePageViewModel extends ChangeNotifier {
  final String email;

  SendOTPChangePageViewModel(this.email);

  bool isLoading = false;
  String? errorMessage;
  bool goToResetPassword = false;

  Future<void> forgetPassword() async {
    isLoading = true;
    notifyListeners();

    try {
      if (email.isEmpty) {
        errorMessage = 'Vui lòng nhập email';
        isLoading = false;
        notifyListeners();
        return;
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        errorMessage = 'Vui lòng nhập email hợp lệ';
        isLoading = false;
        notifyListeners();
        return;
      }

      await AuthRepository().sendResetPasswordOtp(email.trim());
      errorMessage = null;
      goToResetPassword = true;
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
}
