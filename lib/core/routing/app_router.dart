import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/complaints/views/complain_details_screen.dart';
import 'package:app_test/features/complaints/views/complains_screen.dart';
import 'package:app_test/features/more/views/aboutus/views/aboutus_screen.dart';
import 'package:app_test/features/more/views/company_structure/company_structure_screen.dart';
import 'package:app_test/features/more/views/contactus/views/contact_screen.dart';
import 'package:app_test/features/more/views/faq/views/faq_screen.dart';
import 'package:app_test/features/more/views/lang_setting/lang_setting_screen.dart';
import 'package:app_test/features/more/views/notification/views/add_notification_screen.dart';
import 'package:app_test/features/more/views/notification/views/notification_details_screen.dart';
import 'package:app_test/features/more/views/notification/views/notification_screen.dart';
import 'package:app_test/features/complaints/views/add_complain_screen.dart';
import 'package:app_test/features/more/views/update_password/update_password_screen.dart';
import 'package:app_test/features/pages/default_list_page.dart';
import 'package:app_test/core/services/app_config.service.dart';
import 'package:app_test/features/authentication/views/login_screen.dart';
import 'package:app_test/features/authentication/views/update_main_data.dart';
import 'package:app_test/features/home/views/home_screen.dart';
import 'package:app_test/features/main_screen/views/main_screen.dart';
import 'package:app_test/features/more/views/company_structure/views/company_structure_tree_screen.dart';
import 'package:app_test/features/more/views/more_screen.dart';
import 'package:app_test/features/more/views/user_devices/user_devices_screen.dart';
import 'package:app_test/features/offline/views/offline_screen.dart';
import 'package:app_test/features/pages/default_page.dart';
import 'package:app_test/features/pages/default_details.dart';
import 'package:app_test/features/personal_profile/views/personal_profile_screen.dart';
import 'package:app_test/features/points/fawry_view/fawry_provider_screen.dart';
import 'package:app_test/features/points/points_categories_screen.dart';
import 'package:app_test/features/points/points_screen.dart';
import 'package:app_test/features/points/prize_screen.dart';
import 'package:app_test/features/points/widgets/select_contact_screen.dart';
import 'package:app_test/features/splash_and_onboarding/views/onboarding_screen.dart';
import 'package:app_test/features/splash_and_onboarding/views/splash_screen.dart';
import 'app_router_transitions.dart';
import 'not_found/not_found_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum AppRoutes {
  home,
  splash,
  onboarding,
  fingerprintView,
  teamFingerprint,
  defaultSinglePage,
  defaultListPage,
  defaultPage,
  login,
  webViewMainDataScreen,
  webViewScreen,
  fawryProviderScreen,
  CategoriesprizePointsViewScreen,
  prizePointsViewScreen,
  pointsContactScreenView,
  pointsScreenView,
  userDevices,
  offlineScreen,
  complainDetails,
  complainScreen,
  taskDetails,
  qrcodeScreen,
  notification,
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
  newRequestScreen,
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

enum NavbarPages { home, requests, fingerprint, notifications, more }

NavbarPages getNavbarPage({required String currentLocationRoute}) {
  if (currentLocationRoute.contains('requests')) {
    return NavbarPages.requests;
  }
  if (currentLocationRoute.contains('fingerprint')) {
    return NavbarPages.fingerprint;
  }
  if (currentLocationRoute.contains('notifications')) {
    return NavbarPages.notifications;
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
        // ConnectionService removed from refreshListenable to prevent router refresh
        // Offline handling is done via overlay, not navigation
      ]),
  redirect: (context, state) {
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    final isLoggedIn = appConfigServiceProvider.isLogin && appConfigServiceProvider.token.isNotEmpty;
    
    // Extract lang from current state
    String lang = 'en';
    if (state.pathParameters['lang'] != null) {
      lang = state.pathParameters['lang']!;
    }
    
    // Set locale only if it's a valid locale
    try {
      if (lang == 'en' || lang == 'ar') {
        context.setLocale(Locale(lang));
      }
    } catch (e) {
      debugPrint('Error setting locale: $e');
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
                  child:  const HomeScreen(),
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
                    path: 'points-screen',
                    parentNavigatorKey: rootNavigatorKey,
                    name: AppRoutes.pointsScreenView.name,
                    builder: (context, state) => PointsScreen(arrow: true,),
                    routes: [
                      GoRoute(
                          path: 'pointsContactScreenView',
                          parentNavigatorKey: rootNavigatorKey,
                          name: AppRoutes.pointsContactScreenView.name,
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
                              child: const ContactSelectionScreen(),
                              animation: animationController,
                              begin: begin ?? const Offset(1.0, 0.0),
                            );
                          },
                          routes: const [

                          ]
                      ),
                      GoRoute(
                          path: 'prize-point-screen/:id',
                          parentNavigatorKey: rootNavigatorKey,
                          name: AppRoutes.prizePointsViewScreen.name,
                          pageBuilder: (context, state) {
                            final lang = state.uri.queryParameters['lang'];
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
                              child: const PointsCategoriesScreen(true,),
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
                                  child: const FawryProviderScreen(),
                                  animation: animationController,
                                  begin: const Offset(1.0, 0.0),
                                );
                              },
                            ),
                            // GoRoute(
                            //   path: 'billPaymentScreen',
                            //   parentNavigatorKey: rootNavigatorKey,
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
                            //   parentNavigatorKey: rootNavigatorKey,
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
                            //   parentNavigatorKey: rootNavigatorKey,
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
                            //   parentNavigatorKey: rootNavigatorKey,
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
                      child:  const ContactScreen(),
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
                        path: 'newRequestScreens',
                        parentNavigatorKey: rootNavigatorKey,
                        name: AppRoutes.newRequestScreen.name,
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
                            child: const NewComplainScreen(),
                            animation: animationController,
                            begin: begin ?? const Offset(1.0, 0.0),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'complainDetailsScreen/:id',
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
                            child: ComplainDetailsScreen(id : id),
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
              child: const WebViewStackMainData(),
              animation: animationController,
              begin: begin ?? const Offset(1.0, 0.0),
            );
          },
        ),
      ],
      debugLogDiagnostics: true,
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
