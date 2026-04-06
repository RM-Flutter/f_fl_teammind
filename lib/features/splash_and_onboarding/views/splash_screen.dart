import 'dart:convert';
import 'package:app_test/core/constants/cache_constants.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/models/settings/general_settings.model.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/models/settings/user_settings_2.model.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
import 'package:app_test/core/widgets/dynamic_image_widget.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/update_app.dart';
import 'package:app_test/core/services/device_info_service.dart';
import 'package:app_test/core/services/internet_check.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/services/domain_selection_service.dart';
import 'package:app_test/features/splash_and_onboarding/controller/splash_onboarding_controller.dart';
import '../../../core/utils/overlay_gradient_widget.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final OnboardingController viewModel;
  late final HomeController homeViewModel;
  bool _initializationCompleted = false;
  bool _isInitializing = false;
  ConnectionService? _connectionService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to ConnectionService for safe access in dispose()
    if (_connectionService == null) {
      _connectionService = Provider.of<ConnectionService>(context, listen: false);
      // Register callback in ConnectionService to resume initialization when connection is restored
      // But only if we're not on offline screen
      final navigatorContext = rootNavigatorKey.currentContext;
      if (navigatorContext != null) {
        try {
          final router = GoRouter.of(navigatorContext);
          final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
          final isOnOfflineScreen = currentLocation.contains('offline-screen') ||
              currentLocation.contains('offline') ||
              currentLocation.contains('fingerPrintOffline');

          if (!isOnOfflineScreen) {
            _connectionService!.onConnectionRestored = _resumeInitialization;
            debugPrint("✅ Registered connection restored callback (not on offline screen)");
          } else {
            debugPrint("⚠️ Not registering connection restored callback (on offline screen: $currentLocation)");
            _connectionService!.onConnectionRestored = null; // Clear callback
          }
        } catch (e) {
          debugPrint("⚠️ Error checking route in didChangeDependencies: $e");
          // If we can't check route, don't register callback to avoid navigation issues
          _connectionService!.onConnectionRestored = null;
        }
      } else {
        // If we can't get context, don't register callback to avoid navigation issues
        _connectionService!.onConnectionRestored = null;
      }
    }
  }

  @override
  void initState(){
    super.initState();
    homeViewModel = HomeController();
    viewModel = OnboardingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if we're on offline screen before initializing
      final navigatorContext = rootNavigatorKey.currentContext;
      if (navigatorContext != null) {
        try {
          final router = GoRouter.of(navigatorContext);
          final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
          final isOnOfflineScreen = currentLocation.contains('offline-screen') ||
              currentLocation.contains('offline') ||
              currentLocation.contains('fingerPrintOffline');

          if (isOnOfflineScreen) {
            debugPrint("⚠️ User is on offline screen ($currentLocation) - skipping splash initialization in initState");
            return;
          }
        } catch (e) {
          debugPrint("⚠️ Error checking route in initState: $e");
          // If we can't check route, don't initialize to avoid navigation issues
          return;
        }
      }

      _handleInitialNotification();
      initializeHomeAndSplash();
    });
  }

  // Callback to resume initialization when connection is restored
  void _resumeInitialization() {
    if (!_initializationCompleted && !_isInitializing && mounted) {
      // Check if we're on offline screen before resuming initialization
      // Use rootNavigatorKey to get the most accurate current route
      final navigatorContext = rootNavigatorKey.currentContext;
      if (navigatorContext != null) {
        try {
          final router = GoRouter.of(navigatorContext);
          final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
          final isOnOfflineScreen = currentLocation.contains('offline-screen') ||
              currentLocation.contains('offline') ||
              currentLocation.contains('fingerPrintOffline');

          if (isOnOfflineScreen) {
            debugPrint("🔄 Connection restored, but user is on offline screen ($currentLocation) - skipping initialization completely");
            return;
          }
        } catch (e) {
          debugPrint("⚠️ Error checking route in _resumeInitialization: $e");
          // If we can't check route, don't resume initialization to avoid navigation issues
          return;
        }
      } else {
        debugPrint("⚠️ No navigator context in _resumeInitialization - skipping to avoid navigation issues");
        return;
      }

      debugPrint("🔄 Connection restored, resuming initialization...");
      initializeHomeAndSplash();
    }
  }
  Future<void> _handleInitialNotification() async {
    bool isArabic = LocalizationService.isArabic(context: context);
    if (isArabic) {
      await CacheHelper.setString(key: "lang", value: "ar");
    } else {
      await CacheHelper.setString(key: "lang", value: "en");
    }
  }
  Future<void> initializeHomeAndSplash() async {
    if (!mounted || _isInitializing) return;

    _isInitializing = true;

    // Wait a bit to ensure ConnectionService is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));

    // Use saved reference or get from Provider
    final connectionService = _connectionService ?? Provider.of<ConnectionService>(context, listen: false);
    await connectionService.checkConnection();

    // Double-check connection status after a brief delay
    await Future.delayed(const Duration(milliseconds: 200));
    await connectionService.checkConnection();

    // إذا ظهر أوفلاين: إعادة فحص بعد تأخير (قد يكون التطبيق جاء من شاشة أوفلاين والاتصال لم يُحدَّث بعد)
    if (!connectionService.isConnected) {
      debugPrint("⚠️ Offline detected - re-checking after 1.5s (may have just left offline screen)");
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) {
        _isInitializing = false;
        return;
      }
      await connectionService.checkConnection();
      if (connectionService.isConnected) {
        debugPrint("✅ Re-check: now online, proceeding with normal initialization");
        _isInitializing = false;
        await initializeHomeAndSplash();
        return;
      }
      debugPrint("⚠️ Still offline after re-check - using cached data only");
    }

    if (!connectionService.isConnected) {
      // Check and select domain (may require network, but try anyway)
      try {
        final domainSelected = await DomainSelectionService.checkAndSelectDomain(context);
        if (!domainSelected || !mounted) {
          _isInitializing = false;
          return;
        }
      } catch (e) {
        debugPrint("❌ Error in checkAndSelectDomain (offline), continuing anyway: $e");
      }

      if (!mounted) {
        _isInitializing = false;
        return;
      }
      // إعادة فحص الاتصال بعد إدخال الدومين — أحياناً يصبح النت متاحاً
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) {
        _isInitializing = false;
        return;
      }
      await connectionService.checkConnection();
      if (connectionService.isConnected) {
        debugPrint("✅ Connection available after domain - proceeding with online flow");
        _isInitializing = false;
        await initializeHomeAndSplash();
        return;
      }

      // Only initialize device info (doesn't require network)
      try {
        await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
      } catch (e) {
        debugPrint("❌ Error in initializeAndSetDeviceInfo, continuing anyway: $e");
      }

      // Load USG from cache and apply fingerprint security
      try {
        await CacheConsts.initUSG();
        debugPrint("✅ USG loaded from cache, fingerprint checks updated");
      } catch (e) {
        debugPrint("❌ Error in initUSG (offline), continuing anyway: $e");
      }

      _isInitializing = false;
      if (mounted) {
        final lang = context.locale.languageCode;
        context.goNamed(AppRoutes.offlineScreen.name, pathParameters: {'lang': lang});
        debugPrint("✅ Navigated to offline screen (lang: $lang)");
      }
      return;
    }

    debugPrint("✅ Online: Proceeding with normal initialization");

    if (!mounted) return;

    // Check and select domain before initializing app
    try {
      final domainSelected = await DomainSelectionService.checkAndSelectDomain(context);
      if (!domainSelected || !mounted) return;
    } catch (e) {
      debugPrint("❌ Error in checkAndSelectDomain, continuing anyway: $e");
    }

    try {
      await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
    } catch (e) {
      debugPrint("❌ Error in initializeAndSetDeviceInfo, continuing anyway: $e");
    }

    if (!mounted) return;

    try {
      await homeViewModel.initializeHomeScreen(context, null);
    } catch (e) {
      debugPrint("❌ Error in initializeHomeScreen, continuing anyway: $e");
      // Continue even if home screen initialization fails (e.g., due to network issues)
    }

    if (!mounted) return;

    try {
      await UpdateApp.checkForForceUpdate(context);
    } catch (e) {
      debugPrint("❌ Error in checkForForceUpdate, continuing anyway: $e");
      // Continue even if update check fails
    }

    // await UpdateApp.checkForForceUpdate(context);
    final jsonString = CacheHelper.getString("US1");
    final json2String = CacheHelper.getString("US2");
    final json3String = CacheHelper.getString("USG");
    var us1Cache;
    var us2Cache;
    var us3Cache;
    GeneralSettingsModel? generalSettingsModel;
    if (jsonString != null && jsonString != "") {
      us1Cache = json.decode(jsonString) as Map<String, dynamic>;// Convert String back to JSON
    }
    if (json2String != null && json2String != "") {
      us2Cache = json.decode(json2String) as Map<String, dynamic>;// Convert String back to JSON
    }
    if (json3String != null && json3String != "") {
      us3Cache = json.decode(json3String) as Map<String, dynamic>;// Convert String back to JSON
    }
    if (us1Cache != null && us1Cache.isNotEmpty && us1Cache != "") {
      try {
        // Decode JSON string into a Map
        // Convert the Map to the appropriate type (e.g., UserSettingsModel)
        UserSettingConst.userSettings = UserSettingsModel.fromJson(us1Cache);
      } catch (e) {
        print("Error decoding user settings: $e");
      }
    }
    else {
      print("us1Cache is null or empty.");
    }
    if (us2Cache != null && us2Cache.isNotEmpty && us2Cache != "") {
      try {
        // Decode JSON string into a Map
        // Convert the Map to the appropriate type (e.g., UserSettingsModel)
        UserSettingConst.userSettings2 = UserSettings2Model.fromJson(us2Cache);
      } catch (e) {
        print("Error decoding user settings: $e");
      }
    }
    else {
      print("us2Cache is null or empty.");
    }
    if (us3Cache != null && us3Cache.isNotEmpty && us3Cache != "") {
      try {
        UserSettingConst.generalSettingsModel = GeneralSettingsModel.fromJson(us3Cache);
        generalSettingsModel = GeneralSettingsModel.fromJson(us3Cache);
        print("IS THIS IS -> ${generalSettingsModel.requestTypes}");
      } catch (e) {
        print("Error decoding user settings: $e");
      }
    }
    else {
      print("us2Cache is null or empty.");
    }
    if (!mounted) {
      _isInitializing = false;
      return;
    }

    // Check if we're on offline screen before initializing splash screen navigation
    // Use rootNavigatorKey to get the most accurate current route
    final navigatorContext = rootNavigatorKey.currentContext ?? context;
    try {
      final router = GoRouter.of(navigatorContext);
      final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
      final isOnOfflineScreen = currentLocation.contains('offline-screen') ||
          currentLocation.contains('offline') ||
          currentLocation.contains('fingerPrintOffline');

      if (isOnOfflineScreen) {
        debugPrint("⚠️ User is on offline screen ($currentLocation), skipping splash screen initialization to avoid navigation");
        _initializationCompleted = true;
        _isInitializing = false;
        return;
      }
    } catch (e) {
      debugPrint("⚠️ Error checking route before splash initialization: $e");
      // If we can't check route, don't proceed with initialization to avoid navigation issues
      _initializationCompleted = true;
      _isInitializing = false;
      return;
    }

    viewModel.initializeSplashScreen(
        context: context,
        role: (UserSettingConst.userSettings != null)? UserSettingConst.userSettings!.role : CacheHelper.getString("roles")
    );

    _initializationCompleted = true;
    _isInitializing = false;
    debugPrint("✅ Initialization completed successfully");
  }

  @override
  void dispose() {
    homeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingController>(
        create: (context) => viewModel,
        child: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(!kIsWeb?AppImages.splashScreenBackground:AppImages.splashScreenBackgroundWeb,
                    fit: BoxFit.cover),
                const OverlayGradientWidget(),
                Positioned(
                  bottom: AppSizes.s48,
                  left: AppSizes.s0,
                  right: AppSizes.s0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DynamicImageWidget(
                        imageUrl: AppImages.logo,
                        height: AppSizes.s75,
                        width: AppSizes.s75,
                      ),
                      Text(
                        AppStrings.loading.tr(),
                        style: LocalizationService.isArabic(context: context)
                            ? Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(letterSpacing: 0)
                            : Theme.of(context).textTheme.displayMedium,
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}