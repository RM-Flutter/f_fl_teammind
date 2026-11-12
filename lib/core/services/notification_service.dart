import 'package:app_test/core/services/fcm_token.service.dart';
import 'package:app_test/core/services/app_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'backend_services/api_service/dio_api_service/shared.dart';
import 'general_listener.dart';
import 'package:app_test/core/routing/app_router.dart' show rootNavigatorKey;
import 'package:app_test/core/constants/app_images.dart';
import 'notification_service/timeout_message_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static bool _initStarted = false;

  /// Runs once per app launch. MyApp.build calls it, and build can run many
  /// times; each extra run used to start another getToken() (see FcmTokenService).
  Future<void> init(BuildContext? context) async {
    if (_initStarted) return;
    _initStarted = true;
    await _requestPermissions(context);
    _initializeLocalNotifications(context);
    await _setForegroundPresentation();
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
    AppToast.showToast(
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
      // Through FcmTokenService so it shares the one getToken() request.
      String? token = await FcmTokenService.getToken();
      debugPrint("🔑 FCM Token: $token");
    } catch (e) {
      debugPrint("⚠️ Failed to get FCM token: $e");
    }
  }

  /// The one Android channel for pushes. Same id as `default_notification_channel_id` in
  /// AndroidManifest.xml, so background pushes (shown by Firebase) and foreground ones (shown here)
  /// use the same high-importance channel; before, the manifest named a channel nobody created
  /// and Firebase fell back to a low-importance "Miscellaneous" one.
  static const String androidChannelId = 'default_channel_id';
  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    androidChannelId,
    'High Importance Notifications',
    importance: Importance.high,
    playSound: true,
  );

  void _initializeLocalNotifications(BuildContext? context) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (!kIsWeb) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel)
          .catchError((e) => debugPrint("⚠️ Failed to create notification channel: $e"));
    }
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iOSSettings);

    flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleMessage(response.payload, context);
      },
    );
  }

  /// Opens the page of a tapped notification. A push without an `endpoint` just opens the app.
  Future<void> _handleMessage(dynamic popup, BuildContext? context) async {
    if (popup is! String || popup.isEmpty) return;
    if (rootNavigatorKey.currentContext == null) return;
    try {
      await GeneralListener.linksAction(popup: popup);
    } catch (e) {
      debugPrint("⚠️ Failed to handle message: $e");
    }
  }

  /// iOS: let the system show a push that arrives while the app is open (banner, sound, badge).
  /// Before, these options were only set after a logged-in splash, so a fresh login or the
  /// login screen showed nothing.
  Future<void> _setForegroundPresentation() async {
    if (kIsWeb) return;
    try {
      await _messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint("⚠️ Failed to set foreground presentation options: $e");
    }
  }

  static bool _isForegroundListenerAttached = false;
  static bool _isBackgroundListenerAttached = false;

  void _setupForegroundMessages() {
    if (_isForegroundListenerAttached) return;
    _isForegroundListenerAttached = true;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🔔 Foreground Notification: ${message.notification?.title}");
      // Filter out notifications with no title or body
      // iOS already shows a push that has a notification part (see _setForegroundPresentation);
      // showing a local one too would give two banners. Data-only pushes still go local.
      final iosShownBySystem =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS && message.notification != null;
      if (iosShownBySystem) return;
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
    if (_isBackgroundListenerAttached) return;
    _isBackgroundListenerAttached = true;
    // Tap on a push while the app was in the background.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message.data['endpoint'], context);
    });
    // A tap that launched the app from closed is handled once, by the splash: _checkInitialMessage
    // caches the link and the splash opens it when the router is ready. Opening it here as well
    // navigated twice (or before the navigator existed).
  }

  void _showNotification(RemoteMessage message) async {
    // Web has no local notifications: show the in-app banner. This listener runs
    // from app start, logged in or not (PushNotificationService only starts after
    // a logged-in splash, so after a fresh login the web showed nothing).
    if (kIsWeb) {
      final title = message.data['title'] ?? message.notification?.title ?? '';
      final body = message.data['body'] ?? message.notification?.body ?? '';
      final endpoint = message.data['endpoint'];
      TimeoutMessage.show(
        title: title,
        message: body,
        logoWithWihteText: AppImages.logoWithWihteText,
        width: 360,
        onClick: () {
          if (endpoint is String && endpoint.isNotEmpty) {
            _handleMessage(endpoint, null);
          }
        },
      );
      return;
    }
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Get title and body (should already be validated by _shouldShowNotification)
    final title = message.data['title'] ?? message.notification?.title ?? '';
    final body = message.data['body'] ?? message.notification?.body ?? '';

    // For web, use app icon path; for mobile, use drawable resource
    // Note: Icon-192.png is in web/icons/ folder (used in manifest.json)
    // If you want to use your app logo, copy it to web/icons/ and update the path here
    const androidDetails = kIsWeb
        ? const AndroidNotificationDetails(
      androidChannelId,
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: 'icons/Icon-192.png', // Use app icon from web/icons/ instead of Chrome logo
    )
        : const AndroidNotificationDetails(
      androidChannelId,
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
        // A different id per push, so a new one no longer replaces the previous one.
        (message.messageId ?? '${DateTime.now().microsecondsSinceEpoch}').hashCode & 0x7fffffff,
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
      var endpoint = initialMessage?.data['endpoint'];
      // Launched by tapping a local notification (foreground push on Android, or a data-only push
      // shown by showDataOnlyInBackground): its payload is the endpoint.
      if (endpoint == null && !kIsWeb) {
        final launch = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
        if (launch?.didNotificationLaunchApp == true) {
          endpoint = launch?.notificationResponse?.payload;
        }
      }
      if (endpoint is String && endpoint.isNotEmpty) {
        await CacheHelper.setString(
          key: 'initialNotification',
          value: endpoint,
        );
      }
    } catch (e) {
      debugPrint("⚠️ Failed to check initial message: $e");
    }
  }

  /// Android, app in the background or closed: Firebase shows pushes that have a `notification`
  /// part by itself, but data-only pushes (title / body inside `data`) arrive and show nothing.
  /// Called from the background handler in main.dart to show those. iOS and web are handled by
  /// the system / the service worker.
  static Future<void> showDataOnlyInBackground(RemoteMessage message) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    if (message.notification != null) return;
    final title = message.data['title']?.toString() ?? '';
    final body = message.data['body']?.toString() ?? '';
    if (title.isEmpty || body.isEmpty || title == 'No Title' || body == 'No Body') return;
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ));
      await plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
      await plugin.show(
        (message.messageId ?? '${DateTime.now().microsecondsSinceEpoch}').hashCode & 0x7fffffff,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            androidChannelId,
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            icon: '@drawable/notif_icon',
          ),
        ),
        payload: message.data['endpoint']?.toString(),
      );
    } catch (e) {
      debugPrint("⚠️ Failed to show background notification: $e");
    }
  }

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint("🔹 Background Notification: ${message.notification?.title}");
  }
}
