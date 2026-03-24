import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../general_services/telegram_error_service.dart';

void registerErrorHandlers() {
  // * Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
    // Send to Telegram
    TelegramErrorService.captureException(
      details.exception,
      stackTrace: details.stack,
    );
  };
  // * Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint(error.toString());
    // Send to Telegram
    TelegramErrorService.captureException(error, stackTrace: stack);
    return true;
  };
  // * Show some error UI when any widget in the app fails to build.
  // Wrapped in Directionality (and Material) so it works even when invoked
  // before MaterialApp is built (e.g. early startup errors).
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: const Text('An error occurred'),
          ),
          body: Center(child: Text(details.toString())),
        ),
      ),
    );
  };
}
