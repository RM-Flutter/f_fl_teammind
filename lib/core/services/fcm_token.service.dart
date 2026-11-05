import 'dart:async';

import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Single place for FCM token: generated at app start with retry,
/// updated via onTokenRefresh. No cached fallback when getToken() returns null.
abstract class FcmTokenService {
  static const String _cacheKey = 'fcm_token';

  /// Web Push public key of the rm-emp project (Firebase Console → Project
  /// settings → Cloud Messaging → Web Push certificates). It is public, safe to
  /// commit. Empty = the Firebase SDK's default key is used.
  static const String _webVapidKey =
      'BMXS-KbqGXjuuWNZ9fUnt2-OMiTjiB0hT9emgKU1iytzSiX0sYKDP2ysKlXO2aRJpaWhfIhcvrFytWLAqGuddUU';

  /// Pass to every getToken() call: on web a different key replaces the push
  /// subscription and changes the token.
  static String? get vapidKey =>
      kIsWeb && _webVapidKey.isNotEmpty ? _webVapidKey : null;

  static bool _listenerAttached = false;

  /// Completes after the first getToken() attempt of this launch (success or
  /// not). The web token can change between launches, so start_app waits for
  /// it instead of sending the previous launch's token.
  static final Completer<void> _firstAttempt = Completer<void>();

  /// Waits (at most [timeout]) for this launch's first token attempt.
  static Future<void> waitForFirstAttempt(
      {Duration timeout = const Duration(seconds: 5)}) {
    return _firstAttempt.future.timeout(timeout, onTimeout: () {});
  }

  static void _markFirstAttemptDone() {
    if (!_firstAttempt.isCompleted) _firstAttempt.complete();
  }

  /// Call once at app start (e.g. after Firebase.initializeApp() in main.dart).
  /// Requests permission, gets token with retry, and subscribes to onTokenRefresh.
  /// Does not use cached token as fallback when getToken() returns null.
  static Future<void> initAtAppStart() async {
    try {
      await _requestPermission();
      await _getTokenWithRetry();
      _attachTokenRefreshListener();
    } catch (e) {
      debugPrint('⚠️ FcmTokenService.initAtAppStart error: $e');
    } finally {
      _markFirstAttemptDone();
    }
  }

  static Future<void> _requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('⚠️ FCM: notification permission not granted');
      }
    } catch (e) {
      debugPrint('⚠️ FCM requestPermission error: $e');
    }
  }

  /// Retry getToken(); only save to cache when non-null. No cached fallback.
  static Future<void> _getTokenWithRetry() async {
    const maxAttempts = 10;
    const delayBetweenAttempts = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final token =
            await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
        if (token != null && token.isNotEmpty) {
          await CacheHelper.setString(key: _cacheKey, value: token);
          debugPrint('🔑 FCM token obtained (attempt $attempt)');
          _markFirstAttemptDone();
          return;
        }
      } catch (e) {
        debugPrint('⚠️ FCM getToken attempt $attempt failed: $e');
      }
      // Don't hold start_app up for the retries.
      _markFirstAttemptDone();
      if (attempt < maxAttempts) {
        await Future.delayed(delayBetweenAttempts);
      }
    }
    debugPrint('⚠️ FCM getToken returned null after $maxAttempts attempts; onTokenRefresh will update when ready.');
  }

  static void _attachTokenRefreshListener() {
    if (_listenerAttached) return;
    _listenerAttached = true;
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      if (token.isNotEmpty) {
        CacheHelper.setString(key: _cacheKey, value: token);
        debugPrint('🔑 FCM token refreshed and cached');
      }
    });
  }

  /// Adds this launch's token to a login/register `device_info` map. The
  /// backend stores it on the device row it creates for the login; without it
  /// the new row inherits the previous (possibly dead) token, and start_app
  /// only sends the token again at the next launch.
  static Map<String, dynamic> withToken(Map<String, dynamic> deviceInfo) {
    final token = getCachedToken();
    if (token == null || token.isEmpty) return deviceInfo;
    return {
      ...deviceInfo,
      'notification_token': token,
      'notification_token_status': true,
    };
  }

  /// Returns the token from cache only. Does not call getToken().
  static String? getCachedToken() {
    return CacheHelper.getString(_cacheKey);
  }
}
