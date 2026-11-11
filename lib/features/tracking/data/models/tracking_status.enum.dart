import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
  Color get baseColor {
    switch (this) {
      case RequestTrackingStatus.active:
        return Color(AppColors.successGreen);
      case RequestTrackingStatus.completed:
        return Color(AppColors.buttons);
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

/// State of one tracking session (leg).
enum TrackingSessionStatus {
  active,
  completed,
  interrupted,
  cancelled;

  String getLabel({bool isArabic = true}) {
    switch (this) {
      case TrackingSessionStatus.active:
        return 'active_2'.tr();
      case TrackingSessionStatus.completed:
        return 'completed_2'.tr();
      case TrackingSessionStatus.interrupted:
        return 'interrupted'.tr();
      case TrackingSessionStatus.cancelled:
        return 'cancelled_2'.tr();
    }
  }

  Color get color {
    switch (this) {
      case TrackingSessionStatus.active:
        return Color(AppColors.successGreen);
      case TrackingSessionStatus.completed:
        return Color(AppColors.buttons);
      case TrackingSessionStatus.interrupted:
        return Color(AppColors.warningYellow);
      case TrackingSessionStatus.cancelled:
        return _kNeutral;
    }
  }

  IconData get icon {
    switch (this) {
      case TrackingSessionStatus.active:
        return Icons.radio_button_checked_rounded;
      case TrackingSessionStatus.completed:
        return Icons.check_circle_outline_rounded;
      case TrackingSessionStatus.interrupted:
        return Icons.pause_circle_outline_rounded;
      case TrackingSessionStatus.cancelled:
        return Icons.block_rounded;
    }
  }
}

/// What the phone can do with the location right now (spec: mobile §5). Anything but [ok] is shown
/// to the employee as a clear banner, never as a silent gap.
enum TrackingLocationState {
  ok,
  waitingForLocation,
  permissionRequired,
  permissionLimited,
  offline;

  String get title {
    switch (this) {
      case TrackingLocationState.ok:
        return '';
      case TrackingLocationState.waitingForLocation:
        return 'tracking_waiting_for_location'.tr();
      case TrackingLocationState.permissionRequired:
        return 'tracking_permission_required'.tr();
      case TrackingLocationState.permissionLimited:
        return 'tracking_permission_limited'.tr();
      case TrackingLocationState.offline:
        return 'tracking_offline'.tr();
    }
  }

  String get message {
    switch (this) {
      case TrackingLocationState.ok:
        return '';
      case TrackingLocationState.waitingForLocation:
        return 'tracking_waiting_for_location_hint'.tr();
      case TrackingLocationState.permissionRequired:
        return 'tracking_permission_required_hint'.tr();
      case TrackingLocationState.permissionLimited:
        return 'tracking_permission_limited_hint'.tr();
      case TrackingLocationState.offline:
        return 'tracking_offline_hint'.tr();
    }
  }

  Color get color {
    switch (this) {
      case TrackingLocationState.ok:
        return Color(AppColors.successGreen);
      case TrackingLocationState.waitingForLocation:
        return Color(AppColors.buttons);
      case TrackingLocationState.permissionRequired:
        return Color(AppColors.failureRed);
      case TrackingLocationState.permissionLimited:
      case TrackingLocationState.offline:
        return Color(AppColors.warningYellow);
    }
  }

  IconData get icon {
    switch (this) {
      case TrackingLocationState.ok:
        return Icons.my_location_rounded;
      case TrackingLocationState.waitingForLocation:
        return Icons.gps_not_fixed_rounded;
      case TrackingLocationState.permissionRequired:
        return Icons.location_disabled_rounded;
      case TrackingLocationState.permissionLimited:
        return Icons.location_searching_rounded;
      case TrackingLocationState.offline:
        return Icons.cloud_off_rounded;
    }
  }

  /// Whether the banner has a button that opens the phone's location settings.
  bool get hasSettingsAction =>
      this == TrackingLocationState.permissionRequired ||
      this == TrackingLocationState.permissionLimited;
}

/// Live presence of an employee on the group map (spec: mobile screen 4, employee status card).
enum EmployeeTrackingPresence {
  active,
  stopped,
  offline,
  noActiveTracking;

  static EmployeeTrackingPresence fromRaw(String raw) {
    switch (raw) {
      case 'active':
        return EmployeeTrackingPresence.active;
      case 'completed':
      case 'stopped':
        return EmployeeTrackingPresence.stopped;
      case 'offline':
        return EmployeeTrackingPresence.offline;
      default:
        return EmployeeTrackingPresence.noActiveTracking;
    }
  }

  String get label {
    switch (this) {
      case EmployeeTrackingPresence.active:
        return 'active_2'.tr();
      case EmployeeTrackingPresence.stopped:
        return 'tracking_stopped'.tr();
      case EmployeeTrackingPresence.offline:
        return 'tracking_offline'.tr();
      case EmployeeTrackingPresence.noActiveTracking:
        return 'no_active_tracking'.tr();
    }
  }

  Color get color {
    switch (this) {
      case EmployeeTrackingPresence.active:
        return Color(AppColors.successGreen);
      case EmployeeTrackingPresence.stopped:
        return Color(AppColors.buttons);
      case EmployeeTrackingPresence.offline:
        return Color(AppColors.warningYellow);
      case EmployeeTrackingPresence.noActiveTracking:
        return _kNeutral;
    }
  }

  IconData get icon {
    switch (this) {
      case EmployeeTrackingPresence.active:
        return Icons.radio_button_checked_rounded;
      case EmployeeTrackingPresence.stopped:
        return Icons.stop_circle_outlined;
      case EmployeeTrackingPresence.offline:
        return Icons.cloud_off_rounded;
      case EmployeeTrackingPresence.noActiveTracking:
        return Icons.remove_circle_outline_rounded;
    }
  }
}
