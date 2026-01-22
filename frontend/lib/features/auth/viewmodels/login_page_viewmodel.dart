import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool goToRegister = false;
  bool goToForgetPassword = false;
  bool goToHome = false; // Thêm state để navigate đến home

  bool isLoading = false;
  String? errorMessage;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage = 'Vui lòng nhập email và mật khẩu';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print(' Calling login API...');
      final response = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );
      
      // Lưu token vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response.accessToken);
      
      print(' Login success, token saved');
      
      // Set state để navigate đến home
      if( response.accessToken.isNotEmpty )
        goToHome = true;
      isLoading = false;
      notifyListeners();
      
    } catch (e) {
      print(' Login error: $e');
      errorMessage = 'Email hoặc mật khẩu không đúng';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading = true;
    notifyListeners();

    // fake logic
    await Future.delayed(const Duration(seconds: 2));

    isLoading = false;
    notifyListeners();
  } 
  
  void onRegisterTap() {
    goToRegister = true;
    notifyListeners();
  }
  
  void onForgetPasswordTap() {
    goToForgetPassword = true;
    notifyListeners();
  }

  void resetNavigation() {
    goToRegister = false;
    goToForgetPassword = false;
    goToHome = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
