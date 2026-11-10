import 'dart:convert';

import 'package:app_test/features/home/controllers/home_controller.dart';
import 'package:app_test/features/personal_profile/controllers/personal_profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/features/more/customized_notification/views/customize_notification_screen.dart';
import 'package:app_test/features/more/more_screen.dart' show DefaultListTile, MoreSectionLabel;
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/string_extensions.dart';
import 'package:app_test/core/constants/app_design.dart';

class FreeServiceMoreScreen extends StatefulWidget {
  const FreeServiceMoreScreen({super.key});

  @override
  State<FreeServiceMoreScreen> createState() => _FreeServiceMoreScreenState();
}

class _FreeServiceMoreScreenState extends State<FreeServiceMoreScreen> {
  final ValueNotifier<bool?> isLogout = ValueNotifier<bool?>(null);

  @override
  void initState() {
    super.initState();
    isLogout.addListener(() {
      if (isLogout.value == false) {
        context.pop();
      } else if (isLogout.value == true) {
        context.pop();

        PersonalProfileController().logout(context: context);
      }
    });
  }

  @override
  void dispose() {
    isLogout.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? gCache;
    final jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    final name = (gCache?['name'] ?? '').toString();
    final job = (gCache?['job_title'] ?? '').toString();

    return Consumer<HomeController>(
      builder: (context, value, child) {
        // Same layout as the More tab: navy picture on top, white card with the avatar on its edge.
        final safeTop = MediaQuery.paddingOf(context).top;
        final cardTop = safeTop + AppSizes.moreHeaderBelowSafeArea;
        const avatar = AppSizes.moreAvatar;
        return Scaffold(
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                alignment: Alignment.topCenter,
                color: Color(AppColors.secondaryButton),
                child: SizedBox(
                  height: cardTop + AppRadius.xl,
                  width: double.infinity,
                  child: Image.asset("assets/images/png/more_back.png", fit: BoxFit.cover),
                ),
              ),
              Positioned.fill(
                top: cardTop,
                child: Container(
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(0, 0),
                      end: const Alignment(1, 0),
                      colors: [Color(AppColors.background), Color(AppColors.cardBackground)],
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.xl),
                        topRight: Radius.circular(AppRadius.xl),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: avatar / 2 + AppSpacing.md),
                      if (name.isNotEmpty)
                        Padding(
                          padding: AppSpacing.pagePadding,
                          child: Text(
                            name.titleCase,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppStyles.heading(context)
                                .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      if (job.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Padding(
                          padding: AppSpacing.pagePadding,
                          child: Text(
                            job,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppStyles.greyContent(context)
                                .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Expanded(
                        child: ListView(
                          // A ListView adds the status-bar height on top by itself.
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          children: [
                            MoreSectionLabel(AppStrings.functionality.tr()),
                            DefaultListTile(
                              title: AppStrings.home.tr(),
                              src: "assets/images/svg/free_home.svg",
                              onTap: () => context.goNamed(
                                AppRoutes.freeServicesHome.name,
                                pathParameters: {'lang': context.locale.languageCode},
                              ),
                            ),
                            DefaultListTile(
                              title: AppStrings.articlesNew.tr(),
                              src: "assets/images/svg/man.svg",
                              onTap: () => context.pushNamed(
                                AppRoutes.defaultPage.name,
                                pathParameters: {
                                  "lang": context.locale.languageCode,
                                  "type": "blogs"
                                },
                              ),
                            ),
                            DefaultListTile(
                              title: AppStrings.aboutComapny.tr(),
                              src: "assets/images/svg/map.svg",
                              onTap: () => context.pushNamed(
                                AppRoutes.aboutUsScreen.name,
                                pathParameters: {"lang": context.locale.languageCode},
                              ),
                            ),
                            MoreSectionLabel(AppStrings.myAccount.tr()),
                            DefaultListTile(
                              title: AppStrings.customizeNotifications.tr(),
                              src: "assets/images/svg/mcn.svg",
                              onTap: () => showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    const CustomizeNotificationScreen(),
                              ),
                            ),
                            DefaultListTile(
                              title: AppStrings.languageSettings.tr(),
                              src: "assets/images/svg/mls.svg",
                              onTap: () => context.pushNamed(
                                AppRoutes.langSettingScreen.name,
                                pathParameters: {'lang': context.locale.languageCode},
                              ),
                            ),
                            DefaultListTile(
                              title: AppStrings.updatePassword.tr(),
                              src: "assets/images/svg/mup.svg",
                              onTap: () => context.pushNamed(
                                AppRoutes.updatePassword.name,
                                pathParameters: {"lang": context.locale.languageCode},
                              ),
                            ),
                            DefaultListTile(
                              title: AppStrings.personalInfo.tr(),
                              src: "assets/images/svg/mpi.svg",
                              onTap: () => context.pushNamed(
                                AppRoutes.personalProfile.name,
                                pathParameters: {"lang": context.locale.languageCode},
                              ),
                            ),
                            const SizedBox(height: AppSpacing.section),
                            DefaultListTile(
                              title: AppStrings.logout.tr(),
                              src: "assets/images/svg/mlo.svg",
                              onTap: () async {
                                final appConfigService =
                                    Provider.of<AppConfigService>(context, listen: false);
                                appConfigService.logout(context, viewAlert: true).then((v) {
                                  context.goNamed(
                                    AppRoutes.splash.name,
                                    pathParameters: {'lang': context.locale.languageCode},
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: cardTop - avatar / 2,
                child: GestureDetector(
                  onTap: () => context.pushNamed(
                    AppRoutes.personalProfile.name,
                    pathParameters: {'lang': context.locale.languageCode},
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: CachedNetworkImage(
                        imageUrl: (gCache?['photo'] ?? '').toString(),
                        fit: BoxFit.cover,
                        height: avatar,
                        width: avatar,
                        placeholder: (context, url) => ShimmerAnimatedLoading(
                            width: avatar, height: avatar, circularRaduis: avatar),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          height: avatar,
                          width: avatar,
                          child: Icon(Icons.person, size: 48, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
