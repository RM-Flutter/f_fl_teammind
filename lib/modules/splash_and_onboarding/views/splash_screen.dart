import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/models/settings/general_settings.model.dart';
import 'package:app_test/models/settings/user_settings.model.dart';
import 'package:app_test/models/settings/user_settings_2.model.dart';
import 'package:app_test/modules/home/view_models/home.viewmodel.dart';
import 'package:app_test/core/widgets/dynamic_image_widget.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/update_app.dart';
import 'package:app_test/core/services/device_info.service.dart';
import 'package:app_test/core/services/internet_check.dart';
import 'package:app_test/core/services/localization.service.dart';
import 'package:app_test/core/services/domain_selection.service.dart';
import 'package:app_test/modules/splash_and_onboarding/view_models/splash_onboarding.viewmodel.dart';

import '../../../core/utils/overlay_gradient_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final OnboardingViewModel viewModel;
  late final HomeViewModel homeViewModel;
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
      _connectionService!.onConnectionRestored = _resumeInitialization;
    }
  }

  @override
  void initState(){
    super.initState();
    homeViewModel = HomeViewModel();
    viewModel = OnboardingViewModel();
    
    initializeHomeAndSplash();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialNotification();
    });
  }

  @override
  void dispose() {
    // Unregister callback safely
    if (_connectionService != null) {
      _connectionService!.onConnectionRestored = null;
    }
    super.dispose();
  }

  // Callback to resume initialization when connection is restored
  void _resumeInitialization() {
    if (!_initializationCompleted && !_isInitializing && mounted) {
      print("🔄 Connection restored, resuming initialization...");
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
    
    // If offline, skip API calls and use cached data only
    if (!connectionService.isConnected) {
      print("⚠️ Offline detected: Skipping ALL API calls, using cached data only");
      print("⚠️ Connection status: ${connectionService.isConnected}");
      
      // Check and select domain (may require network, but try anyway)
      try {
        final domainSelected = await DomainSelectionService.checkAndSelectDomain(context);
        if (!domainSelected || !mounted) {
          _isInitializing = false;
          return;
        }
      } catch (e) {
        print("❌ Error in checkAndSelectDomain (offline), continuing anyway: $e");
      }
      
      // Only initialize device info (doesn't require network)
      try {
        await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
      } catch (e) {
        print("❌ Error in initializeAndSetDeviceInfo, continuing anyway: $e");
      }
      // Skip initializeHomeScreen which makes API calls
      // The overlay will be shown automatically by ConnectionService
      print("⚠️ Exiting initializeHomeAndSplash early - no API calls will be made");
      _isInitializing = false;
      return;
    }
    
    print("✅ Online: Proceeding with normal initialization");
    
    if (!mounted) return;
    
    // Check and select domain before initializing app
    try {
      final domainSelected = await DomainSelectionService.checkAndSelectDomain(context);
      if (!domainSelected || !mounted) return;
    } catch (e) {
      print("❌ Error in checkAndSelectDomain, continuing anyway: $e");
    }
    
    // Online: proceed with normal initialization
    try {
      await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
    } catch (e) {
      print("❌ Error in initializeAndSetDeviceInfo, continuing anyway: $e");
      // Continue even if device info initialization fails
    }
    
    try {
      await homeViewModel.initializeHomeScreen(context, null);
    } catch (e) {
      print("❌ Error in initializeHomeScreen, continuing anyway: $e");
      // Continue even if home screen initialization fails (e.g., due to network issues)
    }
    
    try {
      await UpdateApp.checkForForceUpdate(context);
    } catch (e) {
      print("❌ Error in checkForForceUpdate, continuing anyway: $e");
      // Continue even if update check fails
    }

    // await UpdateApp.checkForForceUpdate(context);
    final jsonString = CacheHelper.getString("US1");
    final json2String = CacheHelper.getString("US2");
    final json3String = CacheHelper.getString("USG");
    Map<String, dynamic> us1Cache = {};
    Map<String, dynamic> us2Cache = {};
    Map<String, dynamic> us3Cache = {};
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
    if (us1Cache.isNotEmpty && us1Cache != "") {
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
    if (us2Cache.isNotEmpty && us2Cache != "") {
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
    if (us3Cache.isNotEmpty && us3Cache != "") {
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
    viewModel.initializeSplashScreen(
        context: context,
        role: (UserSettingConst.userSettings != null)? UserSettingConst.userSettings!.role : CacheHelper.getString("roles")
    );
    
    _initializationCompleted = true;
    _isInitializing = false;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingViewModel>(
        create: (context) => viewModel,
        child: Scaffold(
            body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppImages.splashScreenBackground,
                fit: BoxFit.cover,
                key: const ValueKey<String>(AppImages.splashScreenBackground)),
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
