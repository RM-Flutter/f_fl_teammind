import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_test/core/models/settings/user_settings_2.model.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/notification_service/local_notification_service.dart';

class CheckInScheduler {
  static const String lastScheduleMonthKey = 'last_schedule_month';

  static Future<void> scheduleNotifications(BuildContext context) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    
    String? hireDate;
    bool isCheckInActive = false;

    // Check US1 Cache for Check-In package and hire_date
    final us1Cache = CacheHelper.getString("US1");
    if (us1Cache != null && us1Cache.isNotEmpty) {
      try {
        final gCache = json.decode(us1Cache) as Map<String, dynamic>;
        hireDate ??= gCache['hire_date']?.toString();
        
        final userSettings = UserSettingsModel.fromJson(gCache);
        final avFingerprint = userSettings.avFingerprint;
        if (avFingerprint != null) {
          for (var entry in avFingerprint.entries) {
            final val = entry.value?.toString().toLowerCase().trim();
            if (val == 'active_all' || val == 'active_some') {
              isCheckInActive = true;
              break;
            }
          }
        }
      } catch (e) {
        debugPrint('Error parsing US1: $e');
      }
    }

    if (!isCheckInActive) {
      debugPrint("Check-in package is not active. Canceling all local notifications.");
      await LocalNotificationService.cancelAllNotifications();
      return;
    }

    // Check if already scheduled for the current month
    final lastMonth = prefs.getInt(lastScheduleMonthKey);
    if (lastMonth == now.month) {
      debugPrint("Notifications already scheduled for this month.");
      return;
    }

    // Fetch off-days from API
    List<String> offDays = [];
    try {
      final response = await DioHelper.getData(
        url: "/emp_requests/v1/off-days-this-month",
        query: {},
        context: context,
      );

      if (response.data != null && response.data['off_days'] is List) {
        final List<dynamic> offDaysList = response.data['off_days'];
        for (var item in offDaysList) {
          if (item is Map && item['date'] != null) {
            offDays.add(item['date'].toString());
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching off-days: $e");
      return;
    }

    // Cancel previous alarms
    await LocalNotificationService.cancelAllNotifications();

    // Get Working Hours & Hire Date from US2 Cache
    String? workingHoursFrom;
    String? workingHoursTo;

    final us2Cache = CacheHelper.getString("US2");
    if (us2Cache != null && us2Cache.isNotEmpty) {
      try {
        final Map<String, dynamic> us2Json = json.decode(us2Cache);
        hireDate ??= us2Json['hire_date']?.toString();

        if (us2Json['worktime'] != null) {
          workingHoursFrom = us2Json['worktime']['working_hours_from']?.toString();
          workingHoursTo = us2Json['worktime']['working_hours_to']?.toString();
        }
      } catch (e) {
        debugPrint('Error parsing US2: $e');
      }
    }

    int idCounter = 1;

    // Schedule Check-in and Check-out
    if (workingHoursFrom != null && workingHoursTo != null) {
      final fromParts = workingHoursFrom.split(':');
      final toParts = workingHoursTo.split(':');
      if (fromParts.length >= 2 && toParts.length >= 2) {
        final fromHour = int.tryParse(fromParts[0]) ?? 9;
        final fromMinute = int.tryParse(fromParts[1]) ?? 0;
        final toHour = int.tryParse(toParts[0]) ?? 17;
        final toMinute = int.tryParse(toParts[1]) ?? 0;

        final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
        for (int day = now.day; day <= daysInMonth; day++) {
          final date = DateTime(now.year, now.month, day);
          final dateStr = DateFormat('yyyy-MM-dd').format(date);

          if (!offDays.contains(dateStr)) {
            // Schedule Check-In 5 minutes before
            final checkInDate = DateTime(date.year, date.month, date.day, fromHour, fromMinute).subtract(const Duration(minutes: 5));
            if (checkInDate.isAfter(now)) {
              await LocalNotificationService.scheduleNotification(
                id: idCounter++,
                title: "attendance_reminder".tr(),
                body: "check_in_reminder_body".tr(),
                scheduledDate: checkInDate,
              );
            }

            // Schedule Check-Out exactly at time
            final checkOutDate = DateTime(date.year, date.month, date.day, toHour, toMinute);
            if (checkOutDate.isAfter(now)) {
              await LocalNotificationService.scheduleNotification(
                id: idCounter++,
                title: "attendance_reminder".tr(),
                body: "check_out_reminder_body".tr(),
                scheduledDate: checkOutDate,
              );
            }
          }
        }
      }
    }

    // Schedule Work Anniversary Notification
    if (hireDate != null && hireDate.isNotEmpty) {
      try {
        final parsedHireDate = DateTime.parse(hireDate);
        if (parsedHireDate.month == now.month) {
          int years = now.year - parsedHireDate.year;
          // Only if it's 1 year or more, and the date hasn't passed this month
          if (years >= 1) {
            final anniversaryDate = DateTime(now.year, parsedHireDate.month, parsedHireDate.day, 10, 0); // 10:00 AM
            if (anniversaryDate.isAfter(now)) {
              await LocalNotificationService.scheduleNotification(
                id: idCounter++,
                title: "happy_work_anniversary".tr(),
                body: "thank_you_for_your_dedication".tr(),
                scheduledDate: anniversaryDate,
              );
            }
          }
        }
      } catch (e) {
        debugPrint("Error parsing hire_date: $e");
      }
    }

    // Save schedule state
    await prefs.setInt(lastScheduleMonthKey, now.month);
    debugPrint("Scheduled ${idCounter - 1} notifications for this month.");
  }
}
