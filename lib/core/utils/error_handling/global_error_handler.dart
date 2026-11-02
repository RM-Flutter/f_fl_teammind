import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/app_error_reporter.dart';
import '../../services/sentry_serivce.dart';

/// Nothing may crash the app or show a technical error to the user:
/// every uncaught error is sent to Sentry and the Telegram channel, and the user only
/// sees a friendly "please contact the RightMind team" message.
void registerErrorHandlers() {
  // Errors thrown by the Flutter framework (build, layout, paint, gestures...)
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
    // Layout overflows and failed network images are not crashes: report quietly, no alert
    if (_isQuietFrameworkError(details)) {
      if (!_isImageLoadError(details)) {
        AppErrorReporter.report(details.exception, stackTrace: details.stack, hint: _hintOf(details));
      }
      return;
    }
    SentryService.captureException(details.exception, stackTrace: details.stack);
    AppErrorReporter.handleUncaught(details.exception, details.stack, hint: _hintOf(details));
  };

  // Uncaught async errors (futures, streams, platform channels). Returning true marks them
  // handled, so they never crash the app.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint(error.toString());
    SentryService.captureException(error, stackTrace: stack);
    AppErrorReporter.handleUncaught(error, stack);
    return true;
  };

  // A widget that fails to build is simply left out: the rest of the screen still shows.
  // (FlutterError.onError above already reported it and showed the friendly message.)
  ErrorWidget.builder = (FlutterErrorDetails details) => const SizedBox.shrink();
}

/// Where it happened, plus the widget Flutter blames (with its source file and line), e.g.
/// "during layout | Column Column:file:///.../task_screen.dart:145:18". Without the widget, an
/// overflow or build error can't be traced to a screen.
String? _hintOf(FlutterErrorDetails details) {
  final where = details.context?.toDescription();
  String? widget;
  try {
    final text = details.toString();
    final line = text.split('\n').firstWhere((l) => l.contains('file:///'), orElse: () => '');
    if (line.isNotEmpty) {
      widget = line.trim().replaceAll(RegExp(r'file:///.*?/lib/'), 'lib/');
    }
  } catch (_) {}
  return [where, widget].whereType<String>().join(' | ').trim().isEmpty
      ? null
      : [where, widget].whereType<String>().join(' | ');
}

bool _isImageLoadError(FlutterErrorDetails details) {
  final library = details.library ?? '';
  final text = details.exceptionAsString();
  return library.contains('image resource') ||
      text.contains('NetworkImageLoadException') ||
      text.contains('HttpException: Invalid statusCode') ||
      text.contains('No host specified in URI');
}

bool _isQuietFrameworkError(FlutterErrorDetails details) {
  final text = details.exceptionAsString();
  return _isImageLoadError(details) ||
      text.contains('overflowed by') ||
      text.contains('A RenderFlex overflowed') ||
      // Showing the error alert (itself a snackbar) here would repeat this error every frame
      text.contains('SnackBar presented off screen');
}
