import 'dart:async';
import 'dart:convert';

import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/features/company_structure/views/company_structure_tree_screen.dart';
import 'package:app_test/features/complaints/views/add_complaints/add_complain_screen.dart';
import 'package:app_test/features/employee_profiles/views/employee_details_screen.dart';
import 'package:app_test/features/employee_profiles/views/employees_list_screen.dart';
import 'package:app_test/features/home/views/home_screen.dart';
import 'package:app_test/features/more/notifications/views/notification_screen.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';
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
import '../../features/more/notifications/views/widgets/add_notifications/add_notification_screen.dart';
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
import '../../features/services/views/free_service/views/widgets/about_team_mind_screen.dart';
import '../../features/services/views/free_service/views/widgets/cv_generator_screen.dart';
import '../../features/services/views/cvs/views/my_cv_screen.dart';
import '../../features/services/views/free_service/views/widgets/personality_test_screen.dart';
import '../../features/services/views/free_service/views/widgets/premium_templates_screen.dart';
import '../../features/services/views/free_service/views/widgets/smart_card/widgets/select_template_screen.dart';
import '../../features/services/views/smart_card/smart_card_screen.dart';
import '../../features/services/views/shared/ui_widgets/update_my_info_screen.dart';
import '../../features/services/views/free_service/views/widgets/vacation_calc_screen.dart';
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
  home,
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
  complainScreen,
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
  newRequestScreen
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
        'onboarding-screen',
        'login',
        'free-services',
        'my-cv',
        'cv-generator',
        'smart-card',
        'update-my-info',
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
                  final slug = state.pathParameters['slug'] ?? '';

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
              // GoRoute(
              //   path: 'free-services-home',
              //   parentNavigatorKey: rootNavigatorKey,
              //   name: AppRoutes.freeServicesHome.name,
              //   pageBuilder: (context, state) {
              //     final lang = state.uri.queryParameters['lang'];
              //     if (lang != null) {
              //       final locale = Locale(lang);
              //       context.setLocale(locale);
              //     }
              //     final animationController = AnimationController(
              //       vsync: ticker,
              //     );
              //     animationController.addStatusListener((status) {
              //       if (status == AnimationStatus.completed ||
              //           status == AnimationStatus.dismissed) {
              //         animationController.dispose();
              //       }
              //     });
              //     return AppRouterTransitions.slideTransition(
              //       key: state.pageKey,
              //       child: const FreeServicesHomeScreen(),
              //       animation: animationController,
              //       begin: const Offset(1.0, 0.0),
              //     );
              //   },
              // ),
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
                    begin: begin ?? const Offset(1.0, 0.0),
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
                      child: const ComplainScreen(),
                      animation: animationController,
                      begin: begin ?? const Offset(1.0, 0.0),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'requestDetailsScreen/:id',
                      parentNavigatorKey: rootNavigatorKey,
                      name: AppRoutes.requestDetails.name,
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
                          child: ComplainDetailsScreen(id: id),
                          animation: animationController,
                          begin: begin ?? const Offset(1.0, 0.0),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'newRequestScreens/:type/:subject/:details',
                      parentNavigatorKey: rootNavigatorKey,
                      name: AppRoutes.newRequestScreen.name,
                      pageBuilder: (context, state) {
                        Offset? begin = state.extra as Offset?;
                        final lang = state.uri.queryParameters['lang'];
                        final type = state.uri.queryParameters['type'] ?? '';
                        final details = state.uri.queryParameters['details'] ??
                            '';
                        final subject = state.uri.queryParameters['subject'] ??
                            '';
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
                          child: NewComplainScreen(type, subject, details),
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
            child: const LangSettingScreens(),
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
          routes: [
            GoRoute(
              path: 'add-notification',
              parentNavigatorKey: rootNavigatorKey,
              name: AppRoutes.addNotification.name,
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
                  child: const AddNotificationScreen(),
                  animation: animationController,
                  begin: begin ?? const Offset(1.0, 0.0),
                );
              },
            ),
          ]
      ),
      GoRoute(
        path: '/:lang/notification-details-screen/:id',
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.notificationDetails.name,
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
            child: NotificationDetailsScreen(
              id: id,
            ),
            animation: animationController,
            begin: begin ?? const Offset(1.0, 0.0),
          );
        },
      ),
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
          final title = state.pathParameters['title'] ?? '';
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