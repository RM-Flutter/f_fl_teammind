import 'dart:convert';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/general_listener.dart';
import 'package:app_test/core/services/validation_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../authentication/shared/widgets/phone_number_field.dart';
import '../controllers/personal_profile_controller.dart';
import 'widgets/personal_profile_header.widget.dart';

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
          child: AppCard(
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
    );
  }

  @override
  void initState() {
    super.initState();
    viewModel = PersonalProfileController();
    viewModel.initializePersonalProfileScreen(context: context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? jsonString = CacheHelper.getString("USG");
      if (jsonString != null && jsonString.isNotEmpty) {
        Map<String, dynamic> gCache = json.decode(jsonString);
        final popups = gCache['popups'];
        if (popups != null && popups.isNotEmpty) {
          GeneralListener().startAll(context, "profile", popups);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = AppStyles.heading(context).copyWith(
      fontWeight: FontWeight.w600,
      color: Color(AppColors.secondaryButton),
      fontSize: AppSizes.s14,
    );

    return ChangeNotifierProvider<PersonalProfileController>(
      create: (_) => viewModel,
      child: Consumer<HomeController>(
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
                      await value.initializeHomeScreen(
                          context, ['user_settings']);
                    }
                  } finally {
                    viewModel.setReloadingSettingsAfterUpdate(false);
                  }
                });
              }

              Map<String, dynamic>? us1Cache;
              final jsonString = CacheHelper.getString("US1");
              if (jsonString != null && jsonString.isNotEmpty) {
                us1Cache = json.decode(jsonString) as Map<String, dynamic>;
              }

              return Scaffold(
                backgroundColor: Color(AppColors.scaffoldBackGround),
                appBar: AppBarWithBookmark(
                  title: AppStrings.accountAndSettings.tr(),
                  showBookmark: false,
                  actions: [
                    IconButton(
                      onPressed: () async =>
                          await viewModel.logout(context: context),
                      tooltip: 'Logout',
                      icon: Icon(
                        Icons.logout_outlined,
                        color: Color(AppColors.failureRed),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                body: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: viewModel.scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        12,
                        AppSpacing.page,
                        32,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PersonalProfileHeaderWidget(
                                viewModel: viewModel,
                                circleBorderWidth: AppSizes.s12,
                                headerImage: AppImages.companyInfoBackground,
                                backgroundHeight: viewModel.backgroundHeight.h,
                                notchedContainerHeight:
                                    viewModel.notchedContainerHeight.h,
                                notchRadius: viewModel.notchRadius.r,
                                notchPadding: viewModel.notchPadding.r,
                                notchImage: AppImages.logo,
                                title:
                                    viewModel.nameController.text.isNotEmpty
                                        ? viewModel.nameController.text
                                        : "",
                                photo: UserSettingConst.userSettings != null
                                    ? UserSettingConst.userSettings!.photo ?? ""
                                    : "",
                                subtitle: AppStrings.niceToMeetYou.tr(),
                              ),
                              const SizedBox(height: 12),

                              // 1. Update Main Data Card
                              AppCard(
                                child: Form(
                                  key: viewModel.form1Key,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.updateMainData.tr(),
                                        style: textStyle,
                                      ),
                                      gapH12,
                                      TextFormField(
                                        controller: viewModel.nameController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                            hintText: AppStrings.name.tr()),
                                        validator: (value) =>
                                            ValidationService.validateRequired(
                                                value, AppStrings.name.tr()),
                                      ),
                                      gapH12,
                                      TextFormField(
                                        readOnly: true,
                                        onTap: () async => await viewModel
                                            .selectBirthDate(context),
                                        controller:
                                            viewModel.birthDateController,
                                        decoration: InputDecoration(
                                            hintText:
                                                AppStrings.birthdate.tr()),
                                        validator: (value) =>
                                            ValidationService.validateRequired(
                                                value,
                                                AppStrings.birthdate.tr()),
                                      ),
                                      gapH18,
                                      Center(
                                        child: CustomElevatedButton(
                                          isOutlined: true,
                                          width: double.infinity,
                                          titleColor: Color(AppColors.buttons),
                                          title: AppStrings.updateProfile.tr(),
                                          onPressed: () async => viewModel
                                              .updateProfileMainInfo(
                                                  context: context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 2. Change Email Card
                              AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.changeEmail.tr(),
                                      style: textStyle,
                                    ),
                                    gapH12,
                                    Form(
                                      key: viewModel.form2Key,
                                      child: TextFormField(
                                        controller: viewModel.emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                            hintText: 'Email'),
                                        validator: (value) =>
                                            ValidationService.validateEmail(
                                                value),
                                      ),
                                    ),
                                    gapH18,
                                    Center(
                                      child: CustomElevatedButton(
                                        isOutlined: true,
                                        width: double.infinity,
                                        titleColor: Color(AppColors.buttons),
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
                                              UserSettingConst
                                                      .userSettings?.email !=
                                                  null) {
                                            await viewModel.getUUID(
                                                context, "email");
                                            viewModel
                                                .showEmailVerificationPopup(
                                              context: context,
                                              validate: true,
                                              sendBy: "email",
                                              newEmail: viewModel
                                                  .emailController.text,
                                              emailUuid: CacheHelper.getString(
                                                  "uuid")!,
                                            );
                                          } else {
                                            viewModel.updateProfileEmail(
                                                context: context);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 3. Change Phone Number Card
                              AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.changePhoneNumber.tr(),
                                      style: textStyle,
                                    ),
                                    gapH12,
                                    PhoneNumberField(
                                      controller:
                                          viewModel.phoneNumberController,
                                      countryCodeController:
                                          viewModel.countryCodeController,
                                    ),
                                    gapH18,
                                    Center(
                                      child: CustomElevatedButton(
                                        isOutlined: true,
                                        width: double.infinity,
                                        titleColor: Color(AppColors.buttons),
                                        title: UserSettingConst.userSettings
                                                        ?.phoneVerifiedAt ==
                                                    null &&
                                                UserSettingConst
                                                        .userSettings?.phone !=
                                                    null
                                            ? AppStrings.phoneVerification.tr()
                                            : AppStrings.updatePhone.tr(),
                                        onPressed: () async {
                                          if (UserSettingConst.userSettings
                                                      ?.phoneVerifiedAt ==
                                                  null &&
                                              UserSettingConst
                                                      .userSettings?.phone !=
                                                  null) {
                                            await viewModel.getUUID(
                                                context, "sms");
                                            viewModel
                                                .showPhoneVerificationPopup(
                                              context: context,
                                              validate: true,
                                              sendBy: "sms",
                                              newPhoneNumber: viewModel
                                                  .phoneNumberController.text,
                                              phoneUuid: CacheHelper.getString(
                                                  "uuid")!,
                                            );
                                          } else {
                                            viewModel.updateProfilePhoneNumber(
                                                context: context);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 4. Two-Factor Auth Card
                              if (us1Cache != null) ...[
                                AppCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.two_factor_auth.tr(),
                                        style: textStyle,
                                      ),
                                      gapH12,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              AppStrings.enableAndDisable2fa
                                                  .tr(),
                                              style: textStyle.copyWith(
                                                  fontSize: 14),
                                            ),
                                          ),
                                          Switch(
                                            inactiveTrackColor: Colors.white,
                                            inactiveThumbColor: Colors.grey,
                                            activeColor: Colors.white,
                                            activeTrackColor: Color(
                                                AppColors.secondaryButton),
                                            value: fa,
                                            onChanged: (v) async {
                                              setState(() {
                                                fa = v;
                                              });
                                              await viewModel.activate2FA(
                                                context: context,
                                                tfa: fa == true ? "1" : "0",
                                                twoFa: false,
                                              );
                                              await value.initializeHomeScreen(
                                                  context, ['user_settings']);
                                            },
                                          ),
                                        ],
                                      ),
                                      if (us1Cache['tfa'] == true) ...[
                                        gapH12,
                                        CustomElevatedButton(
                                          width: double.infinity,
                                          backgroundColor:
                                              Color(AppColors.buttons),
                                          title: AppStrings.enable2fa.tr(),
                                          onPressed: () async =>
                                              await viewModel.activate2FA(
                                            context: context,
                                            twoFa: true,
                                            tfa: "1",
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // 5. Delete Account Card
                              AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.delete_account.tr(),
                                      style: textStyle,
                                    ),
                                    gapH12,
                                    CustomElevatedButton(
                                      width: double.infinity,
                                      isDestructive: true,
                                      backgroundColor:
                                          Color(AppColors.failureRed),
                                      title:
                                          AppStrings.deleteYourAccount.tr(),
                                      onPressed: () async => await viewModel
                                          .removeAccount(context: context),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (viewModel.isReloadingSettingsAfterUpdate)
                      _buildReloadingOverlay(context),
                  ],
                ),
              );
            },
          );
        },
      ),
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
          color: Color(AppColors.secondaryButton).withOpacity(0.12),
          height: AppSizes.s6,
          thickness: 1,
        ),
        gapH20,
      ],
    );
  }
}
