import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/modules/home/view_models/home.viewmodel.dart';
import '../../../common_modules_widgets/cached_network_image_widget.dart';
import '../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_images.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/user_consts.dart';
import '../../../general_services/layout.service.dart';
import '../../../general_services/validation_service.dart';
import '../../../utils/base_page/mobile.header.dart';
import '../../../utils/base_page/mobile.scaffold.dart';
import '../../../utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import '../../../utils/gradient_bg_image.dart';
import '../../authentication/views/widgets/phone_number_field.dart';
import '../../authentication/views/widgets/switch_row_widget.dart';
import '../viewmodels/personal_profile.viewmodel.dart';
import 'widgets/personal_profile_header.widget.dart';
import 'widgets/personal_profile_shrinked_header.widget.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  late final PersonalProfileViewModel viewModel;
  bool fa = CacheHelper.getBool("twoFa") ?? false;

  @override
  void initState() {
    super.initState();
    viewModel = PersonalProfileViewModel();
    viewModel.initializePersonalProfileScreen(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.secondary,
      fontSize: AppSizes.s14,
    );
    return ChangeNotifierProvider<PersonalProfileViewModel>(
      create: (_) => viewModel,
      child: CoreMobileScaffold(
          backgroundColor: Colors.white,
          controller: viewModel.scrollController,
          headers: [
            CoreHeader.transform(
              pinned: true,
              color: Colors.white,
              shrinkHeight: AppSizes.s140,
              expandedHeight: AppSizes.s340,
              shrinkChild: const PersonalProfileShrinkedHeaderWidget(),
              child: SingleChildScrollView(
                  controller: viewModel.scrollController,
                  child: Consumer<PersonalProfileViewModel>(
                    builder: (context, viewModel, child) =>
                        PersonalProfileHeaderWidget(
                            viewModel: viewModel,
                            circleBorderWidth: AppSizes.s12,
                            key: UniqueKey(),
                            headerImage: AppImages.companyInfoBackground,
                            backgroundHeight: viewModel.backgroundHeight,
                            notchedContainerHeight:
                            viewModel.notchedContainerHeight,
                            notchRadius: viewModel.notchRadius,
                            notchPadding: viewModel.notchPadding,
                            notchImage: AppImages.logo,
                            title: viewModel.nameController.text.isNotEmpty ? viewModel.nameController.text : "",
                            photo: UserSettingConst.userSettings != null ?UserSettingConst.userSettings!.photo ??"" : "",
                            subtitle: AppStrings.niceToMeetYou.tr()),
                  )),
            )
          ],
          children: [
            Consumer<HomeViewModel>(
              builder: (context, value, child) {
                return Consumer<PersonalProfileViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.isSuccessUpdate == true ||
                          viewModel.isSuccessUpdateImage == true) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Future.delayed(Duration(seconds: 1), () {
                            value.initializeHomeScreen(context, ['user_settings']);
                          });
                        });
                        viewModel.isSuccessUpdate = false;
                        viewModel.isSuccessUpdateImage = false;
                      }
                      var jsonString;
                      var us1Cache;
                      jsonString = CacheHelper.getString("US1");
                      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
                        us1Cache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSizes.s12),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: AppSizes.s12, right: AppSizes.s12),
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
                                        child: CustomElevatedButton( isOutlined: true,titleColor: Color(AppColors.primary),
                                            radius: AppSizes.s10,
                                            titleSize: AppSizes.s14,
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
                                  child: CustomElevatedButton( isOutlined: true,titleColor: Color(AppColors.primary),
                                      radius: AppSizes.s10,
                                      titleSize: AppSizes.s14,
                                      backgroundColor: UserSettingConst.userSettings
                                          ?.emailVerifiedAt ==
                                          null &&
                                          UserSettingConst
                                              .userSettings?.email !=
                                              null
                                          ? Colors.yellow
                                          : Color(AppColors.primary),
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
                                  child: CustomElevatedButton( isOutlined: true,titleColor: Color(AppColors.primary),
                                      titleSize: AppSizes.s14,
                                      radius: AppSizes.s10,
                                      backgroundColor: UserSettingConst.userSettings
                                          ?.phoneVerifiedAt ==
                                          null &&
                                          UserSettingConst
                                              .userSettings?.phone !=
                                              null
                                          ? Colors.yellow
                                          : const Color(AppColors.primary),
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
                                    style: textStyle.copyWith(fontSize: 18),
                                  ),
                                  const Spacer(),
                                  if(us1Cache != null) Switch(
                                    inactiveTrackColor: Colors.white,
                                    inactiveThumbColor: Colors.grey,
                                    activeColor: Colors.white,
                                    activeTrackColor: Color(AppColors.dark),
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
                                  titleSize: AppSizes.s14,
                                  width: LayoutService.getWidth(context),
                                  radius: AppSizes.s10,
                                  backgroundColor:
                                  Theme.of(context).colorScheme.primary,
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
                                  titleSize: AppSizes.s14,
                                  width: LayoutService.getWidth(context),
                                  radius: AppSizes.s10,
                                  backgroundColor: const Color(0xffFF0000),
                                  title: AppStrings.deleteYourAccount.tr(),
                                  onPressed: () async => await viewModel
                                      .removeAccount(context: context),
                                ),
                              ),
                              SizedBox(height: 25,)
                            ],
                          ):
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1100),
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
                                        SizedBox(width: 20,),
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
                                          titleColor: Color(AppColors.primary),
                                          radius: AppSizes.s10,
                                          titleSize: AppSizes.s14,
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
                                              : Color(AppColors.primary),
                                          outlineColor:UserSettingConst.userSettings?.emailVerifiedAt == null && UserSettingConst.userSettings?.email != null
                                              ? Colors.yellow
                                              : Color(AppColors.primary),
                                          isOutlined: true,
                                          radius: AppSizes.s10,
                                          titleSize: AppSizes.s14,
                                          backgroundColor: UserSettingConst.userSettings?.emailVerifiedAt == null && UserSettingConst.userSettings?.email != null
                                              ? Colors.yellow
                                              : Color(AppColors.primary),
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
                                              : Color(AppColors.primary),
                                          outlineColor:UserSettingConst.userSettings?.phoneVerifiedAt == null && UserSettingConst.userSettings?.phone != null
                                              ? Colors.yellow
                                              : Color(AppColors.primary),
                                          isOutlined: true,
                                          titleSize: AppSizes.s14,
                                          radius: AppSizes.s10,
                                          backgroundColor: UserSettingConst.userSettings
                                              ?.phoneVerifiedAt ==
                                              null &&
                                              UserSettingConst
                                                  .userSettings?.phone !=
                                                  null
                                              ? Colors.yellow
                                              : const Color(AppColors.primary),
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
                                        style: textStyle.copyWith(fontSize: 18),
                                      ),
                                      const Spacer(),
                                      if(us1Cache != null) Switch(
                                        value: fa,
                                        inactiveTrackColor: Colors.white,
                                        inactiveThumbColor: Colors.grey,
                                        activeColor: Colors.white,
                                        activeTrackColor: Color(AppColors.dark),
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
                                    child: CustomElevatedButton( isOutlined: true,titleColor: Color(AppColors.primary),
                                      titleSize: AppSizes.s14,
                                      width: LayoutService.getWidth(context),
                                      radius: AppSizes.s10,
                                      backgroundColor:
                                      Theme.of(context).colorScheme.primary,
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
                                      titleSize: AppSizes.s14,
                                      width: LayoutService.getWidth(context),
                                      radius: AppSizes.s10,
                                      backgroundColor: const Color(0xffFF0000),
                                      title: AppStrings.deleteYourAccount.tr(),
                                      onPressed: () async => await viewModel
                                          .removeAccount(context: context),
                                    ),
                                  ),
                                  SizedBox(height: 25,)
                                ],
                              ),
                            ),
                          ),
                        ),
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
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          height: AppSizes.s6,
          thickness: AppSizes.s2,
        ),
        gapH20,
      ],
    );
  }
}
