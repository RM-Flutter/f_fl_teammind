import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app_test/core/widgets/comments/logic/controller.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/more/blog/controllers/blog_controller.dart';
import 'package:app_test/features/more/notifications/controllers/notification_controller.dart';
import 'app.dart';
import 'features/assistant/controllers/assistant_controller.dart';
import 'core/services/fcm_token.service.dart';
import 'features/more/user_device/controllers/user_device_controller.dart';
import 'features/overtime_requests/controllers/overtime_requests_controller.dart';
import 'features/shifts/controllers/shift_change_controller.dart';
import 'features/daily_reports/controllers/daily_reports_controller.dart';
import 'core/services/app_config_service.dart';
import 'package:flutter/material.dart';

import 'package:app_test/features/cv_hub/controllers/cv_hub_interviews_controller.dart';
import 'package:app_test/features/cv_hub/controllers/cv_hub_interview_details_controller.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/services/internet_check.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/main_layout/controllers/main_controller.dart';
import 'package:app_test/core/utils/error_handling/global_error_handler.dart';
import 'package:app_test/core/services/notification_service/local_notification_service.dart';
import 'package:app_test/core/services/notification_service/check_in_scheduler.dart';
import 'package:app_test/core/models/settings/user_settings_2.model.dart';
import 'package:app_test/core/services/settings_service.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       await CacheHelper.init();
//       final appConfig = AppConfigService();
//       await appConfig.init();
//
//       final userSettings2 = appConfig.getSettings(type: SettingsType.user2Settings) as UserSettings2Model?;
//       if (userSettings2 != null) {
//         await LocalNotificationService.init();
//         await CheckInScheduler.scheduleAlarmsForNext30Days(userSettings2);
//       }
//     } catch (e) {
//       debugPrint("Background task error: $e");
//     }
//     return Future.value(true);
//   });
// }

GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("🔹 Background Notification: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register global error handlers
  registerErrorHandlers();
  await EasyLocalization.ensureInitialized();
  await CacheHelper.init();
  AppConstants.updateFingerprintSecurityFromUsgFingerprintChecks();
  await LocalNotificationService.init();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBe4BoD2wwFmzy136pdOD8NU4XazECs6gg",
        authDomain: "rm-csapp.firebaseapp.com",
        projectId: "rm-csapp",
        storageBucket: "rm-csapp.appspot.com",
        messagingSenderId: "567522084254",
        appId: "1:567522084254:web:726243823f43f1a78b428f",
        measurementId: "G-E9C7RGQQ4S",
      ),
    );
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Needs Firebase to be initialized first; not awaited so it never blocks startup.
  FcmTokenService.initAtAppStart();

  GoRouter.optionURLReflectsImperativeAPIs = true;
  try {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  } catch (ex, t) {
    debugPrint('Failed to initialize Hive Database $ex $t');
  }
  final appConfigService = AppConfigService();
  await appConfigService.init();

  // if (!kIsWeb) {
  //   await LocalNotificationService.init();
  //   Workmanager().initialize(
  //     callbackDispatcher,
  //   );
  //   Workmanager().registerPeriodicTask(
  //     "1",
  //     "checkInSchedulingTask",
  //     frequency: const Duration(days: 7),
  //   );
  //
  //   // Also trigger immediately to schedule if not scheduled yet
  //   final userSettings2 = appConfigService.getSettings(type: SettingsType.user2Settings) as UserSettings2Model?;
  //   if (userSettings2 != null) {
  //     await CheckInScheduler.scheduleAlarmsForNext30Days(userSettings2);
  //   }
  // }

  runApp(EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/json/lang',
      fallbackLocale: const Locale('en'),
      // Enable saving the selected locale in local storage
      saveLocale: true,
      child: MultiProvider(
        // inject all providers to make it accessable intire all application via context.
        providers: [
          ChangeNotifierProvider<AppConfigService>.value(
            value: appConfigService,
          ),
          ChangeNotifierProvider<MainLayoutController>(
            create: (_) => MainLayoutController(),
          ),
          ChangeNotifierProvider<HomeController>(
            create: (_) => HomeController(),
          ),
          ChangeNotifierProvider(create: (context) => BlogProviderModel()),
          ChangeNotifierProvider(create: (context) => ConnectionService()),
          ChangeNotifierProvider(
              create: (context) => DeviceControllerProvider()),
          ChangeNotifierProvider(create: (context) => CommentProvider()),
          ChangeNotifierProvider(
              create: (context) => NotificationProviderModel()),
          ChangeNotifierProvider(
              create: (context) => OvertimeRequestsProvider()),
          ChangeNotifierProvider(create: (context) => ShiftChangeController()),
          ChangeNotifierProvider(create: (context) => DailyReportsProvider()),
          ChangeNotifierProvider(create: (_) => CvHubInterviewsController()),
          ChangeNotifierProvider(create: (_) => AssistantController()),
          ChangeNotifierProvider(
              create: (_) => CvHubInterviewDetailsController()),
        ],
        child: MyApp(),
      )));
}
