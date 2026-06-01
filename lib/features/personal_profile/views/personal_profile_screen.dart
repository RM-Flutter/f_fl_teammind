import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/validation_service.dart';
import '../../../core/utils/base_page/mobile_header.dart';
import '../../../core/utils/base_page/mobile.scaffold.dart';
import '../../authentication/shared/widgets/phone_number_field.dart';
import '../controllers/personal_profile_controller.dart';
import 'widgets/personal_profile_header.widget.dart';
import 'widgets/personal_profile_shrinked_header.widget.dart';


class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  late final PersonalProfileController viewModel;
  bool fa = CacheHelper.getBool("twoFa") ?? false;

  Widget _buildReloadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black26,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppStrings.loading.tr()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    viewModel = PersonalProfileController();
    viewModel.initializePersonalProfileScreen(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = AppStyles.heading(context).copyWith(
      fontWeight: FontWeight.w600,
      color: Color(AppColors.secondaryButton),
      fontSize: AppSizes.s14.sp,
    );
    return ChangeNotifierProvider<PersonalProfileController>(
      create: (_) => viewModel,
      child: CoreMobileScaffold(
          backgroundColor: Colors.white,
          controller: viewModel.scrollController,
          headers: [
            CoreHeader.transform(
              pinned: true,
              color: Colors.white,
              shrinkHeight: AppSizes.s140.h,
              expandedHeight: AppSizes.s340.h,
              shrinkChild: const PersonalProfileShrinkedHeaderWidget(),
              child: SingleChildScrollView(
                  controller: viewModel.scrollController,
                  child: Consumer<PersonalProfileController>(
                    builder: (context, viewModel, child) =>
                        PersonalProfileHeaderWidget(
                            viewModel: viewModel,
                            circleBorderWidth: AppSizes.s12.r,
                            key: UniqueKey(),
                            headerImage: AppImages.companyInfoBackground,
                            backgroundHeight: viewModel.backgroundHeight.h,
                            notchedContainerHeight:
                            viewModel.notchedContainerHeight.h,
                            notchRadius: viewModel.notchRadius.r,
                            notchPadding: viewModel.notchPadding.r,
                            notchImage: AppImages.logo,
                            title: viewModel.nameController.text.isNotEmpty ? viewModel.nameController.text : "",
                            photo: UserSettingConst.userSettings != null ?UserSettingConst.userSettings!.photo ??"" : "",
                            subtitle: AppStrings.niceToMeetYou.tr()),
                  )),
            )
          ],
          children: [
            Consumer<HomeController>(
              builder: (context, value, child) {
                return Consumer<PersonalProfileController>(
                    builder: (context, viewModel, child) {
                      if (viewModel.isSuccessUpdate == true ||
                          viewModel.isSuccessUpdateImage == true) {
                        viewModel.isSuccessUpdate = false;
                        viewModel.isSuccessUpdateImage = false;
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          viewModel.setReloadingSettingsAfterUpdate(true);
                          try {
                            await Future.delayed(const Duration(seconds: 1));
                            if (context.mounted) {
                              await value.initializeHomeScreen(context, ['user_settings']);
                            }
                          } finally {
                            viewModel.setReloadingSettingsAfterUpdate(false);
                          }
                        });
                      }
                      var jsonString;
                      var us1Cache;
                      jsonString = CacheHelper.getString("US1");
                      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
                        us1Cache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
                      }
                      return Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: AppSizes.s12.h),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSizes.s12.w),
                              child: !kIsWeb?Column(
                                children: [
                                  // CHANGE PHONE NUMBER
                                  ...[
                                    Text(
                                      AppStrings.updateMainData.tr(),
                                      style: textStyle,
                                    ),
                                    Form(
                                      key: viewModel.form1Key,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          //Avatar

                                          gapH12,
                                          //Name
                                          TextFormField(
                                            controller: viewModel.nameController,
                                            keyboardType: TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                                hintText: AppStrings.name.tr()),
                                            validator: (value) =>
                                                ValidationService.validateRequired(
                                                    value, AppStrings.name.tr()),
                                          ),

                                          gapH12,
                                          //BirthDate
                                          TextFormField(
                                            readOnly: true,
                                            onTap: () async => await viewModel
                                                .selectBirthDate(context),
                                            controller: viewModel.birthDateController,
                                            decoration: InputDecoration(
                                                hintText: AppStrings.birthdate.tr()),
                                            validator: (value) =>
                                                ValidationService.validateRequired(
                                                    value, AppStrings.birthdate.tr()),
                                          ),
                                          //update profile button
                                          gapH18,
                                          Center(
                                            child: CustomElevatedButton( isOutlined: true,titleColor: Color(AppColors.buttons),
                                                radius: AppSizes.s10.r,
                                                titleSize: AppSizes.s14.sp,
                                                title: AppStrings.updateProfile.tr(),
                                                onPressed: () async =>
                                                    viewModel.updateProfileMainInfo(
                                                        context: context)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const CustomDivider(),
                                  ],
                                  // CHANGE EMAIL
                                  ...[
                                    Text(
                                      AppStrings.changeEmail.tr(),
                                      style: textStyle,
                                    ),
                                    gapH18,
                                    //Email
                                    Form(
                                      key: viewModel.form2Key,
                                      child: TextFormField(
                                        controller: viewModel.emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        decoration:
                                        const InputDecoration(hintText: 'Email'),
                                        validator: (value) =>
                                            ValidationService.validateEmail(value),
                                      ),
                                    ),
                                    gapH18,
                                    Center(
                                      child: CustomElevatedButton( isOutlined: true,titleColor: Color(AppColors.buttons),
                                          radius: AppSizes.s10.r,
                                          titleSize: AppSizes.s14.sp,
                                          backgroundColor: UserSettingConst.userSettings
                                              ?.emailVerifiedAt ==
                                              null &&
                                              UserSettingConst
                                                  .userSettings?.email !=
                                                  null
                                              ? Colors.yellow
                                              : Color(AppColors.buttons),
                                          title: UserSettingConst.userSettings
                                              ?.emailVerifiedAt ==
                                              null &&
                                              UserSettingConst
                                                  .userSettings?.email !=
                                                  null
                                              ? AppStrings.emailVerification.tr()
                                              : AppStrings.updateEmail.tr(),
                                          onPressed: () async {
                                            if (UserSettingConst.userSettings
                                                ?.emailVerifiedAt ==
                                                null &&
                                                UserSettingConst.userSettings?.email !=
                                                    null) {
                                              await viewModel.getUUID(
                                                  context,"email");
                                              viewModel.showEmailVerificationPopup(
                                                  context: context,
                                                  validate: true,
                                                  sendBy: "email",
                                                  newEmail: viewModel.emailController.text,
                                                  emailUuid: CacheHelper.getString("uuid")!);
                                            } else {
                                              viewModel.updateProfileEmail(
                                                  context: context);
                                            }
                                          }),
                                    ),
                                    const CustomDivider(),
                                  ],
                                  ...[
                                    Text(
                                      AppStrings.changePhoneNumber.tr(),
                                      style: textStyle,
                                    ),
                                    gapH18,
                                    //phone number
                                    PhoneNumberField(
                                      controller: viewModel.phoneNumberController,
                                      countryCodeController:
                                      viewModel.countryCodeController,
                                    ),
                                    gapH18,
                                    Center(
                                      child: CustomElevatedButton( isOutlined: true,titleColor: Color(AppColors.buttons),
                                          titleSize: AppSizes.s14.sp,
                                          radius: AppSizes.s10.r,
                                          backgroundColor: UserSettingConst.userSettings
                                              ?.phoneVerifiedAt ==
                                              null &&
                                              UserSettingConst
                                                  .userSettings?.phone !=
                                                  null
                                              ? Colors.yellow
                                              : Color(AppColors.buttons),
                                          title: UserSettingConst.userSettings
                                              ?.phoneVerifiedAt ==
                                              null &&
                                              UserSettingConst
                                                  .userSettings?.phone !=
                                                  null
                                              ? AppStrings.phoneVerification.tr()
                                              : AppStrings.updatePhone.tr(),
                                          onPressed: () async {
                                            if (UserSettingConst.userSettings?.phoneVerifiedAt ==
                                                null &&
                                                UserSettingConst.userSettings?.phone !=
                                                    null) {
                                              await viewModel.getUUID(
                                                  context,"sms");
                                              viewModel.showPhoneVerificationPopup(
                                                  context: context,
                                                  validate: true,
                                                  sendBy: "sms",
                                                  newPhoneNumber: viewModel
                                                      .phoneNumberController.text,
                                                  phoneUuid: CacheHelper.getString("uuid")!);
                                            } else {
                                              viewModel.updateProfilePhoneNumber(
                                                  context: context);
                                            }
                                          }),
                                    ),
                                    gapH20,
                                    const CustomDivider(),
                                  ],
                                  gapH12,
                                  Text(AppStrings.two_factor_auth.tr(), style: textStyle, textAlign: TextAlign.center,),
                                  gapH20,
                                  if(us1Cache != null)  Row(
                                    children: [
                                      Text(
                                        AppStrings.enableAndDisable2fa.tr(),
                                        style: textStyle.copyWith(fontSize: 18.sp),
                                      ),
                                      const Spacer(),
                                      if(us1Cache != null) Switch(
                                        inactiveTrackColor: Colors.white,
                                        inactiveThumbColor: Colors.grey,
                                        activeColor: Colors.white,
                                        activeTrackColor: Color(AppColors.secondaryButton),
                                        value: fa,
                                        onChanged: (v) async{
                                          setState(() {
                                            fa = v;
                                          });
                                          await viewModel.activate2FA(context: context, tfa: fa == true ? "1" : "0", twoFa: false);
                                          await value.initializeHomeScreen(context, ['user_settings']);
                                        },
                                      ),

                                    ],
                                  ),
                                  if(us1Cache['tfa'] == true)Center(
                                    child: CustomElevatedButton(
                                      titleSize: AppSizes.s14.sp,
                                      width: 1.sw,
                                      radius: AppSizes.s10.r,
                                      backgroundColor:
                                      Color(AppColors.buttons),
                                      title: AppStrings.enable2fa.tr(),
                                      onPressed: () async =>
                                      await viewModel.activate2FA(
                                          context: context, twoFa: true, tfa: "1"),
                                    ),
                                  ),
                                  const CustomDivider(),
                                  Text(AppStrings.delete_account.tr(), style: textStyle, textAlign: TextAlign.center),
                                  gapH20,
                                  // Enable 2FA
                                  Center(
                                    child: CustomElevatedButton(
                                      titleSize: AppSizes.s14.sp,
                                      width: 1.sw,
                                      radius: AppSizes.s10.r,
                                      backgroundColor: const Color(AppColors.pureRed),
                                      title: AppStrings.deleteYourAccount.tr(),
                                      onPressed: () async => await viewModel
                                          .removeAccount(context: context),
                                    ),
                                  ),
                                  SizedBox(height: 25.h,)
                                ],
                              ):
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 1100.w),
                                  child: Column(
                                    children: [
                                      // CHANGE PHONE NUMBER
                                      ...[
                                        gapH12,
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppStrings.updateMainData.tr(),
                                              style: textStyle,
                                            ),
                                            SizedBox(width: 20.w,),
                                            Expanded(
                                              flex: 5,
                                              child: Form(
                                                key: viewModel.form1Key,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextFormField(
                                                      controller: viewModel.nameController,
                                                      keyboardType: TextInputType.emailAddress,
                                                      decoration: InputDecoration(
                                                          hintText: AppStrings.name.tr()),
                                                      validator: (value) =>
                                                          ValidationService.validateRequired(
                                                              value, AppStrings.name.tr()),
                                                    ),

                                                    gapH12,
                                                    //BirthDate
                                                    TextFormField(
                                                      readOnly: true,
                                                      onTap: () async => await viewModel
                                                          .selectBirthDate(context),
                                                      controller: viewModel.birthDateController,
                                                      decoration: InputDecoration(
                                                          hintText: AppStrings.birthdate.tr()),
                                                      validator: (value) =>
                                                          ValidationService.validateRequired(
                                                              value, AppStrings.birthdate.tr()),
                                                    ),
                                                    //update profile button

                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        gapH18,
                                        Center(
                                          child: CustomElevatedButton( isOutlined: true,
                                              titleColor: Color(AppColors.buttons),
                                              radius: AppSizes.s10.r,
                                              titleSize: AppSizes.s14.sp,
                                              title: AppStrings.updateProfile.tr(),
                                              onPressed: () async =>
                                                  viewModel.updateProfileMainInfo(
                                                      context: context)),
                                        ),
                                        const CustomDivider(),
                                      ],
                                      // CHANGE EMAIL
                                      ...[
                                        Row(
                                          children: [
                                            Text(
                                              AppStrings.changeEmail.tr(),
                                              style: textStyle,
                                            ),
                                            gapW20,
                                            //Email
                                            Expanded(
                                              flex: 5,
                                              child: Form(
                                                key: viewModel.form2Key,
                                                child: TextFormField(
                                                  controller: viewModel.emailController,
                                                  keyboardType: TextInputType.emailAddress,
                                                  decoration:
                                                  const InputDecoration(hintText: 'Email'),
                                                  validator: (value) =>
                                                      ValidationService.validateEmail(value),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        gapH18,
                                        Center(
                                          child: CustomElevatedButton(
                                              titleColor:UserSettingConst.userSettings?.emailVerifiedAt == null && UserSettingConst.userSettings?.email != null
                                                  ? Colors.yellow
                                                  : Color(AppColors.buttons),
                                              outlineColor:UserSettingConst.userSettings?.emailVerifiedAt == null && UserSettingConst.userSettings?.email != null
                                                  ? Colors.yellow
                                                  : Color(AppColors.buttons),
                                              isOutlined: true,
                                              radius: AppSizes.s10.r,
                                              titleSize: AppSizes.s14.sp,
                                              backgroundColor: UserSettingConst.userSettings?.emailVerifiedAt == null && UserSettingConst.userSettings?.email != null
                                                  ? Colors.yellow
                                                  : Color(AppColors.buttons),
                                              title: UserSettingConst.userSettings?.emailVerifiedAt == null && UserSettingConst.userSettings?.email != null
                                                  ? AppStrings.emailVerification.tr()
                                                  : AppStrings.updateEmail.tr(),
                                              onPressed: () async {
                                                if (UserSettingConst.userSettings
                                                    ?.emailVerifiedAt ==
                                                    null &&
                                                    UserSettingConst.userSettings?.email !=
                                                        null) {
                                                  await viewModel.getUUID(
                                                      context,"email");
                                                  viewModel.showEmailVerificationPopup(
                                                      context: context,
                                                      validate: true,
                                                      sendBy: "email",
                                                      newEmail: viewModel.emailController.text,
                                                      emailUuid: CacheHelper.getString("uuid")!);
                                                } else {
                                                  viewModel.updateProfileEmail(
                                                      context: context);
                                                }
                                              }),
                                        ),
                                        const CustomDivider(),
                                      ],
                                      ...[
                                        Row(
                                          children: [
                                            Text(
                                              AppStrings.changePhoneNumber.tr(),
                                              style: textStyle,
                                            ),
                                            gapW20,
                                            //phone number
                                            Expanded(
                                              flex: 5,
                                              child: PhoneNumberField(
                                                controller: viewModel.phoneNumberController,
                                                countryCodeController:
                                                viewModel.countryCodeController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        gapH18,
                                        Center(
                                          child: CustomElevatedButton(
                                              titleColor:UserSettingConst.userSettings?.phoneVerifiedAt == null && UserSettingConst.userSettings?.phone != null
                                                  ? Colors.yellow
                                                  : Color(AppColors.buttons),
                                              outlineColor:UserSettingConst.userSettings?.phoneVerifiedAt == null && UserSettingConst.userSettings?.phone != null
                                                  ? Colors.yellow
                                                  : Color(AppColors.buttons),
                                              isOutlined: true,
                                              titleSize: AppSizes.s14.sp,
                                              radius: AppSizes.s10.r,
                                              backgroundColor: UserSettingConst.userSettings
                                                  ?.phoneVerifiedAt ==
                                                  null &&
                                                  UserSettingConst
                                                      .userSettings?.phone !=
                                                      null
                                                  ? Colors.yellow
                                                  : Color(AppColors.buttons),
                                              title: UserSettingConst.userSettings
                                                  ?.phoneVerifiedAt ==
                                                  null &&
                                                  UserSettingConst
                                                      .userSettings?.phone !=
                                                      null
                                                  ? AppStrings.phoneVerification.tr()
                                                  : AppStrings.updatePhone.tr(),
                                              onPressed: () async {
                                                if (UserSettingConst.userSettings?.phoneVerifiedAt ==
                                                    null &&
                                                    UserSettingConst.userSettings?.phone !=
                                                        null) {
                                                  await viewModel.getUUID(
                                                      context,"sms");
                                                  viewModel.showPhoneVerificationPopup(
                                                      context: context,
                                                      validate: true,
                                                      sendBy: "sms",
                                                      newPhoneNumber: viewModel
                                                          .phoneNumberController.text,
                                                      phoneUuid: CacheHelper.getString("uuid")!);
                                                } else {
                                                  viewModel.updateProfilePhoneNumber(
                                                      context: context);
                                                }
                                              }),
                                        ),
                                        gapH20,
                                        const CustomDivider(),
                                      ],
                                      gapH12,
                                      Text(AppStrings.two_factor_auth.tr(), style: textStyle, textAlign: TextAlign.center,),
                                      gapH20,
                                      if(us1Cache != null)  Row(
                                        children: [
                                          Text(
                                            AppStrings.enableAndDisable2fa.tr(),
                                            style: textStyle.copyWith(fontSize: 18.sp),
                                          ),
                                          const Spacer(),
                                          if(us1Cache != null) Switch(
                                            value: fa,
                                            inactiveTrackColor: Colors.white,
                                            inactiveThumbColor: Colors.grey,
                                            activeColor: Colors.white,
                                            activeTrackColor: Color(AppColors.secondaryButton),
                                            onChanged: (v) async{
                                              setState(() {
                                                fa = v;
                                              });
                                              await viewModel.activate2FA(context: context, tfa: fa == true ? "1" : "0", twoFa: false);
                                              await value.initializeHomeScreen(context, ['user_settings']);
                                            },
                                          ),

                                        ],
                                      ),

                                      if( us1Cache!= null && us1Cache['tfa'] == true) Center(
                                        child: CustomElevatedButton( isOutlined: true,titleColor: Color(AppColors.buttons),
                                          titleSize: AppSizes.s14.sp,
                                          width: 1.sw,
                                          radius: AppSizes.s10.r,
                                          backgroundColor:
                                          Color(AppColors.buttons),
                                          title: AppStrings.enable2fa.tr(),
                                          onPressed: () async =>
                                          await viewModel.activate2FA(
                                              context: context),
                                        ),
                                      ),
                                      gapH20,
                                      const CustomDivider(),
                                      Text(AppStrings.delete_account.tr(), style: textStyle, textAlign: TextAlign.center),
                                      gapH20,
                                      // Enable 2FA
                                      Center(
                                        child: CustomElevatedButton(
                                          titleSize: AppSizes.s14.sp,
                                          width: 1.sw,
                                          radius: AppSizes.s10.r,
                                          backgroundColor: const Color(AppColors.pureRed),
                                          title: AppStrings.deleteYourAccount.tr(),
                                          onPressed: () async => await viewModel
                                              .removeAccount(context: context),
                                        ),
                                      ),
                                      SizedBox(height: 25.h,)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (viewModel.isReloadingSettingsAfterUpdate)
                            _buildReloadingOverlay(context),
                        ],
                      );
                    });
              },
            )
          ]),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gapH20,
        Divider(
          color: Color(AppColors.secondaryButton).withOpacity(0.2),
          height: AppSizes.s6,
          thickness: AppSizes.s2,
        ),
        gapH20,
      ],
    );
  }
}
