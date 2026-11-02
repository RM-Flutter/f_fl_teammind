import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_strings.dart';
import '../routing/app_router.dart';
import 'alert_service/alerts_service.dart';
import 'backend_services/api_service/dio_api_service/shared.dart';
import 'telegram_error_service.dart';

/// One place for technical errors:
///  - the user never sees technical text: it is replaced by a friendly
///    "please contact the RightMind team" message
///  - the real error is sent to the Telegram channel (same error at most once per 5 minutes)
abstract class AppErrorReporter {
  static const Duration _dedupeWindow = Duration(minutes: 5);
  static final Map<String, DateTime> _recentlyReported = {};
  static DateTime? _lastAlertShownAt;

  /// Text shown to the user instead of any technical error.
  static String get friendlyMessage {
    try {
      return AppStrings.unexpectedErrorContactTeam.tr();
    } catch (_) {
      return 'Something went wrong. Please contact the RightMind team.';
    }
  }

  static final List<RegExp> _technicalPatterns = [
    RegExp(r'exception', caseSensitive: false),
    RegExp(r'\b(Type|Range|State|Argument|NoSuchMethod|Assertion|Cast|Format|Unsupported|LateInitialization|Concurrent\w*)Error\b'),
    RegExp(r'Null check operator', caseSensitive: false),
    RegExp(r'is not a subtype of', caseSensitive: false),
    RegExp(r"Instance of '", caseSensitive: false),
    RegExp(r'Bad state', caseSensitive: false),
    RegExp(r'Invalid argument', caseSensitive: false),
    RegExp(r'Unexpected (character|end of input|token)', caseSensitive: false),
    RegExp(r'Failed host lookup|Connection (refused|reset|closed)|errno|OS Error', caseSensitive: false),
    RegExp(r'XMLHttpRequest|status code of \d{3}|Http status error|Internal Server Error|Server Error', caseSensitive: false),
    RegExp(r'SQLSTATE|Illuminate\\|vendor/|Call to (a member function|undefined)|Undefined (index|variable|array key|property)|Attempt to read property', caseSensitive: false),
    RegExp(r'\.dart[: ]\d|package:\w+/|#\d+\s+\S+\s+\(|dart:\w+', caseSensitive: false),
    RegExp(r"type '[^']+' is not", caseSensitive: false),
  ];

  /// True when [text] looks like a developer error rather than a message written for users.
  static bool isTechnical(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    return _technicalPatterns.any((p) => p.hasMatch(text));
  }

  /// Text that is safe to show the user.
  ///
  /// Error/Exception objects and technical text are reported to Telegram and replaced by
  /// [friendlyMessage]; normal messages (e.g. validation messages from the server) are kept.
  static String safeMessage(
    Object? errorOrMessage, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
    String? fallback,
  }) {
    if (errorOrMessage == null) return fallback ?? friendlyMessage;

    final isErrorObject = errorOrMessage is Error || errorOrMessage is Exception;
    final text = errorOrMessage.toString();

    if (isErrorObject || isTechnical(text)) {
      report(errorOrMessage, stackTrace: stackTrace ?? StackTrace.current, extra: extra);
      return fallback ?? friendlyMessage;
    }
    return text;
  }

  /// Send a technical error to Telegram (deduplicated).
  static void report(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
    String? hint,
  }) {
    // Every occurrence goes to the device log with a fixed tag, so errors can be collected
    // while the phone is connected: adb logcat | grep TM-ERROR
    _logToConsole(error, stackTrace, hint);
    try {
      final key = error.toString().length > 300 ? error.toString().substring(0, 300) : error.toString();
      final now = DateTime.now();
      _recentlyReported.removeWhere((_, at) => now.difference(at) > _dedupeWindow);
      if (_recentlyReported.containsKey(key)) return;
      _recentlyReported[key] = now;

      TelegramErrorService.captureException(
        error,
        stackTrace: stackTrace,
        hint: hint,
        extra: {..._appContext(), ...?extra},
      );
    } catch (e) {
      debugPrint('AppErrorReporter.report failed: $e');
    }
  }

  /// One compact block per error: the message, where it happened, the current route and the
  /// first app frames of the stack (frames from Flutter/Dart internals are skipped).
  static void _logToConsole(Object error, StackTrace? stackTrace, String? hint) {
    try {
      String? route;
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        route = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
      }
      final lines = (stackTrace?.toString() ?? '').split('\n').where((l) => l.trim().isNotEmpty);
      var frames = lines.where((l) => l.contains('package:app_test/')).take(6);
      // Framework errors (e.g. from a widget's build) may have no app frames: show the top ones
      final label = frames.isEmpty ? '    (no app frames, top of stack:)\n' : '';
      if (frames.isEmpty) frames = lines.take(4);
      debugPrint('[TM-ERROR] ${error.runtimeType}: ${error.toString().split('\n').first}\n'
          '  where: ${hint ?? '-'} | route: ${route ?? '-'}\n'
          '$label${frames.map((l) => '    ${l.trim()}').join('\n')}\n'
          '[TM-ERROR-END]');
    } catch (_) {
      // Logging must never throw
    }
  }

  /// Uncaught error: report it and tell the user once (at most every 10 seconds), never crash.
  static void handleUncaught(Object error, StackTrace? stackTrace, {String? hint}) {
    report(error, stackTrace: stackTrace, hint: hint);

    final now = DateTime.now();
    if (_lastAlertShownAt != null && now.difference(_lastAlertShownAt!) < const Duration(seconds: 10)) {
      return;
    }
    _lastAlertShownAt = now;

    try {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        AlertsService.error(context: context, title: AppStrings.somethingWentWrong, message: friendlyMessage);
      }
    } catch (_) {
      // Showing the alert must never throw
    }
  }

  /// App/user details added to every Telegram report.
  static Map<String, dynamic> _appContext() {
    final info = <String, dynamic>{
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'build': kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug'),
    };
    try {
      info['domain'] = CacheHelper.getString('domain');
      final us1 = CacheHelper.getString('US1');
      if (us1 != null && us1.isNotEmpty) {
        final data = json.decode(us1);
        final user = data is Map ? (data['data'] ?? data) : null;
        if (user is Map) {
          info['user'] = '${user['name'] ?? ''} (#${user['id'] ?? user['user_id'] ?? '?'})';
        }
      }
    } catch (_) {}
    info.removeWhere((_, v) => v == null || v.toString().isEmpty);
    return info;
  }
}
