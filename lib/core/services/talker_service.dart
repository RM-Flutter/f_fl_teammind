import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../routing/app_router.dart';

class TalkerLoggerService {
  static final Talker talker = TalkerFlutter.init(
    settings: TalkerSettings(
      useConsoleLogs: true, // Output to console in all modes to help web debugging
      maxHistoryItems: 500,
    ),
    logger: TalkerLogger(
      settings: TalkerLoggerSettings(
        enableColors: true,
      ),
    ),
  );

  static TalkerDioLogger get dioLogger => TalkerDioLogger(
    talker: talker,
    settings: const TalkerDioLoggerSettings(
      printRequestHeaders: true,
      printResponseHeaders: false,
      printResponseMessage: true,
      printRequestData: true,
      printResponseData: true,
    ),
  );

  static void init() {
    FlutterError.onError = (details) {
      talker.handle(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      talker.handle(error, stack);
      return true;
    };
  }

  static void info(String msg) => talker.info(msg);
  static void error(String msg, [Object? error, StackTrace? stackTrace]) => talker.error(msg, error, stackTrace);
  static void warning(String msg) => talker.warning(msg);

  // Can be called anywhere to show the UI
  static void openInspector([BuildContext? context]) {
    final navigator = rootNavigatorKey.currentState;
    if (navigator != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => TalkerScreen(talker: talker),
        ),
      );
    } else if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TalkerScreen(talker: talker),
        ),
      );
    } else {
      print("Error: Navigator not found. Cannot open Talker inspector.");
    }
  }
}
