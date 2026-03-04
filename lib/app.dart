import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/notification_service.dart';
import 'core/services/app_theme_service.dart';
import 'core/platform/platform_is.dart';
import 'core/routing/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  MyApp({super.key});
  NotificationService? notificationService;
  @override
  Widget build(BuildContext context) {
    DioHelper.initail(context);
    notificationService = NotificationService();
    notificationService!.init(context);

    if(CacheHelper.getString("lang") == ""){
      CacheHelper.setString(key: "lang", value: context.locale.languageCode);
    }
    // precacheImage(const AssetImage(AppImages.splashScreenBackground), context);
    final appGoRouter = goRouter(context);
    return MaterialApp.router(
      title: 'Team Mind',
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