import 'package:app_test/core/controllers/request_controller/request_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app_test/core/widgets/comments/logic/view_model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/modules/more/views/blog/controller/blog_controller.dart';
import 'package:app_test/modules/more/views/notification/logic/notification_provider.dart';
import 'app.dart';
import 'core/controllers/device_sys/device_controller.dart';
import 'core/services/app_config.service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/services/internet_check.dart';
import 'modules/home/view_models/home.viewmodel.dart';
import 'modules/main_screen/view_models/main_viewmodel.dart';
import 'utils/error_handling/global_error_handler.dart';

GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
   // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔹 Background Notification: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register global error handlers
  registerErrorHandlers();
  await EasyLocalization.ensureInitialized();
  await CacheHelper.init();
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
    await Firebase.initializeApp();
  }

  GoRouter.optionURLReflectsImperativeAPIs = true;
  try {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  } catch (ex, t) {
    print('Failed to initialize Hive Database $ex $t');
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
          ChangeNotifierProvider(create: (context) => ConnectionService()),
          ChangeNotifierProvider(create: (context) => RequestController()),
          ChangeNotifierProvider(create: (context) => DeviceControllerProvider()),
          ChangeNotifierProvider(create: (context) => CommentProvider()),
          ChangeNotifierProvider(create: (context) => NotificationProviderModel()),
        ],
        child: MyApp(),
      )));
}