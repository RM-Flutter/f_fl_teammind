import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/models/settings/general_settings.model.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/models/settings/user_settings_2.model.dart';
import 'package:rmemp/modules/home/view_models/home.viewmodel.dart';
import 'package:rmemp/routing/app_router.dart';
import '../../../constants/app_images.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/general_listener.dart';
import '../../../constants/update_app.dart';
import '../../../general_services/app_config.service.dart';
import '../../../general_services/device_info.service.dart';
import '../../../general_services/device_info.service.dart' as checkForForceUpdate;
import '../../../general_services/localization.service.dart';
import '../../../utils/overlay_gradient_widget.dart';
import '../view_models/splash_onboarding.viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final OnboardingViewModel viewModel;
  late final HomeViewModel homeViewModel;

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
  Future<void> _handleInitialNotification() async {
    bool isArabic = LocalizationService.isArabic(context: context);
    if (isArabic) {
      await CacheHelper.setString(key: "lang", value: "ar");
    } else {
      await CacheHelper.setString(key: "lang", value: "en");
    }
  }
  Future<void> initializeHomeAndSplash() async {
   //  print("INITIAL11");
   //  final start = DateTime.now();
   //  final bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;
   //  final end = DateTime.now();
   //  final diff = end.difference(start).inMilliseconds;
   //  print("⏱️ الوقت المستغرق نت: $diff ms");
   //  print("isConnected --> ${isConnected}");
   //  if(isConnected == false){
   //    context.goNamed(
   //      AppRoutes.offlineScreen.name,
   //      pathParameters: {'lang': context.locale.languageCode,
   //      },
   //    );
   //  }
   // else{
   //
   //  }
    if (!mounted) return;
    await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
    if (!mounted) return;
    await homeViewModel.initializeHomeScreen(context, null);
    if (!mounted) return;
    await UpdateApp.checkForForceUpdate(context);

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
    if (!mounted) return;
    viewModel.initializeSplashScreen(
        context: context,
        role: (UserSettingConst.userSettings != null)? UserSettingConst.userSettings!.role : CacheHelper.getString("roles")
    );
  }

  @override
  void dispose() {
    homeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingViewModel>(
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
                  Image.asset(
                    AppImages.logo,
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
