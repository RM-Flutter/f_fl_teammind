import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

//
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

//
  static Future<void> init() async {
    tz.initializeTimeZones();
//
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
//
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
//
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
//
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap here if needed
      },
    );
  }

//
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool exact = true,
  }) async {
    // No local notifications on web; only schedule future dates.
    if (kIsWeb || scheduledDate.isBefore(DateTime.now())) {
      return;
    }
//
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'check_in_out_channel',
          'Attendance Reminders',
          channelDescription: 'Reminders for daily check-in and check-out',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Android 12+ may deny exact alarms (denied by default on Android 14 when
  /// only SCHEDULE_EXACT_ALARM is granted). zonedSchedule with an exact mode
  /// throws in that case, so callers fall back to inexact.
  static Future<bool> canScheduleExact() async {
    if (kIsWeb) return false;
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true; // iOS: no such restriction.
    try {
      return await android.canScheduleExactNotifications() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Cancels every scheduled (pending) notification without removing the ones
  /// already shown in the tray (FCM pushes etc.), unlike [cancelAllNotifications].
  static Future<void> cancelAllPending() async {
    if (kIsWeb) return;
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    for (final p in pending) {
      await _notificationsPlugin.cancel(p.id);
    }
  }

//
  static Future<void> cancelAllNotifications() async {
    // flutter_local_notifications has no web implementation: cancelAll()
    // throws LateInitializationError there.
    if (kIsWeb) return;
    await _notificationsPlugin.cancelAll();
  }
}

