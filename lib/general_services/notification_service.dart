import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/modules/home/view_models/home.viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/general_listener.dart';
import '../constants/update_app.dart';
import '../routing/app_router.dart';
import 'backend_services/api_service/dio_api_service/shared.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> init(BuildContext? context) async {
    await _requestPermissions(context);
    _initializeLocalNotifications(context);
    _setupForegroundMessages();
    _setupBackgroundMessages(context);
    await _checkInitialMessage();
    await _safeRetrieveFcmToken();
  }

  Future<void> _requestPermissions(BuildContext? context) async {

    // Native
    try {
      final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint("❌ Notifications not granted");
      }
    } catch (e) {
      debugPrint("⚠️ Failed to request native permissions: $e");
    }
  }

  void _showWebToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> _safeRetrieveFcmToken() async {

    try {
      String? token = await _messaging.getToken();
      debugPrint("🔑 FCM Token: $token");
    } catch (e) {
      debugPrint("⚠️ Failed to get FCM token: $e");
    }
  }

  void _initializeLocalNotifications(BuildContext? context) {
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

  void _handleMessage(String popup, BuildContext? context) {
    // Safe call
    try {
      GeneralListener.linksAction(popup: popup);
    } catch (e) {
      debugPrint("⚠️ Failed to handle message: $e");
    }
  }

  void _setupForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🔔 Foreground Notification: ${message.notification?.title}");
      // Filter out notifications with no title or body
      if (_shouldShowNotification(message)) {
        _showNotification(message);
      } else {
        debugPrint("⚠️ Skipping notification: No valid title or body");
      }
    });
  }

  bool _shouldShowNotification(RemoteMessage message) {
    final title = message.data['title'] ?? message.notification?.title ?? '';
    final body = message.data['body'] ?? message.notification?.body ?? '';
    
    // Don't show if title or body is empty, null, or equals "No Title"/"No Body"
    if (title.isEmpty || 
        title == 'No Title' || 
        body.isEmpty || 
        body == 'No Body') {
      return false;
    }
    return true;
  }

  void _setupBackgroundMessages(BuildContext? context) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message.data['endpoint'], context);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message.data['endpoint'], context);
      }
    });
  }

  void _showNotification(RemoteMessage message) async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Get title and body (should already be validated by _shouldShowNotification)
    final title = message.data['title'] ?? message.notification?.title ?? '';
    final body = message.data['body'] ?? message.notification?.body ?? '';

    // For web, use app icon path; for mobile, use drawable resource
    // Note: Icon-192.png is in web/icons/ folder (used in manifest.json)
    // If you want to use your app logo, copy it to web/icons/ and update the path here
    final androidDetails = kIsWeb
        ? AndroidNotificationDetails(
            'channel_id',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            icon: 'icons/Icon-192.png', // Use app icon from web/icons/ instead of Chrome logo
          )
        : const AndroidNotificationDetails(
            'channel_id',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            icon: '@drawable/notif_icon',
          );
    
    const iOSDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        details,
        payload: message.data['endpoint'],
      );
    } catch (e) {
      debugPrint("⚠️ Failed to show local notification: $e");
    }
  }

  Future<void> _checkInitialMessage() async {
    try {
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        await CacheHelper.setString(
          key: 'initialNotification',
          value: initialMessage.data['endpoint'],
        );
      }
    } catch (e) {
      debugPrint("⚠️ Failed to check initial message: $e");
    }
  }

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint("🔹 Background Notification: ${message.notification?.title}");
  }
}
