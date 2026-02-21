import 'dart:async';
import 'dart:convert';

import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/features/company_structure/views/company_structure_tree_screen.dart';
import 'package:app_test/features/complaints/views/add_complaints/add_complain_screen.dart';
import 'package:app_test/features/employee_profiles/details/views/employee_details_screen.dart';
import 'package:app_test/features/employee_profiles/list/views/employees_list_screen.dart';
import 'package:app_test/features/home/views/home_screen.dart';
import 'package:app_test/features/more/notifications/views/notification_screen.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';
import 'package:app_test/features/points/views/fawry/fawry_provider_screen.dart';
import 'package:app_test/features/points/views/points/main_points_layout/points_screen.dart';
import 'package:app_test/features/points/views/points/points_categories/points_categories_screen.dart';
import 'package:app_test/features/points/controllers/points_controller/points_controller.dart';
import 'package:app_test/features/points/views/prize/prize_screen.dart';
import 'package:app_test/features/requests/add/views/add_request_screen.dart';
import 'package:app_test/features/requests/details/views/request_details_screen.dart';
import 'package:app_test/features/requests/view_by_ids/views/requests_by_id_screen.dart';
import 'package:app_test/features/requests/calender/views/requests_calendar_screen.dart';
import 'package:app_test/features/requests/main_request_layout/views/requests_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import '../../features/authentication/login/views/login_screen.dart';
import '../../features/authentication/login/views/update_main_data.dart';
import '../../features/complaints/views/complain_list/complains_screen.dart';
import '../../features/complaints/views/complains_details/complain_details_screen.dart';
import '../../features/customer_service_requests/views/new_customer_service/new_customer_service_screen.dart';
import '../../features/customer_service_requests/views/customer_service_list/customer_service_screen.dart';
import '../../features/customer_service_requests/views/customer_service_details/customer_service_details_screen.dart';
import '../../features/evaluation/views/require/evaluation_require_screen.dart';
import '../../features/evaluation/views/main_evaluation_layout/evaluation_screen.dart';
import '../../features/fingerprint/views/widgets/offline/finger_print_offline.dart';
import '../../features/more/team_fingerprint/view/widgets/finger_print_view_screen.dart';
import '../../features/fingerprint/views/finger_print_screen.dart';
import '../../features/main_layout/views/main_layout_screen.dart';
import '../../features/more/about_us/views/about_us_screen.dart';
import '../../features/more/company_structure/company_structure_screen.dart';
import '../../features/more/contact_us/views/contact_us_screen.dart';
import '../../features/more/faqs/views/faq_screen.dart';
import '../../features/more/general_data/views/general_data_screen.dart';
import '../../features/more/language_settings/views/language_setting_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/more/notifications/views/widgets/notifications_list/widgets/notifications_details/notification_details_screen.dart';
import '../../features/more/request_terms/views/request_terms_screen.dart';
import '../../features/more/team_fingerprint/view/team_fingerprint_screen.dart';
import '../../features/more/update_profile/views/update_password_screen.dart';
import '../../features/more/user_device/views/user_devices_screen.dart';
import '../../features/offline/views/offline_screen.dart';
import '../../features/pages/views/default_details.dart';
import '../../features/pages/views/default_list_page.dart';
import '../../features/pages/views/default_page.dart';
import '../../features/payrolls/payroll_details/views/payroll_details_screen.dart';
import '../../features/payrolls/payroll_list/views/payrolls_list_screen.dart';
import '../../features/personal_profile/views/personal_profile_screen.dart';
import '../../features/rewards_and_penalties/add_rewards/views/add_rewards_and_penalties_screen.dart';
import '../../features/rewards_and_penalties/view_rewards/views/rewards_and_penalties_screen.dart';
import '../../features/services/views/about_team_mind/about_team_mind_screen.dart';
import '../../features/services/views/about_team_mind/youtube_video_player_screen.dart';
import '../../features/services/views/cv_generator/cv_generator_screen.dart';
import '../../features/services/views/free_service_more.dart';
import '../../features/services/views/free_services_home_screen.dart';
import '../../features/services/views/my_cv_screen.dart';
import '../../features/services/views/personality_test/personality_test_screen.dart';
import '../../features/services/views/premium_templates/premium_templates_screen.dart';
import '../../features/services/views/select_template/select_template_screen.dart';
import '../../features/services/views/smart_card/smart_card_company_detail_screen.dart';
import '../../features/services/views/smart_card/smart_card_profile_detail_screen.dart';
import '../../features/services/views/smart_card/smart_card_screen.dart';
import '../../features/services/views/update_company_info/update_company_info_screen.dart';
import '../../features/services/views/update_employee_info/update_employee_info_screen.dart';
import '../../features/services/views/update_my_info/update_my_info_screen.dart';
import '../../features/services/views/vacation_calc/vacation_calc_screen.dart';
import '../../features/services/views/widgets/youtube_video_player.dart';
import '../../features/splash_and_onboarding/views/onboarding_screen.dart';
import '../../features/splash_and_onboarding/views/splash_screen.dart';
import '../../features/tasks/views/add/add_task_screen.dart';
import '../../features/tasks/views/edit/edit_task_screen.dart';
import '../../features/tasks/views/details/task_details_screen.dart';
import '../../features/tasks/views/main_tasks_layout/task_screen.dart';
import '../platform/platform_is.dart';
import '../routing/app_router_transitions.dart';
import '../routing/not_found/not_found_screen.dart';
import '../services/app_config_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/backend_services/api_service/dio_api_service/shared.dart';
import '../services/sentry_serivce.dart';
import '../widgets/webview_offers.dart';

enum AppRoutes {
  fawryProviderScreen,
  CategoriesprizePointsViewScreen,
  prizePointsViewScreen,
  painterPointsViewScreen,


  home,
  freeServicesHome,

  splash,
  onboarding,
  fingerprintView,
  teamFingerprint,
  defaultSinglePage,
  defaultListPage,
  defaultPage,
  defaultPage2,
  generalDataScreen,
  login,
  webViewMainDataScreen,
  webViewScreen,
  userDevices,
  offlineScreen,
  complainDetails,
  customerServiceScreen,
  taskDetails,
  qrcodeScreen,
  notification,
  requests2,
  addNotification,
  fingerprint,
  langSettingScreen,
  blog,
  blogDetails,
  employeeFingerprint,
  requests,
  notifications,
  more,
  evaluationScreen,
  evaluationRequireScreen,
  requestsById,
  requestDetails,
  customerServiceDetailsScreen,
  addRequest,
  requestsCalendar,
  employeesList,
  newComplainScreen,
  employeeDetails,
  companyTree,
  updatePassword,
  personalProfile,
  payrollsList,
  payrollDetails,
  rewardsAndPenalties,
  taskScreen,
  addTaskScreen,
  editTaskScreen,
  addRewardsAndPenalties,
  contactUs,
  faqScreen,
  fingerPrintOffline,
  aboutUsScreen,
  notificationDetails,
  requestTermsScreen,
  // freeServicesHome,
  myCVScreen,
  cvGeneratorScreen,
  smartCardScreen,
  updateMyInfoScreen,
  selectTemplateScreen,
  premiumTemplatesScreen,
  vacationCalcScreen,
  personalityTestScreen,
  aboutTeamMindScreen,
  newCusomterService,
  youtubeVideoScreen,
  freeMoreScreen,
  smartCardCompanyDetailScreen,
  smartCardProfileDetailScreen,
  updateCompanyInfoScreen,
  updateEmployeeInfoScreen,
  mediaCenterYoutubeScreenView,

  complainScreen,


}

const TestVSync ticker = TestVSync();

class TestVSync implements TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

enum NavbarPages { home, requests, fingerprint, page, more }

NavbarPages getNavbarPage({required String currentLocationRoute}) {
  if (currentLocationRoute.contains('requests')) {
    return NavbarPages.requests;
  }
  if (currentLocationRoute.contains('fingerprint')) {
    return NavbarPages.fingerprint;
  }
  if (currentLocationRoute.contains('notifications')) {
    return NavbarPages.page;
  }
  if (currentLocationRoute.contains('more')) {
    return NavbarPages.more;
  }
  return NavbarPages.home;
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter goRouter(BuildContext context) {
  // في الويب، لا نستخدم refreshListenable لتجنب refresh مستمر
  // في الموبايل، لا نستخدم ConnectionService في refreshListenable لتجنب refresh عند تغيير الاتصال
  // Offline handling is done via overlay, not navigation
  final refreshListenable = kIsWeb
      ? Listenable.merge([]) // Listenable فارغ في الويب
      : Listenable.merge(
      []); // ConnectionService removed to prevent router refresh

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/${context.locale.languageCode}/splash-screen',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final appConfigServiceProvider = Provider.of<AppConfigService>(
          context, listen: false);
      final isLoggedIn = appConfigServiceProvider.isLogin &&
          appConfigServiceProvider.token.isNotEmpty;
      final lang = state.pathParameters['lang'] ?? 'en';
      context.setLocale(Locale(lang));


      // لا نغيّر المسار أثناء الـ splash؛ الـ splash يقرر بنفسه بعد تهيئة الخدمات
      if (state.fullPath?.contains('splash-screen') == true) {
        return null;
      }

      // 🌐 Offline handling is now done via overlay, no redirect needed
      // The overlay will be shown/hidden by ConnectionService

      if (isLoggedIn && state.fullPath?.contains('login') == true) {
        var update = CacheHelper.getString("update_url");
        if (update != null && update.isNotEmpty && update != "") {
          return '/$lang/webviewMainData';
        }
        // Redirect to splash screen first, then splash will navigate to home
        return '/$lang/splash-screen';
      }

      // قائمة الصفحات المسموح بها للزائر (Visitor)
      final allowedForVisitor = [
        'splash',
        'offline',
        'freeMoreScreen',
        'onboarding-screen',
        'login',
        'free-services',
        'my-cv',
        'cv-generator',
        'smart-card',
        'smart-card-company-detail',
        'smart-card-profile-detail',
        'update-my-info',
        'update-company-info',
        'update-employee-info',
        'select-template',
        'premium-templates',
        'vacation-calc',
        'personality-test',
        'about-team-mind',
      ];

      final isAllowedPage = allowedForVisitor.any((page) =>
      state.fullPath?.contains(page) == true);

      if (!isLoggedIn && !isAllowedPage) {
        return '/$lang/login-screen';
      }

      return null;
    },

    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            MainLayoutScreen(
              key: UniqueKey(),
              currentNavPage: state.fullPath == null
                  ? NavbarPages.home
                  : getNavbarPage(currentLocationRoute: state.fullPath!),
              child: child,
            ),
        routes: [
          GoRoute(
            path: '/:lang',
            parentNavigatorKey: _shellNavigatorKey,
            name: AppRoutes.home.name,
            pageBuilder: (context, state) {
              // Track screen navigation for Sentry
              final screenName = state.uri.path
                  .split('/')
                  .last;
              SentryService.setCurrentScreen(screenName, context: context);

              Offset? begin = state.extra as Offset?;
              final lang = state.uri.queryParameters['lang'];
              if (lang != null) {
                final locale = Locale(lang);
                context.setLocale(locale);
              }
              final animationController = AnimationController(
                vsync: ticker,
              );
              // Make sure to dispose the controller after the transition is complete
              animationController.addStatusListener((status) {
                if (status == AnimationStatus.completed ||
                    status == AnimationStatus.dismissed) {
                  animationController.dispose();
                }
              });
              return AppRouterTransitions.slideTransition(
                key: state.pageKey,
                child: const HomeScreen(),
                animation: animationController,
                begin: begin ?? const Offset(1.0, 0.0),
              );
            },
            routes: [
              GoRoute(
                path: 'personal-profile',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.personalProfile.name,
                pageBuilder: (context, state) {
                  Offset? begin = state.extra as Offset?;
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const PersonalProfileScreen(),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
              )
            ],
          ),
          GoRoute(
            path: '/:lang/default-page2/:type',
            parentNavigatorKey: _shellNavigatorKey,
            name: AppRoutes.defaultPage2.name,
            pageBuilder: (context, state) {
              Offset? begin = state.extra as Offset?;
              final lang = state.uri.queryParameters['lang'];
              final type = state.pathParameters['type'] ?? '';

              if (lang != null) {
                final locale = Locale(lang);
                context.setLocale(locale);
              }
              final animationController = AnimationController(
                vsync: ticker,
              );
              // Make sure to dispose the controller after the transition is complete
              animationController.addStatusListener((status) {
                if (status == AnimationStatus.completed ||
                    status == AnimationStatus.dismissed) {
                  animationController.dispose();
                }
              });
              return AppRouterTransitions.slideTransition(
                key: state.pageKey,
                child: DefaultPage(type),
                animation: animationController,
                begin: begin ?? const Offset(1.0, 0.0),
              );
            },
          ),
          GoRoute(
            path: '/:lang/requests/:type',
            parentNavigatorKey: _shellNavigatorKey,
            name: AppRoutes.requests.name,
            pageBuilder: (context, state) {
              GetRequestsTypes? requestType =
              RequestsServices.getRequestTypeFromString(
                  reqTypeString: state.pathParameters['type']);
              final animationController = AnimationController(
                vsync: ticker,
              );
              // Make sure to dispose the controller after the transition is complete
              animationController.addStatusListener((status) {
                if (status == AnimationStatus.completed ||
                    status == AnimationStatus.dismissed) {
                  animationController.dispose();
                }
              });
              return AppRouterTransitions.slideTransition(
                key: state.pageKey,
                child: RequestsScreen(
                  requestsType: requestType,
                ),
                animation: animationController,
                begin: const Offset(1.0, 0.0),
              );
            },
            routes: [
              GoRoute(
                path: 'requests2',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.requests2.name,
                pageBuilder: (context, state) {
                  GetRequestsTypes? requestType =
                  RequestsServices.getRequestTypeFromString(
                      reqTypeString: state.pathParameters['type']);
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: RequestsScreen(
                      requestsType: requestType,
                    ),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'requests-calendar',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.requestsCalendar.name,
                pageBuilder: (context, state) {
                  GetRequestsTypes? requestType =
                  RequestsServices.getRequestTypeFromString(
                      reqTypeString: state.pathParameters['type']);
                  List requests = state.extra != null ? state.extra as List : [
                  ];
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: RequestsCalendarScreen(
                      requestType: requestType,
                      requests: requests,
                    ),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'add-new-request',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.addRequest.name,
                pageBuilder: (context, state) {
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const AddRequestScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'requests-by-id/:id',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.requestsById.name,
                pageBuilder: (context, state) {
                  Offset? begin = (state.extra as Map<String,
                      dynamic>)['offset'] as Offset?;
                  String? userId = (state.extra
                  as Map<String, dynamic>)['userId'] as String?;
                  String? id = state.pathParameters['id'];
                  final type = state.pathParameters['type'] ?? '';
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: RequestsByTypeIdScreen(
                      requestTypeId: id!,
                      employeeId: userId,
                      type: type,
                    ),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'request-details/:id',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.requestDetails.name,
                pageBuilder: (context, state) {
                  final type = state.pathParameters['type'] ?? '';
                  final id = state.pathParameters['id'] ?? '';
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: RequestDetailsScreen(
                      request: id,
                      requestType: type,
                    ),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },

              ),
            ],
          ),

          GoRoute(
              path: '/:lang/fingerprint',
              parentNavigatorKey: _shellNavigatorKey,
              name: AppRoutes.fingerprint.name,
              pageBuilder: (context, state) {
                final lang = state.uri.queryParameters['lang'];
                if (lang != null) {
                  final locale = Locale(lang);
                  context.setLocale(locale);
                }
                final animationController = AnimationController(
                  vsync: ticker,
                );
                // Make sure to dispose the controller after the transition is complete
                animationController.addStatusListener((status) {
                  if (status == AnimationStatus.completed ||
                      status == AnimationStatus.dismissed) {
                    animationController.dispose();
                  }
                });
                return AppRouterTransitions.slideTransition(
                  key: state.pageKey,
                  child: const FingerprintScreen(),
                  animation: animationController,
                  begin: const Offset(1.0, 0.0),
                );
              },
              routes: [
                GoRoute(
                  path: 'fingerprint-offline',
                  parentNavigatorKey: rootNavigatorKey,
                  name: AppRoutes.fingerPrintOffline.name,
                  pageBuilder: (context, state) {
                    Offset? begin = state.extra as Offset?;
                    final animationController = AnimationController(
                      vsync: ticker,
                    );
                    // Make sure to dispose the controller after the transition is complete
                    animationController.addStatusListener((status) {
                      if (status == AnimationStatus.completed ||
                          status == AnimationStatus.dismissed) {
                        animationController.dispose();
                      }
                    });
                    return AppRouterTransitions.slideTransition(
                      key: state.pageKey,
                      child: const FingerprintOfflineScreen(),
                      animation: animationController,
                      begin: begin ?? const Offset(1.0, 0.0),
                    );
                  },
                ),
              ]
          ),
          GoRoute(
            path: '/:lang/notifications',
            parentNavigatorKey: _shellNavigatorKey,
            name: AppRoutes.notifications.name,
            pageBuilder: (context, state) {
              Offset? begin = state.extra as Offset?;
              final animationController = AnimationController(
                vsync: ticker,
              );
              // Make sure to dispose the controller after the transition is complete
              animationController.addStatusListener((status) {
                if (status == AnimationStatus.completed ||
                    status == AnimationStatus.dismissed) {
                  animationController.dispose();
                }
              });
              CacheHelper.deleteData(key: "value");
              return AppRouterTransitions.slideTransition(
                key: state.pageKey,
                child: const NotificationScreen(false),
                animation: animationController,
                begin: begin ?? const Offset(1.0, 0.0),
              );
            },
          ),
          GoRoute(
            path: '/:lang/more',
            parentNavigatorKey: _shellNavigatorKey,
            name: AppRoutes.more.name,
            pageBuilder: (context, state) {
              Offset? begin = state.extra as Offset?;
              final animationController = AnimationController(
                vsync: ticker,
              );
              // Make sure to dispose the controller after the transition is complete
              animationController.addStatusListener((status) {
                if (status == AnimationStatus.completed ||
                    status == AnimationStatus.dismissed) {
                  animationController.dispose();
                }
              });
              return AppRouterTransitions.slideTransition(
                key: state.pageKey,
                child: const MoreScreen(),
                animation: animationController,
                begin: begin ?? const Offset(1.0, 0.0),
              );
            },
            routes: [
              GoRoute(
                path: 'general-data-screen',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.generalDataScreen.name,
                pageBuilder: (context, state) {
                  Offset? begin = state.extra as Offset?;
                  final lang = state.uri.queryParameters['lang'];

                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: GeneralDataScreen(),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'fingerprintView/:id/:name',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.fingerprintView.name,
                pageBuilder: (context, state) {
                  // Offset? begin =
                  //     (state.extra as Map<String, dynamic>)['offset'] as Offset?;
                  // String? employeeName = (state.extra
                  //     as Map<String, dynamic>)['employeeName'] as String?;
                  // String? employeeId = (state.extra
                  //     as Map<String, dynamic>)['employeeId'] as String?;
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final id = state.pathParameters['id'] ?? "";
                  final name = state.pathParameters['name'] ?? "";
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: FingerPrintViewScreen(empId: id, empName: name,),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'webview',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.webViewScreen.name,
                pageBuilder: (context, state) {
                  Offset? begin = state.extra as Offset?;
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
// Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const WebViewStack(),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'teamFingerprint',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.teamFingerprint.name,
                pageBuilder: (context, state) {
                  Offset? begin = state.extra as Offset?;
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
// Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const TeamFingerprintScreen(),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'update-password',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.updatePassword.name,
                pageBuilder: (context, state) {
                  Offset? begin = state.extra as Offset?;
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const UpdatePasswordScreen(),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'about-us-screen',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.aboutUsScreen.name,
                pageBuilder: (context, state) {
                  Offset? begin = state.extra as Offset?;
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const AboutUsScreen(),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'faq-screen',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.faqScreen.name,
                pageBuilder: (context, state) {
                  Offset? begin = state.extra as Offset?;
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const FaqScreen(),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'request-terms-screen',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.requestTermsScreen.name,
                pageBuilder: (context, state) {
                  Offset? begin = state.extra as Offset?;
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const RequestTermsScreen(),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'contact-us',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.contactUs.name,
                pageBuilder: (context, state) {
                  // Offset? begin = state.extra as Offset?;
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const ContactScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'free-services-home',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.freeServicesHome.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const FreeServicesHomeScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'my-cv',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.myCVScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const MyCVScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'free_more',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.freeMoreScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const FreeServiceMoreScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'cv-generator',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.cvGeneratorScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const CVGeneratorScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'smart-card',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.smartCardScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const SmartCardScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'smart-card-company-detail',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.smartCardCompanyDetailScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final company = state.extra as Map<String, dynamic>?;
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: SmartCardCompanyDetailScreen(company: company ?? {}),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'update-my-info',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.updateMyInfoScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const UpdateMyInfoScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'update-company-info',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.updateCompanyInfoScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final company = state.extra as Map<String, dynamic>?;
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: UpdateCompanyInfoScreen(company: company ?? {}),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'smart-card-profile-detail',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.smartCardProfileDetailScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final extra = state.extra as Map<String, dynamic>? ?? {};
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: SmartCardProfileDetailScreen(
                      employee: extra['employee'] as Map<String, dynamic>? ?? {},
                      isPersonal: extra['isPersonal'] as bool? ?? false,
                      companyId: extra['companyId'] as int?,
                    ),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'update-employee-info',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.updateEmployeeInfoScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final extra = state.extra as Map<String, dynamic>? ?? {};
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: UpdateEmployeeInfoScreen(
                      employee: extra['employee'] as Map<String, dynamic>? ?? {},
                      isPersonal: extra['isPersonal'] as bool? ?? false,
                      companyId: extra['companyId'] as int?,
                    ),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),

              GoRoute(
                path: 'select-template',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.selectTemplateScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const SelectTemplateScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'premium-templates',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.premiumTemplatesScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const PremiumTemplatesScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'vacation-calc',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.vacationCalcScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const VacationCalcScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'personality-test',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.personalityTestScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const PersonalityTestScreen(),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                  path: 'about-team-mind',
                  parentNavigatorKey: rootNavigatorKey,
                  name: AppRoutes.aboutTeamMindScreen.name,
                  pageBuilder: (context, state) {
                    final lang = state.uri.queryParameters['lang'];
                    if (lang != null) {
                      final locale = Locale(lang);
                      context.setLocale(locale);
                    }
                    final animationController = AnimationController(
                      vsync: ticker,
                    );
                    animationController.addStatusListener((status) {
                      if (status == AnimationStatus.completed ||
                          status == AnimationStatus.dismissed) {
                        animationController.dispose();
                      }
                    });
                    return AppRouterTransitions.slideTransition(
                      key: state.pageKey,
                      child: const AboutTeamMindScreen(),
                      animation: animationController,
                      begin: const Offset(1.0, 0.0),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'mediaCenterYoutubeScreenView/:url',
                      parentNavigatorKey: rootNavigatorKey,
                      name: AppRoutes.mediaCenterYoutubeScreenView.name,
                      pageBuilder: (context, state) {
                        Offset? begin = state.extra as Offset?;
                        final lang = state.uri.queryParameters['lang'];
                        final String url = Uri.decodeComponent(state.pathParameters['url']!);
                        if (lang != null) {
                          final locale = Locale(lang);
                          context.setLocale(locale);
                        }
                        final animationController = AnimationController(
                          vsync: ticker,
                        );
                        // Make sure to dispose the controller after the transition is complete
                        animationController.addStatusListener((status) {
                          if (status == AnimationStatus.completed ||
                              status == AnimationStatus.dismissed) {
                            animationController.dispose();
                          }
                        });
                        return AppRouterTransitions.slideTransition(
                          key: state.pageKey,
                          child: YouTubeVideoPlayer(videoUrl: url,),
                          animation: animationController,
                          begin: begin ?? const Offset(1.0, 0.0),
                        );
                      },

                    ),
                  ]
              ),
              GoRoute(
                path: 'youtube-video/:url',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.youtubeVideoScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.uri.queryParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final url = Uri.decodeComponent(state.pathParameters['url']!);
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: YoutubeVideoPlayerScreen(videoUrl: url),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'company-tree',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.companyTree.name,
                pageBuilder: (context, state) {
                  Offset? begin = state.extra as Offset?;
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const CompanyStructureTreeScreen(),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                path: 'evaluation-Screen',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.evaluationScreen.name,
                pageBuilder: (context, state) {
                  var jsonString;
                  var gCache;
                  jsonString = CacheHelper.getString("US1");
                  if (jsonString != null && jsonString.isNotEmpty &&
                      jsonString != "") {
                    gCache = json.decode(jsonString) as Map<String,
                        dynamic>; // Convert String back to JSON
                  }
                  debugPrint(
                      "ID CACHE IS --> ${CacheHelper.getInt("id").toString()}");
                  final extra = state.extra as Map<String, dynamic>?;
                  final empId = extra?["empId"] ??
                      gCache['employee_profile_id'].toString();
                  final begin = extra?["begin"] as Offset? ??
                      const Offset(1.0, 0.0);
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: EvaluationScreen(empId: empId,),
                    animation: animationController,
                    begin: begin,
                  );
                },
              ),
              GoRoute(
                path: 'evaluation-require-Screen',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.evaluationRequireScreen.name,
                pageBuilder: (context, state) {
                  Offset? begin = state.extra as Offset?;
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: const EvaluationRequireScreen(),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
              ),
              GoRoute(
                  path: 'task-screen',
                  parentNavigatorKey: rootNavigatorKey,
                  name: AppRoutes.taskScreen.name,
                  pageBuilder: (context, state) {
                    Offset? begin = state.extra as Offset?;
                    final animationController = AnimationController(
                      vsync: ticker,
                    );
                    // Make sure to dispose the controller after the transition is complete
                    animationController.addStatusListener((status) {
                      if (status == AnimationStatus.completed ||
                          status == AnimationStatus.dismissed) {
                        animationController.dispose();
                      }
                    });
                    return AppRouterTransitions.slideTransition(
                      key: state.pageKey,
                      child: const TaskScreen(),
                      animation: animationController,
                      begin: begin ?? const Offset(1.0, 0.0),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'add-new-task',
                      parentNavigatorKey: rootNavigatorKey,
                      name: AppRoutes.addTaskScreen.name,
                      pageBuilder: (context, state) {
                        final animationController = AnimationController(
                          vsync: ticker,
                        );
                        // Make sure to dispose the controller after the transition is complete
                        animationController.addStatusListener((status) {
                          if (status == AnimationStatus.completed ||
                              status == AnimationStatus.dismissed) {
                            animationController.dispose();
                          }
                        });
                        return AppRouterTransitions.slideTransition(
                          key: state.pageKey,
                          child: const AddTaskScreen(),
                          animation: animationController,
                          begin: const Offset(1.0, 0.0),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'edit-new-tas/:id',
                      parentNavigatorKey: rootNavigatorKey,
                      name: AppRoutes.editTaskScreen.name,
                      pageBuilder: (context, state) {
                        final id = state.pathParameters['id'] ?? '';
                        final animationController = AnimationController(
                          vsync: ticker,
                        );
                        // Make sure to dispose the controller after the transition is complete
                        animationController.addStatusListener((status) {
                          if (status == AnimationStatus.completed ||
                              status == AnimationStatus.dismissed) {
                            animationController.dispose();
                          }
                        });
                        return AppRouterTransitions.slideTransition(
                          key: state.pageKey,
                          child: EditTaskScreen(id: id,),
                          animation: animationController,
                          begin: const Offset(1.0, 0.0),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'task-details/:id',
                      parentNavigatorKey: rootNavigatorKey,
                      name: AppRoutes.taskDetails.name,
                      pageBuilder: (context, state) {
                        final id = state.pathParameters['id'] ?? '';
                        final animationController = AnimationController(
                          vsync: ticker,
                        );
                        // Make sure to dispose the controller after the transition is complete
                        animationController.addStatusListener((status) {
                          if (status == AnimationStatus.completed ||
                              status == AnimationStatus.dismissed) {
                            animationController.dispose();
                          }
                        });
                        return AppRouterTransitions.slideTransition(
                          key: state.pageKey,
                          child: TaskDetailsScreen(id: id,),
                          animation: animationController,
                          begin: const Offset(1.0, 0.0),
                        );
                      },
                    ),
                  ]
              ),
              GoRoute(
                path: 'rewards-and-penalties-screen',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.rewardsAndPenalties.name,
                pageBuilder: (context, state) {
                  Offset? begin = (state.extra
                  as Map<String, dynamic>)['offset'] as Offset?;
                  String? employeeName = (state.extra
                  as Map<String, dynamic>)['employeeName'] as String?;
                  String? employeeId = (state.extra
                  as Map<String, dynamic>)['employeeId'] as String?;
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  // Make sure to dispose the controller after the transition is complete
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: RewardsAndPenaltiesScreen(
                      empId: employeeId,
                      empName: employeeName,
                    ),
                    animation: animationController,
                    begin: begin ?? const Offset(1.0, 0.0),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'add-rewards-and-penalties-screen',
                    parentNavigatorKey: rootNavigatorKey,
                    name: AppRoutes.addRewardsAndPenalties.name,
                    pageBuilder: (context, state) {
                      final animationController = AnimationController(
                        vsync: ticker,
                      );
                      // Make sure to dispose the controller after the transition is complete
                      animationController.addStatusListener((status) {
                        if (status == AnimationStatus.completed ||
                            status == AnimationStatus.dismissed) {
                          animationController.dispose();
                        }
                      });
                      return AppRouterTransitions.slideTransition(
                        key: state.pageKey,
                        child: const AddRewardAndPenaltyScreen(),
                        animation: animationController,
                        begin: const Offset(1.0, 0.0),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                  path: 'customerServiceScreen',
                  parentNavigatorKey: rootNavigatorKey,
                  name: AppRoutes.customerServiceScreen.name,
                  pageBuilder: (context, state) {
                    Offset? begin = state.extra as Offset?;
                    final lang = state.uri.queryParameters['lang'];
                    if (lang != null) {
                      final locale = Locale(lang);
                      context.setLocale(locale);
                    }
                    final animationController = AnimationController(
                      vsync: ticker,
                    );
                    // Make sure to dispose the controller after the transition is complete
                    animationController.addStatusListener((status) {
                      if (status == AnimationStatus.completed ||
                          status == AnimationStatus.dismissed) {
                        animationController.dispose();
                      }
                    });
                    return AppRouterTransitions.slideTransition(
                      key: state.pageKey,
                      child: const CustomerServiceScreen(),
                      animation: animationController,
                      begin: begin ?? const Offset(1.0, 0.0),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'customerRequestDetailsScreen/:id',
                      parentNavigatorKey: rootNavigatorKey,
                      name: AppRoutes.customerServiceDetailsScreen.name,
                      pageBuilder: (context, state) {
                        Offset? begin = state.extra as Offset?;
                        final lang = state.uri.queryParameters['lang'];
                        final id = state.pathParameters['id'] ?? '';
                        if (lang != null) {
                          final locale = Locale(lang);
                          context.setLocale(locale);
                        }
                        final animationController = AnimationController(
                          vsync: ticker,
                        );
                        // Make sure to dispose the controller after the transition is complete
                        animationController.addStatusListener((status) {
                          if (status == AnimationStatus.completed ||
                              status == AnimationStatus.dismissed) {
                            animationController.dispose();
                          }
                        });
                        return AppRouterTransitions.slideTransition(
                          key: state.pageKey,
                          child: CustomerServiceDetailsScreen(id : id),
                          animation: animationController,
                          begin: begin ?? const Offset(1.0, 0.0),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'newCustomerServiceScreen/:type/:subject/:details',
                      parentNavigatorKey: rootNavigatorKey,
                      name: AppRoutes.newCusomterService.name,
                      pageBuilder: (context, state) {
                        Offset? begin = state.extra as Offset?;
                        final lang = state.uri.queryParameters['lang'];
                        final type = state.uri.queryParameters['type'] ?? '';
                        final details = state.uri.queryParameters['details'] ?? '';
                        final subject = state.uri.queryParameters['subject'] ?? '';
                        if (lang != null) {
                          final locale = Locale(lang);
                          context.setLocale(locale);
                        }
                        final animationController = AnimationController(
                          vsync: ticker,
                        );
                        // Make sure to dispose the controller after the transition is complete
                        animationController.addStatusListener((status) {
                          if (status == AnimationStatus.completed ||
                              status == AnimationStatus.dismissed) {
                            animationController.dispose();
                          }
                        });
                        return AppRouterTransitions.slideTransition(
                          key: state.pageKey,
                          child: NewCustomerServiceScreen(type, subject, details),
                          animation: animationController,
                          begin: begin ?? const Offset(1.0, 0.0),
                        );
                      },
                    ),
                  ]
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/:lang/webview',
        name: 'webview',
        builder: (context, state) {
          final link = state.extra as String;
          return WebViewStackOffers(link);
        },
      ),

      GoRoute(
        path: '/:lang/payrolls-screen',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.payrollsList.name,
        pageBuilder: (context, state) {
          Offset? begin =
          (state.extra as Map<String, dynamic>)['offset'] as Offset?;
          String? employeeName = (state.extra
          as Map<String, dynamic>)['employeeName'] as String?;
          String? employeeId =
          (state.extra as Map<String, dynamic>)['employeeId'] as String?;
          final animationController = AnimationController(
            vsync: ticker,
          );
          // Make sure to dispose the controller after the transition is complete
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: PayrollsListScreen(
              empId: employeeId,
              empName: employeeName,
            ),
            animation: animationController,
            begin: begin ?? const Offset(1.0, 0.0),
          );
        },
        routes: [
          GoRoute(
            path: 'payroll-details',
            parentNavigatorKey: rootNavigatorKey,
            name: AppRoutes.payrollDetails.name,
            pageBuilder: (context, state) {
              PayrollModel? payroll = state.extra as PayrollModel;
              final animationController = AnimationController(
                vsync: ticker,
              );
              // Make sure to dispose the controller after the transition is complete
              animationController.addStatusListener((status) {
                if (status == AnimationStatus.completed ||
                    status == AnimationStatus.dismissed) {
                  animationController.dispose();
                }
              });
              return AppRouterTransitions.slideTransition(
                key: state.pageKey,
                child: PayrollDetailsScreen(payroll: payroll),
                animation: animationController,
                begin: const Offset(1.0, 0.0),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/:lang/employee-fingerprint/:employeeId',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.employeeFingerprint.name,
        pageBuilder: (context, state) {
          String? employeeId = state.pathParameters["employeeId"];
          final animationController = AnimationController(
            vsync: ticker,
          );
          // Make sure to dispose the controller after the transition is complete
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: FingerprintScreen(
              empId: employeeId,
            ),
            animation: animationController,
            begin: const Offset(1.0, 0.0),
          );
        },
      ),
      GoRoute(
          path: '/:lang/employees-list',
          parentNavigatorKey: rootNavigatorKey,
          name: AppRoutes.employeesList.name,
          pageBuilder: (context, state) {
            Offset? begin = state.extra as Offset?;
            final animationController = AnimationController(
              vsync: ticker,
            );
            // Make sure to dispose the controller after the transition is complete
            animationController.addStatusListener((status) {
              if (status == AnimationStatus.completed ||
                  status == AnimationStatus.dismissed) {
                animationController.dispose();
              }
            });
            return AppRouterTransitions.slideTransition(
              key: state.pageKey,
              child: const EmployeesListScreen(),
              animation: animationController,
              begin: begin ?? const Offset(1.0, 0.0),
            );
          },
          routes: [
            GoRoute(
              path: 'employee-details/:id',
              parentNavigatorKey: rootNavigatorKey,
              name: AppRoutes.employeeDetails.name,
              pageBuilder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                final animationController = AnimationController(
                  vsync: ticker,
                );
                // Make sure to dispose the controller after the transition is complete
                animationController.addStatusListener((status) {
                  if (status == AnimationStatus.completed ||
                      status == AnimationStatus.dismissed) {
                    animationController.dispose();
                  }
                });
                return AppRouterTransitions.slideTransition(
                  key: state.pageKey,
                  child: EmployeeDetailsScreen(
                    id: id,
                  ),
                  animation: animationController,
                  begin: const Offset(1.0, 0.0),
                );
              },
            ),
          ]),
      GoRoute(
        path: '/:lang/splash-screen',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/:lang/lang-setting-screen',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.langSettingScreen.name,
        pageBuilder: (context, state) {
          Offset? begin = state.extra as Offset?;
          final lang = state.uri.queryParameters['lang'];
          if (lang != null) {
            final locale = Locale(lang);
            context.setLocale(locale);
          }
          final animationController = AnimationController(
            vsync: ticker,
          );
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: LangSettingScreens(),
            animation: animationController,
            begin: begin ?? const Offset(1.0, 0.0),
          );
        },
      ),


      GoRoute(
        path: '/:lang/notification-screen',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.notification.name,
        builder: (context, state) => const NotificationScreen(true),
      ),
      GoRoute(
        path: '/:lang/notification-details-screen/:title/:image/:contant/:date/:id',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.notificationDetails.name,
        pageBuilder: (context, state) {
          Offset? begin = state.extra as Offset?;
          final lang = state.uri.queryParameters['lang'];
          final title = state.pathParameters['title'] ?? '';
          final id = state.pathParameters['id'] ?? '';
          final image = state.pathParameters['image'] ?? '';
          final contant = state.pathParameters['contant'] ?? '';
          final date = state.pathParameters['date'] ?? '';

          if (lang != null) {
            final locale = Locale(lang);
            context.setLocale(locale);
          }
          final animationController = AnimationController(
            vsync: ticker,
          );
          // Make sure to dispose the controller after the transition is complete
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: NotificationDetailsScreen(
              date: date,
              title: title,
              image: image,
              contant: contant,
              id: id,
            ),
            animation: animationController,
            begin: begin ?? const Offset(1.0, 0.0),
          );
        },
      ),
      // GoRoute(
      //     path: '/:lang/notification-screen',
      //     parentNavigatorKey: rootNavigatorKey,
      //     name: AppRoutes.notification.name,
      //     builder: (context, state) => NotificationScreen(true),
      //     routes: [
      //       GoRoute(
      //         path: 'add-notification',
      //         parentNavigatorKey: rootNavigatorKey,
      //         name: AppRoutes.addNotification.name,
      //         pageBuilder: (context, state) {
      //           Offset? begin = state.extra as Offset?;
      //           final lang = state.uri.queryParameters['lang'];
      //           if (lang != null) {
      //             final locale = Locale(lang);
      //             context.setLocale(locale);
      //           }
      //           final animationController = AnimationController(
      //             vsync: ticker,
      //           );
      //           animationController.addStatusListener((status) {
      //             if (status == AnimationStatus.completed ||
      //                 status == AnimationStatus.dismissed) {
      //               animationController.dispose();
      //             }
      //           });
      //           return AppRouterTransitions.slideTransition(
      //             key: state.pageKey,
      //             child: const AddNotificationScreen(),
      //             animation: animationController,
      //             begin: begin ?? const Offset(1.0, 0.0),
      //           );
      //         },
      //       ),
      //     ]
      // ),
      // GoRoute(
      //   path: '/:lang/notification-details-screen/:id',
      //   parentNavigatorKey: rootNavigatorKey,
      //   name: AppRoutes.notificationDetails.name,
      //   pageBuilder: (context, state) {
      //     Offset? begin = state.extra as Offset?;
      //     final lang = state.uri.queryParameters['lang'];
      //     final id = state.pathParameters['id'] ?? '';
      //
      //     if (lang != null) {
      //       final locale = Locale(lang);
      //       context.setLocale(locale);
      //     }
      //     final animationController = AnimationController(
      //       vsync: ticker,
      //     );
      //     // Make sure to dispose the controller after the transition is complete
      //     animationController.addStatusListener((status) {
      //       if (status == AnimationStatus.completed ||
      //           status == AnimationStatus.dismissed) {
      //         animationController.dispose();
      //       }
      //     });
      //     return AppRouterTransitions.slideTransition(
      //       key: state.pageKey,
      //       child: NotificationDetailsScreen(
      //         id: id,
      //       ),
      //       animation: animationController,
      //       begin: begin ?? const Offset(1.0, 0.0),
      //     );
      //   },
      // ),

      GoRoute(
        path: '/:lang/default-page/:type',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.defaultPage.name,
        pageBuilder: (context, state) {
          Offset? begin = state.extra as Offset?;
          final lang = state.uri.queryParameters['lang'];
          final type = state.pathParameters['type'] ?? '';

          if (lang != null) {
            final locale = Locale(lang);
            context.setLocale(locale);
          }
          final animationController = AnimationController(
            vsync: ticker,
          );
          // Make sure to dispose the controller after the transition is complete
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: DefaultPage(type),
            animation: animationController,
            begin: begin ?? const Offset(1.0, 0.0),
          );
        },
      ),
      GoRoute(
        path: '/:lang/default-list-page/:type',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.defaultListPage.name,
        pageBuilder: (context, state) {
          Offset? begin = state.extra as Offset?;
          final lang = state.uri.queryParameters['lang'];
          final type = state.pathParameters['type'] ?? '';
          if (lang != null) {
            final locale = Locale(lang);
            context.setLocale(locale);
          }
          final animationController = AnimationController(
            vsync: ticker,
          );
          // Make sure to dispose the controller after the transition is complete
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: DefaultListPage(type: type,),
            animation: animationController,
            begin: begin ?? const Offset(1.0, 0.0),
          );
        },
      ),
      GoRoute(
        path: '/:lang/default-single-page/:type/:id',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.defaultSinglePage.name,
        pageBuilder: (context, state) {
          Offset? begin = state.extra as Offset?;
          final lang = state.uri.queryParameters['lang'];
          final type = state.pathParameters['type'] ?? '';
          final id = state.pathParameters['id'] ?? '';
          if (lang != null) {
            final locale = Locale(lang);
            context.setLocale(locale);
          }
          final animationController = AnimationController(
            vsync: ticker,
          );
          // Make sure to dispose the controller after the transition is complete
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: DefaultDetails(type: type, id: id,),
            animation: animationController,
            begin: begin ?? const Offset(1.0, 0.0),
          );
        },
      ),
      GoRoute(
        path: '/:lang/userDevices-screen',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.userDevices.name,
        builder: (context, state) => const UserDeviceScreen(),
      ),
      GoRoute(
        path: '/:lang/blog_details/:title/:type/:id',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.blogDetails.name,
        pageBuilder: (context, state) {
          Offset? begin = state.extra as Offset?;
          final lang = state.uri.queryParameters['lang'];
          final id = Uri.decodeComponent(state.pathParameters['id'] ?? '');
          final type = state.pathParameters['type'] ?? '';
          if (lang != null) {
            final locale = Locale(lang);
            context.setLocale(locale);
          }
          final animationController = AnimationController(
            vsync: ticker,
          );
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: DefaultDetails(
              id: id,
              type: type,
            ),
            animation: animationController,
            begin: begin ?? const Offset(1.0, 0.0),
          );
        },
      ),
      // GoRoute(
      //   path: '/:lang/newComplainsScreen',
      //   parentNavigatorKey: rootNavigatorKey,
      //   name: AppRoutes.newComplainScreen.name,
      //   pageBuilder: (context, state) {
      //     Offset? begin = state.extra as Offset?;
      //     final lang = state.uri.queryParameters['lang'];
      //     if (lang != null) {
      //       final locale = Locale(lang);
      //       context.setLocale(locale);
      //     }
      //     final animationController = AnimationController(
      //       vsync: ticker,
      //     );
      //     // Make sure to dispose the controller after the transition is complete
      //     animationController.addStatusListener((status) {
      //       if (status == AnimationStatus.completed ||
      //           status == AnimationStatus.dismissed) {
      //         animationController.dispose();
      //       }
      //     });
      //     return AppRouterTransitions.slideTransition(
      //       key: state.pageKey,
      //       child: NewComplainScreen(),
      //       animation: animationController,
      //       begin: begin ?? const Offset(1.0, 0.0),
      //     );
      //   },
      // ),
      GoRoute(
        path: '/:lang/onboarding-screen',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.onboarding.name,
        pageBuilder: (context, state) {
          final animationController = AnimationController(
            vsync: ticker,
          );
          // Make sure to dispose the controller after the transition is complete
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: const OnBoardingScreen(),
            animation: animationController,
            begin: const Offset(1.0, 0.0),
          );
        },
      ),
      GoRoute(
        path: '/:lang/login-screen',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.login.name,
        pageBuilder: (context, state) {
          final animationController = AnimationController(
            vsync: ticker,
          );
          // Make sure to dispose the controller after the transition is complete
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: const LoginScreen(),
            animation: animationController,
            begin: const Offset(1.0, 0.0),
          );
        },
      ),
      GoRoute(
        path: '/:lang/offline-screen',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.offlineScreen.name,
        builder: (context, state) => const OfflineScreen(),
      ),
      GoRoute(
        path: '/:lang/webviewMainData',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.webViewMainDataScreen.name,
        pageBuilder: (context, state) {
          Offset? begin = state.extra as Offset?;
          final lang = state.uri.queryParameters['lang'];
          if (lang != null) {
            final locale = Locale(lang);
            context.setLocale(locale);
          }
          final animationController = AnimationController(
            vsync: ticker,
          );
// Make sure to dispose the controller after the transition is complete
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: WebViewStackMainData(),
            animation: animationController,
            begin: begin ?? const Offset(1.0, 0.0),
          );
        },
      ),
      GoRoute(
          path: '/:lang/painters-point-screen',
          parentNavigatorKey: rootNavigatorKey,
          name: AppRoutes.painterPointsViewScreen.name,
          pageBuilder: (context, state) {
            final lang = state.pathParameters['lang'];
            if (lang != null) {
              final locale = Locale(lang);
              context.setLocale(locale);
            }
            final animationController = AnimationController(
              vsync: ticker,
            );
            animationController.addStatusListener((status) {
              if (status == AnimationStatus.completed ||
                  status == AnimationStatus.dismissed) {
                animationController.dispose();
              }
            });
            return AppRouterTransitions.slideTransition(
              key: state.pageKey,
              child: PointsScreen(arrow: true,),
              animation: animationController,
              begin: const Offset(1.0, 0.0),
            );
          },
          routes: [
            GoRoute(
                path: 'prize-point-screen/:id',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.prizePointsViewScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.pathParameters['lang'];
                  final id = state.pathParameters['id'] ?? '';
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: PrizeScreen(true,id),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                }
            ),
            GoRoute(
                path: 'categories-prize-point-screen',
                parentNavigatorKey: rootNavigatorKey,
                name: AppRoutes.CategoriesprizePointsViewScreen.name,
                pageBuilder: (context, state) {
                  final lang = state.pathParameters['lang'];
                  if (lang != null) {
                    final locale = Locale(lang);
                    context.setLocale(locale);
                  }
                  final animationController = AnimationController(
                    vsync: ticker,
                  );
                  animationController.addStatusListener((status) {
                    if (status == AnimationStatus.completed ||
                        status == AnimationStatus.dismissed) {
                      animationController.dispose();
                    }
                  });
                  return AppRouterTransitions.slideTransition(
                    key: state.pageKey,
                    child: ChangeNotifierProvider(
                      create: (_) => PointsController(),
                      child: const PointsCategoriesScreen(true,),
                    ),
                    animation: animationController,
                    begin: const Offset(1.0, 0.0),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'fawryProviderScreen',
                    parentNavigatorKey: rootNavigatorKey,
                    name: AppRoutes.fawryProviderScreen.name,
                    pageBuilder: (context, state) {
                      //  Offset? begin = state.extra as Offset?;
                      final lang = state.pathParameters['lang'];
                      if (lang != null) {
                        final locale = Locale(lang);
                        context.setLocale(locale);
                      }
                      final animationController = AnimationController(
                        vsync: ticker,
                      );
                      // Make sure to dispose the controller after the transition is complete
                      animationController.addStatusListener((status) {
                        if (status == AnimationStatus.completed ||
                            status == AnimationStatus.dismissed) {
                          animationController.dispose();
                        }
                      });
                      return AppRouterTransitions.slideTransition(
                        key: state.pageKey,
                        child: FawryProviderScreen(),
                        animation: animationController,
                        begin: const Offset(1.0, 0.0),
                      );
                    },
                  ),
                  // GoRoute(
                  //   path: 'billPaymentScreen',
                  //   parentNavigatorKey: _rootNavigatorKey,
                  //   name: AppRoutes.billPaymentScreen.name,
                  //   pageBuilder: (context, state) {
                  //     //  Offset? begin = state.extra as Offset?;
                  //     final lang = state.pathParameters['lang'];
                  //     if (lang != null) {
                  //       final locale = Locale(lang);
                  //       context.setLocale(locale);
                  //     }
                  //     final animationController = AnimationController(
                  //       vsync: ticker,
                  //     );
                  //     // Make sure to dispose the controller after the transition is complete
                  //     animationController.addStatusListener((status) {
                  //       if (status == AnimationStatus.completed ||
                  //           status == AnimationStatus.dismissed) {
                  //         animationController.dispose();
                  //       }
                  //     });
                  //     return AppRouterTransitions.slideTransition(
                  //       key: state.pageKey,
                  //       child: BillPaymentScreen(),
                  //       animation: animationController,
                  //       begin: const Offset(1.0, 0.0),
                  //     );
                  //   },
                  // ),
                  // GoRoute(
                  //   path: 'chargePhoneScreen',
                  //   parentNavigatorKey: _rootNavigatorKey,
                  //   name: AppRoutes.chargePhoneScreen.name,
                  //   pageBuilder: (context, state) {
                  //     //  Offset? begin = state.extra as Offset?;
                  //     final lang = state.pathParameters['lang'];
                  //     if (lang != null) {
                  //       final locale = Locale(lang);
                  //       context.setLocale(locale);
                  //     }
                  //     final animationController = AnimationController(
                  //       vsync: ticker,
                  //     );
                  //     // Make sure to dispose the controller after the transition is complete
                  //     animationController.addStatusListener((status) {
                  //       if (status == AnimationStatus.completed ||
                  //           status == AnimationStatus.dismissed) {
                  //         animationController.dispose();
                  //       }
                  //     });
                  //     return AppRouterTransitions.slideTransition(
                  //       key: state.pageKey,
                  //       child: ChargePhoneScreen(),
                  //       animation: animationController,
                  //       begin: const Offset(1.0, 0.0),
                  //     );
                  //   },
                  // ),
                  // GoRoute(
                  //   path: 'payBillScreen',
                  //   parentNavigatorKey: _rootNavigatorKey,
                  //   name: AppRoutes.payBillScreen.name,
                  //   pageBuilder: (context, state) {
                  //     //  Offset? begin = state.extra as Offset?;
                  //     final lang = state.pathParameters['lang'];
                  //     if (lang != null) {
                  //       final locale = Locale(lang);
                  //       context.setLocale(locale);
                  //     }
                  //     final animationController = AnimationController(
                  //       vsync: ticker,
                  //     );
                  //     // Make sure to dispose the controller after the transition is complete
                  //     animationController.addStatusListener((status) {
                  //       if (status == AnimationStatus.completed ||
                  //           status == AnimationStatus.dismissed) {
                  //         animationController.dispose();
                  //       }
                  //     });
                  //     return AppRouterTransitions.slideTransition(
                  //       key: state.pageKey,
                  //       child: PayBillScreen(),
                  //       animation: animationController,
                  //       begin: const Offset(1.0, 0.0),
                  //     );
                  //   },
                  // ),
                  // GoRoute(
                  //   path: 'withdrawMoneyScreen',
                  //   parentNavigatorKey: _rootNavigatorKey,
                  //   name: AppRoutes.withdrawMoneyScreen.name,
                  //   pageBuilder: (context, state) {
                  //     //  Offset? begin = state.extra as Offset?;
                  //     final lang = state.pathParameters['lang'];
                  //     if (lang != null) {
                  //       final locale = Locale(lang);
                  //       context.setLocale(locale);
                  //     }
                  //     final animationController = AnimationController(
                  //       vsync: ticker,
                  //     );
                  //     // Make sure to dispose the controller after the transition is complete
                  //     animationController.addStatusListener((status) {
                  //       if (status == AnimationStatus.completed ||
                  //           status == AnimationStatus.dismissed) {
                  //         animationController.dispose();
                  //       }
                  //     });
                  //     return AppRouterTransitions.slideTransition(
                  //       key: state.pageKey,
                  //       child: WithdrawMoneyScreen(),
                  //       animation: animationController,
                  //       begin: const Offset(1.0, 0.0),
                  //     );
                  //   },
                  // ),
                ]
            ),
          ]
      ),
      GoRoute(
          path: 'complainScreen',
          parentNavigatorKey: rootNavigatorKey,
          name: AppRoutes.complainScreen.name,
          pageBuilder: (context, state) {
            Offset? begin = state.extra as Offset?;
            final lang = state.uri.queryParameters['lang'];
            if (lang != null) {
              final locale = Locale(lang);
              context.setLocale(locale);
            }
            final animationController = AnimationController(
              vsync: ticker,
            );
            // Make sure to dispose the controller after the transition is complete
            animationController.addStatusListener((status) {
              if (status == AnimationStatus.completed ||
                  status == AnimationStatus.dismissed) {
                animationController.dispose();
              }
            });
            return AppRouterTransitions.slideTransition(
              key: state.pageKey,
              child: ComplainScreen(),
              animation: animationController,
              begin: begin ?? const Offset(1.0, 0.0),
            );
          },
          routes: [
            GoRoute(
              path: 'complainDetailsScreen/:id/:type',
              parentNavigatorKey: rootNavigatorKey,
              name: AppRoutes.complainDetails.name,
              pageBuilder: (context, state) {
                Offset? begin = state.extra as Offset?;
                final lang = state.uri.queryParameters['lang'];
                final id = state.pathParameters['id'] ?? '';
                final type = state.pathParameters['type'] ?? '';
                if (lang != null) {
                  final locale = Locale(lang);
                  context.setLocale(locale);
                }
                final animationController = AnimationController(
                  vsync: ticker,
                );
                // Make sure to dispose the controller after the transition is complete
                animationController.addStatusListener((status) {
                  if (status == AnimationStatus.completed ||
                      status == AnimationStatus.dismissed) {
                    animationController.dispose();
                  }
                });
                return AppRouterTransitions.slideTransition(
                  key: state.pageKey,
                  child: ComplainDetailsScreen(id : id, type: type,),
                  animation: animationController,
                  begin: begin ?? const Offset(1.0, 0.0),
                );
              },
            ),
          ]
      ),

      GoRoute(
        path: '/:lang/newComplainsScreen',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.newComplainScreen.name,
        pageBuilder: (context, state) {
          Offset? begin = state.extra as Offset?;
          final lang = state.uri.queryParameters['lang'];
          if (lang != null) {
            final locale = Locale(lang);
            context.setLocale(locale);
          }
          final animationController = AnimationController(
            vsync: ticker,
          );
          // Make sure to dispose the controller after the transition is complete
          animationController.addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              animationController.dispose();
            }
          });
          return AppRouterTransitions.slideTransition(
            key: state.pageKey,
            child: NewComplainScreen(),
            animation: animationController,
            begin: begin ?? const Offset(1.0, 0.0),
          );
        },
      ),


    ],
    debugLogDiagnostics: true,
    errorBuilder: (context, state) {
      // Track error screen for Sentry
      final screenName = state.uri.path
          .split('/')
          .last;
      SentryService.setCurrentScreen(screenName);

      // على الويب، عند حدوث خطأ 404، إعادة توجيه إلى splash screen
      if (kIsWeb || PlatformIs.web) {
        try {
          final lang = state.pathParameters['lang'] ??
              ((state.uri.pathSegments.isNotEmpty &&
                  (state.uri.pathSegments.first == 'ar' ||
                      state.uri.pathSegments.first == 'en'))
                  ? state.uri.pathSegments.first
                  : context.locale.languageCode);
          // إعادة التوجيه إلى splash screen
          Future.microtask(() {
            if (context.mounted) {
              try {
                context.go('/$lang/splash-screen');
              } catch (e) {
                debugPrint('Error redirecting to splash: $e');
              }
            }
          });
          return const SplashScreen();
        } catch (e) {
          debugPrint('Error in errorBuilder: $e');
          return const SplashScreen();
        }
      }
      return const NotFoundScreen();
    },
  );
}
