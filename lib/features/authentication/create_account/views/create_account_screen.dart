import 'package:app_test/features/authentication/create_account/controller/create_account_controller.dart';
import 'package:app_test/features/authentication/login/controller/login_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/validation_service.dart';
import '../../shared/widgets/phone_number_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_test/core/utils/app_styles.dart';


class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _obscureText = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers:[
          ChangeNotifierProvider<AuthenticationController>(
            create: (_) => AuthenticationController(),),
          ChangeNotifierProvider<CreateAccountController>(
            create: (_) => CreateAccountController(),),
        ],
        child: Consumer<AuthenticationController>(
            builder:(context, authenticationViewModel, child){
              return Consumer<CreateAccountController>(
                  builder: (context, viewModel, child) {
                    return Form(
                      key: viewModel.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppSizes.s20.h),
                          PhoneNumberField(
                            controller: viewModel.phoneController,
                            phoneError: viewModel.phoneError,
                            countryCodeController: viewModel.countryCodeController,
                          ),
                          SizedBox(height: AppSizes.s20.h),
                          TextFormField(
                            controller: viewModel.emailController,
                            decoration: InputDecoration(
                              hintText: AppStrings.yourEmail.tr().toUpperCase(),
                              hintStyle: AppStyles.hintTitleContent(context).copyWith(fontSize: 12),
                              errorText: viewModel.emailError,
                            ),
                            validator: (val) => ValidationService.validateEmail(val),
                          ),
                          SizedBox(height: AppSizes.s20.h),
                          TextFormField(
                            controller: viewModel.passwordController,
                            decoration: InputDecoration(
                              hintText: AppStrings.password.tr().toUpperCase(),
                              hintStyle: AppStyles.hintTitleContent(context).copyWith(fontSize: 12),
                              errorText: viewModel.passwordError,
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
                            validator: (value) =>
                                ValidationService.validatePassword(value, login: false),
                            obscureText: _obscureText,
                          ),
                          SizedBox(height: AppSizes.s20.h),
                          TextFormField(
                            controller: viewModel.nameController,
                            decoration: InputDecoration(
                              hintText: AppStrings.yourName.tr().toUpperCase(),
                              hintStyle: AppStyles.hintTitleContent(context).copyWith(fontSize: 12),
                              errorText: viewModel.nameError,
                            ),
                            validator: (val) => ValidationService.validateRequired(val, AppStrings.yourName.tr()),
                          ),
                          SizedBox(height: AppSizes.s28.h),
                          Center(
                              child: viewModel.isEmailRegister == false ?CustomElevatedButton(
                                  isPrimaryBackground: false,
                                  title: AppStrings.create.tr(),
                                  titleSize: 14.sp,
                                  onPressed: () async {
                                    if(viewModel.phoneController.text.isEmpty){
                                      Fluttertoast.showToast(
                                          msg: AppStrings.phoneNumberIsRequired.tr(),
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 5,
                                           backgroundColor: Color(AppColors.failureRed),
                                           textColor: Color(AppColors.appBarText),
                                          fontSize: 16.0
                                      );
                                      return;
                                    }
                                    if(viewModel.formKey.currentState!.validate()){
                                      viewModel.createAccount(context: context,
                                          making: (){
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
                                                password: viewModel.passwordController.text,
                                                email: viewModel.emailController.text,
                                                phones: viewModel.phoneController,
                                                cCode: viewModel.countryCodeController.text
                                            );
                                          }
                                      );
                                    }
                                  }
                              ): const CircularProgressIndicator()
                          ),
                          SizedBox(height: AppSizes.s32.h),
                        ],
                      ),
                    );
                  });
            }
        )
    );
  }
}
