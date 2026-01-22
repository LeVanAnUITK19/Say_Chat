import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';

class RegisterPageViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordCFController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool isRegistered = false;
  bool isLoggedIn = false;

  Future<void> register() async {
    
    
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
      print(' Calling register API...');
      await _authRepository.register(
        userNameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );

      print(' Register API success');
      isRegistered = true;
      isLoading = false;
      userNameController.clear();
      emailController.clear();
      passwordController.clear();
      passwordCFController.clear();
      isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      print(' Register API error: $e');
      errorMessage = _handleError(e);
      isLoading = false;
      notifyListeners();
    }
  }

  bool _validateInputs() {
    if (userNameController.text.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập tên người dùng';
      notifyListeners();
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      errorMessage = 'Vui lòng nhập email';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      errorMessage = 'Email không hợp lệ';
      notifyListeners();
      return false;
    }

    if (passwordController.text.length < 6) {
      errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự';
      notifyListeners();
      return false;
    }

    if (passwordController.text != passwordCFController.text) {
      errorMessage = 'Mật khẩu xác nhận không khớp';
      notifyListeners();
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _handleError(dynamic error) {
    if (error.toString().contains('Email đã được sử dụng')) {
      return 'Email này đã được đăng ký';
    }
    return error.toString();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
  void resetNavigation() {
    isLoggedIn = false;
  }
  
  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordCFController.dispose();
    super.dispose();
  }
}
