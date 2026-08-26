import 'package:app_test/core/models/settings/user_settings_2.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'local_notification_service.dart';

class CheckInScheduler {
  static const String lastScheduleDateKey = 'last_schedule_date';
  
  static Future<void> scheduleAlarmsForNext30Days(UserSettings2Model userSettings2) async {
    // Check if check_in package is available 
    // Using CacheHelper to see av_fingerprint if available or just proceed since we check on server too
    final now = DateTime.now();
    
    // Save last schedule date
    await CacheHelper.setString(key: lastScheduleDateKey, value: now.toIso8601String());

    // Clear previous alarms
    await LocalNotificationService.cancelAllNotifications();

    final worktime = userSettings2.worktime;
    if (worktime == null || worktime.workingHoursFrom == null || worktime.workingHoursTo == null) {
      return;
    }

    final String fromStr = worktime.workingHoursFrom!;
    final String toStr = worktime.workingHoursTo!;
    
    // Parse time like "09:00:00"
    final fromParts = fromStr.split(':');
    final toParts = toStr.split(':');
    if (fromParts.length < 2 || toParts.length < 2) return;

    final fromHour = int.tryParse(fromParts[0]) ?? 9;
    final fromMinute = int.tryParse(fromParts[1]) ?? 0;
    final toHour = int.tryParse(toParts[0]) ?? 17;
    final toMinute = int.tryParse(toParts[1]) ?? 0;

    final List<String> weekends = userSettings2.weekend ?? [];
    final List<Holiday> holidays = userSettings2.holidays ?? [];
    final List<String> approvedLeaves = userSettings2.approvedLeaveDays ?? [];

    int daysScheduled = 0;
    int idCounter = 1;

    for (int i = 0; i < 60 && daysScheduled < 30; i++) {
      final date = now.add(Duration(days: i));
      
      // Check weekend
      final dayName = DateFormat('EEEE').format(date).toLowerCase(); // e.g. monday
      bool isWeekend = weekends.any((w) => w.toLowerCase() == dayName);
      if (isWeekend) continue;

      // Check holidays
      bool isHoliday = false;
      for (var holiday in holidays) {
        if (holiday.from != null && holiday.to != null) {
          try {
            final fromDate = DateTime.parse(holiday.from!);
            final toDate = DateTime.parse(holiday.to!);
            // Compare dates ignoring time
            final checkDate = DateTime(date.year, date.month, date.day);
            final fDate = DateTime(fromDate.year, fromDate.month, fromDate.day);
            final tDate = DateTime(toDate.year, toDate.month, toDate.day);
            
            if (checkDate.compareTo(fDate) >= 0 && checkDate.compareTo(tDate) <= 0) {
              isHoliday = true;
              break;
            }
          } catch (e) {
            debugPrint("Error parsing holiday dates: $e");
          }
        }
      }
      if (isHoliday) continue;

      // Check approved leaves (assuming format is yyyy-MM-dd)
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      if (approvedLeaves.contains(dateStr)) continue;

      // Schedule Check In
      final checkInDate = DateTime(date.year, date.month, date.day, fromHour, fromMinute);
      if (checkInDate.isAfter(now)) {
        await LocalNotificationService.scheduleNotification(
          id: idCounter++,
          title: "check_in_title".tr(),
          body: "check_in_body".tr(),
          scheduledDate: checkInDate,
        );
      }

      // Schedule Check Out
      final checkOutDate = DateTime(date.year, date.month, date.day, toHour, toMinute);
      if (checkOutDate.isAfter(now)) {
        await LocalNotificationService.scheduleNotification(
          id: idCounter++,
          title: "check_out_title".tr(),
          body: "check_out_body".tr(),
          scheduledDate: checkOutDate,
        );
      }

      daysScheduled++;
    }
  }
}
