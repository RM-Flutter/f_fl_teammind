import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'app_error_reporter.dart';

/// Drop-in for [Fluttertoast.showToast] that never shows technical text:
/// errors are replaced by the friendly message and reported to Telegram.
abstract class AppToast {
  static Future<bool?> showToast({
    required String msg,
    Toast? toastLength,
    int timeInSecForIosWeb = 1,
    double? fontSize,
    String? fontAsset,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    bool webShowClose = false,
    webBgColor = "linear-gradient(to right, #00b09b, #96c93d)",
    webPosition = "right",
  }) {
    return Fluttertoast.showToast(
      msg: AppErrorReporter.safeMessage(msg),
      toastLength: toastLength,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
      fontAsset: fontAsset,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  }
}
