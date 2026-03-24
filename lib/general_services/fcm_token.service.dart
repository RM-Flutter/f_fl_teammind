import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/settings.service.dart';

/// Single place for FCM token: generated at app start with retry,
/// updated via onTokenRefresh. No cached fallback when getToken() returns null.
abstract class FcmTokenService {
  static const String _cacheKey = 'fcm_token';

  /// مطلوب للويب فقط: مفتاح Web Push (Key pair) من Firebase Console > Project Settings > Cloud Messaging > Web Push certificates.
  /// استخدم المفتاح العام (Key pair) فقط — ليس المفتاح الخاص (Private key) من APNs.
  /// الطول المتوقع للمفتاح الصحيح حوالي 88 حرفاً (base64url). أي مسافات تُزال تلقائياً.
  // NOTE: هذه هي القيمة التي كانت مستخدمة سابقاً في getToken(vapidKey: ...)
  // وتم نقلها هنا لتُستخدم كمصدر واحد صحيح لمفتاح الويب.
  static const String? webVapidKey =
      'BMXS-KbqGXjuuWNZ9fUnt2-OMiTjiB0hT9emgKU1iytzSiX0sYKDP2ysKlXO2aRJpaWhfIhcvrFytWLAqGuddUU';

  static bool _listenerAttached = false;

  /// Call once at app start (e.g. after Firebase.initializeApp() in main.dart).
  /// Requests permission, gets token with retry, and subscribes to onTokenRefresh.
  /// على الويب: المتصفح لا يظهر نافذة الصلاحية إلا بعد تفاعل المستخدم (كليك)، لذلك نؤجل الطلب لأول ضغطة.
  static Future<void> initAtAppStart() async {
    try {
      if (kIsWeb) {
        _attachTokenRefreshListener();
        return;
      }
      await _requestPermission();
      await _getTokenWithRetry();
      _attachTokenRefreshListener();
    } catch (e) {
      debugPrint('⚠️ FcmTokenService.initAtAppStart error: $e');
    }
  }

  static bool _webPermissionRequested = false;
  static bool _webPromptShownThisSession = false;

  /// للويب فقط: تعرض نافذة في بداية التطبيق تطلب تفعيل الإشعارات؛ عند الضغط على "السماح" يظهر طلب صلاحية المتصفح.
  static void showWebNotificationPromptIfNeeded(BuildContext context) {
    if (!kIsWeb || _webPromptShownThisSession || !context.mounted) return;
    _webPromptShownThisSession = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.notifications.tr()),
        content: Text(
          context.locale.languageCode == 'ar'
              ? 'السماح بالإشعارات لاستقبال التحديثات المهمة؟'
              : 'Allow notifications to receive important updates?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.locale.languageCode == 'ar' ? 'لاحقاً' : 'Not now'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await requestPermissionAndTokenIfWeb();
              // إرسال التوكن في start_app للويب فقط بعد الحصول عليه (لا يؤثر على الموبايل)
              if (kIsWeb && getCachedToken() != null && context.mounted) {
                await AppSettingsService.getUserSettingsAndUpdateTheStoredSettings(context: context);
              }
            },
            child: Text(context.locale.languageCode == 'ar' ? 'السماح' : 'Allow'),
          ),
        ],
      ),
    );
  }

  /// للويب فقط: استدعِها بعد ضغطة المستخدم لطلب صلاحية الإشعارات ثم جلب الـ token.
  static Future<void> requestPermissionAndTokenIfWeb() async {
    if (!kIsWeb) return;
    debugPrint('🔔 FCM Web: requestPermissionAndTokenIfWeb called (already requested? $_webPermissionRequested)');
    final cached = getCachedToken();
    // لو عندنا توكن صالح بالفعل، لا داعي لإعادة الطلب
    if (cached != null && cached.isNotEmpty) {
      debugPrint('🔔 FCM Web: token already cached (${cached.length} chars) — skipping request.');
      return;
    }
    // لو permission اتطلب قبل كده لكن لسه مافيش توكن، اسمح بمحاولة جديدة
    if (_webPermissionRequested) {
      debugPrint('🔔 FCM Web: permission was already requested but token is null — retrying getToken only.');
      try {
        await _getTokenWithRetry();
        final token = getCachedToken();
        final hasValidToken = token != null && token.isNotEmpty;
        debugPrint('🔔 FCM Web (retry): بعد الطلب — التوكن في الكاش: ${hasValidToken ? "موجود (${token!.length} حرف)" : "غير موجود أو فاضي"}');
      } catch (e) {
        debugPrint('⚠️ FcmTokenService.requestPermissionAndTokenIfWeb retry error: $e');
      }
      return;
    }
    _webPermissionRequested = true;
    try {
      await _requestPermission();
      await _getTokenWithRetry();
      final token = getCachedToken();
      final hasValidToken = token != null && token.isNotEmpty;
      debugPrint('🔔 FCM Web: بعد الطلب — التوكن في الكاش: ${hasValidToken ? "موجود (${token.length} حرف)" : "غير موجود أو فاضي"}');
    } catch (e) {
      debugPrint('⚠️ FcmTokenService.requestPermissionAndTokenIfWeb error: $e');
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
  /// على الويب يجب استدعاء getToken(vapidKey: ...) وإلا يرجع null — الموبايل بدون تغيير.
  static Future<void> _getTokenWithRetry() async {
    const maxAttempts = 10;
    const delayBetweenAttempts = Duration(seconds: 2);

    if (kIsWeb && (webVapidKey == null || webVapidKey!.isEmpty)) {
      debugPrint('⚠️ FCM Web: التوكن مش هيُجاب — webVapidKey = null. ضع FcmTokenService.webVapidKey من Firebase Console > Project Settings > Cloud Messaging > Web Push certificates');
      await CacheHelper.deleteData(key: _cacheKey);
      return;
    }

    // على الويب: إزالة أي مسافات/أسطر من المفتاح (المتصفح يرفض المفتاح إذا كان فيه مسافات)
    final String vapidKeyForWeb =
        webVapidKey!.replaceAll(RegExp(r'\s'), '');
    if (kIsWeb) {
      debugPrint('🔔 FCM Web: طول مفتاح VAPID: ${vapidKeyForWeb.length} (المتوقع ~88)');
    }

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final String? token = kIsWeb
            ? await FirebaseMessaging.instance.getToken(
                vapidKey: vapidKeyForWeb,
              )
            : await FirebaseMessaging.instance.getToken();
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
  /// يعيد null إذا القيمة فاضية عشان نتعامل معها كـ "مافيش توكن".
  static String? getCachedToken() {
    final v = CacheHelper.getString(_cacheKey);
    return (v != null && v.isNotEmpty) ? v : null;
  }
}
