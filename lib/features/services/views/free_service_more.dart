import 'dart:convert';

import 'package:app_test/features/home/controllers/home_controller.dart';
import 'package:app_test/features/personal_profile/controllers/personal_profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/user_consts.dart';
import '../../../core/models/settings/user_settings.model.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/app_config_service.dart';
import '../../../core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import '../../more/customized_notification/views/customize_notification_screen.dart';

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
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }

    return Consumer<HomeController>(
      builder: (context, value, child) {
        return Scaffold(
          body: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.topCenter,
                  color: Color(AppColors.titleText),
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.25,
                    child: Image.asset(
                      "assets/images/png/more_back.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  top: MediaQuery.sizeOf(context).height * 0.25,
                  child: Container(
                    // height: MediaQuery.sizeOf(context).height * 0.66,
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(0, 0),
                        end: const Alignment(1, 0),
                        colors: [Color(AppColors.background), Color(AppColors.cardBackground)],
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.15,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: ListView(
                              children: [
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: kIsWeb ? 1070 : double.infinity,
                                    ),
                                    child: Container(
                                      alignment: LocalizationService.isArabic(context: context)? Alignment.centerRight:Alignment.centerLeft,
                                      child: Text(AppStrings.functionality.tr().toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(AppColors.buttons))),
                                    ),
                                  ),
                                ),

                                const SizedBox(height : 15),
                                DefaultListTile(
                                  title: AppStrings.home.tr(),
                                  src: "assets/images/svg/free_home.svg",
                                  onTap: () {
                                    context.goNamed(
                                      AppRoutes.freeServicesHome.name,
                                      pathParameters: {'lang': context.locale.languageCode,},
                                    );
                                  },
                                ),
                                DefaultListTile(
                                  title: AppStrings.articlesNew.tr(),
                                  src: "assets/images/svg/man.svg",
                                  onTap: () {
                                    if (kIsWeb) {
                                      context.pushNamed(
                                        AppRoutes.defaultListPage.name,
                                        pathParameters: {
                                          "lang": context.locale.languageCode,
                                          "type": "blogs"
                                        },
                                      );
                                    } else {
                                      context.pushNamed(
                                        AppRoutes.defaultPage.name,
                                        pathParameters: {
                                          "lang": context.locale.languageCode,
                                          "type": "blogs"
                                        },
                                      );
                                    }
                                  },
                                ),
                                DefaultListTile(
                                  title: AppStrings.aboutComapny.tr(),
                                  src: "assets/images/svg/map.svg",
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutes.aboutUsScreen.name,
                                      pathParameters: {
                                        "lang": context.locale.languageCode,
                                      },
                                    );
                                  },
                                ),
                              const SizedBox(height : 15),
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: kIsWeb ? 1070 : double.infinity,
                                    ),
                                    child: Container(
                                      alignment: LocalizationService.isArabic(context: context)? Alignment.centerRight:Alignment.centerLeft,
                                      child: Text(AppStrings.myAccount.tr().toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(AppColors.buttons))),
                                    ),
                                  ),
                                ),
                                const SizedBox(height : 15),
                                DefaultListTile(
                                  title:AppStrings.customizeNotifications.tr(),
                                  src: "assets/images/svg/mcn.svg",
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const CustomizeNotificationScreen();
                                        });
                                  },
                                ),
                                DefaultListTile(
                                  title:AppStrings.languageSettings.tr(),
                                  src: "assets/images/svg/mls.svg",
                                  onTap: () {
                                    context.pushNamed(AppRoutes.langSettingScreen.name,
                                        pathParameters: {'lang': context.locale.languageCode,
                                        });
                                  },
                                ),
                                DefaultListTile(
                                  title:AppStrings.updatePassword.tr(),
                                  src: "assets/images/svg/mup.svg",
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutes.updatePassword.name,
                                      pathParameters: {
                                        "lang": context.locale.languageCode,
                                      },
                                    );
                                  },
                                ),
                                DefaultListTile(
                                  title: AppStrings.personalInfo.tr(),
                                  src: "assets/images/svg/mpi.svg",
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutes.personalProfile.name,
                                      pathParameters: {
                                        "lang": context.locale.languageCode,
                                      },
                                    );
                                  },
                                ),
                                DefaultListTile(
                                  title: AppStrings.logout.tr(),
                                  src: "assets/images/svg/mlo.svg",
                                  onTap: () async {
                                    final appConfigService =
                                    Provider.of<AppConfigService>(context,
                                        listen: false);
                                    appConfigService.logout(context, viewAlert: true).then((v) {
                                      context.goNamed(
                                        AppRoutes.splash.name,
                                        pathParameters: {'lang': context.locale.languageCode,},
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.sizeOf(context).height * 0.15,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(124),
                        child: GestureDetector(
                          onTap:(){
                            context.pushNamed(AppRoutes.personalProfile.name,
                                pathParameters: {'lang': context.locale.languageCode,
                                });
                          },
                          child: CachedNetworkImage(
                              imageUrl:(gCache != null)? gCache['photo'] : "https://th.bing.com/th/id/OIP.NV-x3Km5_nHK2ZcRuqV5OgHaHa?rs=1&pid=ImgDetMain",
                              fit: BoxFit.cover,
                              height: 124,
                              width: 124,
                              placeholder: (context, url) => const ShimmerAnimatedLoading(
                                width: 63.0,
                                height: 63,
                                circularRaduis: 63,
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image_not_supported_outlined,
                              )),
                        ),
                      ),
                      const SizedBox(height: 15),
                     if(gCache != null) Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        width: MediaQuery.sizeOf(context).width * 1,
                        child: Text(
                          (gCache['name'] ?? '').toUpperCase(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            color: Color(AppColors.titleText),
                            // fontSize: 16,
          
                            // fontWeight: FontWeight.w700,
                            // height: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                     if(gCache != null) Text(
                        gCache['job_title'] ?? "",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: const Color(AppColors.grey4F),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          // height: 0,
                        ),
          
                        //      TextStyle(
                        // color: Color(0xFF4F4F4F),
                        // fontSize: 10,
                        //   fontFamily: 'Bai Jamjuree',
                        //   fontWeight: FontWeight.w500,
                        //   height: 0,
                        // ),
                      )
                    ],
                  ),
          
                )
              ]
          ),
        );
      },
    );
  }
}

class DefaultListTile extends StatelessWidget {
  final String src;
  final String title;
  final VoidCallback? onTap;

  const DefaultListTile({
    super.key,
    required this.src,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: kIsWeb ? 1100 : double.infinity,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: SvgPicture.asset(
              src,
              color: Color(AppColors.buttons),
              fit: BoxFit.scaleDown,
              width: 20, height: 20,
            ),
            title: Text(
              title!.toUpperCase() ?? "",
              style: Theme.of(context).textTheme.labelSmall,
            ),
            // trailing: Icon(
            //   Icons.arrow_forward_ios,
            //   color: Theme.of(context).colorScheme.primary,
            // ),
            onTap: onTap ?? () {}, // Add your onTap functionality here
          ),
        ),
      ),
    );
  }
}
