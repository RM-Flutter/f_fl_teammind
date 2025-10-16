import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/modules/home/view_models/home.viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/general_listener.dart';
import '../constants/update_app.dart';
import '../routing/app_router.dart';
import 'backend_services/api_service/dio_api_service/shared.dart';
import 'device_info.service.dart';

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize everything
  Future<void> init(context) async {
    await _requestPermissions();
    _initializeLocalNotifications(context);
    _setupForegroundMessages();
    _setupBackgroundMessages(context);
    await checkInitialMessage();
    _retrieveFcmToken();
  }
  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // خزّن الـ endpoint أو أي بيانات محتاجها
      await CacheHelper.setString(key: 'initialNotification',value: initialMessage.data['endpoint']);
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ User granted permission");
    } else {
      print("❌ User denied permission");
    }
  }

  // Foreground notifications
  void _setupForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Foreground Notification: ${message.notification?.title}");
      _showNotification(message);
    });
  }

  // Background / terminated notifications
  void _setupBackgroundMessages(context) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📩 User clicked notification: ${message.data}");
      _handleMessage(message.data['endpoint'], context);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("🚀 Launched from terminated state: ${message.data}");
        _handleMessage(message.data['endpoint'],context);
      }
    });
  }

  // Background handler for Firebase (isolated)
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("🔹 Background Notification: ${message.notification?.title}");
  }

  // Show local notification
  void _showNotification(RemoteMessage message) async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@drawable/notif_icon',
    );
    const iOSDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.data['title'] ?? message.notification?.title ?? "No Title",
      message.data['body'] ?? message.notification?.body ?? "No Body",
      details,
      payload: message.data['endpoint'],
    );
  }

  // Initialize local notifications
  void _initializeLocalNotifications(context) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iOSSettings);

    flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handleMessage(response.payload!, context);
        }
      },
    );
  }

  // Handle notification click
  void _handleMessage(String popup, context)async {
    late final HomeViewModel homeViewModel;
    homeViewModel = HomeViewModel();
    await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
    await homeViewModel.initializeHomeScreen(context, null);
    await UpdateApp.checkForForceUpdate(context);
    // Use navigatorKey.currentContext if context not available
     GeneralListener.linksAction(popup: popup, out: true);
  }

  // Retrieve FCM token
  void _retrieveFcmToken() async {
    String? token = await _messaging.getToken();
    print("🔑 FCM Token: $token");
  }
}
