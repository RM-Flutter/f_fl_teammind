import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';

/// Single place for FCM token: generated at app start with retry,
/// updated via onTokenRefresh. No cached fallback when getToken() returns null.
abstract class FcmTokenService {
  static const String _cacheKey = 'fcm_token';

  static bool _listenerAttached = false;

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
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          CacheHelper.setString(key: _cacheKey, value: token);
          debugPrint('🔑 FCM token obtained (attempt $attempt)');
          return;
        }
      } catch (e) {
        debugPrint('⚠️ FCM getToken attempt $attempt failed: $e');
      }
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

  /// Returns the token from cache only. Does not call getToken().
  static String? getCachedToken() {
    return CacheHelper.getString(_cacheKey);
  }
}
