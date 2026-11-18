import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';

/// Neutral grey used for "nothing to show" states (same grey as field hints).
const Color _kNeutral = Color(0xFF8A8FA3);

/// Tracking state of a whole request (simplified, see the spec "Request-Level Status").
/// Colours come from the app palette and are split with [AppColors.statusTones], like every
/// other status badge in the app.
enum RequestTrackingStatus {
  notRequired,
  optionalNotStarted,
  requiredNotStarted,
  active,
  completed,
  requiredMissing;

  /// Server value of `tracking.status` (see the API doc "مرجع القيم").
  static RequestTrackingStatus fromRaw(String? raw) {
    switch (raw) {
      case 'optional_not_started':
        return RequestTrackingStatus.optionalNotStarted;
      case 'required_not_started':
        return RequestTrackingStatus.requiredNotStarted;
      case 'active':
        return RequestTrackingStatus.active;
      case 'completed':
        return RequestTrackingStatus.completed;
      case 'required_missing':
        return RequestTrackingStatus.requiredMissing;
      default:
        return RequestTrackingStatus.notRequired;
    }
  }

  String getLabel({bool isArabic = true}) {
    switch (this) {
      case RequestTrackingStatus.notRequired:
        return 'no_tracking'.tr();
      case RequestTrackingStatus.optionalNotStarted:
        return 'optional_not_started'.tr();
      case RequestTrackingStatus.requiredNotStarted:
        return 'required_not_started'.tr();
      case RequestTrackingStatus.active:
        return 'tracking_active'.tr();
      case RequestTrackingStatus.completed:
        return 'tracking_completed'.tr();
      case RequestTrackingStatus.requiredMissing:
        return 'tracking_missing'.tr();
    }
  }

  /// The one colour of this status; badges derive text / tint / border from it.
  /// API doc: active = blue, completed = green, required not started = yellow, missing = red.
  Color get baseColor {
    switch (this) {
      case RequestTrackingStatus.active:
        return Color(AppColors.buttons);
      case RequestTrackingStatus.completed:
        return Color(AppColors.successGreen);
      case RequestTrackingStatus.requiredNotStarted:
        return Color(AppColors.warningYellow);
      case RequestTrackingStatus.requiredMissing:
        return Color(AppColors.failureRed);
      case RequestTrackingStatus.optionalNotStarted:
      case RequestTrackingStatus.notRequired:
        return _kNeutral;
    }
  }

  Color get textColor => AppColors.statusTones(baseColor).text;
  Color get backgroundColor => AppColors.statusTones(baseColor).tint;
  Color get borderColor => AppColors.statusTones(baseColor).border;

  IconData get icon {
    switch (this) {
      case RequestTrackingStatus.active:
        return Icons.radio_button_checked_rounded;
      case RequestTrackingStatus.completed:
        return Icons.check_circle_outline_rounded;
      case RequestTrackingStatus.requiredNotStarted:
        return Icons.error_outline_rounded;
      case RequestTrackingStatus.requiredMissing:
        return Icons.cancel_outlined;
      case RequestTrackingStatus.optionalNotStarted:
        return Icons.radio_button_unchecked_rounded;
      case RequestTrackingStatus.notRequired:
        return Icons.remove_rounded;
    }
  }
}

