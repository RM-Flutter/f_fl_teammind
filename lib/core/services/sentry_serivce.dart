import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  static String? _currentScreenName;
  static BuildContext? _currentContext;

  /// Initialize Sentry
  /// NOTE: Replace YOUR_SENTRY_DSN_HERE with your actual Sentry DSN
  static Future<void> init() async {
    try {
      // TODO: Replace with your actual Sentry DSN
      const dsn =
          'https://0d94befc800e6d6d3a2aa7025b0b1435@o4509722812284928.ingest.us.sentry.io/4510596001038336';

      if (dsn == 'YOUR_SENTRY_DSN_HERE') {
        debugPrint(
            '⚠️ Sentry DSN not configured. Please set your DSN in sentry_service.dart');
        return;
      }

      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.tracesSampleRate =
              1.0; // Capture 100% of transactions for performance monitoring
          options.environment = kDebugMode ? 'development' : 'production';
          // Screen name will be added via scope.setExtra in setCurrentScreen and capture methods
        },
        appRunner: () {
          // App will run after Sentry initialization
        },
      );

      debugPrint('✅ Sentry service initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Sentry initialization error: $e');
    }
  }

  /// Set current screen name (call this when navigating to a new screen)
  static void setCurrentScreen(String screenName, {BuildContext? context}) {
    _currentScreenName = screenName;
    _currentContext = context;

    debugPrint('📍 Screen tracked: $screenName');

    try {
      Sentry.configureScope((scope) {
        scope.setTag('screen', screenName);
        scope.setExtra('screen_name', screenName);
        scope.setExtra('screen_timestamp', DateTime.now().toIso8601String());
      });
    } catch (e) {
      debugPrint('⚠️ Error setting screen name in Sentry: $e');
    }
  }

  /// Get current screen name from GoRouter
  static String? getCurrentScreenName(BuildContext? context) {
    if (context != null) {
      try {
        final router = GoRouter.of(context);
        final route = router.routerDelegate.currentConfiguration.uri.path;
        if (route.isNotEmpty) {
          // Extract screen name from route
          final parts = route.split('/');
          if (parts.length >= 3) {
            // Format: /lang/screen-name
            return parts[2];
          }
          return route;
        }
      } catch (e) {
        debugPrint('Error getting screen name from router: $e');
      }
    }
    return _currentScreenName ?? 'unknown';
  }

  /// Capture exception with screen name
  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? screenName,
    Map<String, dynamic>? extra,
    String? hint,
  }) async {
    final screen = screenName ??
        _currentScreenName ??
        getCurrentScreenName(_currentContext) ??
        'unknown';

    debugPrint('🚨 Sentry Error [Screen: $screen]: ${exception.toString()}');
    if (stackTrace != null) {
      debugPrint('   StackTrace: ${stackTrace.toString()}');
    }
    if (extra != null) {
      debugPrint('   Extra: $extra');
    }

    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: hint != null ? Hint.withMap({'hint': hint}) : null,
        withScope: (scope) {
          scope.setTag('screen', screen);
          scope.setExtra('screen_name', screen);
          scope.setExtra('screen_timestamp', DateTime.now().toIso8601String());
          if (extra != null) {
            extra.forEach((key, value) {
              scope.setExtra('extra_$key', value);
            });
          }
        },
      );
    } catch (e) {
      debugPrint('⚠️ Error capturing exception to Sentry: $e');
    }
  }

  /// Capture message with screen name
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    String? screenName,
    Map<String, dynamic>? extra,
  }) async {
    final screen = screenName ??
        _currentScreenName ??
        getCurrentScreenName(_currentContext) ??
        'unknown';

    debugPrint('📝 Sentry Message [Screen: $screen] [$level]: $message');
    if (extra != null) {
      debugPrint('   Extra: $extra');
    }

    try {
      await Sentry.captureMessage(
        message,
        level: level,
        withScope: (scope) {
          scope.setTag('screen', screen);
          scope.setExtra('screen_name', screen);
          scope.setExtra('screen_timestamp', DateTime.now().toIso8601String());
          if (extra != null) {
            extra.forEach((key, value) {
              scope.setExtra('extra_$key', value);
            });
          }
        },
      );
    } catch (e) {
      debugPrint('⚠️ Error capturing message to Sentry: $e');
    }
  }

  /// Helper method to wrap a function with error tracking
  static Future<T> captureErrors<T>({
    required Future<T> Function() action,
    String? screenName,
    Map<String, dynamic>? extra,
  }) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      await captureException(
        e,
        stackTrace: stackTrace,
        screenName: screenName,
        extra: extra,
      );
      rethrow;
    }
  }
}
