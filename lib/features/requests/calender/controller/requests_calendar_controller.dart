import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class RequestsCalendarViewModel extends ChangeNotifier {
  CalendarView? calendarView = CalendarView.month;
  final List<Map<String, dynamic>> calendarViews = [
    // day view
    {'name': AppStrings.day.tr(), 'value': CalendarView.day},
    // week view
    {'name': AppStrings.week.tr(), 'value': CalendarView.week},
    // month view
    {'name': AppStrings.month.tr(), 'value': CalendarView.month},
    // schedule view
    {'name': AppStrings.schedule.tr(), 'value': CalendarView.schedule},
    // Timeline day view
    {'name': AppStrings.timelineDay.tr(), 'value': CalendarView.timelineDay},
    // Timeline week view
    {'name': AppStrings.timelineWeek.tr(), 'value': CalendarView.timelineWeek},
    // Timeline month view
    {'name': AppStrings.timelineMonth.tr(), 'value': CalendarView.timelineMonth},
  ];
  void updateCalendarView(CalendarView view) {
    calendarView = view;
    notifyListeners();
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase().trim()) {
      case 'approved':
        return Colors.green;
      // case 'refused' || 'canceled':
      //   return Colors.red;
      case 'waiting_seen' || 'waiting_cancel'|| 'waiting':
        return Color(AppColors.darkGrey);
      default:
        return Colors.transparent;
    }
  }
}
