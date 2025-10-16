import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/modules/complain_screen/complain_details_screen.dart';
import 'package:rmemp/modules/complain_screen/complains_screen.dart';
import 'package:rmemp/modules/evaluation/evaluation_screen.dart';
import 'package:rmemp/modules/fingerprint/views/finger_print_offilen.dart';
import 'package:rmemp/modules/fingerprint/views/finger_print_view_screen.dart';
import 'package:rmemp/modules/more/views/aboutus/view/aboutus_screen.dart';
import 'package:rmemp/modules/more/views/blog/view/blog_details_screen.dart';
import 'package:rmemp/modules/more/views/blog/view/blog_screen.dart';
import 'package:rmemp/modules/more/views/company_structure/company_structure_screen.dart';
import 'package:rmemp/modules/more/views/contactus/view/contact_screen.dart';
import 'package:rmemp/modules/more/views/faq/view/faq_screen.dart';
import 'package:rmemp/modules/more/views/lang_setting/lang_setting_screen.dart';
import 'package:rmemp/modules/more/views/notification/view/add_notification_screen.dart';
import 'package:rmemp/modules/more/views/notification/view/notification_details_screen.dart';
import 'package:rmemp/modules/more/views/notification/view/notification_screen.dart';
import 'package:rmemp/modules/complain_screen/add_complain_screen.dart';
import 'package:rmemp/modules/more/views/team_fingerprint/view/team_fingerprint_screen.dart';
import 'package:rmemp/modules/more/views/update_password/update_password_screen.dart';
import 'package:rmemp/modules/pages/default_list_page.dart';
import 'package:rmemp/modules/tasks/add_task_screen.dart';
import 'package:rmemp/modules/tasks/edit_task_screen.dart';
import 'package:rmemp/modules/tasks/task_details_screen.dart';
import 'package:rmemp/modules/tasks/task_screen.dart';
import '../constants/internet_check.dart';
import '../constants/user_consts.dart';
import '../general_services/app_config.service.dart';
import '../models/settings/user_settings.model.dart';
import '../modules/authentication/views/login_screen.dart';
import '../modules/authentication/views/update_main_data.dart';
import '../modules/evaluation/evaluation_require_screen.dart';
import '../modules/fingerprint/views/fingerprint_screen.dart';
import '../modules/general/views/company_structure_tree_screen.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/home/views/widgets/webview_offers.dart';
import '../modules/main_screen/views/main_screen.dart';
import '../modules/more/views/more_screen.dart';
import '../modules/more/views/user_devices/user_devices_screen.dart';
import '../modules/offline/views/offline_screen.dart';
import '../modules/pages/default_page.dart';
import '../modules/pages/default_details.dart';
import '../modules/payrolls/models/payroll.model.dart';
import '../modules/payrolls/views/payroll_details_screen.dart';
import '../modules/payrolls/views/payrolls_list_screen.dart';
import '../modules/personal_profile/views/personal_profile_screen.dart';
import '../modules/profiles/views/employee_details_screen.dart';
import '../modules/profiles/views/employees_list_screen.dart';
import '../modules/requests/views/add_request_screen.dart';
import '../modules/requests/views/request_details_screen.dart';
import '../modules/requests/views/requests_screen.dart';
import '../modules/requests/views/requests_by_id_screen.dart';
import '../modules/rewards_and_penalties/views/add_rewards_and_penalties_screen.dart';
import '../modules/rewards_and_penalties/views/rewards_and_penalties_screen.dart';
import '../modules/splash_and_onboarding/views/onboarding_screen.dart';
import '../modules/splash_and_onboarding/views/splash_screen.dart';
import '../routing/app_router_transitions.dart';
import '../routing/not_found/not_found_screen.dart';
import '../services/requests.services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../modules/requests/views/requests_calendar_screen.dart';

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
  notificationDetails
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

GoRouter goRouter(BuildContext context) => GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/${context.locale.languageCode}/splash-screen',
      refreshListenable: Listenable.merge([
        Provider.of<AppConfigService>(context),
        Provider.of<ConnectionService>(context), // 🆕 نسمع للاتصال
      ]),
  redirect: (context, state) {
    final connectionService = Provider.of<ConnectionService>(context, listen: false);
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    final isLoggedIn = appConfigServiceProvider.isLogin && appConfigServiceProvider.token.isNotEmpty;
    final lang = state.pathParameters['lang'] ?? 'en';
    context.setLocale(Locale(lang));

    // 🌐 Offline redirection (instant, no await)
    if (!connectionService.isConnected &&
        !(state.fullPath?.contains('offline') ?? false)) {
      return '/$lang/offline-screen';
    }

    if (isLoggedIn && state.fullPath?.contains('login') == true) {
      var update = CacheHelper.getString("update_url");
      if (update != null && update.isNotEmpty && update != "") {
        return '/$lang/webviewMainData';
      }
      return '/$lang';
    }

    if (!isLoggedIn &&
        !(state.fullPath?.contains('splash') == true ||
            state.fullPath?.contains('offline') == true ||
            state.fullPath?.contains('onboarding-screen') == true)) {
      return '/$lang/login-screen';
    }

    return null;
  },

  routes: [
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainScreen(
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
                    List requests = state.extra != null ? state.extra as List : [];
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
                    List requests = state.extra != null ? state.extra as List : [];
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
                    Offset? begin = (state.extra as Map<String, dynamic>)['offset'] as Offset?;
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
                  child: FingerprintScreen(),
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
                      child: FingerprintOfflineScreen(),
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
                  child: NotificationScreen(false),
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
                        child: FingerPrintViewScreen(empId: id,empName: name,),
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
                      child: WebViewStack(),
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
                      child: UpdatePasswordScreen(),
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
                      child: AboutUsScreen(),
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
                      child: FaqScreen(),
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
                      child:  ContactScreen(),
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
                    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
                      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
                    }
                    print("ID CACHE IS --> ${CacheHelper.getInt("id").toString()}");
                    final extra = state.extra as Map<String, dynamic>?;
                    final empId = extra?["empId"] ?? gCache['employee_profile_id'].toString();
                    final begin = extra?["begin"] as Offset? ?? const Offset(1.0, 0.0);
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
                      child: EvaluationScreen( empId: empId,),
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
          builder: (context, state) => NotificationScreen(true),
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
          builder: (context, state) => UserDeviceScreen(),
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
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
