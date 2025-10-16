import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/modules/authentication/view_models/login.viewmodel.dart';
import 'package:rmemp/utils/helpers/media_query_values.dart';
import '../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../general_services/validation_service.dart';
import '../../../utils/widgets/text_form_widget.dart';
import '../view_models/create_account.viewmodel.dart';
import 'widgets/phone_number_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class CreateAccountModal extends StatefulWidget {
  const CreateAccountModal({super.key});

  @override
  State<CreateAccountModal> createState() => _CreateAccountModalState();
}

class _CreateAccountModalState extends State<CreateAccountModal> {
  bool _obscureText = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers:[
          ChangeNotifierProvider<AuthenticationViewModel>(
            create: (_) => AuthenticationViewModel(),),
          ChangeNotifierProvider<CreateAccountViewModel>(
            create: (_) => CreateAccountViewModel(),),
        ],
        child: Consumer<AuthenticationViewModel>(
            builder:(context, authenticationViewModel, child){
              return Consumer<CreateAccountViewModel>(
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
                          //       side: const BorderSide(
                          //         color: Color(0xffE3E5E5),
                          //         width: 1.0,
                          //       ),
                          //     ),
                          //     shadows: const [
                          //       BoxShadow(
                          //         color: Color(0x0C000000),
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
