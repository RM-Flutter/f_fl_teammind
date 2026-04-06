import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/models/notifications_model.dart';
import 'package:app_test/core/models/requests_model.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/vocation_list.widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/user_consts.dart' show UserSettingConst;


class HomeAppbarWidget extends StatelessWidget {
  final bool? isExpanded;
  final List<RequestModel>? requests;
  final List<NotificationModel>? notifications;
  const HomeAppbarWidget(
      {super.key,
        this.requests,
        this.notifications,
        this.isExpanded = true,});
  String formatName(String fullName) {
    List<String> names = fullName.split(" ");
    if (names.length < 2) return fullName;

    String firstName = names[0];
    String lastInitial = names[1][0].toUpperCase();

    return "${firstName[0].toUpperCase()}${firstName.substring(1)} $lastInitial.";
  }

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
    var us1Cache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      us1Cache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(us1Cache);
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: isExpanded == true
            ? BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s32.r),
            bottomRight: Radius.circular(AppSizes.s32.r))
            : null,
      ),
      child: Stack(
        children: [
          Stack(
            children: [
              // Background image
              ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSizes.s32.r),
                    bottomRight: Radius.circular(AppSizes.s32.r)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppSizes.s32.r),
                        bottomRight: Radius.circular(AppSizes.s32.r)),
                  ),
                    child: Image.asset(
                      "assets/images/png/team-mind-home.jpg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300.0.h,
                    ),
                ),
              ),
              // Your content goes here, if any
            ],
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                if ( us1Cache != null &&  ( (us1Cache['phone'] != null && us1Cache['phone_verified_at'] == null) ||(us1Cache['email'] != null && us1Cache['email_verified_at'] == null)  ) )  GestureDetector(
                  onTap: ()async{
                    await context.pushNamed(
                        AppRoutes.personalProfile.name,
                        pathParameters: {'lang': context.locale.languageCode});
                  },
                  child: Container(
                    color: Colors.yellow,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 24.r),
                        SizedBox(width: 8.w),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.6,
                          child: Text(
                            getVerificationStatus(us1Cache),   style: AppStyles.content(context).copyWith(color: Colors.red, fontSize: 14.sp),
                          ),
                        ),
                        const Spacer(),
                        Text(AppStrings.activeNow.tr(), style: AppStyles.content(context).copyWith(fontSize: 12.sp, color: Colors.green),),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 5.h,
                    right: LocalizationService.isArabic(context: context) ? 15.w : 0, left: LocalizationService.isArabic(context: context) ? 0 : 15.w,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if(us1Cache != null )InkWell(
                              onTap: () async =>
                                  context.pushNamed(
                                      AppRoutes.personalProfile.name,
                                      pathParameters: {'lang': context.locale.languageCode}),
                              child: (us1Cache != null && us1Cache['photo'] == null ||
                                  (us1Cache['photo'].isEmpty == true))
                                  ? Container(
                                width: AppSizes.s40.w,
                                height: AppSizes.s40.h,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                    border:
                                    Border.all(color: Colors.white, width: 2.w)),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: AppSizes.s28.r,
                                ),
                              )
                                  : CircleAvatar(
                                radius: AppSizes.s22.r,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    imageUrl: us1Cache['photo'] ?? "",
                                    placeholder: (context, url) =>
                                    const ShimmerAnimatedLoading(),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.image_not_supported_outlined,
                                      size: AppSizes.s32.r,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            us1Cache == null
                                ? ShimmerAnimatedLoading(
                              height: AppSizes.s32.h,
                              width: AppSizes.s50.w,
                            )
                                : Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(formatName(us1Cache['name']?.toString() ?? ''),
                                      minFontSize: 20,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyles.whiteHeading(context).copyWith(fontSize: 24.sp)),
                                   Text(AppStrings.niceToMeetYou.tr().toUpperCase(),
                                       maxLines: 2,
                                       overflow: TextOverflow.ellipsis,
                                       style: AppStyles.whiteContent(context).copyWith(
                                           fontWeight: FontWeight.w400,
                                           letterSpacing: 0.5,
                                           fontSize: 15.5.sp
                                       )),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (us1Cache != null)
                              Stack(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.notifications_none_outlined,
                                        color: Colors.white, size: 28.r),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                        minWidth: 40.w, minHeight: 40.h),
                                    onPressed: () => context.pushNamed(
                                        AppRoutes.notification.name,
                                        pathParameters: {
                                          'lang': context.locale.languageCode
                                        }),
                                  ),
                                  if (notifications?.any((n) => n.seen == false || n.seen == 0) ?? false)
                                    Positioned(
                                      top: 10.h,
                                      right: LocalizationService.isArabic(context: context) ? 12.w : null,
                                      left: LocalizationService.isArabic(context: context) ? null : 12.w,
                                      child: Container(
                                        width: 7.r,
                                        height: 7.r,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            if(us1Cache != null && ((us1Cache['email_verified_at'] == null) || ( us1Cache['phone_verified_at'] == null)))
                              GestureDetector(
                                  onTap: ()async{
                                    await context.pushNamed(
                                        AppRoutes.personalProfile.name,
                                        pathParameters: {'lang': context.locale.languageCode});
                                  },
                                  child: Icon(Icons.error, color: Colors.yellow, size: 24.r))
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      if (isExpanded == true)
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: kIsWeb ? 1100.w : double.infinity
                            ),
                            child: VacationListWidget(
                              requests: requests,
                              tap: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
