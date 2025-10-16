import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/general_services/validation_service.dart';
import 'package:rmemp/modules/home/view_models/home.viewmodel.dart';
import 'package:rmemp/modules/personal_profile/viewmodels/personal_profile.viewmodel.dart';
import 'package:rmemp/utils/widgets/text_form_widget.dart';
import '../../../../constants/app_strings.dart';

class UpdatePasswordScreen extends StatefulWidget {
  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => PersonalProfileViewModel(),
        child: Consumer<HomeViewModel>(
          builder: (context, values, child) {
            return Consumer<PersonalProfileViewModel>(
              builder: (context, value, child) {
                if(value.isSuccess){
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    passwordController.clear();
                  });
                }
                return Scaffold(
                  backgroundColor: const Color(0xffFFFFFF),
                  appBar: AppBar(
                    backgroundColor: const Color(0xffFFFFFF),
                    leading: Padding(
                      padding: const EdgeInsets.all(AppSizes.s10),
                      child: InkWell(
                        onTap: () =>  Navigator.pop(context),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(AppColors.dark)),
                          child: const Icon(
                            Icons.arrow_back_sharp,
                            color: Colors.white,
                            size: AppSizes.s18,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      AppStrings.updatePassword.tr().toUpperCase(),
                      style: const TextStyle(
                          fontSize: AppSizes.s16,
                          fontWeight: FontWeight.w700,
                          color: Color(AppColors.dark)),
                    ),
                  ),
                  body: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * 1,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 30),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    hintText: AppStrings.newPassword.tr(),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        hidePassword ? Icons.visibility : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          hidePassword = !hidePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) =>
                                      ValidationService.validatePassword(value, login: true),
                                  obscureText: hidePassword,
                                ),
                                const SizedBox(height: 30,),
                                if(value.isLoading) const Center(child: CircularProgressIndicator(),),
                                if(!value.isLoading) GestureDetector(
                                  onTap: (){
                                    if(formKey.currentState!.validate()){
                                      value.updatePassword(context: context, password: passwordController.text);
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width * 0.6,
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(AppColors.primary),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 40),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/images/svg/apply_filter.svg"),
                                        const SizedBox(width: 15,),
                                        Text(
                                          AppStrings.saveChanges.tr().toUpperCase(),
                                          style:const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xffFFFFFF)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        )
    );
  }
}
