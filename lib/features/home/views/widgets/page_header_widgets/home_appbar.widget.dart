import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
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
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/user_consts.dart' show UserSettingConst;


class HomeAppbarWidget extends StatelessWidget {
  final bool? isExpanded;
  final List<RequestModel>? requests;
  const HomeAppbarWidget(
      {super.key,
        this.requests,
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
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s32),
            bottomRight: Radius.circular(AppSizes.s32)),
      ),
      child: Stack(
        children: [
          Stack(
            children: [
              // Background image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppSizes.s32),
                    bottomRight: Radius.circular(AppSizes.s32)),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppSizes.s32),
                        bottomRight: Radius.circular(AppSizes.s32)),
                  ),
                  child: Image.asset(
                    "assets/images/png/team-mind-home.jpg",
                    fit: BoxFit.cover,
                    width: double.infinity,height: 380,
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
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.6,
                          child: Text(
                            getVerificationStatus(us1Cache),   style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        const Spacer(),
                        Text(AppStrings.activeNow.tr(), style: const TextStyle(fontSize: 12, color: Colors.green),),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 25,
                    right: LocalizationService.isArabic(context: context) ? 15 : 0, left: LocalizationService.isArabic(context: context) ? 0 : 15,
                  ),
                  child: Column(
                    children: [
                      gapH18,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                width: AppSizes.s40,
                                height: AppSizes.s40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                    border:
                                    Border.all(color: Colors.white, width: 2)),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: AppSizes.s28,
                                ),
                              )
                                  : CircleAvatar(
                                radius: AppSizes.s22,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    imageUrl: us1Cache['photo'] ?? "",
                                    placeholder: (context, url) =>
                                    const ShimmerAnimatedLoading(),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: AppSizes.s32,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            gapW12,
                            us1Cache == null
                                ? const ShimmerAnimatedLoading(
                              height: AppSizes.s32,
                              width: AppSizes.s50,
                            )
                                : Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(formatName(us1Cache['name']?.toString() ?? ''),
                                      minFontSize: 20,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                          color: AppThemeService.colorPalette
                                              .quinaryTextColor.color)),
                                  Text(AppStrings.niceToMeetYou.tr(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 15, color: Color(AppColors.white)
                                      )),
                                ],
                              ),
                            ),
                            // if (us1Cache != null)
                            //   IconButton(
                            //     icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 22),
                            //     tooltip: AppStrings.logout.tr(),
                            //     padding: EdgeInsets.zero,
                            //     constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            //     onPressed: () async {
                            //       final appConfigService = Provider.of<AppConfigService>(context, listen: false);
                            //       await appConfigService.logout(context, viewAlert: true);
                            //       if (context.mounted) {
                            //         context.goNamed(AppRoutes.splash.name, pathParameters: {'lang': context.locale.languageCode});
                            //       }
                            //     },
                            //   ),
                            gapW8,
                            // const Spacer(),
                            // NotificationIcon(
                            //   hasNewNotifications: true,
                            //   numOfUnreadNotifications:
                            //   us1Cache['new_notification_count'] ?? 0,
                            //   // onTap: () async => await context.pushNamed(
                            //   //     AppRoutes.rewardsAndPenalties.name,
                            //   //     extra: {'employeeName': null, 'employeeId': null},
                            //   //     pathParameters: {'lang': context.locale.languageCode})
                            //   onTap: () => context.pushNamed(AppRoutes.notification.name,
                            //       pathParameters: {'lang': context.locale.languageCode}),
                            // )
                            const Spacer(),
                            if((us1Cache['email_verified_at'] == null) || ( us1Cache['phone_verified_at'] == null))
                              GestureDetector(
                                  onTap: ()async{
                                    await context.pushNamed(
                                        AppRoutes.personalProfile.name,
                                        pathParameters: {'lang': context.locale.languageCode});
                                  },
                                  child: const Icon(Icons.error, color: Colors.yellow,))
                          ],
                        ),
                      ),
                      gapH32,
                      if (isExpanded == true)
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                maxWidth: kIsWeb ? 1100 : double.infinity
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
