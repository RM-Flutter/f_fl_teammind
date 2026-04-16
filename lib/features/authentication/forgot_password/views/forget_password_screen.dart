import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/validation_service.dart';
import '../../shared/widgets/switch_row_widget.dart';
import '../controller/forgot_password_controller.dart';
import '../../login/controller/login_controller.dart';
import '../../shared/widgets/phone_number_field.dart';
import '../../shared/widgets/verification_tile_widget.dart';
import 'package:app_test/core/utils/app_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool isPhoneLogin;
  const ForgotPasswordScreen({super.key, required this.isPhoneLogin});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<ForgotPasswordController>(create: (_) => ForgotPasswordController()..init(widget.isPhoneLogin),),
      ChangeNotifierProvider<AuthenticationController>(create: (_) => AuthenticationController(),),
    ],
      child: Consumer<AuthenticationController>(
        builder: (context, authenticationViewModel, child) {
          return Consumer<ForgotPasswordController>(
            builder: (context, viewModel, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!viewModel.goToChooseForgotMethod && !viewModel.codeSent) ...[
                    SwitchRow(
                      viewPhone: true,
                      value: viewModel.isPhoneLogin,
                      onChanged: (newValue) =>
                          viewModel.toggleLoginMethod(newValue),
                    ),
                    SizedBox(height: AppSizes.s24.h),
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
                            hintStyle: AppStyles.hintTitleContent(context).copyWith(fontSize: 12),
                            hintText: AppStrings.yourEmail.tr().toUpperCase()),
                        validator: (value) =>
                            ValidationService.validateEmail(value),
                      ),),
                    SizedBox(height: AppSizes.s26.h),
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
                    SizedBox(height: AppSizes.s28.h),
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
                              InputDecoration(
                                  hintStyle: AppStyles.hintTitleContent(context).copyWith(fontSize: 12),
                                  hintText: AppStrings.enterVerificationCode.tr().toUpperCase()),
                              validator: (value) =>
                                  ValidationService.validateRequired(value, AppStrings.code.tr()),
                            ),
                            SizedBox(height: AppSizes.s20.h),
                            TextFormField(
                              controller: viewModel.newPasswordController,
                              decoration: InputDecoration(
                                hintStyle: AppStyles.hintTitleContent(context).copyWith(fontSize: 12),
                                hintText: AppStrings.newPassword.tr().toUpperCase(),
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
                    SizedBox(height: AppSizes.s20.h),
                    Center(
                      child: CustomElevatedButton(
                          isPrimaryBackground: false,
                          title: AppStrings.send.tr(),
                          onPressed: () async {
                            if(viewModel.codeFormKey.currentState!.validate()){
                              await viewModel.resetNewPasswordWithCodeAndNewPassword(
                                  mak: ()async{
                                    if(viewModel.phoneController.text.isEmpty || viewModel.phoneController.text == null){
                                      setState(() {
                                        authenticationViewModel.isPhoneLogin = false;
                                      });
                                    }else{
                                      setState(() {
                                        authenticationViewModel.isPhoneLogin = true;
                                      });
                                    }
                                    authenticationViewModel.login(
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
                    SizedBox(height: AppSizes.s28.h),
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
