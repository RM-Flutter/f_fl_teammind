import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/more/customized_notification/views/customize_notification_screen.dart';
import 'package:app_test/core/services/requests.services.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_icons.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/app_config.service.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
import '../../core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import '../personal_profile/controllers/personal_profile_controller.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
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
    Map<String, dynamic> gCache = {};
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }

    return Consumer<HomeController>(
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: EdgeInsets.zero,
              alignment: Alignment.topCenter,
              color: Color(AppColors.dark),
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
                decoration:  ShapeDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(0, 0),
                    end: const Alignment(1, 0),
                    colors: [Colors.white, Color(AppColors.bgC4)],
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
                            Text(AppStrings.functionality.tr().toUpperCase(),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(AppColors.primary))
                            ),
                            const SizedBox(height : 15),
                            DefaultListTile(
                              title: AppStrings.payroll.tr(),
                              src: AppIcons.payroll,
                              onTap: () async => await context
                                  .pushNamed(AppRoutes.payrollsList.name, extra: {
                                'employeeName': null,
                                'employeeId': null
                              }, pathParameters: {
                                'lang': context.locale.languageCode
                              }),
                            ),
                            DefaultListTile(
                              title: AppStrings.tasks.tr(),
                              src: AppIcons.tasks,
                              onTap: () async => await context.pushNamed(
                                  AppRoutes.taskScreen.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode
                                  }),
                            ),
                            DefaultListTile(
                              title: AppStrings.evaluationRequests.tr(),
                              src: AppIcons.payroll,
                              onTap: () async => await context.pushNamed(
                                  AppRoutes.evaluationRequireScreen.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode
                                  }),
                            ),
                            DefaultListTile(
                                title: AppStrings.rewardsAndPenalties.tr(),
                                src: AppIcons.reward,
                                onTap: () async => await context.pushNamed(
                                    AppRoutes.rewardsAndPenalties.name,
                                    extra: {'employeeName': gCache['name'], 'employeeId': gCache['employee_profile_id'].toString()},
                                    pathParameters: {'lang': context.locale.languageCode})
                            ),
                            if(gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty|| gCache['is_hr'] == true || gCache['top_management'] == true) const SizedBox(height : 15),
                           if(gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty|| gCache['is_hr'] == true || gCache['top_management'] == true) Text(AppStrings.management.tr().toUpperCase(),
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(AppColors.primary))
                            ),
                            if(gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty|| gCache['is_hr'] == true || gCache['top_management'] == true)DefaultListTile(
                              title: AppStrings.teamRequests.tr(),
                              src: AppIcons.teamRequests,
                              onTap: ()async {
                                await context.pushNamed(AppRoutes.requests.name,
                                  //  extra: requests,
                                    pathParameters: {
                                      'type': GetRequestsTypes.myTeam.name,
                                      'lang': context.locale.languageCode
                                    });
                              },
                            ),
                            if(gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty|| gCache['is_hr'] == true || gCache['top_management'] == true)DefaultListTile(
                              title: AppStrings.otherDepartmentsRequests.tr(),
                              src: AppIcons.otherDepartments,
                              onTap: () async{
                                await context.pushNamed(AppRoutes.requests.name,
                                    //  extra: requests,
                                    pathParameters: {
                                      'type': GetRequestsTypes.otherDepartment.name,
                                      'lang': context.locale.languageCode
                                    });
                              },
                            ),
                            if(gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty|| gCache['is_hr'] == true || gCache['top_management'] == true)DefaultListTile(
                              title: AppStrings.teamFingerprint.tr(),
                              src: AppIcons.teamFingerprint,
                              onTap: () async{
                                await context.pushNamed(AppRoutes.teamFingerprint.name,
                                    pathParameters: {
                                      'lang': context.locale.languageCode
                                    });
                              },
                            ),
                            const SizedBox(height : 15),
                            Text(AppStrings.more.tr().toUpperCase(),
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(AppColors.primary))
                            ),
                            const SizedBox(height : 15),
                            DefaultListTile(
                              title: AppStrings.ticketSystem.tr(),
                              src: "assets/images/svg/mts.svg",
                              onTap: () {
                                context.pushNamed(AppRoutes.complainScreen.name,
                                    pathParameters: {
                                      'lang': context.locale.languageCode
                                    });
                              },
                            ),
                            DefaultListTile(
                              title: AppStrings.employeesDirectory.tr(),
                              src:  "assets/images/svg/med.svg",
                              onTap: () {
                                context.pushNamed(AppRoutes.employeesList.name,
                                    pathParameters: {'lang': context.locale.languageCode,
                                    });
                              },
                            ),
                            DefaultListTile(
                              title: AppStrings.companyStructure.tr(),
                              src:  "assets/images/svg/mcs.svg",
                              onTap: () {
                                context.pushNamed(AppRoutes.webViewScreen.name,
                                    pathParameters: {'lang': context.locale.languageCode,
                                    });
                              },
                            ),
                            DefaultListTile(
                              title: AppStrings.articlesNew.tr(),
                              src:  "assets/images/svg/man.svg",
                              onTap: () {
                                context.pushNamed(AppRoutes.defaultPage.name,
                                    pathParameters: {'lang': context.locale.languageCode,
                                      "type" : "blogs",
                                      "title" : AppStrings.blogCenter.tr(),
                                    });
                              },
                            ),
                            DefaultListTile(
                              title: AppStrings.points.tr(),
                              src: "assets/images/svg/map.svg",
                              onTap: () {
                                context.pushNamed(
                                  AppRoutes.pointsScreenView.name,
                                  pathParameters: {
                                    "lang": context.locale.languageCode,
                                  },
                                );
                              },
                            ), DefaultListTile(
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
                            DefaultListTile(
                              title: AppStrings.contactUs.tr(),
                              src: "assets/images/svg/s8.svg",
                              onTap: () {
                                context.pushNamed(
                                  AppRoutes.contactUs.name,
                                  pathParameters: {
                                    "lang": context.locale.languageCode,
                                  },
                                );
                              },
                            ), DefaultListTile(
                              title: AppStrings.faqs.tr(),
                              src: "assets/images/svg/faqqs.svg",
                              onTap: () {
                                context.pushNamed(
                                  AppRoutes.faqScreen.name,
                                  pathParameters: {
                                    "lang": context.locale.languageCode,
                                  },
                                );
                              },
                            ),
                            const SizedBox(height : 15),
                            Text(AppStrings.myAccount.tr().toUpperCase(),
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(AppColors.primary))
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
                            ),DefaultListTile(
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
                              title: AppStrings.userDevices.tr(),
                              src: "assets/images/svg/mpi.svg",
                              onTap: () {
                                context.pushNamed(
                                  AppRoutes.userDevices.name,
                                  pathParameters: {
                                    "lang": context.locale.languageCode,
                                  },
                                );
                              },
                            ),
                            DefaultListTile(
                              title: AppStrings.logout.tr(),
                              src: "assets/images/svg/mlo.svg",
                              onTap: ()async{
                                final appConfigService =
                                Provider.of<AppConfigService>(context, listen: false);
                                appConfigService.logout(context, viewAlert: false).then((v){
                                  context.goNamed(AppRoutes.splash.name,
                                      pathParameters: {'lang': context.locale.languageCode});
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
                          errorWidget: (context, url, error) =>  const Icon(
                            Icons.image_not_supported_outlined,
                          )),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
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
                        color: Theme.of(context).colorScheme.primary,
                        // fontSize: 16,

                        // fontWeight: FontWeight.w700,
                        // height: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gCache['job_title'] ?? "",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: const Color(0xff4F4F4F),
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
          ],
        ) ;
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
    return Container(
      margin: const EdgeInsets.symmetric( vertical: 8),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: SvgPicture.asset(
          src,
          color: Color(AppColors.primary),
          fit: BoxFit.contain,
        ),
        title: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        // trailing: Icon(
        //   Icons.arrow_forward_ios,
        //   color: Theme.of(context).colorScheme.primary,
        // ),
        onTap: onTap ?? () {}, // Add your onTap functionality here
      ),
    );
  }
}
