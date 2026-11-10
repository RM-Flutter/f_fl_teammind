import 'package:app_test/core/utils/string_extensions.dart';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/app_content_width.widget.dart';
import 'package:app_test/core/constants/app_design.dart';

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
      height: MediaQuery.paddingOf(context).top + (isExpanded ? 120 : 64),
      decoration: BoxDecoration(
        borderRadius: isExpanded
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.xl),
                bottomRight: Radius.circular(AppRadius.xl),
              )
            : null,
      ),
      child: Stack(
        children: [
          // Background image: fills the header, so the rounded bottom is really visible.
          Positioned.fill(
            child: ClipRRect(
              borderRadius: isExpanded
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadius.xl),
                      bottomRight: Radius.circular(AppRadius.xl),
                    )
                  : BorderRadius.zero,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset("assets/images/png/team-mind-home.jpg",
                      fit: BoxFit.cover),
                  // Soft darkening so the white text reads on any part of the picture.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content: sits on the bottom edge with a fixed gap, whatever the status bar height.
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: AppContentWidth(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: isExpanded ? 30 : 12,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.page),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // User Photo or Visitor Icon
                                  if (isVisitor)
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
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
                                            pathParameters: {
                                              'lang':
                                                  context.locale.languageCode
                                            },
                                          );
                                        } catch (e) {
                                          debugPrint('Navigation error: $e');
                                        }
                                      },
                                      child: (us1Cache['photo'] == null ||
                                              (us1Cache['photo'].isEmpty ==
                                                  true))
                                          ? Container(
                                              width: 52,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.transparent,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: AppSizes.s28,
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 26,
                                              child: ClipOval(
                                                child: CachedNetworkImage(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                  imageUrl:
                                                      us1Cache['photo'] ?? "",
                                                  placeholder: (context, url) =>
                                                      const ShimmerAnimatedLoading(),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AutoSizeText(
                                          isVisitor
                                              ? AppStrings.visitor.tr()
                                              : _formatName(
                                                      us1Cache?['name'] ?? '')
                                                  .titleCase,
                                          minFontSize: 14,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge
                                              ?.copyWith(
                                                color: AppThemeService
                                                    .colorPalette
                                                    .quinaryTextColor
                                                    .color,
                                              ),
                                        ),
                                        Text(
                                          isVisitor
                                              ? AppStrings.welcomeToFreeServices
                                                  .tr()
                                              : AppStrings.niceToMeetYou.tr(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 15,
                                            color: Color(AppColors.background),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  gapW12,
                                  // Logout icon for logged-in users (same logic as MoreScreen: logout then go to splash)
                                  GestureDetector(
                                    onTap: () {
                                      context.pushNamed(
                                        AppRoutes.freeMoreScreen.name,
                                        pathParameters: {
                                          'lang': context.locale.languageCode
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white
                                            .withValues(alpha: 0.18),
                                        border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.6)),
                                      ),
                                      child: const Icon(Icons.menu,
                                          color: Colors.white, size: 22),
                                    ),
                                  ),
                                  // Login button for visitors
                                  if (isVisitor)
                                    TextButton.icon(
                                      onPressed: () {
                                        context.goNamed(
                                          AppRoutes.login.name,
                                          pathParameters: {
                                            'lang': context.locale.languageCode
                                          },
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
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.2),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.lg),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
