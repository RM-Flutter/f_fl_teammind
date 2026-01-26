import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/validation_service.dart';
import 'package:app_test/features/authentication/controllers/forgot_password_controller.dart';
import 'package:app_test/features/authentication/controllers/login_controller.dart';
import 'widgets/phone_number_field.dart';
import 'widgets/switch_row_widget.dart';
import 'widgets/verification_tile_widget.dart';

class ForgotPasswordModal extends StatefulWidget {
  final bool isPhoneLogin;
  const ForgotPasswordModal({super.key, required this.isPhoneLogin});

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<ForgotPasswordController>(create: (_) => ForgotPasswordController()..init(widget.isPhoneLogin),),
      ChangeNotifierProvider<AuthenticationController>(create: (_) => AuthenticationController(),),
    ],
    child: Consumer<AuthenticationController>(
      builder: (context, authenticationController, child) {
        return Consumer<ForgotPasswordController>(
          builder: (context, viewModel, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!viewModel.goToChooseForgotMethod && !viewModel.codeSent) ...[
                  SwitchRow(
                    viewPhone: true,
                    value: viewModel.isPhoneLogin,
                    onChanged: (newValue) =>
                        viewModel.toggleLoginMethod(newValue),
                  ),
                  gapH24,
                  Form(
                    key: viewModel.codeFormKey,
                    child: viewModel.isPhoneLogin
                      ? PhoneNumberField(
                    controller: viewModel.phoneController,
                    countryCodeController: viewModel.countryCodeController,
                  )
                      : TextFormField(
                    controller: viewModel.emailController,
                    decoration: InputDecoration(
                        hintText: AppStrings.yourEmail.tr()),
                    validator: (value) =>
                        ValidationService.validateEmail(value),
                  ),),
                  gapH26,
                  Center(
                    child: CustomElevatedButton(
                      isPrimaryBackground: false,
                      title: AppStrings.send.tr(),
                        onPressed: ()async {
                          if (viewModel.codeFormKey.currentState!.validate()) {
                           await viewModel.prepeareForgotPassword(context);
                          }
                        }

                    ),
                  ),
                  gapH28,
                ] else if (!viewModel.codeSent &&
                    viewModel.goToChooseForgotMethod &&
                    viewModel.forgotPasswordMethods != null &&
                    (viewModel.forgotPasswordMethods?.isNotEmpty ?? false)) ...[
                  ...viewModel.forgotPasswordMethods!.entries.map((m) {
                    final method = {m.key: m.value};
                    return VerificationTileWidget(
                        method: method,
                        onSelected: () async {
                          viewModel.sendType = method.keys.first;
                          await viewModel.chooseForgotPasswordMethod(
                              context: context);
                        });
                  }),
                ] else if (viewModel.codeSent) ...[
                  Form(
                      key: viewModel.codeFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: viewModel.codeController,
                            keyboardType: TextInputType.number,
                            decoration:
                            InputDecoration(hintText: AppStrings.enterVerificationCode.tr()),
                            validator: (value) =>
                                ValidationService.validateRequired(value, AppStrings.code.tr()),
                          ),
                          gapH20,
                          TextFormField(
                            controller: viewModel.newPasswordController,
                            decoration: InputDecoration(
                              hintText: AppStrings.newPassword.tr(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscureText,
                            validator: (value) =>
                                ValidationService.validatePassword(value, login: false),
                          ),
                        ],
                      )),
                  gapH20,
                  Center(
                    child: CustomElevatedButton(
                        isPrimaryBackground: false,
                        title: AppStrings.send.tr(),
                        onPressed: () async {
                          if(viewModel.codeFormKey.currentState!.validate()){
                            await viewModel.resetNewPasswordWithCodeAndNewPassword(
                                mak: ()async{
                                  if(viewModel.phoneController.text.isEmpty){
                                    setState(() {
                                      authenticationController.isPhoneLogin = false;
                                    });
                                  }else{
                                    setState(() {
                                      authenticationController.isPhoneLogin = true;
                                    });
                                  }
                                 authenticationController.login(
                                      context: context,
                                      password: viewModel.newPasswordController.text,
                                      email: viewModel.emailController,
                                      phones: viewModel.phoneController,
                                      cCode: viewModel.countryCodeController.text
                                  );
                                },
                                context: context
                            );
                          }
                        }
                    ),
                  ),
                  gapH28,
                ],
              ],
            );
          },
        );
      },
    ),
    );
  }
}
