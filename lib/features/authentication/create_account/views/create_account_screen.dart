import 'package:app_test/features/authentication/create_account/controller/create_account_controller.dart';
import 'package:app_test/features/authentication/login/controller/login_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/validation_service.dart';
import '../../shared/widgets/phone_number_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


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
                          gapH20,
                          PhoneNumberField(
                            controller: viewModel.phoneController,
                            phoneError: viewModel.phoneError,
                            countryCodeController: viewModel.countryCodeController,
                          ),
                          // gapH4,
                          // SwitchRow(
                          //   value: false,
                          //   onChanged: (newValue) => setState(() {}),
                          //   leftText: AppStrings.smsActive.tr(),
                          //   rightText: AppStrings.whatsAppActive.tr(),
                          // ),
                          gapH20,
                          TextFormField(
                            controller: viewModel.emailController,
                            decoration: InputDecoration(
                              hintText: AppStrings.yourEmail.tr(),
                              errorText: viewModel.emailError,
                            ),
                            validator: (val) => ValidationService.validateEmail(val),
                          ),
                          gapH20,
                          TextFormField(
                            controller: viewModel.passwordController,
                            decoration: InputDecoration(
                              hintText: AppStrings.password.tr().toUpperCase(),
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
                          gapH20,
                          TextFormField(
                            controller: viewModel.nameController,
                            decoration: InputDecoration(
                              hintText: AppStrings.yourName.tr(),
                              errorText: viewModel.nameError,
                            ),
                            validator: (val) => ValidationService.validateRequired(val, AppStrings.yourName.tr()),
                          ),
                          // const SizedBox(height: 10,),
                          // Container(
                          //   height: 55,
                          //   alignment: LocalizationService.isArabic(context: context)
                          //       ?Alignment.centerRight : Alignment.centerLeft,
                          //   margin: const EdgeInsets.symmetric(vertical: AppSizes.s10),
                          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          //   decoration: ShapeDecoration(
                          //     color: AppThemeService.colorPalette.tertiaryColorBackground.color,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(AppSizes.s8),
                          //       side: BorderSide(
                          //         color: Color(AppColors.whiteGrey),
                          //         width: 1.0,
                          //       ),
                          //     ),
                          //     shadows: const [
                          //       BoxShadow(
                          //         color: AppColors.black,
                          //         blurRadius: 10,
                          //         offset: Offset(0, 1),
                          //         spreadRadius: 0,
                          //       )
                          //     ],
                          //   ),
                          //   child: Directionality(
                          //     textDirection: LocalizationService.isArabic(context: context)
                          //         ? TextDirection.rtl
                          //         : TextDirection.ltr,
                          //     child: Text(
                          //          "${CacheHelper.getString("role")}".tr(),
                          //       style: TextStyle(
                          //           fontSize: 16,
                          //           fontWeight: FontWeight.w400,
                          //           color:const Color(0xff000000)
                          //               .withOpacity(0.74)),
                          //     ),
                          //   ),
                          // ),
                          gapH28,
                          Center(
                              child: viewModel.isEmailRegister == false ?CustomElevatedButton(
                                  isPrimaryBackground: false,
                                  title: AppStrings.create.tr(),
                                  onPressed: () async {
                                    if(viewModel.phoneController.text.isEmpty){
                                      Fluttertoast.showToast(
                                          msg: AppStrings.phoneNumberIsRequired.tr(),
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 5,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
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
                          gapH32,
                        ],
                      ),
                    );
                  });
            }
        )
    );
  }
}
