import 'package:app_test/core/widgets/app_content_width.widget.dart';
import 'package:app_test/core/widgets/profile_avatar_menu_widget.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'dart:convert';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/services/general_listener.dart';
import 'package:app_test/features/more/company_structure/company_structure_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/more/customized_notification/views/customize_notification_screen.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_icons.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import '../personal_profile/controllers/personal_profile_controller.dart';
import 'package:app_test/core/helpers/package_helper.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/request_scope_helper.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? jsonString = CacheHelper.getString("USG");
      if (jsonString != null && jsonString.isNotEmpty) {
        Map<String, dynamic> gCache = json.decode(jsonString);
        final popups = gCache['popups'];
        if (popups != null && popups.isNotEmpty) {
          GeneralListener().startAll(context, "more", popups);
        }
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
      gCache = json.decode(jsonString)
          as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    Map<String, dynamic>? us2Cache;
    final us2String = CacheHelper.getString("US2");
    if (us2String != null && us2String.isNotEmpty) {
      try {
        us2Cache = json.decode(us2String) as Map<String, dynamic>;
      } catch (_) {}
    }
    final bool isShiftsEmployee =
        us2Cache?['worktime']?['working_hours_type']?.toString() == 'shifts';

    return Consumer<HomeController>(
      builder: (context, value, child) {
        final safeTop = MediaQuery.paddingOf(context).top;
        // Where the white card starts; the avatar straddles this line.
        final cardTop = safeTop + AppSizes.moreHeaderBelowSafeArea;
        const avatar = AppSizes.moreAvatar;
        return Stack(alignment: Alignment.topCenter, children: [
          Container(
            alignment: Alignment.topCenter,
            color: Color(AppColors.secondaryButton),
            child: SizedBox(
              height: cardTop + AppRadius.xl,
              width: double.infinity,
              child: Image.asset(
                "assets/images/png/more_back.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            top: cardTop,
            child: Container(
              decoration: ShapeDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(0, 0),
                  end: const Alignment(1, 0),
                  colors: [
                    Color(AppColors.background),
                    Color(AppColors.cardBackground)
                  ],
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
                  // Room for the lower half of the avatar, then name and job title.
                  const SizedBox(height: avatar / 2 + AppSpacing.md),
                  Padding(
                    padding: AppSpacing.pagePadding,
                    child: Text(
                      (gCache['name'] ?? '').toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppStyles.heading(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if ((gCache['job_title'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding: AppSpacing.pagePadding,
                      child: Text(
                        gCache['job_title'].toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppStyles.greyContent(context).copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: ListView(
                        // A ListView adds the status-bar height on top by itself (extra ~60 of
                        // empty space under the job title); this page already sits below it.
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        children: [
                          DefaultListTile(
                            title: AppStrings.teamMindAssistant.tr(),
                            icon: Icons.smart_toy_outlined,
                            onTap: () => context.pushNamed(
                                AppRoutes.teamMindAssistant.name,
                                pathParameters: {
                                  'lang': context.locale.languageCode
                                }),
                          ),
                          MoreSectionLabel(AppStrings.myWork.tr()),
                          DefaultListTile(
                            title: AppStrings.tasks.tr(),
                            src: AppIcons.tasks,
                            onTap: () async => await context.pushNamed(
                                AppRoutes.taskScreen.name,
                                pathParameters: {
                                  'lang': context.locale.languageCode
                                }),
                          ),
                          // Every shift employee can open it: the backend makes it view-only
                          // (own department) for employees and editable for managers / HR
                          if (isShiftsEmployee)
                            DefaultListTile(
                              title: AppStrings.shiftsSchedule.tr(),
                              icon: Icons.calendar_month_rounded,
                              onTap: () async {
                                await context.pushNamed(
                                  AppRoutes.shiftsScheduler.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode,
                                  },
                                );
                              },
                            ),
                          if (PackageHelper.hasPackage('emp-reports'))
                            DefaultListTile(
                              title: AppStrings.dailyReports.tr(),
                              icon: Icons.edit_document,
                              onTap: () async => await context.pushNamed(
                                  AppRoutes.dailyReportsListScreen.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode
                                  }),
                            ),
                          if (PackageHelper.hasPackage('emp-evaluation'))
                            DefaultListTile(
                              title: AppStrings.evaluationRequests.tr(),
                              src: AppIcons.payroll,
                              onTap: () async => await context.pushNamed(
                                  AppRoutes.evaluationRequireScreen.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode
                                  }),
                            ),
                          if (PackageHelper.hasPackage('emp-payroll'))
                            DefaultListTile(
                              title: 'CV Hub Interviews'.tr(),
                              src: "assets/icons/meetings.svg",
                              onTap: () async => await context.pushNamed(
                                  AppRoutes.cvHubInterviews.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode
                                  }),
                            ),
                          if (PackageHelper.hasPackage('emp-requests') ||
                              PackageHelper.hasPackage('fingerprint-sys') ||
                              PackageHelper.hasPackage('emp-payroll') ||
                              isShiftsEmployee)
                            MoreSectionLabel(AppStrings.myRequests.tr()),
                          if (PackageHelper.hasPackage('emp-requests'))
                            DefaultListTile(
                              title: AppStrings.myRequests.tr(),
                              icon: Icons.assignment_outlined,
                              onTap: () async => await context.pushNamed(
                                  AppRoutes.requests2.name,
                                  pathParameters: {
                                    'type': GetRequestsTypes.mine.name,
                                    'lang': context.locale.languageCode
                                  }),
                            ),
                          if (PackageHelper.hasPackage('fingerprint-sys'))
                            DefaultListTile(
                              title: AppStrings.overtimeRequests.tr(),
                              icon: Icons.access_time,
                              // Reusing an existing icon
                              onTap: () async => await context.pushNamed(
                                  AppRoutes.overtimeRequestsScreen.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode
                                  }),
                            ),
                          // Removed redundant block
                          if (PackageHelper.hasPackage('emp-payroll'))
                            DefaultListTile(
                              title: AppStrings.salaryAdvanceRequests.tr(),
                              src: AppIcons.payroll,
                              onTap: () async => await context.pushNamed(
                                  AppRoutes.salaryAdvanceList.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode
                                  }),
                            ),
                          if (PackageHelper.hasPackage('emp-payroll'))
                            DefaultListTile(
                              title: AppStrings.expenseClaims.tr(),
                              src: AppIcons.payroll,
                              // Assuming payroll icon is fine, or we can use another one
                              onTap: () async => await context.pushNamed(
                                  AppRoutes.expenseClaimList.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode
                                  }),
                            ),
                          if (isShiftsEmployee)
                            DefaultListTile(
                              title: AppStrings.shiftChangeRequests.tr(),
                              icon: Icons.swap_horiz_rounded,
                              onTap: () async => await context.pushNamed(
                                  AppRoutes.shiftChangeRequests.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode
                                  }),
                            ),
                          if (PackageHelper.hasPackage('emp-payroll'))
                            MoreSectionLabel(AppStrings.myPay.tr()),
                          // Removed redundant block
                          if (PackageHelper.hasPackage('emp-payroll'))
                            DefaultListTile(
                              title: AppStrings.payroll.tr(),
                              src: AppIcons.payroll,
                              onTap: () async => await context.pushNamed(
                                  AppRoutes.payrollsList.name,
                                  extra: {
                                    'employeeName': null,
                                    'employeeId': null
                                  },
                                  pathParameters: {
                                    'lang': context.locale.languageCode
                                  }),
                            ),
                          if (PackageHelper.hasPackage('emp-payroll'))
                            DefaultListTile(
                                title: AppStrings.rewardsAndPenalties.tr(),
                                src: AppIcons.reward,
                                onTap: () async => await context.pushNamed(
                                        AppRoutes.rewardsAndPenalties.name,
                                        extra: {
                                          'employeeName': gCache['name'],
                                          'employeeId':
                                              gCache['employee_profile_id']
                                                  .toString()
                                        },
                                        pathParameters: {
                                          'lang': context.locale.languageCode
                                        })),
                          if (PackageHelper.hasPackage('emp-payroll'))
                            DefaultListTile(
                              title: AppStrings.commissions.tr(),
                              src: AppIcons.payroll,
                              onTap: () async => await context.pushNamed(
                                AppRoutes.commissionList.name,
                                pathParameters: {
                                  'lang': context.locale.languageCode,
                                },
                              ),
                            ),
                          // "Management" section: other departments / all company are open to every employee
                          if (RequestScopeHelper.canSeeTeam ||
                              PackageHelper.hasPackage('emp-requests'))
                            MoreSectionLabel(AppStrings.management.tr()),
                          if (gCache['is_teamleader_in'].isNotEmpty ||
                              gCache['is_manager_in'].isNotEmpty ||
                              gCache['is_hr'] == true ||
                              gCache['top_management'] == true)
                            if (PackageHelper.hasPackage('emp-requests'))
                              DefaultListTile(
                                title: AppStrings.teamRequests.tr(),
                                src: AppIcons.teamRequests,
                                onTap: () async {
                                  await context.pushNamed(
                                      AppRoutes.requests2.name,
                                      //  extra: requests,
                                      pathParameters: {
                                        'type': GetRequestsTypes.myTeam.name,
                                        'lang': context.locale.languageCode
                                      });
                                },
                              ),
                          if (PackageHelper.hasPackage('emp-requests'))
                            DefaultListTile(
                              title: AppStrings.otherDepartmentsRequests.tr(),
                              src: AppIcons.otherDepartments,
                              onTap: () async {
                                await context.pushNamed(
                                    AppRoutes.requests2.name,
                                    pathParameters: {
                                      'type':
                                          GetRequestsTypes.otherDepartment.name,
                                      'lang': context.locale.languageCode
                                    });
                              },
                            ),
                          if (PackageHelper.hasPackage('emp-requests'))
                            DefaultListTile(
                              title: 'all_company_requests'.tr(),
                              icon: Icons.business, // Fallback icon
                              onTap: () async {
                                await context.pushNamed(
                                    AppRoutes.requests2.name,
                                    pathParameters: {
                                      'type': GetRequestsTypes.allCompany.name,
                                      'lang': context.locale.languageCode
                                    });
                              },
                            ),
                          if (gCache['is_teamleader_in'].isNotEmpty ||
                              gCache['is_manager_in'].isNotEmpty ||
                              gCache['is_hr'] == true ||
                              gCache['top_management'] == true)
                            DefaultListTile(
                              title: AppStrings.teamTodayStatus.tr(),
                              icon: Icons.groups_rounded,
                              onTap: () async {
                                await context.pushNamed(
                                    AppRoutes.teamTodayStatus.name,
                                    pathParameters: {
                                      'lang': context.locale.languageCode
                                    });
                              },
                            ),
                          if (gCache['is_teamleader_in'].isNotEmpty ||
                              gCache['is_manager_in'].isNotEmpty ||
                              gCache['is_hr'] == true ||
                              gCache['top_management'] == true)
                            if (PackageHelper.hasPackage('fingerprint-sys'))
                              DefaultListTile(
                                title: AppStrings.teamFingerprint.tr(),
                                src: AppIcons.teamFingerprint,
                                onTap: () async {
                                  await context.pushNamed(
                                      AppRoutes.teamFingerprint.name,
                                      pathParameters: {
                                        'lang': context.locale.languageCode
                                      });
                                },
                              ),
                          // Team tracking map + tracking reports (request-linked tracking).
                          if (gCache['is_teamleader_in'].isNotEmpty ||
                              gCache['is_manager_in'].isNotEmpty ||
                              gCache['is_hr'] == true ||
                              gCache['top_management'] == true)
                            DefaultListTile(
                              title: 'tracking_team_map'.tr(),
                              icon: Icons.share_location_rounded,
                              onTap: () async {
                                await context.pushNamed(
                                    AppRoutes.liveGroupMap.name,
                                    pathParameters: {
                                      'lang': context.locale.languageCode
                                    });
                              },
                            ),
                          MoreSectionLabel(AppStrings.company.tr()),
                          if (PackageHelper.hasPackage('emp-requests'))
                            DefaultListTile(
                              title: AppStrings.employeesDirectory.tr(),
                              src: "assets/images/svg/med.svg",
                              onTap: () {
                                context.pushNamed(AppRoutes.employeesList.name,
                                    pathParameters: {
                                      'lang': context.locale.languageCode,
                                    });
                              },
                            ),
                          if (PackageHelper.hasPackage('emp-requests'))
                            DefaultListTile(
                              title: AppStrings.companyStructure.tr(),
                              src: "assets/images/svg/mcs.svg",
                              onTap: () async {
                                final jsonString = CacheHelper.getString("USG");
                                Map<String, dynamic>? gCache;
                                if (jsonString != null &&
                                    jsonString.isNotEmpty) {
                                  gCache = json.decode(jsonString)
                                      as Map<String, dynamic>;
                                }
                                final url = gCache?['company_structure_url'] ??
                                    "https://www.google.com/";

                                // On web, open in browser. On mobile, use WebView
                                if (PlatformIs.web) {
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Could not open $url')),
                                      );
                                    }
                                  }
                                } else {
                                  // On mobile, navigate to WebView screen
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const WebViewStack(),
                                    ),
                                  );
                                }
                              },
                            ),
                          if (PackageHelper.hasPackage('emp-requests'))
                            DefaultListTile(
                              title: 'files_center'.tr(),
                              src: "assets/images/svg/faqqs.svg",
                              icon: Icons.folder,
                              onTap: () {
                                context.pushNamed(
                                  AppRoutes.filesCenter.name,
                                  pathParameters: {
                                    "lang": context.locale.languageCode,
                                  },
                                );
                              },
                            ),
                          if (PackageHelper.hasPackage('emp-reports'))
                            DefaultListTile(
                              title: 'reports'.tr(),
                              icon: Icons.analytics_outlined,
                              onTap: () {
                                context.pushNamed(
                                  AppRoutes.reportsCatalog.name,
                                  pathParameters: {
                                    "lang": context.locale.languageCode,
                                  },
                                );
                              },
                            ),
                          DefaultListTile(
                            title: AppStrings.articlesNew.tr(),
                            src: "assets/images/svg/man.svg",
                            onTap: () {
                              context.pushNamed(
                                AppRoutes.defaultPage.name,
                                pathParameters: {
                                  "lang": context.locale.languageCode,
                                  "type": "blogs"
                                },
                              );
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
                          ),

                          MoreSectionLabel(AppStrings.helpAndPolicies.tr()),
                          if (PackageHelper.hasPackage('emp-requests'))
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
                          // DefaultListTile(
                          //   title: AppStrings.points.tr(),
                          //   src: "assets/images/svg/mts.svg",
                          //   onTap: () {
                          //     context.pushNamed(AppRoutes.painterPointsViewScreen.name,
                          //         pathParameters: {
                          //           'lang': context.locale.languageCode
                          //         });
                          //   },
                          // ),
                          DefaultListTile(
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
                          DefaultListTile(
                            title: AppStrings.companyPolicy.tr(),
                            src: "assets/images/svg/faqqs.svg",
                            onTap: () {
                              context.pushNamed(
                                AppRoutes.generalDataScreen.name,
                                pathParameters: {
                                  "lang": context.locale.languageCode,
                                },
                              );
                            },
                          ),
                          DefaultListTile(
                            title: AppStrings.requestTerms.tr(),
                            src: "assets/images/svg/faqqs.svg",
                            onTap: () {
                              context.pushNamed(
                                AppRoutes.requestTermsScreen.name,
                                pathParameters: {
                                  "lang": context.locale.languageCode,
                                },
                              );
                            },
                          ),
                          MoreSectionLabel(AppStrings.myAccount.tr()),
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
                            title: AppStrings.updatePassword.tr(),
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
                            title: AppStrings.customizeNotifications.tr(),
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
                            title: AppStrings.languageSettings.tr(),
                            src: "assets/images/svg/mls.svg",
                            onTap: () {
                              context.pushNamed(
                                  AppRoutes.langSettingScreen.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode,
                                  });
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
                          if (PackageHelper.hasPackage('ai'))
                            DefaultListTile(
                              title: AppStrings.aiConnectTitle.tr(),
                              icon: Icons.hub_outlined,
                              onTap: () {
                                context.pushNamed(
                                  AppRoutes.aiConnect.name,
                                  pathParameters: {
                                    "lang": context.locale.languageCode,
                                  },
                                );
                              },
                            ),
                          const SizedBox(height: AppSpacing.section),
                          DefaultListTile(
                            title: AppStrings.logout.tr(),
                            src: "assets/images/svg/mlo.svg",
                            onTap: () async {
                              final appConfigService =
                                  Provider.of<AppConfigService>(context,
                                      listen: false);
                              appConfigService
                                  .logout(context, viewAlert: true)
                                  .then((v) {
                                context.goNamed(
                                  AppRoutes.splash.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode,
                                  },
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
            top: cardTop - avatar / 2,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: ProfileAvatarMenuWidget(
                  employeeProfileId: gCache?['employee_profile_id'],
                  child: kIsWeb
                      ? Image.network(
                          (gCache != null)
                              ? gCache['photo'] ?? ""
                              : "https://th.bing.com/th/id/OIP.NV-x3Km5_nHK2ZcRuqV5OgHaHa?rs=1&pid=ImgDetMain",
                          fit: BoxFit.cover,
                          height: avatar,
                          width: avatar,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[200],
                            height: avatar,
                            width: avatar,
                            child: Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: (gCache != null)
                              ? gCache['photo'] ?? ""
                              : "https://th.bing.com/th/id/OIP.NV-x3Km5_nHK2ZcRuqV5OgHaHa?rs=1&pid=ImgDetMain",
                          fit: BoxFit.cover,
                          height: avatar,
                          width: avatar,
                          placeholder: (context, url) => ShimmerAnimatedLoading(
                            width: avatar,
                            height: avatar,
                            circularRaduis: avatar,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }
}

/// Small uppercase caption above a group of menu rows. 16 above it, 8 below it, so it reads as
/// the title of the rows that follow (layout rule 3).
class MoreSectionLabel extends StatelessWidget {
  final String title;

  const MoreSectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return AppContentWidth(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.page,
          AppSpacing.section,
          AppSpacing.page,
          AppSpacing.sectionHeaderGap,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            title,
            style: AppStyles.primaryContent(context).copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

class DefaultListTile extends StatelessWidget {
  final String? src;
  final IconData? icon;
  final String title;
  final VoidCallback? onTap;

  const DefaultListTile({
    super.key,
    this.src,
    this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    return AppContentWidth(
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            minVerticalPadding: 0,
            visualDensity: VisualDensity.compact,
            horizontalTitleGap: AppSpacing.md,
            // Icon in a soft square, same look as the icons on the home cards.
            leading: Container(
              width: AppSizes.moreIconBox,
              height: AppSizes.moreIconBox,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: icon != null
                  ? Icon(icon, color: accent, size: 18)
                  : SvgPicture.asset(
                      src ?? "",
                      colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                      fit: BoxFit.scaleDown,
                      width: 18,
                      height: 18,
                    ),
            ),
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.darkContent(context).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: onTap ?? () {},
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Color(AppColors.divider),
            // Starts under the text, not under the icon box.
            indent: AppSpacing.page + AppSizes.moreIconBox + AppSpacing.md,
            endIndent: 0,
          ),
        ],
      ),
    );
  }
}
