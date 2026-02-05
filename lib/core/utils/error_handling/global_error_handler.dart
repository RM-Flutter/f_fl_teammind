// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:app_test/core/services/telegram_error_service.dart';
//
// void registerErrorHandlers() {
//   // * Show some error UI if any uncaught exception happens
//   FlutterError.onError = (FlutterErrorDetails details) {
//     FlutterError.presentError(details);
//     debugPrint(details.toString());
//     // Send to Telegram
//     TelegramErrorService.captureException(
//       details.exception,
//       stackTrace: details.stack,
//     );
//   };
//   // * Handle errors from the underlying platform/OS
//   PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
//     debugPrint(error.toString());
//     // Send to Telegram
//     TelegramErrorService.captureException(error, stackTrace: stack);
//     return true;
//   };
//   // * Show some error UI when any widget in the app fails to build
//   ErrorWidget.builder = (FlutterErrorDetails details) {
//     // Send to Telegram
//     TelegramErrorService.captureException(
//       details.exception,
//       stackTrace: details.stack,
//     );
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.red,
//           title: const Text('An error occurred'),
//         ),
//         body: Center(child: Text(details.toString())),
//       ),
//     );
//   };
// }
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/sentry_serivce.dart';

void registerErrorHandlers() {
  // * Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
    // Send to Sentry
    SentryService.captureException(
      details.exception,
      stackTrace: details.stack,
    );
  };
  // * Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint(error.toString());
    // Send to Sentry
    SentryService.captureException(error, stackTrace: stack);
    return true;
  };
  // * Show some error UI when any widget in the app fails to build
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'حدث خطأ غير متوقع\n\n${details.exceptionAsString()}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  };
}
