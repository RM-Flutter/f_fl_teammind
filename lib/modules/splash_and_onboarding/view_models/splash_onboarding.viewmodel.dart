import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_codes/country_codes.dart';
import 'package:easy_localization/easy_localization.dart';
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

    List? getAllOnboardingData({required BuildContext context}) {
      final jsonString = CacheHelper.getString("USG");
      if (jsonString != null && jsonString.isNotEmpty) {
        final gCache = json.decode(jsonString) as Map<String,
            dynamic>; // Convert String back to JSON

        return gCache['features']['items'];
      }
    }
  List<Map<String, dynamic>>? _getOnboardingDataFromCache() {
    final jsonString = CacheHelper.getString("USG");
    if (jsonString == null || jsonString.isEmpty) {
      debugPrint('⚠️ Cache empty');
      return null;
    }

    final gCache = json.decode(jsonString) as Map<String, dynamic>?;
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
        await precacheImage(const AssetImage(AppImages.logo), context);
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
          if (appConfigService.isLogin && appConfigService.token.isNotEmpty) {
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
            final referenceDate = safeParseDateTime(gCache['features']['date']);
            print("dateWatchScreen is ${CacheHelper.getString("dateWatchScreen") ?? ""}");
            if (CacheHelper.getString("dateWatchScreen") == null ||
                CacheHelper.getString("dateWatchScreen") == "" ||
                gCache['features']['date'] == null ||
                referenceDate!.isAfter(dateToCheck!)) {
              await _precacheImages(context);
              if (gCache['features'] != null ||
                  gCache['features']['items'].isNotEmpty) {
                context.goNamed(AppRoutes.onboarding.name,
                    pathParameters: {'lang': context.locale.languageCode});
              } else {
                context.goNamed(
                  AppRoutes.home.name,
                  pathParameters: {'lang': context.locale.languageCode},
                );
              }
            } else {
              context.goNamed(
                AppRoutes.home.name,
                pathParameters: {'lang': context.locale.languageCode},
              );
            }
            return;
          }
          else {
            print("WATCH 0");
            final jsonString2 = CacheHelper.getString("USG");
            var cache;
            if (jsonString2 != null && jsonString2.isNotEmpty) {
              cache = json.decode(jsonString2) as Map<String, dynamic>;
            }
            final features = cache['features']['items'];
            print("WATCH 1");
            final jsonString = CacheHelper.getString("USG");
            var gCache;
            var dateToCheck;
            var referenceDate;
            print("WATCH 2");
            if (jsonString != null && jsonString != "") {
              gCache = json.decode(jsonString) as Map<String,
                  dynamic>; // Convert String back to JSON
              referenceDate = safeParseDateTime(gCache['features']['date']);
            }
            print("WATCH IN1 ${CacheHelper.getString("dateWatchScreen")}");
            if (CacheHelper.getString("dateWatchScreen") != null &&
                CacheHelper.getString("dateWatchScreen") != "") {
              dateToCheck =
                  safeParseDateTime(CacheHelper.getString("dateWatchScreen"));
            } else {
              if (CacheHelper.getString("dateWatchScreen") == null ||
                  CacheHelper.getString("dateWatchScreen") == "" ||
                  gCache == null || gCache['features']['date'] == "" ||
                  dateToCheck.isAfter(referenceDate) == false){
                print("WATCH IN IN");
                await _precacheImages(context);
                print("WATCH IN 2");
                context.goNamed(AppRoutes.onboarding.name,
                    pathParameters: {'lang': context.locale.languageCode});
              }else{
                print("login-1");
                context.goNamed(
                  AppRoutes.login.name,
                  pathParameters: {'lang': context.locale.languageCode},
                );
              }
            }
            if (features == null || features.isEmpty) {
              print("login-2");
              context.goNamed(
                AppRoutes.login.name,
                pathParameters: {'lang': context.locale.languageCode,
                },
              );
              return;
            } else {
              if (CacheHelper.getString("dateWatchScreen") == null ||
                  CacheHelper.getString("dateWatchScreen") == "" ||
                  gCache == null || gCache['features']['date'] == "" ||
                  dateToCheck.isAfter(referenceDate) == false) {
                await _precacheImages(context);
                print("WATCH IN 4");
                context.goNamed(AppRoutes.onboarding.name,
                    pathParameters: {'lang': context.locale.languageCode});
              } else {
                print("login-3");
                context.goNamed(
                  AppRoutes.login.name,
                  pathParameters: {'lang': context.locale.languageCode},
                );
              }
            }
            // print("login-4");
            // return context.goNamed(
            //   AppRoutes.login.name,
            //   pathParameters: {'lang': context.locale.languageCode},
            // );
          }
        }
      } catch (err, t) {
        print("login-5");
        return context.goNamed(
          AppRoutes.login.name,
          pathParameters: {'lang': context.locale.languageCode},
        );
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
          var role;
          if (jsonString != "") {
            us1Cache = json.decode(jsonString) as Map<String,
                dynamic>; // Convert String back to JSON
            print("S2 IS --> $us1Cache");
            role = us1Cache['role'];
          }
          if (appConfigService.isLogin && appConfigService.token.isNotEmpty) {
            context.goNamed(
              AppRoutes.home.name,
              pathParameters: {'lang': context.locale.languageCode,},
            );
          } else {
            context.goNamed(
              AppRoutes.login.name,
              pathParameters: {'lang': context.locale.languageCode,},
            );
          }
        }
      }
      void skip(BuildContext context) {
        final appConfigService =
        Provider.of<AppConfigService>(context, listen: false);
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


// void skip(BuildContext context) => context.goNamed(AppRoutes.stores.name,
//     pathParameters: {'lang': context.locale.languageCode});
