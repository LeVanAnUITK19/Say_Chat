import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/my_textfield.dart';
import '../../../widgets/my_button.dart';
import '../viewmodels/sendOTPChange_page_viewmodel.dart';
import 'package:provider/provider.dart';
import 'changePassword_page_view.dart';

class SendOTPChangeView extends StatelessWidget {
  const SendOTPChangeView({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => SendOTPChangePageViewModel(email),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.reTurn)),
        body: Center(
          child: Consumer<SendOTPChangePageViewModel>(
            builder: (context, vm, _) {
              /// ✅ Lắng nghe điều hướng ĐÚNG CHỖ
              if (vm.goToResetPassword) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPageView(),
                    ),
                  );
                  vm.onResetPasswordNavigated();
                });
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email, size: 60, color: Colors.blue),
                  const SizedBox(height: 20),

                  Text(
                    l10n.forget,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 10),
                  
                  Text(
                    "Bấm xác nhận để nhận mã OTP qua email đăng ký tài khoản",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),


                  const SizedBox(height: 20),

                  vm.isLoading
                      ? ButtonConfirm(text: l10n.loading, onTap: null)
                      : ButtonConfirm(
                          text: l10n.confirm,
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
