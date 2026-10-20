import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
        return isArabic ? "بدون تتبع" : "No Tracking";
      case RequestTrackingStatus.optionalNotStarted:
        return isArabic ? "تتبع اختياري / لم يبدأ" : "Optional / Not Started";
      case RequestTrackingStatus.requiredNotStarted:
        return isArabic ? "تتبع مطلوب / لم يبدأ" : "Required / Not Started";
      case RequestTrackingStatus.active:
        return isArabic ? "جارٍ التتبع الآن" : "Tracking Active";
      case RequestTrackingStatus.completed:
        return isArabic ? "اكتمل التتبع" : "Tracking Completed";
      case RequestTrackingStatus.requiredMissing:
        return isArabic ? "تتبع مفقود (مطلوب)" : "Tracking Missing";
    }
  }

  Color get textColor {
    switch (this) {
      case RequestTrackingStatus.active:
        return const Color(0xff2D6A4F); // successGreen
      case RequestTrackingStatus.completed:
        return const Color(0xFF090B60); // titleTextColor
      case RequestTrackingStatus.requiredNotStarted:
        return const Color(0xffE65100); // deep orange
      case RequestTrackingStatus.requiredMissing:
        return const Color(0xffc72c41); // errorColor
      case RequestTrackingStatus.optionalNotStarted:
        return const Color(0xff606060); // subtitleTextColor
      case RequestTrackingStatus.notRequired:
        return const Color(0xFFA3A3A3);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case RequestTrackingStatus.active:
        return const Color(0xFFE8F5E9); // green 50
      case RequestTrackingStatus.completed:
        return const Color(0xFFE3F2FD); // blue 50
      case RequestTrackingStatus.requiredNotStarted:
        return const Color(0xFFFFF3E0); // orange 50
      case RequestTrackingStatus.requiredMissing:
        return const Color(0xFFFFEBEE); // red 50
      case RequestTrackingStatus.optionalNotStarted:
        return const Color(0xFFF5F8FA);
      case RequestTrackingStatus.notRequired:
        return Colors.transparent;
    }
  }

  Color get borderColor {
    switch (this) {
      case RequestTrackingStatus.active:
        return const Color(0xFF4CAF50);
      case RequestTrackingStatus.completed:
        return const Color(0xFF3389EE);
      case RequestTrackingStatus.requiredNotStarted:
        return const Color(0xFFFCA652);
      case RequestTrackingStatus.requiredMissing:
        return const Color(0xFFEF5350);
      case RequestTrackingStatus.optionalNotStarted:
        return const Color(0xFFDFDFDF);
      case RequestTrackingStatus.notRequired:
        return Colors.transparent;
    }
  }

  IconData get icon {
    switch (this) {
      case RequestTrackingStatus.active:
        return Icons.radio_button_checked;
      case RequestTrackingStatus.completed:
        return Icons.check_circle_outline;
      case RequestTrackingStatus.requiredNotStarted:
        return Icons.error_outline_rounded;
      case RequestTrackingStatus.requiredMissing:
        return Icons.cancel_outlined;
      case RequestTrackingStatus.optionalNotStarted:
        return Icons.radio_button_unchecked;
      case RequestTrackingStatus.notRequired:
        return Icons.remove;
    }
  }
}

enum TrackingSessionStatus {
  active,
  completed,
  interrupted,
  cancelled;

  String getLabel({bool isArabic = true}) {
    switch (this) {
      case TrackingSessionStatus.active:
        return isArabic ? "نشطة" : "Active";
      case TrackingSessionStatus.completed:
        return isArabic ? "مكتملة" : "Completed";
      case TrackingSessionStatus.interrupted:
        return isArabic ? "انقطاع تلقائي" : "Interrupted";
      case TrackingSessionStatus.cancelled:
        return isArabic ? "ملغاة" : "Cancelled";
    }
  }

  Color get color {
    switch (this) {
      case TrackingSessionStatus.active:
        return const Color(0xff2D6A4F);
      case TrackingSessionStatus.completed:
        return const Color(0xFF3389EE);
      case TrackingSessionStatus.interrupted:
        return const Color(0xffFCA652);
      case TrackingSessionStatus.cancelled:
        return const Color(0xffc72c41);
    }
  }
}
