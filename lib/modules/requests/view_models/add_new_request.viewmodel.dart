import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/string_convert.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/modules/requests/views/widgets/successfull_add_request_sheet.dart';
import '../../../general_services/alert_service/alerts.service.dart';
import '../../../general_services/date.service.dart';
import '../../../general_services/image_file_picker.service.dart';
import '../../../general_services/settings.service.dart';
import '../../../models/operation_result.model.dart';
import '../../../models/settings/general_settings.model.dart';
import '../../../models/settings/user_settings_2.model.dart';
import '../../../routing/app_router.dart';
import '../../../services/requests.services.dart';

class AddNewRequestViewModel extends ChangeNotifier {
  Map<String, dynamic>? selectedRequestType;
  String? selectReqId;
  bool? isAddRequestLoading = false;
  String? errorAddRequestMessage;
  List<Map<String, dynamic>>? requestsTypes;
  TextEditingController controller = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController fileController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  XFile? XImageFileAttachmentPersonal;
  File? attachmentPersonalImage;
  List listAttachmentPersonalImage = [];
  List<XFile> listXAttachmentPersonalImage = [];
  FilePickerResult? attachedFile;
  List<Map<String, dynamic>> departments = [];
  String? errorMessage;
  DateTimeRange? selectedDateOrDatetimeRange;
  num? duration;
  var reqType;
  var halfDay;
  var reqTypeFile;
  var reqTypeMoney;
  String? notes;
  String? selectReqType;
  String? selectStatus;
  bool isLoading = false;
  String? selectedRequestTypes;
  final picker = ImagePicker();
  List status = [
    "canceled", "approved", "seen", "waiting_seen"
  ];
  Future<void> getImage( context, {image1, image2, list, bool one = true, list2}) =>
      showModalBottomSheet<void>(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          backgroundColor: Colors.white,
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Select Photo",
                      style: TextStyle(
                          fontSize: 20, color: Color(0xFF011A51)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () async {
                                await getProfileImageByGallery();
                                await image2 == null
                                    ? null
                                    : Image.asset(
                                    "assets/images/profileImage.png");
                                Navigator.pop(context);
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.image,
                                  color: Color(0xFF011A51),
                                ),
                              ),
                            ),
                            Text("Gallery",
                              style: TextStyle(
                                  fontSize: 18, color: Color(0xFF011A51)),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                await getProfileImageByCam();
                                print(image1);
                                print(image2);
                                await image2 == null
                                    ? null
                                    : Image.asset(
                                    "assets/images/profileImage.png");
                                Navigator.pop(context);
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.camera,
                                  color: Color(0xFF011A51),
                                ),
                              ),
                            ),
                            Text(
                              "Camera",
                              style: TextStyle(fontSize: 18, color: Color(0xFF011A51)),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
  void initializeAddNewRequestScreen({required BuildContext context}) {
    // Initialize your request types here
    _resetValues();
    getDepartment(context: context);
    _getRequestTypes(context: context);
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    reasonController.dispose();
    fileController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _resetValues() {
    selectedRequestType = null;
    requestsTypes = null;
    controller = TextEditingController();
    reasonController = TextEditingController();
    fileController = TextEditingController();
    amountController = TextEditingController();
    attachedFile = null;
    selectedDateOrDatetimeRange = null;
    duration = null;
    notes = null;
  }
  var formattedDuration;
  /// USED WHEN THE DURATION TYPE IN OFFICAIL HOLIDAYS
  Future<void> selectInsteadOfHolidays(BuildContext context,
      {required String? startDateOrDatetime,
      required String? endDateOrDatetime}) async {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm');
    if (startDateOrDatetime == null || endDateOrDatetime == null) {
      AlertsService.warning(
          context: context,
          message: 'please select offical holiday again !',
          title: AppStrings.warning.tr());
      return;
    }
    DateTime start;
    DateTime end;
    bool containsTime =
        startDateOrDatetime.contains(' ') || endDateOrDatetime.contains(' ');

    if (containsTime) {
      // Parse date and time
      start = dateTimeFormatter.parse(startDateOrDatetime);
      end = dateTimeFormatter.parse(endDateOrDatetime);
    } else {
      // Parse date only
      start = dateFormatter.parse(startDateOrDatetime);
      end = dateFormatter.parse(endDateOrDatetime);
    }

    selectedDateOrDatetimeRange = DateTimeRange(start: start, end: end);
    return;
  }

  Future<void> selectDate(BuildContext context,{bool filter = false}) async {
    final String? type = reqType;
    // check if the type is days then show the date range picker
    if(filter == false && reqType == null){
      AlertsService.warning(
          context: context,
          message: AppStrings.pleaseSelectRequestType.tr(),
          title: AppStrings.warning.tr());
      return;
    } if(filter == true && selectReqId == null){
      AlertsService.warning(
          context: context,
          message: AppStrings.pleaseSelectRequestType.tr(),
          title: AppStrings.warning.tr());
      return;
    }
    if(type == null){
      await _selectDateRange(context);
    }
    if (type!.toLowerCase().trim() == 'days') {
      await _selectDateRange(context);
    }
    // check if the type is hours then show date time picker
    else if (type.toLowerCase().trim() == 'hours' || type.toLowerCase().trim() == 'minutes') {
      await _selectDateTimeRange(context);
    }
    // check if the type is instead of holidays then thow list of official holidays to choose from
    else {
      await _selectDateRange(context);
      // AlertsService.warning(
      //     context: context,
      //     message: 'Could not get the request time type, please try later',
      //     title: AppStrings.warning.tr());
      // return;
    }
    if (selectedDateOrDatetimeRange == null) {
      AlertsService.warning(
          context: context,
          message: AppStrings.pleaseSelectRequestDuration.tr(),
          title: AppStrings.warning.tr());
      return;
    }
    controller.text = formatDateTimeRange(context,selectedDateOrDatetimeRange!);
    _calcDuration(context: context);
    notifyListeners();
  }
  Future<void> selectDateFilter(BuildContext context,{bool filter = false}) async {
    // check if the type is days then show the date range picker
    await _selectDateRange(context);
    if (selectedDateOrDatetimeRange == null) {
      AlertsService.warning(
          context: context,
          message: AppStrings.pleaseSelectRequestDuration.tr(),
          title: AppStrings.warning.tr());
      return;
    }
    controller.text = formatDateTimeRange(context,selectedDateOrDatetimeRange!);
    _calcDuration(context: context);
    notifyListeners();
  }

  /// USED WHEN THE DURATION TYPE IN THE SELECTED REQUEST IS DAYS
  Future<void> _selectDateRange(BuildContext context) async {
    final newDateRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDateRange: selectedDateOrDatetimeRange);
    if (newDateRange == null) return;
    selectedDateOrDatetimeRange = newDateRange;
  }

  /// USED WHEN THE DURATION TYPE IN THE SELECTED REQUEST IS (HOURS OR MINUTES)
  Future<void> _selectDateTimeRange(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      switchToInputEntryModeIcon: const Icon(Icons.add, color: Colors.transparent,),
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedStartTime = await showTimePicker(
        helpText: AppStrings.startTime.tr(),
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: const TimePickerThemeData(
                helpTextStyle: TextStyle(            // Style applied here
                  color: Color(AppColors.dark),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      final TimeOfDay? pickedEndTime = await showTimePicker(
        context: context,
        helpText:  AppStrings.endTime.tr(),
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: const TimePickerThemeData(
                helpTextStyle: TextStyle(            // Style applied here
                  color: Color(AppColors.dark),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedStartTime != null && pickedEndTime != null) {
        final startDateTime = _convertToDateTime(pickedDate, pickedStartTime);
        final endDateTime = _convertToDateTime(pickedDate, pickedEndTime);

        if (startDateTime.isAfter(endDateTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Start time must be before end time.')),
          );
          return;
        }

        // Set the selected range
        selectedDateOrDatetimeRange = DateTimeRange(
          start: startDateTime,
          end: endDateTime,
        );

        // Determine request type
        final duration = selectedDateOrDatetimeRange!.duration;
        final isSameDay = selectedDateOrDatetimeRange!.start.day == selectedDateOrDatetimeRange!.end.day;

        if (isSameDay && duration.inHours < 24) {
          reqType = 'hours';
        } else {
          if(halfDay == true){
            reqType = 'hours';
          }else {
            reqType = 'days';
          }
        }

        // Get and print the formatted duration
        formattedDuration = getFormattedDuration(duration);
        print('Duration: $formattedDuration');
      }
    }
  }

  DateTime _convertToDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String getFormattedDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    print("halfDay--->${halfDay}");
    if(halfDay == true){
      return '$hours ${AppStrings.hours.tr()} $minutes ${AppStrings.minutes.tr()}';
    } else if (hours > 0 && minutes > 0) {
      return '$hours ${AppStrings.hours.tr()} $minutes ${AppStrings.minutes.tr()}';
    } else if (hours > 0) {
      return '$hours ${AppStrings.hours.tr()}';
    } else {
      return '$minutes ${AppStrings.minutes.tr()}';
    }
  }

  /// USED TO GET FORMATED STRING FROM THE SELECTED DATE || DATETIME
  String formatDateTimeRange(BuildContext context, DateTimeRange range) {
    final isArabic = LocalizationService.isArabic(context: context);
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd', isArabic ? 'ar' : 'en');
    final DateFormat timeFormatter = DateFormat('HH:mm', isArabic ? 'ar' : 'en');
    final DateFormat dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm', isArabic ? 'ar' : 'en');

    String startDateStr = dateFormatter.format(range.start);
    String endDateStr = dateFormatter.format(range.end);

    bool hasStartTime = range.start.hour != 0 || range.start.minute != 0;
    bool hasEndTime = range.end.hour != 0 || range.end.minute != 0;


    if ((hasStartTime || hasEndTime) && startDateStr == endDateStr) {
      String startTime = timeFormatter.format(range.start);
      String endTime = timeFormatter.format(range.end);
      return '$startDateStr | $startTime - $endTime';
    } else if (hasStartTime || hasEndTime) {
      String startDateTimeStr = dateTimeFormatter.format(range.start);
      String endDateTimeStr = dateTimeFormatter.format(range.end);
      return '$startDateTimeStr : $endDateTimeStr';
    } else {
      return '$startDateStr : $endDateStr';
    }
  }
  void getDepartment({required BuildContext context}) {
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
      url: "/departments/entities-operations",
      context: context,
    ).then((value){
      isLoading = false;
      departments = List<Map<String, dynamic>>.from(value.data['data']);
      notifyListeners();
    }).catchError((error){
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    });
  }
  Future<void> pickFile() async {
    FilePickerResult? result = await FileAndImagePickerService.pickFile();
    if (result != null) {
      attachedFile = result;
      fileController.text = result.files.single.name;
    }
    notifyListeners();
  }

  void _getRequestTypes({required BuildContext context}) {
    try {
      var jsonString;
      var gCache;
      jsonString = CacheHelper.getString("US2");
      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
        gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
        UserSettingConst.userSettings2 = UserSettings2Model.fromJson(gCache);
      }
      print("HI 1");
      // Fetch user2Settings data from app settings

      // Fetch generalSettings data from app settings

      // get user balance from User2Settings
      final userBalance = gCache['balance'];
      // check if the user balance is null || empty then there is no requests types
      if (userBalance == null || userBalance.isEmpty) {
        requestsTypes = [];
        return;
      }
      print("HI 2");
      // Fetch request types from generalSettings and if there is no request types in generalSettings then return requests types with empty list
      print("TYPE IS --> ${UserSettingConst.generalSettingsModel!.requestTypes}");
      final requestsTypesDataFromGeneralSettings = UserSettingConst.generalSettingsModel!.requestTypes;
      if (requestsTypesDataFromGeneralSettings == null ||
          requestsTypesDataFromGeneralSettings.isEmpty) {
        requestsTypes = [];
        return;
      }

      // looping on user balance to get the available requests types with considering the the balance and it can be listed or not
      userBalance.forEach((requestId, val) {
        final userBalanceRequestType = userBalance[requestId];
        final max = userBalanceRequestType?['max'];
        if (max != null &&
            requestsTypesDataFromGeneralSettings.containsKey(requestId)) {
          if (max == -1 || ((userBalanceRequestType?['take'] ?? 0) < max)) {
            requestsTypes ??= [];
            requestsTypes!.add((requestsTypesDataFromGeneralSettings[requestId]
                ?.toJson() as Map<String, dynamic>));
            print("requestsTypes is --> $requestsTypes");
            if(requestsTypes != null && requestsTypes!.isNotEmpty){
              AppConstants.requestsTypess = requestsTypes;
            }
          }
        }
      });
      return;
    } catch (ex, t) {
      debugPrint(
          'Error getting request types ${ex.toString()} at :- ${t.toString()}');
      requestsTypes = [];
    }
  }

  Map<String, String> _filterNonNullValues(Map<String, String?> map) {
    final filteredMap = <String, String>{};
    for (var entry in map.entries) {
      if (entry.value != null) {
        filteredMap[entry.key] = entry.value!;
      }
    }
    return filteredMap;
  }

  void _calcDuration({required BuildContext context}) {
    if (selectedDateOrDatetimeRange == null) {
      duration = 0;
      formattedDuration = null; // Clear formatted duration
      return;
    }
    final String? type = reqType;
    // check if the type is days then duration will be in days
    bool isSameDate(DateTime date1, DateTime date2) {
      return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
    }

    final selectedDate = selectedDateOrDatetimeRange!.start;
    final selectedDates = selectedDateOrDatetimeRange!.end;
    final now = DateTime.now();

    // Check if start date equals end date AND both equal today
    final isStartEndSame = isSameDate(selectedDate, selectedDates);
    final isStartToday = isSameDate(selectedDate, now);
    final isEndToday = isSameDate(selectedDates, now);
    final isSameDay = isStartEndSame && isStartToday && isEndToday;
    
    // If it's a days type request with halfDay enabled and start/end are the same day and it's today, calculate as half day
    print("isSameDay --> ${isSameDay}");
    print("halfDay --> ${halfDay}");
    print("type --> ${type?.toLowerCase().trim()}");
    if(type?.toLowerCase().trim() == 'days' && halfDay == true && isSameDay){
      checkHalfDate(context, selectedDate.toString());
    }
    else if(type?.toLowerCase().trim() == 'days' && halfDay == true && !isSameDay){
      print("I AM HERE");
      formattedDuration = null; // Clear formatted duration before calculating days
      _getDateDifferenceWithoutWeekendsAndOfficailHolidays(context: context);
    }
   else if (type?.toLowerCase().trim() == 'days' && halfDay == false) {
      formattedDuration = null; // Clear formatted duration before calculating days
      _getDateDifferenceWithoutWeekendsAndOfficailHolidays(context: context);
      return;
    }
    // check if the type is hours then duration will be in hours
    else if (type?.toLowerCase().trim() == 'hours' ||
        type?.toLowerCase().trim() == 'minutes') {
      _getHoursDifference(context: context);
      return;
    }else{
      formattedDuration = null; // Clear formatted duration before calculating days
      _getDateDifferenceWithoutWeekendsAndOfficailHolidays(context: context);
    }
  }
  void _getHoursDifference({required BuildContext context}) {
    final totalMinutes = selectedDateOrDatetimeRange?.duration.inMinutes ?? 0;
    duration = double.parse((totalMinutes / 60).toStringAsFixed(1)); // Always store duration in minutes
    notifyListeners();
  }
  bool isWeekendOrHolidayDateFromString(BuildContext context, String dateString) {
    DateTime? date;
    try {
      date = DateTime.parse(dateString);
    } catch (e) {
      // Parsing failed, treat as not weekend/holiday
      return false;
    }

    // Load user settings from cache (similar to your other method)
    final user2Settings = UserSettingConst.userSettings2;
    var jsonString = CacheHelper.getString("US2");
    if (jsonString != null && jsonString.isNotEmpty) {
      final gCache = json.decode(jsonString) as Map<String, dynamic>;
      UserSettingConst.userSettings2 = UserSettings2Model.fromJson(gCache);
    }
    GeneralSettingsModel? generalSettingsModel;
    var gCache2;

    var jsonString2 = CacheHelper.getString("USG");
    if (jsonString2 != null && jsonString2.isNotEmpty) {
      gCache2 = json.decode(jsonString2) as Map<String, dynamic>;
      UserSettingConst.generalSettingsModel = GeneralSettingsModel.fromJson(gCache2);
      generalSettingsModel = GeneralSettingsModel.fromJson(gCache2);

    }
    // Get general settings with holidays list
    final generalSettings = generalSettingsModel;
    final List<HolidayOrString>? holidays = generalSettings!.holidays;

    // Map weekday int to string
    final Map<int, String> weekdaysMap = {
      1: 'monday',
      2: 'tuesday',
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday',
    };

    // Check weekend
    final defaultWeekendDays = ['saturday', 'sunday'];
    final weekendDays = user2Settings?.weekend ?? defaultWeekendDays;

    // If weekend is 'variable', treat as no weekend (custom handling)
    if (!weekendDays.contains('variable')) {
      final dayName = weekdaysMap[date.weekday];
      if (dayName != null && weekendDays.contains(dayName)) {
        return true; // It's a weekend
      }
    }
      print("holidays is --> $holidays");
      print("canUseHolidays is --> ${user2Settings?.canUseHolidays}");
    // Check holidays if user can use holidays
    if (user2Settings?.canUseHolidays == true && holidays != null && holidays.isNotEmpty) {
      print("holidays is --> $holidays");
      print("canUseHolidays is --> ${user2Settings?.canUseHolidays}");
      print("weekendDays is --> $weekendDays");
      print("date is --> $date");
      print("date.weekday is --> ${date.weekday}");
      print("weekdaysMap is --> $weekdaysMap");
      print("weekdaysMap[date.weekday] is --> ${weekdaysMap[date.weekday]}");
      print("weekendDays.contains(weekdaysMap[date.weekday]) is --> ${weekendDays.contains(weekdaysMap[date.weekday])}");
      print("weekendDays.contains(weekdaysMap[date.weekday]) is --> ${weekendDays.contains(weekdaysMap[date.weekday])}");
      for (var holidayOrString in holidays) {
        if (holidayOrString.holiday != null) {
          final holidayStart = DateTime.parse(holidayOrString.holiday!.from!);
          final holidayEnd = DateTime.parse(holidayOrString.holiday!.to!);
          // Check if date falls within holiday range (inclusive)
          if (!date.isBefore(holidayStart) && !date.isAfter(holidayEnd)) {
            // Also ensure date is not weekend to avoid double counting (optional)
            if (!weekendDays.contains(weekdaysMap[date.weekday])) {
              return true; // It's an official holiday
            }
          }
        }
      }
    }

    // If none matched
    return false;
  }

  void checkHalfDate(BuildContext context, date) {
    String dateString = date;
    bool isWeekend = isWeekendOrHolidayDateFromString(context, dateString);
    duration = isWeekend ? 0 : 0.5;
    // Set formattedDuration to show "0.5" or "نصف يوم" for half day
    if (duration == 0.5) {
      formattedDuration = '0.5 ${AppStrings.days.tr()}';
      notifyListeners();
    } else {
      formattedDuration = '0 ${AppStrings.days.tr()}';
      notifyListeners();
    }
    notifyListeners();
    print('$dateString is weekend? $isWeekend');
  }
  void _getDateDifferenceWithoutWeekendsAndOfficailHolidays({required BuildContext context}) {
    var jsonString2;
    var gCache;
    GeneralSettingsModel? generalSettingsModel;
    jsonString2 = CacheHelper.getString("USG");
    if (jsonString2 != null && jsonString2.isNotEmpty && jsonString2 != "") {
      gCache = json.decode(jsonString2) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.generalSettingsModel = GeneralSettingsModel.fromJson(gCache);
      generalSettingsModel = GeneralSettingsModel.fromJson(gCache);
    }
    var jsonString;
    var gCache2;
    jsonString = CacheHelper.getString("US2");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache2 = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings2 = UserSettings2Model.fromJson(gCache2);
    }
    final user2Settigns = UserSettingConst.userSettings2;

    int nbDays = 0;
    final List<HolidayOrString>? holidays = generalSettingsModel!.holidays;
    List<int> weekendDays = [];
    List<String> weekendDaysNames = [];
    Map<int, String> weekdaysMap = {
      1: 'monday',
      2: 'tuesday',
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday',
    };

    // First: Subtracting Weekends if the Current user not Variable [means that the current user follows the weekend system]
   print("WEEK HOLIDAY IS --->${user2Settigns!.weekend}");
    if (user2Settigns!.weekend?.contains('variable') == false) {
      DateTime currentDay = selectedDateOrDatetimeRange!.start;
      while (currentDay.isBefore(
          selectedDateOrDatetimeRange!.end.add(const Duration(days: 1)))) {
        int dayOfWeek = currentDay.weekday;

        // Check if the current day is a weekend day
        final weekendDaysList = user2Settigns.weekend;
        if (weekendDaysList != null &&
            weekendDaysList.contains(weekdaysMap[dayOfWeek])) {
          nbDays++;
          weekendDays.add(dayOfWeek);
        }
        currentDay = currentDay.add(const Duration(days: 1));
      }

      // Calculate the duration after subtracting weekends
      duration =
          ((selectedDateOrDatetimeRange?.duration.inDays ?? 0) + 1) - nbDays;

      // Convert weekend days from integer to week day names
      for (var element in weekendDays) {
        if (weekdaysMap.containsKey(element)) {
          weekendDaysNames.add(weekdaysMap[element]!);
        }
      }

      notes = nbDays != 0
          ? 'New Request Subtracting ${weekendDaysNames.length} as the Weekends Days'
          : null;
    }

    debugPrint(
        '1- duration after subtracting weekends |||||||||||||||||| $duration');

    // Second: Subtracting Holidays if the Current user can use holidays
      print("holidays is --> $holidays");
      print("canUseHolidays is --> ${user2Settigns.canUseHolidays}");
    if (user2Settigns.canUseHolidays == true && holidays != null) {
      int holidayDays = 0;

      for (var holidayOrString in holidays) {
        if (holidayOrString.holiday != null) {
          DateTime holidayStart =
              DateTime.parse(holidayOrString.holiday!.from!);
          DateTime holidayEnd = DateTime.parse(holidayOrString.holiday!.to!);

          DateTime currentDay = selectedDateOrDatetimeRange!.start;
          while (currentDay.isBefore(
              selectedDateOrDatetimeRange!.end.add(const Duration(days: 1)))) {
            if (currentDay
                    .isAfter(holidayStart.subtract(const Duration(days: 1))) &&
                currentDay.isBefore(holidayEnd.add(const Duration(days: 1))) &&
                !weekendDays.contains(currentDay.weekday)) {
              holidayDays++;
            }
            currentDay = currentDay.add(const Duration(days: 1));
          }
        }
      }

      duration = (duration ?? 0) - holidayDays;
      if ((duration ?? 0) < 0) duration = 0;
      if (holidayDays != 0) {
        notes =
            '${notes ?? ''} \n New Request Subtracting $holidayDays as the Official Holidays';
      }
    }

    debugPrint(
        '2- duration after subtracting holidays |||||||||||||||||| $duration');
    notifyListeners();
  }

  String getHoursOrDayesStringDependsOnRequestType() {
    print("HOUSRS US --> ${ (reqType as String?)?.trim().toLowerCase() }");
    if (selectedRequestType == null) return '';
    return (reqType as String?)?.trim().toLowerCase() ==
            'days' ?  AppStrings.days.tr() : (reqType as String?)?.trim().toLowerCase() == 'hours'
        ?  AppStrings.hours.tr() : AppStrings.minutes.tr();
  }

  Future<void> createNewRequest({required BuildContext context}) async {
    try {
      // First Validate on the main data
      // if (selectedRequestType == null ||
      //     (selectedRequestType?.isEmpty ?? true)) {
      //   AlertsService.info(
      //       context: context,
      //       message: AppStrings.pleaseSelectRequestType.tr(),
      //       title: AppStrings.information.tr());
      //   return;
      // }
      if (selectedDateOrDatetimeRange == null) {
        AlertsService.info(
            context: context,
            message: AppStrings.pleaseSelectRequestDuration.tr(),
            title: AppStrings.information.tr());
        return;
      }
      if (reasonController.text.isEmpty) {
        AlertsService.info(
            context: context,
            message: AppStrings.pleaseEnterTheReasonForTheRequest.tr(),
            title: AppStrings.information.tr());
        return;
      }

      // Second Validate on the optional data
      final attachingFile =
          (reqTypeFile as String?)
              ?.toLowerCase()
              .trim();
      final isAttachingFile =
          attachingFile == 'required';
      if (isAttachingFile && attachedFile == null) {
        AlertsService.info(
            context: context,
            message: AppStrings.pleaseAttachFile.tr(),
            title: AppStrings.information.tr());
        return;
      }
      final moneyValue =
          (selectedRequestType?['fields']?['money_value'] as String?)
              ?.toLowerCase()
              .trim();
      final isMoneyValue =
          moneyValue == 'required';
      if (isMoneyValue && amountController.text.isEmpty) {
        AlertsService.info(
            context: context,
            message: AppStrings.pleaseEnterAmount.tr(),
            title: AppStrings.failed.tr());
        return;
      }
      // Finally, send Request to server create new request
      print("isAttachingFile $attachingFile");

      final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss'); // include time
      final selectedDate = selectedDateOrDatetimeRange!.start;
      final now = DateTime.now();

      bool isSameDate(DateTime date1, DateTime date2) {
        return date1.year == date2.year &&
            date1.month == date2.month &&
            date1.day == date2.day;
      }
      final isToday = isSameDate(selectedDate, now);
      print("ISTODAY --> $isToday");
      final requestMainData = {
        'emp_request_type_id': selectReqType.toString(),
        'date_from': StringConvert.sanitizeDateString(dateTimeFormat.format(selectedDateOrDatetimeRange!.start)),
        'date_to': StringConvert.sanitizeDateString(dateTimeFormat.format(selectedDateOrDatetimeRange!.end)),
        // 'date_from': normalizeDateToEnglish(DateService.formateDateTimeBeforeSendToServer(
        //     dateTime: selectedDateOrDatetimeRange!.start)).toString(),
        // 'date_to': normalizeDateToEnglish(DateService.formateDateTimeBeforeSendToServer(
        //     dateTime: selectedDateOrDatetimeRange!.end)).toString(),
        'duration': (StringConvert.sanitizeDateString(dateTimeFormat.format(selectedDateOrDatetimeRange!.start)) == StringConvert.sanitizeDateString(dateTimeFormat.format(selectedDateOrDatetimeRange!.end)) &&
        halfDay == true && isToday == true)? "0.5":duration.toString(),
        'reason': reasonController.text,
        if(amountController.text.isNotEmpty)'money_value' : amountController.text,
      };
      if (isMoneyValue) {
        requestMainData['money_value'] = amountController.text;
      }

      final OperationResult<Map<String, dynamic>> result;
      // using form data request to the server
      result = await RequestsServices.createNewRequestWithFile(
          context: context,
          requestData: _filterNonNullValues(requestMainData),
          files:
              (isAttachingFile && attachedFile != null) ? [attachedFile!] : []);

      if (result.success) {
        _resetValues();
        notifyListeners();
        if (kIsWeb) {
          // Use showDialog for web to ensure it's fully visible
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              final screenHeight = MediaQuery.of(dialogContext).size.height;
              final screenWidth = MediaQuery.of(dialogContext).size.width;
              return Dialog(
                alignment: Alignment.center,
                insetPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.2,
                  vertical: screenHeight * 0.15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.6,
                    maxWidth: 500,
                  ),
                  child: SuccessfullAddRequestSheet(),
                ),
              );
            },
          );
        }
        else {
          // Use showModalBottomSheet for mobile
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // This makes the BottomSheet full-screen
            backgroundColor: Colors.white, // Optional, for styling
            builder: (context) {
              return SuccessfullAddRequestSheet();
            },
          );
        }
        return;
      } else {

        if (result.data?['duration'] != null &&
            result.data?['duration'] != '') {
          bool resendRequestWithTheCorrectDuration =
              await AlertsService.confirmMessage(context, '${result.message}',
                  message:
                      '${AppStrings.doYouWantToResendYourRequestWithTheCorrectDurationis.tr()} ${result.data?['duration']} ${getHoursOrDayesStringDependsOnRequestType()} ?');
          if (resendRequestWithTheCorrectDuration) {
            requestMainData['duration'] = result.data!['duration'].toString();
            final resendRequestResult =
                await RequestsServices.createNewRequestWithFile(
                    context: context,
                    requestData: _filterNonNullValues(requestMainData),
                    files: (isAttachingFile && attachedFile != null)
                        ? [attachedFile!]
                        : []);
            if (resendRequestResult.success) {
              _resetValues();
              notifyListeners();
              if (kIsWeb) {
                // Use showDialog for web to ensure it's fully visible
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    final screenHeight = MediaQuery.of(dialogContext).size.height;
                    final screenWidth = MediaQuery.of(dialogContext).size.width;
                    return Dialog(
                      alignment: Alignment.center,
                      insetPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.2,
                        vertical: screenHeight * 0.15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.6,
                          maxWidth: 500,
                        ),
                        child: SuccessfullAddRequestSheet(),
                      ),
                    );
                  },
                );
              }
              else {
                // Use showModalBottomSheet for mobile
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // This makes the BottomSheet full-screen
                  backgroundColor: Colors.white, // Optional, for styling
                  builder: (context) {
                    return SuccessfullAddRequestSheet();
                  },
                );
              }
            } else {
              await AlertsService.error(
                  context: context,
                  title: AppStrings.failed.tr(),
                  message: resendRequestResult.message ??
                      'Failed to create new request');
              return;
            }
          }
          return;
        } else {
          await AlertsService.error(
              context: context,
              title: AppStrings.failed.tr(),
              message: result.message ?? 'Failed to create new request');
          return;
        }
      }
    } catch (ex, t) {
      debugPrint(
          'Error creating new request ${ex.toString()} at :- ${t.toString()}');
      await AlertsService.error(
          context: context,
          title: AppStrings.failed.tr(),
          message: '${ex.toString()}');
      return;
    }
  }
  Future<void> createNewComplaint(BuildContext context, {List<XFile>? images}) async {
    // images = listAttachmentPersonalImage
    //      .map((e) => XFile(e["upload"].path)) // تحويل File → XFile
    //      .toList();
    isAddRequestLoading = true;
    notifyListeners();
    var response;
    FormData formData = FormData.fromMap({
      if(subjectController.text != null && subjectController.text.isNotEmpty)"title" : subjectController.text,
      if(detailsController.text != null && detailsController.text.isNotEmpty) "content" : detailsController.text,
      "department_id" : selectedRequestTypes.toString(),
      "main_thumbnail[]": images != null
          ? !kIsWeb? await Future.wait(
          images.map((file) async =>await MultipartFile.fromFile(file.path, filename: file.name))
      ):await Future.wait(
        images.map((file) async {
          final bytes = await file.readAsBytes();
          return MultipartFile.fromBytes(
            bytes,
            filename: file.name,
          );
        }),
      )
          : [],
    });
    try {
      if(images != null && images.isNotEmpty){
        response = await DioHelper.postData(
            url: "/emp_requests/v1/complain",
            context: context,
            data: formData
        );
      }else{
        response = await DioHelper.postData(
            url: "/emp_requests/v1/complain",
            context: context,
            data: {
              if(subjectController.text != null && subjectController.text.isNotEmpty) "title" : subjectController.text,
              if(detailsController.text != null && detailsController.text.isNotEmpty) "content" : detailsController.text,
              "department_id" : selectedRequestTypes.toString(),
            }
        );
      }
      if(response.data['status']== false){
        Fluttertoast.showToast(
            msg: response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else{
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          builder: (context) {
            return SuccessfullAddRequestSheet(
              title: AppStrings.goToComplain.tr().toUpperCase(),
              onTap: ()async{
                Navigator.pop(context);
                Navigator.pop(context);
              },
            );
          },
        );
      }
      isAddRequestLoading = false;
      notifyListeners();
    } catch (error) {
      errorAddRequestMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg:errorAddRequestMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isAddRequestLoading = false;
      notifyListeners();

    }
  }
  Future<File?> _compressImage(File file) async {
    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
      minWidth: 1600,
      minHeight: 1600,
    );
    return result != null ? File(result.path) : null;
  }
  Future<void> getProfileImageByGallery() async {
    final XFile? imageFileProfile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFileProfile == null) return;

    if (kIsWeb) {
      Uint8List bytes = await imageFileProfile.readAsBytes();
      listXAttachmentPersonalImage.add(imageFileProfile);
      listAttachmentPersonalImage.add({
        "preview": bytes,     // 🖥️ للعرض
        "upload": bytes,      // 🖥️ للرفع برضه
      });
    } else {
      File originalFile = File(imageFileProfile.path);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        listAttachmentPersonalImage.add({
          "preview": compressedFile,   // 📱 للعرض
          "upload": compressedFile,    // 📱 للرفع
        });
      }
    }


    notifyListeners();
  }
  Future<void> getProfileImageByCam() async {
    final XFile? imageFileProfile = await picker.pickImage(source: ImageSource.camera);
    if (imageFileProfile == null) return;

    if (kIsWeb) {
      Uint8List bytes = await imageFileProfile.readAsBytes();
      listXAttachmentPersonalImage.add(imageFileProfile);
      listAttachmentPersonalImage.add({
        "preview": bytes,     // 🖥️ للعرض
        "upload": bytes,      // 🖥️ للرفع برضه
      });
    } else {
      File originalFile = File(imageFileProfile.path);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        listAttachmentPersonalImage.add({
          "preview": compressedFile,   // 📱 للعرض
          "upload": compressedFile,    // 📱 للرفع
        });
      }
    }


    notifyListeners();
  }

}
