import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:rmemp/general_services/localization.service.dart';

abstract class DateService {
  /// Method to convert ISO 8601 date-time string to a specific format
  static String? formatDate(local,context,String? isoDate, {String? format = 'dd/MM/yyyy'}) {
    if (isoDate == null || format == null) {
      return null;
    }
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat(format, local ).format(dateTime);
    } catch (e) {
      return 'Invalid date format';
    }
  }

  /// Method to get the current date in a specific format
  static String getCurrentDate({String format = 'dd/MM/yyyy'}) {
    DateTime now = DateTime.now();
    return DateFormat(format).format(now);
  }

  /// Method to convert a DateTime object to a specific format
  static String formatDateTime(DateTime? dateTime,
      {String? format = 'yyyy-MM-dd'}) {
    if (dateTime == null || format == null) {
      return 'Invalid date';
    }
    return DateFormat(format).format(dateTime);
  }

  static String formateDateTimeBeforeSendToServer(
      {required DateTime dateTime}) {
    String format = (dateTime.hour != 0 || dateTime.minute != 0)
        ? 'yyyy-MM-dd HH:mm'
        : 'yyyy-MM-dd';
    return formatDateTime(dateTime, format: format);
  }

  /// Method to parse a formatted date string back to DateTime
  static DateTime? parseDate(String? formattedDate,
      {String? format = 'dd/MM/yyyy'}) {
    if (formattedDate == null || format == null) {
      return null;
    }
    try {
      return DateFormat(format).parse(formattedDate);
    } catch (e) {
      return null;
    }
  }

  static String? getWeekdayName(String? dateString, context) {
    try {
      if (dateString == null || dateString.isEmpty) return null;
      
      DateTime? date = _parseDateWithMultipleFormats(dateString);
      if (date == null) return null;

      // Format the date to get the weekday name (e.g., Mon, Tue)
      String weekday = DateFormat('EEE', LocalizationService.isArabic(context: context) ?"ar" :"en").format(date);

      return weekday;
    } catch (e) {
      return null;
    }
  }

  static int? getDaysInMonth(String? dateString) {
    try {
      if (dateString == null || dateString.isEmpty) return null;
      
      DateTime? date = _parseDateWithMultipleFormats(dateString);
      if (date == null) return null;
      
      return date.day;
    } catch (ex) {
      return null;
    }
  }

  /// Helper method to parse date string with multiple formats
  static DateTime? _parseDateWithMultipleFormats(String dateString) {
    // Try different date formats
    List<String> formats = [
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd',
      'dd-MM-yyyy HH:mm:ss',
      'dd-MM-yyyy',
      'dd/MM/yyyy HH:mm:ss',
      'dd/MM/yyyy',
    ];
    
    for (String format in formats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (e) {
        continue;
      }
    }
    
    // If all formats fail, try DateTime.parse as last resort
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
