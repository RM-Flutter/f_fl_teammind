import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../constants/app_colors.dart';

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
    final s = status?.toLowerCase().trim();
    switch (s) {
      case 'approved':
        return Colors.green;
      case 'waiting_seen':
      case 'waiting_cancel':
      case 'waiting':
        return Color(AppColors.darkGrey);
      default:
        return Colors.transparent;
    }
  }
}
