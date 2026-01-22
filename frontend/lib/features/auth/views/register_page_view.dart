import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/my_textfield.dart';
import '../../../widgets/my_button.dart';
import '../viewmodels/register_page_viewmodel.dart';
import '../viewmodels/login_page_viewmodel.dart';
import 'login_page_view.dart';
import 'package:provider/provider.dart';


class RegisterPageView extends StatelessWidget {
  const RegisterPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (_) => RegisterPageViewModel(),
      child: Consumer<RegisterPageViewModel>(
        builder: (context, vm, _) {
          
          /// Điều hướng sau khi đăng ký xong
          if (vm.isLoggedIn) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPageView(),
                ),
              );
              vm.resetNavigation();
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.register),
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.message, size: 60, color: Colors.blue),
                      const SizedBox(height: 10),

                      Text(
                        l10n.register,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 30),

                      /// USERNAME
                      MyTextField(
                        icon: Icons.person,
                        hintText: l10n.userName,
                        obscureText: false,
                        controller: vm.userNameController,
                      ),

                      const SizedBox(height: 20),

                      /// EMAIL
                      MyTextField(
                        icon: Icons.email,
                        hintText: l10n.email,
                        obscureText: false,
                        controller: vm.emailController,
                      ),

                      const SizedBox(height: 20),

                      /// PASSWORD
                      MyTextField(
                        icon: Icons.lock,
                        hintText: l10n.password,
                        obscureText: true,
                        controller: vm.passwordController,
                      ),

                      const SizedBox(height: 20),

                      /// CONFIRM PASSWORD
                      MyTextField(
                        icon: Icons.lock,
                        hintText: l10n.cfPassword,
                        obscureText: true,
                        controller: vm.passwordCFController,
                      ),

                      const SizedBox(height: 25),

                      /// REGISTER BUTTON
                      vm.isLoading
                          ? ButtonConfirm(
                              text: l10n.loading,
                              onTap: null,
                            )
                          : ButtonConfirm(
                              text: l10n.register,
                              onTap: vm.register,
                            ),

                      const SizedBox(height: 10),

                      /// ERROR
                      if (vm.errorMessage != null)
                        Text(
                          vm.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
