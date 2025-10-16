import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/notification_service.dart';
import 'package:rmemp/modules/personal_profile/views/personal_profile_screen.dart';
import 'constants/app_images.dart';
import 'constants/general_listener.dart';
import 'general_services/app_theme.service.dart';
import 'main.dart';
import 'platform/platform_is.dart';
import 'routing/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class MyApp extends StatelessWidget {

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("AppConstants.fingerPrints --> ${AppConstants.fingerPrints}");
    DioHelper.initail(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // مثال: startAll أو أي navigation
      NotificationService().init(context);
    });

    if(CacheHelper.getString("lang") == ""){
      print("=========0");
      CacheHelper.setString(key: "lang", value: context.locale.languageCode);
      print("lang is ${CacheHelper.getString("lang")}");
    }
    print("langs is ${CacheHelper.getString("lang")}");
    precacheImage(const AssetImage(AppImages.splashScreenBackground), context);
    final appGoRouter = goRouter(context);
    // return MaterialApp(
    //   title: 'rmemp',
    //   restorationScopeId: 'app',
    //   localizationsDelegates: context.localizationDelegates,
    //   supportedLocales: context.supportedLocales,
    //   locale: context.locale,
    //   home: PersonalProfileScreen(),
    //   debugShowCheckedModeBanner: false,
    //   themeMode: ThemeMode.light,
    //   theme: AppThemeService.getTheme(isDark: false, context: context),
    //   darkTheme: AppThemeService.getTheme(isDark: true, context: context),
    //   scrollBehavior: PlatformIs.web ? AppScrollBehavior() : null,
    // );
    return MaterialApp.router(
      title: 'rmemp',
      restorationScopeId: 'app',
      routerConfig: appGoRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppThemeService.getTheme(isDark: false, context: context),
      darkTheme: AppThemeService.getTheme(isDark: true, context: context),
      scrollBehavior: PlatformIs.web ? AppScrollBehavior() : null,
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
  };
}
