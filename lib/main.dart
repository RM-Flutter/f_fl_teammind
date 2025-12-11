import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rmemp/common_modules_widgets/comments/logic/view_model.dart';
import 'package:rmemp/constants/general_listener.dart';
import 'package:rmemp/constants/restart_app.dart';
import 'package:rmemp/controller/request_controller/request_controller.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/connections.service.dart';
import 'package:rmemp/modules/more/views/blog/controller/blog_controller.dart';
import 'package:rmemp/modules/more/views/notification/logic/notification_provider.dart';
import 'app.dart';
import 'constants/internet_check.dart';
import 'controller/device_sys/device_controller.dart';
import 'firebase_options.dart';
import 'general_services/app_config.service.dart';
import 'general_services/conditional_imports/mock_file.dart'
    if (dart.library.js_util) 'general_services/conditional_imports/change_url_strategy.service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'modules/home/view_models/home.viewmodel.dart';
import 'modules/main_screen/view_models/main_viewmodel.dart';
import 'platform/platform_is.dart';

GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Background handler for Firebase messages
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔹 Background Notification: ${message.notification?.title}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  //await ConnectionsService.init();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  if (await Permission.notification.isPermanentlyDenied) {
    openAppSettings();
  } else {
    try {
      const platform = MethodChannel('notification_settings_channel');
      await platform.invokeMethod('openNotificationSettings');
    } catch (e) {
      print("Error opening notification settings: $e");
    }
  }
  // Request notification permissions
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  // Initialize local notifications
  var androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  var iOSSettings = DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iOSSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    // onDidReceiveNotificationResponse: (NotificationResponse response) {
    //   if (response.payload != null) {
    //     final data = jsonDecode(response.payload!);
    //     final type = data['type'];
    //     final id = data['id'];
    //     GeneralListener.linksAction(popup: data);
    //   }
    //
    // },
  );

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  /// Retrieve and print the FCM Token
  if (!PlatformIs.android && !PlatformIs.iOS) {
    changeUrlStrategyService();
  }
  GoRouter.optionURLReflectsImperativeAPIs = true;
  try {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  } catch (ex, t) {
    debugPrint('Failed to initialize Hive Database $ex $t');
  }
  runApp(EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/json/lang',
      fallbackLocale: const Locale('en'),
      // Enable saving the selected locale in local storage
      saveLocale: true,
      child: MultiProvider(
        // inject all providers to make it accessable intire all application via context.
        providers: [
          ChangeNotifierProvider<AppConfigService>(
            create: (_) => AppConfigService(),
          ),
          ChangeNotifierProvider<MainScreenViewModel>(
            create: (_) => MainScreenViewModel(),
          ),
          ChangeNotifierProvider<HomeViewModel>(
            create: (_) => HomeViewModel(),
          ),
          ChangeNotifierProvider(create: (context) => BlogProviderModel()),
          ChangeNotifierProvider(create: (context) => DeviceControllerProvider()),
          ChangeNotifierProvider(create: (context) => CommentProvider()),
          ChangeNotifierProvider(create: (context) => NotificationProviderModel()),
          ChangeNotifierProvider(create: (context) => RequestController()),
          ChangeNotifierProvider(create: (context) => ConnectionService()),
        ],
        child: MyApp(),
      )));
}
