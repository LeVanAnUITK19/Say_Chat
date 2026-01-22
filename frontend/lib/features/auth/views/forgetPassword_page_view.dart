import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/my_textfield.dart';
import '../../../widgets/my_button.dart';
import '../viewmodels/forgetPassword_page_viewmodel.dart';
import 'package:provider/provider.dart';
import 'resetPassword_page_view.dart';

class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => ForgetPasswordPageViewModel(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.login)),
        body: Center(
          child: Consumer<ForgetPasswordPageViewModel>(
            builder: (context, vm, _) {
              /// ✅ Lắng nghe điều hướng ĐÚNG CHỖ
              if (vm.goToResetPassword) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResetpasswordPageView(),
                    ),
                  );
                  vm.onResetPasswordNavigated();
                });
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_reset, size: 60, color: Colors.blue),
                  const SizedBox(height: 20),

                  Text(
                    l10n.forget,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 30),

                  MyTextField(
                    icon: Icons.email,
                    hintText: l10n.email,
                    obscureText: false,
                    controller: vm.emailController,
                  ),

                  const SizedBox(height: 20),

                  vm.isLoading
                      ? ButtonConfirm(text: l10n.loading, onTap: null)
                      : ButtonConfirm(
                          text: l10n.send,
                          onTap: vm.forgetPassword,
                        ),

                  if (vm.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
