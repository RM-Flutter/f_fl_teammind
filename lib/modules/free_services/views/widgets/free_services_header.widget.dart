import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../general_services/app_config.service.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../constants/user_consts.dart';
import '../../../../general_services/app_theme.service.dart';
import '../../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../../general_services/localization.service.dart';
import '../../../../models/settings/user_settings.model.dart';
import '../../../../routing/app_router.dart';
import '../../../../utils/custom_shimmer_loading/shimmer_animated_loading.dart';

class FreeServicesHeaderWidget extends StatelessWidget {
  final bool isExpanded;

  const FreeServicesHeaderWidget({
    super.key,
    this.isExpanded = true,
  });

  String _formatName(String fullName) {
    List<String> names = fullName.split(" ");
    if (names.length < 2) return fullName;

    String firstName = names[0];
    String lastName = names.length > 1 ? names[1] : '';

    return "$firstName $lastName";
  }

  bool _isVisitor() {
    var jsonString = CacheHelper.getString("US1");
    return jsonString == null || jsonString.isEmpty || jsonString == "";
  }

  @override
  Widget build(BuildContext context) {
    var jsonString = CacheHelper.getString("US1");
    Map<String, dynamic>? us1Cache;
    bool isVisitor = _isVisitor();
    
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      us1Cache = json.decode(jsonString) as Map<String, dynamic>;
      UserSettingConst.userSettings = UserSettingsModel.fromJson(us1Cache);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: isExpanded
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.s32),
                bottomRight: Radius.circular(AppSizes.s32),
              )
            : null,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppSizes.s32),
              bottomRight: Radius.circular(AppSizes.s32),
            ),
            child: Image.asset(
              "assets/images/png/team-mind-home.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: isExpanded ? 200 : 140,
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 25,
                    right: LocalizationService.isArabic(context: context) ? 15 : 0,
                    left: LocalizationService.isArabic(context: context) ? 0 : 15,
                  ),
                  child: Column(
                    children: [
                      gapH18,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // User Photo or Visitor Icon
                            if (isVisitor)
                              Container(
                                width: AppSizes.s40,
                                height: AppSizes.s40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                  size: AppSizes.s28,
                                ),
                              )
                            else if (us1Cache != null)
                              InkWell(
                                onTap: () {
                                  try {
                                    GoRouter.of(context).pushNamed(
                                      AppRoutes.personalProfile.name,
                                      pathParameters: {'lang': context.locale.languageCode},
                                    );
                                  } catch (e) {
                                    debugPrint('Navigation error: $e');
                                  }
                                },
                                child: (us1Cache['photo'] == null ||
                                        (us1Cache['photo'].isEmpty == true))
                                    ? Container(
                                        width: AppSizes.s40,
                                        height: AppSizes.s40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.transparent,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
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
                            // User Name or Visitor Welcome
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    isVisitor 
                                        ? AppStrings.visitor.tr()
                                        : _formatName(us1Cache?['name'] ?? ''),
                                    minFontSize: 20,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                          color: AppThemeService.colorPalette.quinaryTextColor.color,
                                        ),
                                  ),
                                  Text(
                                    isVisitor
                                        ? AppStrings.welcomeToFreeServices.tr()
                                        : AppStrings.niceToMeetYou.tr(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 15,
                                      color: Color(AppColors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Logout icon for logged-in users (same logic as MoreScreen: logout then go to splash)
                            GestureDetector(
                              onTap: (){
                                context.pushNamed(
                                  AppRoutes.freeMoreScreen.name,
                                  pathParameters: {'lang': context.locale.languageCode},
                                );
                              },
                              child: Container(
                                padding: EdgeInsetsGeometry.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white)
                                ),
                                child: Icon(Icons.menu, color: Colors.white,),
                              ),
                            ),
                            // Login button for visitors
                            if (isVisitor)
                              TextButton.icon(
                                onPressed: () {
                                  context.goNamed(
                                    AppRoutes.login.name,
                                    pathParameters: {'lang': context.locale.languageCode},
                                  );
                                },
                                icon: const Icon(
                                  Icons.login,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: Text(
                                  AppStrings.login.tr(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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
          ),
        ],
      ),
    );
  }
}
