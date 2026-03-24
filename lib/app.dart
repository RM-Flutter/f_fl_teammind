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
import 'modules/free_services/views/about_team_mind/about_team_mind_screen.dart';
import 'modules/free_services/views/cv_generator/cv_generator_screen.dart';
import 'modules/free_services/views/update_my_info/update_my_info_screen.dart';
import 'modules/free_services/views/vacation_calc/vacation_calc_screen.dart';
import 'platform/platform_is.dart';

import 'routing/app_router.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/general_services/fcm_token.service.dart';
import 'package:rmemp/general_services/settings.service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyApp extends StatelessWidget {

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("AppConstants.fingerPrints --> ${AppConstants.fingerPrints}");
    DioHelper.initail(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // تأخير بسيط حتى تُزال الـ native splash ويظهر الـ Flutter UI ثم نطلب صلاحية الإشعارات
      await Future.delayed(const Duration(milliseconds: 400));
      if (context.mounted) NotificationService().init(context);
      // لا نعرض رسالة البطارية تلقائياً — تظهر فقط إذا استُدعيت من الإعدادات (مثلاً زر "استثناء من توفير البطارية")
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
    //   home: AboutTeamMindScreen(),
    //   debugShowCheckedModeBanner: false,
    //   themeMode: ThemeMode.light,
    //   theme: AppThemeService.getTheme(isDark: false, context: context),
    //   darkTheme: AppThemeService.getTheme(isDark: true, context: context),
    //   scrollBehavior: PlatformIs.web ? AppScrollBehavior() : null,
    // );
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
      builder: (context, child) {
        if (!kIsWeb || child == null) return child ?? const SizedBox.shrink();
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) async {
            await FcmTokenService.requestPermissionAndTokenIfWeb();
            // على الويب فقط: بعد الحصول على التوكن (مثلاً بعد domain selection) نرسله في start_app
            final token = FcmTokenService.getCachedToken();
            if (kIsWeb) {
              debugPrint('🔔 FCM Web: بعد أول ضغطة — توكن صالح للإرسال: ${token != null}, سياق: ${rootNavigatorKey.currentContext != null}');
            }
            if (kIsWeb && token != null) {
              final ctx = rootNavigatorKey.currentContext;
              if (ctx != null && ctx.mounted) {
                debugPrint('🔔 FCM Web: جاري إرسال التوكن في start_app...');
                await AppSettingsService.getUserSettingsAndUpdateTheStoredSettings(context: ctx);
                debugPrint('🔔 FCM Web: تم استدعاء start_app مع التوكن');
              } else {
                debugPrint('⚠️ FCM Web: لا يوجد سياق صالح — التوكن لم يُرسل');
              }
            }
          },
          child: child,
        );
      },
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
