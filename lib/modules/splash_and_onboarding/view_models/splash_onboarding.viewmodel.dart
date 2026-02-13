import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_codes/country_codes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/modules/home/view_models/home.viewmodel.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_images.dart';
import '../../../constants/cache_consts.dart';
import '../../../constants/general_listener.dart';
import '../../../constants/settings/default_general_settings.dart';
import '../../../general_services/app_config.service.dart';
import '../../../general_services/app_info.service.dart';
import '../../../general_services/backend_services/get_endpoint.service.dart';
import '../../../general_services/connections.service.dart';
import '../../../general_services/device_info.service.dart';
import '../../../general_services/notification_service/notification.service.dart';
import '../../../models/endpoint.model.dart';
import '../../../models/settings/general_settings.model.dart';
import '../../../routing/app_router.dart';

class OnboardingViewModel extends ChangeNotifier {
  final PageController pageController = PageController();
  final PageController pageController2 = PageController();
  int _currentIndex = 0;

  set currentIndex(int newIndex) => _currentIndex = newIndex;

  /// من كاش US1: لو role = ["personal"] فقط → freeServicesHome، وإلا → home
  static String getHomeRouteFromUs1Role() {
    final jsonString = CacheHelper.getString("US1");
    if (jsonString == null || jsonString.isEmpty) return AppRoutes.home.name;
    try {
      final us1 = json.decode(jsonString) as Map<String, dynamic>?;
      final role = us1?['role'];
      if (role != null && role is List && role.isNotEmpty && role.contains("personal")) {
        return AppRoutes.freeServicesHome.name;
      }
      return AppRoutes.home.name;
    } catch (_) {
      return AppRoutes.home.name;
    }
  }

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
    final jsonString = CacheHelper.getString("USG");
    if (jsonString == null || jsonString.isEmpty) {
      debugPrint('⚠️ _precacheImages: USG cache empty');
      return;
    }

    final gCache = json.decode(jsonString) as Map<String, dynamic>?;
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

  /// Default onboarding slides when API returns no images (3 local assets).
  static List<Map<String, dynamic>> get _defaultOnboardingItems => [
        {
          'title': {'ar': 'مرحباً', 'en': 'Welcome'},
          'info': {'ar': 'اكتشف الميزات', 'en': 'Discover the features'},
          'image': [
            {'id': 1, 'file': AppImages.onboardingFallback1}
          ],
          'web_image': [
            {'id': 1, 'file': AppImages.onboardingFallback1}
          ],
        },
        {
          'title': {'ar': 'سهل وسريع', 'en': 'Easy & Fast'},
          'info': {'ar': 'إدارة بسيطة', 'en': 'Simple management'},
          'image': [
            {'id': 1, 'file': AppImages.onboardingFallback2}
          ],
          'web_image': [
            {'id': 1, 'file': AppImages.onboardingFallback2}
          ],
        },
        {
          'title': {'ar': 'ابدأ الآن', 'en': 'Get Started'},
          'info': {'ar': 'انضم إلينا', 'en': 'Join us'},
          'image': [
            {'id': 1, 'file': AppImages.onboardingFallback3}
          ],
          'web_image': [
            {'id': 1, 'file': AppImages.onboardingFallback3}
          ],
        },
      ];

  /// نفس مصدر _getOnboardingDataFromCache عشان الـ itemCount يطابق المحتوى (مع التحقق من title/info/image).
  List? getAllOnboardingData({required BuildContext context}) {
    return _getOnboardingDataFromCache();
  }

  /// قيمة غير فاضية: مش null ومش سترينج فاضي.
  static bool _hasValue(dynamic v) =>
      v != null && v.toString().trim().isNotEmpty;

  /// الاسكرينه تتلغي (العنصر يتتجاهل) فقط في حالة واحدة:
  /// title (عربي وانجليزي) كلهم null + info (عربي وانجليزي) كلهم null + الصور فاضية.
  /// غير كده نعرض الشريحة: لو title فاضي نعرض الانفو أو الصور اللي راجعة.
  static bool _isOnboardingItemValid(Map<String, dynamic> item) {
    final title = item['title'];
    final info = item['info'];
    final imageList = item['image'];
    final webImageList = item['web_image'];
    final hasTitle = title is Map && (_hasValue(title['ar']) || _hasValue(title['en']));
    final hasInfo = info is Map && (_hasValue(info['ar']) || _hasValue(info['en']));
    final hasImage = kIsWeb
        ? (webImageList is List && webImageList.isNotEmpty)
        : (imageList is List && imageList.isNotEmpty);
    final valid = hasTitle || hasInfo || hasImage;
    return valid;
  }

  List<Map<String, dynamic>>? _getOnboardingDataFromCache() {
    final jsonString = CacheHelper.getString("USG");
    if (jsonString == null || jsonString.isEmpty) {
      debugPrint('⚠️ Onboarding cache empty, using default 3 images');
      return _defaultOnboardingItems;
    }

    final gCache = json.decode(jsonString) as Map<String, dynamic>?;
    if (gCache == null) return _defaultOnboardingItems;

    final features = gCache['features']?['items'];
    if (features == null || features is! List || features.isEmpty) {
      debugPrint('⚠️ No features.items from API, using default 3 onboarding images');
      return _defaultOnboardingItems;
    }

    final list = features.cast<Map<String, dynamic>>();
    final validList = list.where(_isOnboardingItemValid).toList();
    if (validList.isEmpty) {
      debugPrint('⚠️ Onboarding: كل العناصر فاضية (title+info+image كلهم null/فاضي) → متعرضش الشاشة');
      return [];
    }
    debugPrint('✅ Onboarding: ${validList.length} شريحة صالحة');
    return validList;
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
        print("done service 1");
        // Initialize application services
        await appConfigService.init();
        // Initialize and set device information in local storage
        print("done service 2");
        // Set base API URL
        appConfigService.apiURL = AppConstants.baseUrl;
        print("done service 3");
        // Optional: Enable or disable checking for token expiration
        appConfigService.checkOnTokenExpiration = false;

        // Optional: Set refresh token API URL
        appConfigService.refreshTokenApiUrl =
            AppConstants.refreshTokenBaseUrl;
        print("done service 4");
        // Optional: Set application name
        appConfigService.appName =
        await ApplicationInformationService.getAppName();
        print("done service 5");
        // Optional: Set application version
        appConfigService.appVersion =
        await ApplicationInformationService.getAppVersion();
        print("done service 6");
        // Optional: Set application build number
        appConfigService.buildNumber =
        await ApplicationInformationService.getAppBuildNumber();
        print("done service 7");
        // Optional: Set application package name
        appConfigService.packageName =
        await ApplicationInformationService.getAppPackageName();
        print("done service 8");
        // await ConnectionsService.init();
      } catch (e) {
        debugPrint('Error initializing app services: $e');
      }
    }
    Future<List<dynamic>> loadJson() async {
      const filepath = 'assets/json/routes.json';
      final content = await rootBundle.loadString(filepath);
      return jsonDecode(content);
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
      final appConfigService =
      Provider.of<AppConfigService>(context, listen: false);
      late final HomeViewModel homeViewModel;
      homeViewModel = HomeViewModel();
      try {
        // Ensure AppConfigService is initialized before checking login status
        if (!appConfigService.isInitialized) {
          await appConfigService.init();
        }
        await _initializeAppServices(context, appConfigService);
        String? payload = CacheHelper.getString('initialNotification');
        print("payload is --> ${payload}");
        if(payload != null && payload.isNotEmpty){
          print("ANA GY MN PRA");
          await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
          await GeneralListener.linksAction(popup: payload, out: true);
          await CacheHelper.setString(key: 'initialNotification',value: '');
        }
        else{
          // Double-check login status after initialization
          final isLoggedIn = appConfigService.isInitialized && 
                            appConfigService.isLogin && 
                            appConfigService.token.isNotEmpty;
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
            final features = getAllOnboardingData(context: context);
            final jsonString = CacheHelper.getString("USG");
            var gCache;
            if (jsonString != null && jsonString != "") {
              gCache = json.decode(jsonString) as Map<String, dynamic>;
            }
            var dateToCheck = safeParseDateTime(CacheHelper.getString("dateWatchScreen"));
            final referenceDate = safeParseDateTime(gCache?['features']?['date']);
            print("dateWatchScreen is ${CacheHelper.getString("dateWatchScreen") ?? ""}");
            print("referenceDate is ${gCache?['features']?['date'] ?? "null"}");
            
            // Small delay to ensure everything is ready
            await Future.delayed(const Duration(milliseconds: 100));
            if (!context.mounted) return;
            
            // Check if dateWatchScreen exists and is valid
            final dateWatchScreenValue = CacheHelper.getString("dateWatchScreen");
            bool shouldShowOnboarding = false;
            
            // If dateWatchScreen is not set, check if we should show onboarding
            if (dateWatchScreenValue == null || dateWatchScreenValue.isEmpty) {
              shouldShowOnboarding = true;
              print("dateWatchScreen is empty, will check features");
            } 
            // If dateWatchScreen exists, only show onboarding if referenceDate is newer
            else if (dateToCheck != null) {
              if (referenceDate != null && referenceDate.isAfter(dateToCheck)) {
                shouldShowOnboarding = true;
                print("referenceDate is newer than dateWatchScreen, will show onboarding");
              } else {
                print("dateWatchScreen is valid and up-to-date, going to home");
              }
            }
            // If we can't parse dateWatchScreen, treat it as if it doesn't exist
            else {
              shouldShowOnboarding = true;
              print("Cannot parse dateWatchScreen, will check features");
            }
            
            if (shouldShowOnboarding) {
              await _precacheImages(context);
              final onboardingItems = getAllOnboardingData(context: context);
              final hasValidSlides = onboardingItems != null && onboardingItems.isNotEmpty;
              if (context.mounted && hasValidSlides) {
                print("Navigating to onboarding (logged in)");
                // Check if we're on offline screen before navigating
                try {
                  final router = GoRouter.of(context);
                  final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                  final isOnOfflineScreen = currentLocation.contains('offline-screen');
                  
                  if (!isOnOfflineScreen) {
                    context.goNamed(AppRoutes.onboarding.name,
                        pathParameters: {'lang': context.locale.languageCode});
                  } else {
                    print("⚠️ User is on offline screen, skipping navigation to onboarding");
                  }
                } catch (e) {
                  debugPrint("⚠️ Error checking route before navigation: $e");
                  // If we can't check route, don't navigate to avoid issues
                }
              } else {
                print("Navigating to home (logged in, no valid onboarding slides)");
                // Check if we're on offline screen before navigating
                if (context.mounted) {
                  try {
                    final router = GoRouter.of(context);
                    final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                    final isOnOfflineScreen = currentLocation.contains('offline-screen');
                    
                    if (!isOnOfflineScreen) {
                      final route = getHomeRouteFromUs1Role();
                      print("✅ Navigating to: $route");
                      context.goNamed(
                        route,
                        pathParameters: {'lang': context.locale.languageCode},
                      );
                    } else {
                      print("⚠️ User is on offline screen, skipping navigation to home");
                    }
                  } catch (e) {
                    debugPrint("⚠️ Error checking route before navigation: $e");
                    // If we can't check route, don't navigate to avoid issues
                  }
                }
              }
            } else {
              print("Navigating to home (logged in, dateWatchScreen is newer)");
              // Check if we're on offline screen before navigating
              if (context.mounted) {
                try {
                  final router = GoRouter.of(context);
                  final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                  final isOnOfflineScreen = currentLocation.contains('offline-screen');
                  
                  if (!isOnOfflineScreen) {
                    final route = getHomeRouteFromUs1Role();
                    print("✅ Navigating to: $route");
                    context.goNamed(
                      route,
                      pathParameters: {'lang': context.locale.languageCode},
                    );
                  } else {
                    print("⚠️ User is on offline screen, skipping navigation to home");
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
            // إعادة التأكد من اللوجين قبل التوجيه للوجين (تجنب فتح اللوجين بسبب race في التهيئة)
            await appConfigService.init();
            final recheckLoggedIn = appConfigService.isInitialized &&
                appConfigService.isLogin &&
                appConfigService.token.isNotEmpty;
            if (recheckLoggedIn) {
              if (!context.mounted) return;
              final route = getHomeRouteFromUs1Role();
              context.goNamed(route, pathParameters: {'lang': context.locale.languageCode});
              return;
            }
            // User is not logged in - navigate to login or onboarding
            print("WATCH 0 - User not logged in");
            final jsonString2 = CacheHelper.getString("USG");
            var cache;
            if (jsonString2 != null && jsonString2.isNotEmpty) {
              try {
                cache = json.decode(jsonString2) as Map<String, dynamic>;
              } catch (e) {
                debugPrint('Error decoding USG cache: $e');
                cache = null;
              }
            }
            
            final features = cache?['features']?['items'];
            print("WATCH 1 - Features: ${features != null ? features.length : 'null'}");
            
            final jsonString = CacheHelper.getString("USG");
            var gCache;
            DateTime? dateToCheck;
            DateTime? referenceDate;
            print("WATCH 2");
            
            if (jsonString != null && jsonString != "") {
              try {
                gCache = json.decode(jsonString) as Map<String, dynamic>;
                if (gCache['features']?['date'] != null) {
                  referenceDate = safeParseDateTime(gCache['features']['date']);
                }
              } catch (e) {
                debugPrint('Error decoding USG jsonString: $e');
                gCache = null;
              }
            }
            
            print("WATCH IN1 ${CacheHelper.getString("dateWatchScreen")}");
            
            if (CacheHelper.getString("dateWatchScreen") != null &&
                CacheHelper.getString("dateWatchScreen") != "") {
              dateToCheck = safeParseDateTime(CacheHelper.getString("dateWatchScreen"));
            }
            
            // Check if we should show onboarding or login
            bool shouldShowOnboarding = false;
            
            // Check if features exist and are not empty
            if (features != null && features is List && features.isNotEmpty) {
              final dateWatchScreen = CacheHelper.getString("dateWatchScreen");
              
              // If dateWatchScreen is not set, show onboarding
              if (dateWatchScreen == null || dateWatchScreen.isEmpty) {
                shouldShowOnboarding = true;
                print("WATCH: dateWatchScreen is empty, showing onboarding");
              } 
              // If dateWatchScreen exists, check if it's older than reference date
              else if (dateToCheck != null && referenceDate != null) {
                if (dateToCheck.isBefore(referenceDate)) {
                  shouldShowOnboarding = true;
                  print("WATCH: dateWatchScreen is older, showing onboarding");
                } else {
                  print("WATCH: dateWatchScreen is newer, going to login");
                }
              } 
              // If we can't parse dates, default to onboarding
              else {
                shouldShowOnboarding = true;
                print("WATCH: Cannot parse dates, defaulting to onboarding");
              }
            } else {
              print("WATCH: No features found, going to login");
            }
            
            print("WATCH: shouldShowOnboarding = $shouldShowOnboarding");
            
            // Navigate - ensure context is ready
            if (!context.mounted) return;
            
            // Small delay to ensure everything is initialized
            await Future.delayed(const Duration(milliseconds: 100));
            
            if (!context.mounted) return;
            
            if (shouldShowOnboarding) {
              final onboardingItems = getAllOnboardingData(context: context);
              final hasValidSlides = onboardingItems != null && onboardingItems.isNotEmpty;
              if (hasValidSlides) {
                print("Navigating to onboarding");
                await _precacheImages(context);
                if (context.mounted) {
                  try {
                    final router = GoRouter.of(context);
                    final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                    final isOnOfflineScreen = currentLocation.contains('offline-screen');
                    
                    if (!isOnOfflineScreen) {
                      context.goNamed(AppRoutes.onboarding.name,
                          pathParameters: {'lang': context.locale.languageCode});
                    } else {
                      print("⚠️ User is on offline screen, skipping navigation to onboarding");
                    }
                  } catch (e) {
                    debugPrint("⚠️ Error checking route before navigation: $e");
                  }
                }
              } else {
                print("No valid onboarding slides (كل العناصر فاضية), navigating to login");
                if (context.mounted) {
                  try {
                    final router = GoRouter.of(context);
                    final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                    final isOnOfflineScreen = currentLocation.contains('offline-screen');
                    if (!isOnOfflineScreen) {
                      context.goNamed(AppRoutes.login.name,
                          pathParameters: {'lang': context.locale.languageCode});
                    }
                  } catch (e) {
                    debugPrint("⚠️ Error checking route: $e");
                  }
                }
              }
            } else {
              print("Navigating to login");
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
                    print("⚠️ User is on offline screen, skipping navigation to login");
                  }
                } catch (e) {
                  debugPrint("⚠️ Error checking route before navigation: $e");
                  // If we can't check route, don't navigate to avoid issues
                }
              }
            }
          }
        }
      } catch (err, t) {
        debugPrint("⚠️ initializeSplashScreen error: $err");
        debugPrint("⚠️ initializeSplashScreen stack: $t");

        // في حالة الخطأ، نحاول على الأقل نرجّع اليوزر على الهوم لو هو لسه لوجين
        try {
          final appConfigService =
              Provider.of<AppConfigService>(context, listen: false);
          final isLoggedIn = appConfigService.isLogin &&
              appConfigService.token.isNotEmpty;

          final router = GoRouter.of(context);
          final currentLocation =
              router.routerDelegate.currentConfiguration.uri.path;
          final isOnOfflineScreen =
              currentLocation.contains('offline-screen');

          if (isOnOfflineScreen) {
            print(
                "⚠️ Error during splash init but user is on offline screen - skipping navigation");
            return;
          }

          if (isLoggedIn) {
            // لو اليوزر لسه لوجين، رجّعه للـ home بدل ما توديه للوجين
            final route = getHomeRouteFromUs1Role();
            print("✅ Recovering from error, navigating to: $route");
            context.goNamed(
              route,
              pathParameters: {'lang': context.locale.languageCode},
            );
            return;
          }

          // لو مش لوجين فعلاً، نودّيه للوجين كـ fallback
          context.goNamed(
            AppRoutes.login.name,
            pathParameters: {'lang': context.locale.languageCode},
          );
        } catch (e) {
          debugPrint("⚠️ Error in error-handling navigation: $e");
          // لو حصل خطأ هنا كمان، ما نحاولش نعمل Navigation زيادة
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
          if (jsonString != null && jsonString != "") {
            us1Cache = json.decode(jsonString) as Map<String,
                dynamic>; // Convert String back to JSON
            print("S2 IS --> $us1Cache");
          }
          if (appConfigService.isLogin && appConfigService.token.isNotEmpty) {
            // Check if we're on offline screen before navigating
            try {
              final router = GoRouter.of(context);
              final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
              final isOnOfflineScreen = currentLocation.contains('offline-screen');
              
              if (!isOnOfflineScreen) {
                final route = getHomeRouteFromUs1Role();
                context.goNamed(
                  route,
                  pathParameters: {'lang': context.locale.languageCode,},
                );
              } else {
                print("⚠️ User is on offline screen, skipping navigation to home (goNext)");
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
                print("⚠️ User is on offline screen, skipping navigation to login (goNext)");
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
            print("⚠️ User is on offline screen, skipping navigation (skip)");
            return;
          }
        } catch (e) {
          debugPrint("⚠️ Error checking route before navigation: $e");
          // If we can't check route, don't navigate to avoid issues
          return;
        }
        
        if (appConfigService.isLogin && appConfigService.token.isNotEmpty) {
          final route = getHomeRouteFromUs1Role();
          context.goNamed(
            route,
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


// void skip(BuildContext context) => context.goNamed(AppRoutes.stores.name,
//     pathParameters: {'lang': context.locale.languageCode});
