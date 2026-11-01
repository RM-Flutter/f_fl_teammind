import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/validation_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/authentication/login/controller/login_controller.dart';
import '../../../shared/widgets/phone_number_field.dart';
import '../../../shared/widgets/switch_row_widget.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/layout_service.dart';

class LoginForm extends StatefulWidget {
  final AuthenticationController viewModel;
  const LoginForm({super.key, required this.viewModel});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    // Figma sizes (scaled) on phones; web and tablets keep the fixed sizes.
    final compact = LayoutService.isPhoneLayout(context);
    final switchFieldGap =
        compact ? AppSizes.loginSwitchFieldGap.h : AppSizes.s20.h;
    final fieldGap = compact ? AppSizes.loginFieldGap.h : AppSizes.s12.h;
    final afterForgotGap =
        compact ? AppSizes.loginAfterForgotGap.h : AppSizes.s16.h;
    final forgotFontSize = compact ? AppSizes.loginForgotFontSize.sp : 13.sp;
    return Column(
      children: [
        // TOGGLE BUTTON TO TOGGLE BETWEEN (PHONE || EMAIL)
        Consumer<AuthenticationController>(
          builder: (context, viewModel, child) {
            return SwitchRow(
              viewPhone: true,
              isLoginPageStyle: true,
              value: viewModel.isPhoneLogin,
              onChanged: (newValue) => viewModel.toggleLoginMethod(),

            );
          },
        ),
        SizedBox(height: switchFieldGap),
        // EMAIL OR PHONE FIELD
        Consumer<AuthenticationController>(
          builder: (context, viewModel, child) {
            return viewModel.isPhoneLogin
                ? PhoneNumberField(
                    key: ValueKey('phone_${viewModel.phoneFieldVersion}'),
                    controller: viewModel.phoneController,
                    countryCodeController: viewModel.countryCodeController,
                    forcedCountryIso: viewModel.forcedCountryIso,
                    forcedDialCode: viewModel.forcedDialCode,
                  )
                : TextFormField(
                    controller: viewModel.emailController,
                    decoration: InputDecoration(
                      hintText: AppStrings.yourEmail.tr().toUpperCase(),
                      hintStyle: AppStyles.hintTitleContent(context).copyWith(fontSize: 12),
                    ),
                    validator: (value) => ValidationService.validateEmail(value),
                  );
          },
        ),
        SizedBox(height: fieldGap),
        // PASSWORD FIELD
        Stack(
          children: [
            TextFormField(
              controller: widget.viewModel.passwordController,
              decoration: InputDecoration(
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 36),
                hintText: AppStrings.password.tr().toUpperCase(),
                hintStyle: AppStyles.hintTitleContent(context).copyWith(fontSize: 12),
                suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints.tightFor(width: 36, height: 36),
                  icon: Icon(
                    hidePassword ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
              ),
              validator: (value) => ValidationService.validatePassword(value, login: true),
              obscureText: hidePassword,
            ),
          ],
        ),
        // FORGET PASSSORD BUTTON
        if (compact) SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: compact
                  ? TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )
                  : null,
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                await widget.viewModel.showForgotPasswordModal(
                  context: context,
                );
              },
              child: Text(
                AppStrings.forgetPassword.tr(),
                style: AppStyles.whiteHeading(context)
                    .copyWith(fontSize: forgotFontSize),
              ),
            ),
          ],
        ),
        SizedBox(height: afterForgotGap),
        // LOGIN BUTTON
        CustomElevatedButton(
          width: compact ? AppSizes.buttonSmallWidth.w : null,
          height: compact ? AppSizes.buttonSmallHeight.h : null,
          title: AppStrings.login.tr(),
          onPressed: () async {
            if (!widget.viewModel.formKey.currentState!.validate()) {
              return;
            }

            if (widget.viewModel.isPhoneLogin) {
              final phoneText = widget.viewModel.phoneController.text.trim();
              if (phoneText.isEmpty) {
                Fluttertoast.showToast(
                    msg: AppStrings.phoneNumberIsRequired.tr(),
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 5,
                    backgroundColor: Color(AppColors.failureRed),
                    textColor: Color(0xffffffff),
                    fontSize: 16.0);
                return;
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(phoneText)) {
                Fluttertoast.showToast(
                    msg: AppStrings.pleaseEnterValidPhoneNumber.tr(),
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 5,
                    backgroundColor: Color(AppColors.failureRed),
                    textColor: Color(0xffffffff),
                    fontSize: 16.0);
                return;
              }
            }
            await widget.viewModel.login(context: context);
          },
          isPrimaryBackground: false,
        ),
      ],
    );
  }
}
