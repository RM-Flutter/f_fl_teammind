import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import '../../../../../common_modules_widgets/vocation_list.widget.dart';
import '../../../../../constants/app_images.dart';
import '../../../../../constants/app_sizes.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../general_services/app_theme.service.dart';
import '../../../../../models/request.model.dart';
import '../../../../../models/settings/user_settings.model.dart';
import '../../../../../models/settings/user_settings_2.model.dart';
import '../../../../../routing/app_router.dart';
import '../../../../../utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'notification_icon.widget.dart';

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
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.s32),
                bottomRight: Radius.circular(AppSizes.s32))
            : null,
      ),
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
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
                    width: double.infinity,height: 300,
                  ),
                ),
              ),
              // Your content goes here, if any
            ],
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                if(us1Cache != null && (us1Cache['email_verified_at'] == null || us1Cache['phone_verified_at'] == null)) GestureDetector(
                  onTap: ()async{
                    await context.pushNamed(
                        AppRoutes.personalProfile.name,
                        pathParameters: {'lang': context.locale.languageCode});
                  },
                  child: Container(
                    color: Colors.yellow,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.6,
                          child: Text(
                            (us1Cache['email_verified_at'] == null && us1Cache['phone_verified_at'] != null)? AppStrings.email_not_verified.tr():
                            (us1Cache['email_verified_at'] != null && us1Cache['phone_verified_at'] == null)? AppStrings.phone_not_verified.tr():
                            (us1Cache['email_verified_at'] == null && us1Cache['phone_verified_at'] == null)? AppStrings.email_phone_not_verified.tr(): "",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        Spacer(),
                        Text(AppStrings.activeNow.tr(), style: TextStyle(fontSize: 12, color: Colors.green),),
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
                                        AutoSizeText(formatName(us1Cache['name']) ?? '',
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
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 15, color: Color(0xffFFFFFF)
                                            )),
                                      ],
                                    ),
                                  ),
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
                            Spacer(),
                            if((us1Cache['email_verified_at'] == null) || ( us1Cache['phone_verified_at'] == null))
                              GestureDetector(
                                  onTap: ()async{
                                    await context.pushNamed(
                                        AppRoutes.personalProfile.name,
                                        pathParameters: {'lang': context.locale.languageCode});
                                  },
                                  child: Icon(Icons.error, color: Colors.yellow,))
                          ],
                        ),
                      ),
                      gapH32,
                      if (isExpanded == true)
                        VacationListWidget(
                          requests: requests,
                          tap: true,
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
