import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/validation_service.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
import 'package:app_test/features/personal_profile/controllers/personal_profile_controller.dart';
import 'package:app_test/core/constants/app_strings.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => PersonalProfileController(),
        child: Consumer<HomeController>(
          builder: (context, values, child) {
            return Consumer<PersonalProfileController>(
              builder: (context, value, child) {
                if(value.isSuccess == true){
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    passwordController.clear();
                  });
                }
                return Scaffold(
                  backgroundColor: const Color(0xffFFFFFF),
                  appBar: AppBar(
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: const Color(0xffFFFFFF),
                    leading: Padding(
                      padding: EdgeInsets.all(AppSizes.s10.r),
                      child: InkWell(
                        onTap: () =>  Navigator.pop(context),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(AppColors.dark)),
                          child: Icon(
                            Icons.arrow_back_sharp,
                            color: Colors.white,
                            size: AppSizes.s18.r,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      AppStrings.updatePassword.tr().toUpperCase(),
                      style: AppStyles.darkHeading(context).copyWith(
                          fontSize: AppSizes.s16.sp,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  body: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: 1.sh,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 30.h),
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
                                SizedBox(height: 30.h),
                                if(value.isLoading) const Center(child: CircularProgressIndicator(),),
                                if(!value.isLoading) GestureDetector(
                                  onTap: (){
                                    if(formKey.currentState!.validate()){
                                      value.updatePassword(context: context, password: passwordController.text);
                                    }
                                  },
                                  child: Container(
                                    width: 0.6.sw,
                                    height: 50.h,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Color(AppColors.primary),
                                      borderRadius: BorderRadius.circular(50.r),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/images/svg/apply_filter.svg"),
                                        SizedBox(width: 15.w,),
                                        Text(
                                          AppStrings.saveChanges.tr().toUpperCase(),
                                          style: AppStyles.whiteContent(context).copyWith(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500),
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