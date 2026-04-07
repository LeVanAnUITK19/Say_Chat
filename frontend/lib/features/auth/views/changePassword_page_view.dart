import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/my_textfield.dart';
import '../../../widgets/my_button.dart';
import '../viewmodels/changePassword_page_viewmodel.dart';
import 'package:provider/provider.dart';

class ChangePasswordPageView extends StatelessWidget {
  const ChangePasswordPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (_) => ChangePasswordPageViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.reTurn),
        ),
        body: Center(
          child: Consumer<ChangePasswordPageViewModel>(
            builder: (context, vm, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_reset, size: 60, color: Colors.blue),
                  const SizedBox(height: 20),

                  Text(
                    l10n.changePW,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 30),

                  /// EMAIL
                  MyTextField(
                    icon: Icons.email,
                    hintText: l10n.email,
                    obscureText: false,
                    controller: vm.emailController,
                  ),
                  const SizedBox(height: 20),
                  //OTP
                  MyTextField(
                    icon: Icons.vpn_key,
                    hintText: l10n.otp,
                    obscureText: false,
                    controller: vm.otpController,
                  ),


                  const SizedBox(height: 20),
                   /// PASSWORD
                  MyTextField(
                    icon: Icons.lock,
                    hintText: l10n.newPassword,
                    obscureText: true,
                    controller: vm.newPasswordController,
                  ),

                  const SizedBox(height: 20),

                  /// CONFIRM PASSWORD
                  MyTextField(
                    icon: Icons.lock,
                    hintText: l10n.cfPassword,
                    obscureText: true,
                    controller: vm.confirmNewPasswordController,
                  ),
                  const SizedBox(height: 30),

                  /// BUTTON
                  vm.isLoading
                      ? ButtonConfirm(text: l10n.loading, onTap: null)
                      : ButtonConfirm(
                          text: l10n.send,
                          onTap: vm.resetPassword,
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
