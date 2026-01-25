import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/localization.service.dart';
import 'package:app_test/models/settings/user_settings.model.dart';

class AppbarProfileContainer extends StatelessWidget {
   String? imageUrl;
   String? userName;
   String? userRole;
   AppbarProfileContainer({super.key, this.userName, this.imageUrl, this.userRole});

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
    String formatName(String fullName) {
      List<String> nameParts = fullName.split(' ');
      if (nameParts.length < 2) {
        return fullName; // Return the full name if no last name is provided.
      }
      String firstName = nameParts[0];
      String lastInitial = nameParts[1][0].toUpperCase();
      return (CacheHelper.getString("lang") == "ar") ?'.$firstName $lastInitial' :'$firstName $lastInitial.';
    }
    var jsonString;
    Map<String, dynamic> us1Cache = {};
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      us1Cache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(us1Cache);
    }
    return Column(
      children: [
        if ( ( (us1Cache['phone'] != null && us1Cache['phone_verified_at'] == null) ||(us1Cache['email'] != null && us1Cache['email_verified_at'] == null)  ) )  GestureDetector(
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
        const SizedBox(height: 15,),
       Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(
            right: AppSizes.s24,
            left: AppSizes.s24,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Container(
            width: 63,
            height: 63,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(AppColors.primary), Color(AppColors.dark)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipOval( // هنا بدل ClipRRect استخدم ClipOval
                child:  CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: 59,
                  height: 59,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ShimmerAnimatedLoading(
                    width: 63,
                    height: 63,
                    circularRaduis: 63,
                  ),
                  errorWidget: (context, url, error) =>  const Icon(
                    Icons.image_not_supported_outlined,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(
                width: 10,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 0,
                  right: LocalizationService.isArabic(context: context) ? 15 : 0,
                  left: LocalizationService.isArabic(context: context) ? 0 : 15,
                ),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.45,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 23,
                        child: Text(
                          userName!.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins"),
                        ),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      SizedBox(
                        height: 15,
                        child: Text(
                          userRole!.toUpperCase(),
                          style: TextStyle(
                              color: const Color(0xffFFFFFF).withOpacity(0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: (){
                  if(kIsWeb) {
                    context.pushNamed(
                      AppRoutes.defaultListPage.name,
                      pathParameters: {
                        "lang": context.locale.languageCode,
                        "type": "rmnotifications"
                      },
                    );
                  }else{
                    context.pushNamed(
                      AppRoutes.defaultPage.name,
                      pathParameters: {
                        "lang": context.locale.languageCode,
                        "type": "rmnotifications"
                      },
                    );
                  }
                },
                child: SvgPicture.asset(
                  "assets/images/svg/notification.svg",
                  color: const Color(0xffFFFFFF),
                  width: AppSizes.s30,
                  height: AppSizes.s30,
                ),
              )
            ],
          ),
        ),
      ],
    );
    }
  }

