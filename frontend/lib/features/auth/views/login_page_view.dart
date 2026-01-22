import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../viewmodels/login_page_viewmodel.dart';
import 'register_page_view.dart';
import 'forgetPassword_page_view.dart';

import '../../../widgets/my_textfield.dart';
import '../../../widgets/my_button.dart';

// import '../../views/register/register_page_view.dart';

class LoginPageView extends StatelessWidget {
  const LoginPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Consumer<LoginViewModel>(
              builder: (context, vm, _) {
                final l10n = AppLocalizations.of(context)!;

                ///  Lắng nghe sự kiện điều hướng
                if (vm.goToRegister) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPageView(),
                      ),
                    );
                    vm.resetNavigation();
                  });
                }
                if (vm.goToForgetPassword) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgetPasswordView(),
                      ),
                    );
                    vm.resetNavigation();
                  });
                }
                //  Navigate to Home after successful login
                if (vm.goToHome) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(context, '/home');
                    // Hoặc nếu chưa có named routes:
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => const HomePageView()),
                    // );
                    vm.resetNavigation();
                  });
                }

                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isDark
                                ? const [
                                    Color.fromARGB(255, 82, 153, 34),
                                    Color.fromARGB(255, 10, 67, 29),
                                    Colors.black,
                                  ]
                                : const [
                                    Color.fromARGB(255, 82, 153, 34),
                                    Color.fromARGB(255, 112, 202, 142),
                                    Colors.white,
                                  ],
                            stops: const [0.2, 0.5, 0.8],
                          ),
                        ),

                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 40),

                                      const Icon(
                                        Icons.message,
                                        size: 60,
                                        color: Color(0xFF7CFC00),
                                      ),

                                      const SizedBox(height: 10),
                                      Text(
                                        "SAY CHAT",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),

                                      const SizedBox(height: 10),
                                      Text(
                                        l10n.welcome,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                      ),

                                      const SizedBox(height: 30),

                                      MyTextField(
                                        icon: Icons.email,
                                        hintText: l10n.email,
                                        obscureText: false,
                                        controller: vm.emailController,
                                      ),

                                      const SizedBox(height: 20),

                                      MyTextField(
                                        icon: Icons.lock,
                                        hintText: l10n.password,
                                        obscureText: true,
                                        controller: vm.passwordController,
                                      ),

                                      const SizedBox(height: 10),

                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 25,
                                              top: 10,
                                            ),
                                            child: TextButton(
                                              onPressed: vm.onForgetPasswordTap,
                                              child: Text(
                                                l10n.forget,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 25,
                                              top: 10,
                                            ),
                                            child: TextButton(
                                              onPressed: vm.onRegisterTap,
                                              child: Text(
                                                l10n.register,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(137, 1, 107, 17),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),

                                      vm.isLoading
                                          ? ButtonConfirm(
                                              text: l10n.loading,
                                              onTap: null,
                                            )
                                          : ButtonConfirm(
                                              text: l10n.login,
                                              onTap: vm.login,
                                            ),

                                      if (vm.errorMessage != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            vm.errorMessage!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),

                                      const SizedBox(height: 10),
                                      const Text(
                                        '----or-----',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),
                                      MyButton(
                                        leading: Image.asset(
                                          'assets/icons/google2.png',
                                          width: 24,
                                          height: 24,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('Asset error: $error');
                                            return Icon(Icons.account_circle, size: 24);
                                          },
                                        ),
                                        backgroundColor: Colors.grey,
                                        text: l10n.signInWithGoogle,
                                        onTap: vm.signInWithGoogle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
