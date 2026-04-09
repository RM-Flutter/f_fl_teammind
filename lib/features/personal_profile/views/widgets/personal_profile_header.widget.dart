import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/widgets/dynamic_image_widget.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/check_values.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/features/personal_profile/controllers/personal_profile_controller.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';

class PersonalProfileHeaderWidget extends StatelessWidget {
  final PersonalProfileController viewModel;
  final String headerImage;
  final double notchedContainerHeight;
  final double backgroundHeight;
  final double notchRadius;
  final double notchPadding;
  final String notchImage;
  final String photo;
  final String title;
  final String subtitle;
  final double circleBorderWidth;
  const PersonalProfileHeaderWidget(
      {super.key,
        required this.viewModel,
        required this.notchImage,
        required this.photo,
        required this.notchPadding,
        required this.headerImage,
        required this.notchedContainerHeight,
        required this.backgroundHeight,
        required this.notchRadius,
        required this.title,
        required this.subtitle,
        required this.circleBorderWidth});

  @override
  Widget build(BuildContext context) {
    String getVerificationStatus(us1Cache) {
      final email = us1Cache['email'];
      final phone = us1Cache['phone'];
      final emailVerified = us1Cache['email_verified_at'] != null;
      final phoneVerified = us1Cache['phone_verified_at'] != null;

      // لا يوجد ايميل ولا تليفون
      if (email == null && phone == null) {
        return "";
      }

      // عنده ايميل فقط
      if (email != null && phone == null) {
        return emailVerified ? "" : AppStrings.email_not_verified.tr();
      }

      // عنده تليفون فقط
      if (phone != null && email == null) {
        return phoneVerified ? "" : AppStrings.phone_not_verified.tr();
      }

      // عنده الاتنين Email + Phone
      if (!emailVerified && !phoneVerified) {
        return AppStrings.email_phone_not_verified.tr();
      }

      if (!emailVerified && phoneVerified) {
        return AppStrings.email_not_verified.tr();
      }

      if (emailVerified && !phoneVerified) {
        return AppStrings.phone_not_verified.tr();
      }

      // الاتنين متحققين ✅
      return "";
    }
    var jsonString;
    Map<String, dynamic> us1Cache = {};
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      us1Cache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
    }
    return SizedBox(
      width: 1.sw,
      height: backgroundHeight +
          (notchedContainerHeight *
              0.35), // background image height + half of notched container height
      child: Stack(
        children: [
          PersonalProfileHeaderBackgroundWidget(
              headerImage: headerImage, backgroundHeight: backgroundHeight),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CompanyInfoNotchedContainer(
              viewModel:viewModel ,
              photo: photo,
              notchedContainerHeight: notchedContainerHeight,
              notchRadius: notchRadius,
              notchPadding: notchPadding,
              notchImage: notchImage,
              title: title,
              subtitle: subtitle,
              circleBorderWidth: circleBorderWidth,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSizes.s12.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.s12.w),
              width: 1.sw,
              child: Column(
                children: [
                  if ( ( (us1Cache['phone'] != null && us1Cache['phone_verified_at'] == null) ||(us1Cache['email'] != null && us1Cache['email_verified_at'] == null)  ) )  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    color: Colors.yellow,
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 20.r,),
                        SizedBox(width: 8.w),
                        SizedBox(
                          width: 0.6.sw,
                          child: Text(
                            getVerificationStatus(us1Cache),style:  const TextStyle(color: Colors.red),
                          ),
                        ),
                        const Spacer(),
                        Text(AppStrings.activeNow.tr(), style:  TextStyle(fontSize: 12.sp, color: Colors.green),),
                      ],
                    ),
                  ),
                  if ( ( (us1Cache['phone'] != null && us1Cache['phone_verified_at'] == null) ||(us1Cache['email'] != null && us1Cache['email_verified_at'] == null)  ) ) SizedBox(height: 15.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            color: Color(AppColors.hintText).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.s15.r),
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: () => context.pop(),
                              icon:  Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: AppSizes.s18.r,
                              ),
                            ),
                          )),
                       Text(
                        AppStrings.accountAndSettings.tr(),
                        style:  AppStyles.whiteContent(context).copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: AppSizes.s14.sp,
                          letterSpacing: 1.4,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                          decoration: BoxDecoration(
                            color: Color(AppColors.hintText).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.s15.r),
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: () async =>
                                  await viewModel.logout(context: context),
                              icon:  Icon(
                                Icons.logout_outlined,
                                color: Colors.red,
                                size: AppSizes.s18.r,
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalProfileHeaderBackgroundWidget extends StatelessWidget {
  final String headerImage;
  final double? backgroundHeight;
  const PersonalProfileHeaderBackgroundWidget(
      {super.key, required this.headerImage, required this.backgroundHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: backgroundHeight,
        width: 1.sw,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(headerImage), fit: BoxFit.fill)),
        child: Stack(
          children: [
            Positioned.fill(
                child: Column(
              children: [
                Container(
                  height: backgroundHeight != null
                      ? backgroundHeight! / 2
                      : double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5],
                    ),
                  ),
                ),
                Container(
                    height: backgroundHeight != null
                        ? backgroundHeight! / 2
                        : double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    )),
              ],
            ))
          ],
        ));
  }
}

class CompanyInfoNotchedContainer extends StatefulWidget {
  final double notchedContainerHeight;
  final double notchRadius;
  final double notchPadding;
  final String notchImage;
  final String title;
  final String photo;
  var viewModel;
  final String subtitle;
  final double circleBorderWidth;
  CompanyInfoNotchedContainer(
      {super.key,
        required this.notchImage,
        required this.photo,
        required this.viewModel,
        required this.notchPadding,
        required this.notchRadius,
        required this.notchedContainerHeight,
        required this.title,
        required this.circleBorderWidth,
        required this.subtitle});

  @override
  State<CompanyInfoNotchedContainer> createState() => _CompanyInfoNotchedContainerState();
}

class _CompanyInfoNotchedContainerState extends State<CompanyInfoNotchedContainer> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    var jsonString;
    Map<String, dynamic> gCache = {};
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    return SizedBox(
      height: widget.notchedContainerHeight,
      width: 1.sw,
      child: Stack(
        children: [
          Positioned(
              top: AppSizes.s6.h,
              left: 0,
              right: 0,
              child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: (widget.notchRadius - widget.notchPadding) * 2.2,
                        height: (widget.notchRadius - widget.notchPadding) * 2.2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Color(AppColors.titleText),
                              width: AppSizes.s2.r),
                        ),
                        child: GestureDetector(
                          onTap: () async => await context
                              .pushNamed(
                              AppRoutes.employeeDetails.name,
                              pathParameters: {
                                'id': gCache['employee_profile_id'].toString(),
                                'lang':
                                context.locale.languageCode
                              }),
                          child: ClipOval(
                            child:widget.viewModel.deleteImage == false ? widget.viewModel
                                .listProfileImage
                                .isNotEmpty
                                ? Image(
                              image: CheckValuesFromApi.safeArray(widget.viewModel.listProfileImage).isNotEmpty &&
                                  CheckValuesFromApi.safeArray(widget.viewModel.listProfileImage)[0]['compressed'] != null
                                  ? FileImage(CheckValuesFromApi.safeArray(widget.viewModel.listProfileImage)[0]['compressed'] as File)
                                  : const AssetImage("assets/images/default_avatar.png") as ImageProvider,
                              fit: BoxFit.cover,
                            )
                                : UserSettingConst.userSettings
                                ?.photo ==
                                null
                                ? DynamicImageWidget(
                              imageUrl: AppImages.logo,
                              fit: BoxFit.cover,
                            )
                                : CachedNetworkImage(
                                imageUrl: widget.photo ??
                                    '',
                                fit: BoxFit.cover,
                                placeholder: (context,
                                    url) =>
                                ShimmerAnimatedLoading(
                                  circularRaduis:
                                  AppSizes
                                      .s50.r,
                                ),
                                errorWidget:
                                    (context, url,
                                    error) =>
                                Icon(
                                  Icons
                                      .image_not_supported_outlined,
                                  size: AppSizes
                                      .s60.r,
                                )) : DynamicImageWidget(
                              imageUrl: AppImages.logo,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 40.r,
                          height: 40.r,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                              color: Color(AppColors.background),
                              shape: BoxShape.circle
                          ),
                          child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Color(AppColors.titleText),
                                size: AppSizes.s20.r,
                              ),
                              onPressed: () async {
                                await widget.viewModel.getImage(context,
                                    image1: widget.viewModel
                                        .profileImage,
                                    image2: widget.viewModel
                                        .XImageFileProfile,
                                    list2: widget.viewModel
                                        .listXProfileImage,
                                    list: widget.viewModel
                                        .listProfileImage);
                                widget.viewModel.updateProfileMainInfoImage(context: context);
                              }),
                        ),
                      ),
                    ],
                  ))),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: PersonalProfileCustomNotchClipper(
                  notchSize: (widget.notchRadius * 2) + (widget.notchPadding * 2)),
              child: Container(
                padding: EdgeInsets.only(
                    top: (widget.notchRadius / 2).r,
                    left: AppSizes.s8.w,
                    right: AppSizes.s8.w),
                height: widget.notchedContainerHeight - (widget.notchRadius + widget.notchPadding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.s32.r),
                    topRight: Radius.circular(AppSizes.s32.r),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      widget.title,
                      style: AppStyles.primaryHeading(context).copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                    gapH12,
                    AutoSizeText(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: AppStyles.blackContent(context).copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 5.h,),
         if(widget.photo != "https://lab.r-m.dev/files/2024/user-profile.png") Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 50.h, left: 95.w),
                child: Container(
                  width: 30.r,
                  height: 30.r,
                  padding: const EdgeInsets.all(0),
                  decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle
                  ),
                  child: _isLoading == false ?IconButton(
                      icon:  Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: AppSizes.s15.r,
                      ),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await widget.viewModel.updateProfileMainInfoImage(context: context);
                        setState(() {
                          _isLoading = false;
                        });
                      }): SizedBox(
                        width: 15.r,
                        height: 15.r,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white,)
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PersonalProfileCustomNotchClipper extends CustomClipper<Path> {
  final double notchSize;

  PersonalProfileCustomNotchClipper({required this.notchSize});

  @override
  Path getClip(Size size) {
    final double radius = notchSize / 2;

    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo((size.width - notchSize) / 2, 0)
      ..arcToPoint(
        Offset((size.width + notchSize) / 2, 0),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
