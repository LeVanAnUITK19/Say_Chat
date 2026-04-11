import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class LoginViewModel extends ChangeNotifier {
  final BuildContext context;
  final AuthRepository _authRepository = AuthRepository();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool goToRegister = false;
  bool goToForgetPassword = false;
  bool goToHome = false; // Thêm state để navigate đến home

  bool isLoading = false;
  String? errorMessage;

  LoginViewModel(this.context);

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
      final response = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      // Lưu token vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response.accessToken);

      // Lấy thông tin user sau khi login
      Map<String, dynamic>? userData;
      try {
        userData = await _authRepository.fetchUserInfo();
      } catch (e) {
        debugPrint('Warning: could not fetch user info: $e');
      }

      if (context.mounted) {
        await Provider.of<AuthProvider>(context, listen: false).onLogin(userData);
      }

      if (response.accessToken.isNotEmpty) goToHome = true;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Email hoặc mật khẩu không đúng';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.googleSignIn();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response.accessToken);

      Map<String, dynamic>? userData;
      try {
        userData = await _authRepository.fetchUserInfo();
      } catch (e) {
        debugPrint('Warning: could not fetch user info: $e');
      }

      if (context.mounted) {
        await Provider.of<AuthProvider>(context, listen: false).onLogin(userData);
      }

      if (response.accessToken.isNotEmpty) goToHome = true;
    } catch (e) {
      errorMessage = 'Đăng nhập Google thất bại';
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
