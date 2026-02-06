import 'dart:convert';
import 'package:app_test/features/splash_and_onboarding/data/repo/splash_repo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/general_listener.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/services/app_info_service.dart';
import 'package:app_test/core/services/backend_services/get_endpoint_service.dart';
import 'package:app_test/core/services/device_info_service.dart';
import 'package:app_test/core/services/notification_service/notification_service.dart';
import 'package:app_test/core/models/endpoint.model.dart';
import 'package:app_test/core/routing/app_router.dart';

class OnboardingController extends ChangeNotifier {
  final PageController pageController = PageController();
  final PageController pageController2 = PageController();
  int _currentIndex = 0;
  final SplashRepo _repo;

  OnboardingController({SplashRepo? repo}) : _repo = repo ?? SplashRepo();

  set currentIndex(int newIndex) => _currentIndex = newIndex;
  @override
  void dispose() {
    pageController.dispose();
    pageController2.dispose();
    super.dispose();
  }
  DateTime? safeParseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      final hasArabicNumerals = RegExp(r'[٠-٩]').hasMatch(dateString);
      final normalized = hasArabicNumerals
          ? dateString.replaceAllMapped(RegExp(r'[٠-٩]'), (match) {
        const arabicNumbers = {
          '٠': '0',
          '١': '1',
          '٢': '2',
          '٣': '3',
          '٤': '4',
          '٥': '5',
          '٦': '6',
          '٧': '7',
          '٨': '8',
          '٩': '9',
        };
        return arabicNumbers[match.group(0)]!;
      })
          : dateString;

      return DateTime.parse(normalized);
    } catch (e) {
      debugPrint('Invalid date format: $dateString');
      return null;
    }
  }
  Future<void> _precacheImages(BuildContext context, {int maxItems = 50}) async {
    final gCache = _repo.getCachedGlobalData();
    if (gCache == null) {
      debugPrint('⚠️ _precacheImages: decoded gCache is null');
      return;
    }

    final features = gCache['features']?['items'];
    if (features == null || features is! List || features.isEmpty) {
      debugPrint('⚠️ _precacheImages: no features.items found');
      return;
    }

    // اختياري: لتخفيف الحمل حدد عدد العناصر اللي عايز تعمل لها precache
    final itemsToProcess = features.take(maxItems);

    for (final item in itemsToProcess) {
      try {
        String? image;

        // لو العنصر هو Map (غالب الحالات)
        if (item is Map<String, dynamic>) {
          // جرب تجيب القائمة item['image'] أولاً
          final imagesList = item['image'] as List<dynamic>?;

          if (imagesList != null && imagesList.isNotEmpty) {
            final first = imagesList.first;
            if (first is String) {
              image = first;
            } else if (first is Map && first['file'] != null) {
              image = first['file'].toString();
            }
          }

          // fallback لو في مسار مختلف أو ملف مباشر داخل العنصر
          image ??= (item['file'] as String?) ?? (item['thumbnail'] as String?);
        } else if (item is String) {
          // لو العنصر نفسه String
          image = item;
        }

        if (image == null || image.isEmpty) {
          debugPrint('ℹ️ _precacheImages: no image for item -> $item');
          continue;
        }

        // الآن اعمل precache حسب نوع الصورة
        if (image.startsWith('http') || image.startsWith('https')) {
          await precacheImage(CachedNetworkImageProvider(image), context);
          debugPrint('✅ precached network image: $image');
        } else {
          await precacheImage(AssetImage(image), context);
          debugPrint('✅ precached asset image: $image');
        }
      } catch (e, st) {
        debugPrint('Error precaching image: $e\n$st');
      }
    }
  }

  List? getAllOnboardingData({required BuildContext context}) {
    return _repo.getAllOnboardingData();
  }
  List<Map<String, dynamic>>? _getOnboardingDataFromCache() {
    final gCache = _repo.getCachedGlobalData();
    if (gCache == null) return null;

    final features = gCache['features']?['items'];
    if (features == null || features is! List || features.isEmpty) {
      debugPrint('⚠️ no features.items found');
      return null;
    }

    return features.cast<Map<String, dynamic>>();
  }
  Map<String, dynamic>? getOnboardingDataWithIndex(int index, BuildContext context) {
    final items = _getOnboardingDataFromCache();
    if (items != null && index >= 0 && index < items.length) {
      return items[index];
    }
    return null;
  }

  // var userSettings;
  Future<void> _initializeAppServices(BuildContext context, AppConfigService appConfigService) async {
    try {
      // Precache logo image
      final logoUrl = AppImages.logo;
      if (logoUrl.startsWith('http://') || logoUrl.startsWith('https://')) {
        await precacheImage(CachedNetworkImageProvider(logoUrl), context);
      } else {
        await precacheImage(AssetImage(logoUrl), context);
      }
      debugPrint("done service 1");
      // Initialize application services
      await appConfigService.init();
      // Initialize and set device information in local storage
      debugPrint("done service 2");
      // Set base API URL
      appConfigService.apiURL = AppConstants.baseUrl;
      debugPrint("done service 3");
      // Optional: Enable or disable checking for token expiration
      appConfigService.checkOnTokenExpiration = false;

      // Optional: Set refresh token API URL
      appConfigService.refreshTokenApiUrl =
          AppConstants.refreshTokenBaseUrl;
      debugPrint("done service 4");
      // Optional: Set application name
      appConfigService.appName =
      await ApplicationInformationService.getAppName();
      debugPrint("done service 5");
      // Optional: Set application version
      appConfigService.appVersion =
      await ApplicationInformationService.getAppVersion();
      debugPrint("done service 6");
      // Optional: Set application build number
      appConfigService.buildNumber =
      await ApplicationInformationService.getAppBuildNumber();
      debugPrint("done service 7");
      // Optional: Set application package name
      appConfigService.packageName =
      await ApplicationInformationService.getAppPackageName();
      debugPrint("done service 8");
      // await ConnectionsService.init();
    } catch (e) {
      debugPrint('Error initializing app services: $e');
    }
  }
  Future<List<dynamic>> loadJson() async {
    return await _repo.getRoutes();
  }
  Future<Map<String, dynamic>?> analyzeRoute(String url) async {
    // Decode JSON into an array
    final allRoute = await loadJson();

    // Parse URL and extract path and query parameters
    final uri = Uri.parse(url);
    final path = uri.path.trim().replaceAll(
        RegExp(r'^/|/$'), ''); // Trim leading/trailing slashes
    final queryParams = uri.queryParameters;

    // Iterate through routes to find a match
    for (final route in allRoute) {
      final routePattern = route['route'];

      // Extract placeholder names (e.g., {id})
      final keys = RegExp(r'\{([^\}]+)\}')
          .allMatches(routePattern)
          .map((match) => match.group(1)!)
          .toList();

      // Convert route pattern to regex
      final pattern = '^' +
          routePattern
              .replaceAll(RegExp(r'\{[^\}]+\}'), '([^/]+)')
              .replaceAll('/', r'\/') +
          r'$';

      // Check if the path matches the pattern
      final matches = RegExp(pattern).allMatches(path);
      if (matches.isNotEmpty) {
        final match = matches.first;
        final params = <String, String>{};

        for (var i = 0; i < keys.length; i++) {
          params[keys[i]] = match.group(i + 1)!;
        }

        // Add query parameters to the values
        params.addAll(queryParams);

        // Return the matching route key and parameters
        return {
          'key': route['key'],
          'values': params,
        };
      }
    }
    // Return null if no match is found
    return null;
  }
  Future<void> initializeSplashScreen({required BuildContext context, role}) async {
    final appConfigService = Provider.of<AppConfigService>(context, listen: false);
    try {
      // Ensure AppConfigService is initialized before checking login status
      if (!appConfigService.isInitialized) {
        await appConfigService.init();
      }
      await _initializeAppServices(context, appConfigService);
      String? payload = _repo.getInitialNotificationPayload();
      debugPrint("payload is --> ${payload}");
      if(payload != null && payload.isNotEmpty){
        debugPrint("ANA GY MN PRA");
        await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
        await GeneralListener.linksAction(popup: payload, out: true);
        await _repo.clearInitialNotificationPayload();
      }
      else{
        // Double-check login status after initialization
        final isLoggedIn = appConfigService.isInitialized && appConfigService.isLogin && appConfigService.token.isNotEmpty;
        if (isLoggedIn) {
          try {
            await PushNotificationService.init(
              context: context,
              apiUrlThatReciveUserToken:
              EndpointServices
                  .getApiEndpoint(EndpointsNames.deviceSys)
                  .url,
            );
          } catch (ex) {
            debugPrint(
                'Failed to send notification device token to server $ex');
          }
          getAllOnboardingData(context: context);
          final gCache = _repo.getCachedGlobalData();

          var dateToCheck = safeParseDateTime(_repo.getDateWatchScreen());
          final referenceDate = safeParseDateTime(gCache?['features']?['date']);
          debugPrint("dateWatchScreen is ${_repo.getDateWatchScreen() ?? ""}");
          debugPrint("referenceDate is ${gCache?['features']?['date'] ?? "null"}");

          // Small delay to ensure everything is ready
          await Future.delayed(const Duration(milliseconds: 100));
          if (!context.mounted) return;

          // Check if dateWatchScreen exists and is valid
          final dateWatchScreenValue = _repo.getDateWatchScreen();
          bool shouldShowOnboarding = false;

          // If dateWatchScreen is not set, check if we should show onboarding
          if (dateWatchScreenValue == null || dateWatchScreenValue.isEmpty) {
            shouldShowOnboarding = true;
            debugPrint("dateWatchScreen is empty, will check features");
          }
          // If dateWatchScreen exists, only show onboarding if referenceDate is newer
          else if (dateToCheck != null) {
            if (referenceDate != null && referenceDate.isAfter(dateToCheck)) {
              shouldShowOnboarding = true;
              debugPrint("referenceDate is newer than dateWatchScreen, will show onboarding");
            } else {
              debugPrint("dateWatchScreen is valid and up-to-date, going to home");
            }
          }
          // If we can't parse dateWatchScreen, treat it as if it doesn't exist
          else {
            shouldShowOnboarding = true;
            debugPrint("Cannot parse dateWatchScreen, will check features");
          }

          if (shouldShowOnboarding) {
            await _precacheImages(context);
            if (context.mounted && gCache?['features'] != null &&
                gCache?['features']['items'] != null &&
                (gCache?['features']['items'] as List).isNotEmpty) {
              debugPrint("Navigating to onboarding (logged in)");
              // Check if we're on offline screen before navigating
              try {
                final router = GoRouter.of(context);
                final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                final isOnOfflineScreen = currentLocation.contains('offline-screen');

                if (!isOnOfflineScreen) {
                  context.goNamed(AppRoutes.onboarding.name,
                      pathParameters: {'lang': context.locale.languageCode});
                } else {
                  debugPrint("⚠️ User is on offline screen, skipping navigation to onboarding");
                }
              } catch (e) {
                debugPrint("⚠️ Error checking route before navigation: $e");
                // If we can't check route, don't navigate to avoid issues
              }
            } else {
              debugPrint("Navigating to home (logged in, no features)");
              // Check if we're on offline screen before navigating
              if (context.mounted) {
                try {
                  final router = GoRouter.of(context);
                  final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                  final isOnOfflineScreen = currentLocation.contains('offline-screen');

                  if (!isOnOfflineScreen) {
                    context.goNamed(
                      AppRoutes.home.name,
                      pathParameters: {'lang': context.locale.languageCode},
                    );
                  } else {
                    debugPrint("⚠️ User is on offline screen, skipping navigation to home");
                  }
                } catch (e) {
                  debugPrint("⚠️ Error checking route before navigation: $e");
                  // If we can't check route, don't navigate to avoid issues
                }
              }
            }
          } else {
            debugPrint("Navigating to home (logged in, dateWatchScreen is newer)");
            // Check if we're on offline screen before navigating
            if (context.mounted) {
              try {
                final router = GoRouter.of(context);
                final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                final isOnOfflineScreen = currentLocation.contains('offline-screen');

                if (!isOnOfflineScreen) {
                  context.goNamed(
                    AppRoutes.home.name,
                    pathParameters: {'lang': context.locale.languageCode},
                  );
                } else {
                  debugPrint("⚠️ User is on offline screen, skipping navigation to home");
                }
              } catch (e) {
                debugPrint("⚠️ Error checking route before navigation: $e");
                // If we can't check route, don't navigate to avoid issues
              }
            }
          }
          return;
        }
        else {
          // User is not logged in - navigate to login or onboarding
          debugPrint("WATCH 0 - User not logged in");
          final cache = _repo.getCachedGlobalData();

          final features = cache?['features']?['items'];
          debugPrint("WATCH 1 - Features: ${features != null ? features.length : 'null'}");

          final gCache = _repo.getCachedGlobalData();
          DateTime? dateToCheck;
          DateTime? referenceDate;
          debugPrint("WATCH 2");

          if (gCache != null) {
            if (gCache['features']?['date'] != null) {
              referenceDate = safeParseDateTime(gCache['features']['date']);
            }
          }

          debugPrint("WATCH IN1 ${_repo.getDateWatchScreen()}");

          if (_repo.getDateWatchScreen() != null &&
              _repo.getDateWatchScreen() != "") {
            dateToCheck = safeParseDateTime(_repo.getDateWatchScreen());
          }

          // Check if we should show onboarding or login
          bool shouldShowOnboarding = false;

          // Check if features exist and are not empty
          if (features != null && features is List && features.isNotEmpty) {
            final dateWatchScreen = _repo.getDateWatchScreen();

            // If dateWatchScreen is not set, show onboarding
            if (dateWatchScreen == null || dateWatchScreen.isEmpty) {
              shouldShowOnboarding = true;
              debugPrint("WATCH: dateWatchScreen is empty, showing onboarding");
            }
            // If dateWatchScreen exists, check if it's older than reference date
            else if (dateToCheck != null && referenceDate != null) {
              if (dateToCheck.isBefore(referenceDate)) {
                shouldShowOnboarding = true;
                debugPrint("WATCH: dateWatchScreen is older, showing onboarding");
              } else {
                debugPrint("WATCH: dateWatchScreen is newer, going to login");
              }
            }
            // If we can't parse dates, default to onboarding
            else {
              shouldShowOnboarding = true;
              debugPrint("WATCH: Cannot parse dates, defaulting to onboarding");
            }
          } else {
            debugPrint("WATCH: No features found, going to login");
          }

          debugPrint("WATCH: shouldShowOnboarding = $shouldShowOnboarding");

          // Navigate - ensure context is ready
          if (!context.mounted) return;

          // Small delay to ensure everything is initialized
          await Future.delayed(const Duration(milliseconds: 100));

          if (!context.mounted) return;

          if (shouldShowOnboarding) {
            debugPrint("Navigating to onboarding");
            await _precacheImages(context);
            // Check if we're on offline screen before navigating
            if (context.mounted) {
              try {
                final router = GoRouter.of(context);
                final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                final isOnOfflineScreen = currentLocation.contains('offline-screen');

                if (!isOnOfflineScreen) {
                  context.goNamed(AppRoutes.onboarding.name,
                      pathParameters: {'lang': context.locale.languageCode});
                } else {
                  debugPrint("⚠️ User is on offline screen, skipping navigation to onboarding");
                }
              } catch (e) {
                debugPrint("⚠️ Error checking route before navigation: $e");
                // If we can't check route, don't navigate to avoid issues
              }
            }
          } else {
            debugPrint("Navigating to login");
            // Check if we're on offline screen before navigating
            if (context.mounted) {
              try {
                final router = GoRouter.of(context);
                final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                final isOnOfflineScreen = currentLocation.contains('offline-screen');

                if (!isOnOfflineScreen) {
                  context.goNamed(
                    AppRoutes.login.name,
                    pathParameters: {'lang': context.locale.languageCode},
                  );
                } else {
                  debugPrint("⚠️ User is on offline screen, skipping navigation to login");
                }
              } catch (e) {
                debugPrint("⚠️ Error checking route before navigation: $e");
                // If we can't check route, don't navigate to avoid issues
              }
            }
          }
        }
      }
    } catch (err) {
      debugPrint("login-5");
      // Check if we're on offline screen before navigating
      try {
        final router = GoRouter.of(context);
        final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
        final isOnOfflineScreen = currentLocation.contains('offline-screen');

        if (!isOnOfflineScreen) {
          return context.goNamed(
            AppRoutes.login.name,
            pathParameters: {'lang': context.locale.languageCode},
          );
        } else {
          debugPrint("⚠️ User is on offline screen, skipping navigation to login (error case)");
          return;
        }
      } catch (e) {
        debugPrint("⚠️ Error checking route before navigation: $e");
        // If we can't check route, don't navigate to avoid issues
        return;
      }
    }
  }
  void goNext(BuildContext context) {
    const int duration = 500;
    final items = getAllOnboardingData(context: context);

    if (items != null && _currentIndex < items.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: duration),
        curve: Curves.easeInOut,
      );
      pageController2.nextPage(
        duration: const Duration(milliseconds: duration),
        curve: Curves.easeInOut,
      );
      currentIndex = _currentIndex + 1;
    } else {
      final appConfigService =
      Provider.of<AppConfigService>(context, listen: false);
      final jsonString = CacheHelper.getString("US1");
      var us1Cache;
      if (jsonString != "") {
        us1Cache = json.decode(jsonString) as Map<String,
            dynamic>; // Convert String back to JSON
        debugPrint("S2 IS --> $us1Cache");
      }
      if (appConfigService.isLogin && appConfigService.token.isNotEmpty) {
        // Check if we're on offline screen before navigating
        try {
          final router = GoRouter.of(context);
          final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
          final isOnOfflineScreen = currentLocation.contains('offline-screen');

          if (!isOnOfflineScreen) {
            context.goNamed(
              AppRoutes.home.name,
              pathParameters: {'lang': context.locale.languageCode,},
            );
          } else {
            debugPrint("⚠️ User is on offline screen, skipping navigation to home (goNext)");
          }
        } catch (e) {
          debugPrint("⚠️ Error checking route before navigation: $e");
          // If we can't check route, don't navigate to avoid issues
        }
      } else {
        // Check if we're on offline screen before navigating
        try {
          final router = GoRouter.of(context);
          final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
          final isOnOfflineScreen = currentLocation.contains('offline-screen');

          if (!isOnOfflineScreen) {
            context.goNamed(
              AppRoutes.login.name,
              pathParameters: {'lang': context.locale.languageCode,},
            );
          } else {
            debugPrint("⚠️ User is on offline screen, skipping navigation to login (goNext)");
          }
        } catch (e) {
          debugPrint("⚠️ Error checking route before navigation: $e");
          // If we can't check route, don't navigate to avoid issues
        }
      }
    }
  }

  void skip(BuildContext context) {
    final appConfigService =
    Provider.of<AppConfigService>(context, listen: false);
    // Check if we're on offline screen before navigating
    try {
      final router = GoRouter.of(context);
      final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
      final isOnOfflineScreen = currentLocation.contains('offline-screen');

      if (isOnOfflineScreen) {
        debugPrint("⚠️ User is on offline screen, skipping navigation (skip)");
        return;
      }
    } catch (e) {
      debugPrint("⚠️ Error checking route before navigation: $e");
      // If we can't check route, don't navigate to avoid issues
      return;
    }

    if (appConfigService.isLogin && appConfigService.token.isNotEmpty) {
      context.goNamed(
        AppRoutes.home.name,
        pathParameters: {'lang': context.locale.languageCode,},
      );
    } else {
      context.goNamed(
        AppRoutes.login.name,
        pathParameters: {'lang': context.locale.languageCode,
        },
      );
    }
  }
}
