import 'package:app_test/core/services/app_error_reporter.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/string_convert.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/features/rewards_and_penalties/add_rewards/views/widgets/skipped_employees_dialog.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AddRewardAndPenaltyViewModel extends ChangeNotifier {
  // days || hours || amount
  bool isLoading = false;
  bool isLoadingPost = false;
  String? errorMessage;
  
  // Target Type
  String targetType = 'employees'; // 'employees', 'departments', 'all'
  
  // Selections
  List<Map<String, dynamic>> selectedEmployees = [];
  List<Map<String, dynamic>> selectedDepartments = [];
  List<Map<String, dynamic>> exceptedEmployees = [];

  List<Map<String, dynamic>> categories = [
    {
      'type': 'days',
      'name': AppStrings.days.tr(),
    },
    {
      'type': 'hours',
      'name': AppStrings.hours.tr(),
    },
    {
      'type': 'amount',
      'name': AppStrings.amount.tr(),
    },
  ];

  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> departments = [];
  Map<String, dynamic>? selectedCategory;

  Map<String, dynamic>? selectedType;
  String? selectedTypes;
  TextEditingController selectedDatecontroller = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  DateTime? selectedDate;

  void initializeAddRewardAndPenaltyScreen({required BuildContext context}) {
    getEmployees(context: context);
    getDepartments(context: context);
    _resetValues();
    notifyListeners();
  }

  @override
  void dispose() {
    selectedDatecontroller.dispose();
    reasonController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _resetValues() {
    selectedType = null;
    selectedDatecontroller = TextEditingController();
    reasonController = TextEditingController();
    amountController = TextEditingController();
    selectedDate = null;
    targetType = 'employees';
    selectedEmployees = [];
    selectedDepartments = [];
    exceptedEmployees = [];
  }

  void getEmployees({required BuildContext context}) {
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
      url: "/emp_requests/v1/employees",
      context: context,
      query: {
        "under_my_management": true
      },
    ).then((value) {
      isLoading = false;
      employees = List<Map<String, dynamic>>.from(value.data['employees']);
      notifyListeners();
    }).catchError((error) {
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = AppErrorReporter.safeMessage(error);
      }
    });
  }

  void getDepartments({required BuildContext context}) {
    DioHelper.getData(
      url: "/departments/entities-operations",
      query: {
        "itemsCount": 200,
      },
      context: context,
    ).then((value) {
      departments = List<Map<String, dynamic>>.from(value.data['data']);
      notifyListeners();
    }).catchError((error) {
      debugPrint("Error fetching departments: $error");
    });
  }

  void setTargetType(String type) {
    targetType = type;
    // Reset selections when changing type to avoid messy state
    selectedEmployees = [];
    selectedDepartments = [];
    exceptedEmployees = [];
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final String? type = selectedType?['type'];
    if (type == null || type.isEmpty) {
      AlertsService.info(
          context: context,
          message: 'please Select First Type',
          title: 'Information');
      return;
    }
    await _selectDate(context);
    if (selectedDate == null) {
      AlertsService.warning(
          context: context,
          message: 'please select the Date again !',
          title: AppStrings.warning.tr());
      return;
    }
    selectedDatecontroller.text = formatDateTimeRange(selectedDate!);
    notifyListeners();
  }

  /// USED WHEN THE DURATION TYPE IN THE SELECTED REQUEST IS DAYS
  Future<void> _selectDate(BuildContext context) async {
    final newDateRange = await showDatePicker(
        context: context,
        switchToInputEntryModeIcon: const Icon(Icons.add, color: Colors.transparent,),
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDate: DateTime.now());
    if (newDateRange == null) return;
    selectedDate = newDateRange;
  }

  String formatDateTimeRange(DateTime date) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    return dateFormatter.format(date);
  }

  Future<void> createRewardAndPenalty({required BuildContext context}) async {
    isLoadingPost = true;
    notifyListeners();
    try {
      // First Validate on the main data
      if (selectedType == null || (selectedType?.isEmpty ?? true)) {
        AlertsService.info(
            context: context,
            message: AppStrings.pleaseSelectRequestType.tr(),
            title: AppStrings.information.tr());
        isLoadingPost = false;
        return;
      }
      if (selectedDate == null) {
        AlertsService.info(
            context: context,
            message: AppStrings.pleaseSelectRequestDate.tr(),
            title: AppStrings.information.tr());
        isLoadingPost = false;
        return;
      }
      if (selectedDatecontroller.text.isEmpty) {
        AlertsService.info(
            context: context,
            message: AppStrings.pleaseSelectRequestDate.tr(),
            title: AppStrings.information.tr());
        isLoadingPost = false;
        return;
      }

      // Target Validation
      if (targetType == 'employees' && selectedEmployees.isEmpty) {
        AlertsService.info(
            context: context,
            message: AppStrings.theAssignToFieldIsRequired.tr(),
            title: AppStrings.information.tr());
        isLoadingPost = false;
        return;
      }
      if (targetType == 'departments' && selectedDepartments.isEmpty) {
        AlertsService.info(
            context: context,
            message: AppStrings.theAssignToFieldIsRequired.tr(), // Or specific translation for departments
            title: AppStrings.information.tr());
        isLoadingPost = false;
        return;
      }

      if (selectedTypes.toString().isEmpty) {
        AlertsService.info(
            context: context,
            message: "${AppStrings.requestType.tr()} ${AppStrings.isRequired.tr()}",
            title: AppStrings.information.tr());
        isLoadingPost = false;
        return;
      }
      debugPrint("selectedDatecontroller.text --> ${StringConvert.sanitizeDateString(selectedDatecontroller.text)}");
      
      // Finally, send Request to server create new request
      final Map<String, dynamic> requestMainData = {
        "target_type": targetType,
        "type": selectedType?['type'],
        "amount": amountController.text,
        "category": selectedTypes.toString(),
        "reason": reasonController.text,
        "due_date": StringConvert.sanitizeDateString(selectedDatecontroller.text)
      };

      if (targetType == 'employees') {
        requestMainData["employee_ids"] = selectedEmployees.map((e) => e['id']).toList();
      } else if (targetType == 'departments') {
        requestMainData["department_ids"] = selectedDepartments.map((e) => e['id']).toList();
        if (exceptedEmployees.isNotEmpty) {
          requestMainData["except_employee_ids"] = exceptedEmployees.map((e) => e['id']).toList();
        }
      } else if (targetType == 'all') {
        if (exceptedEmployees.isNotEmpty) {
          requestMainData["except_employee_ids"] = exceptedEmployees.map((e) => e['id']).toList();
        }
      }

      DioHelper.postData(
          context: context,
          url: "/rm_payroll/v1/payroll/penalities-and-rewards",
          data: requestMainData
      ).then((v) async {
        if (v.data['status'] == true) {
          // created_count / skipped come at the top level of the response, next to status
          final data = v.data is Map ? v.data as Map : const {};
          final skipped = data['skipped'] is List
              ? (data['skipped'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
              : <Map<String, dynamic>>[];
          isLoadingPost = false;
          _resetValues();
          notifyListeners();
          if (skipped.isNotEmpty) {
            // Some employees didn't get the record: show who and why before leaving the screen
            await SkippedEmployeesDialog.show(context,
                createdCount: int.tryParse(data['created_count']?.toString() ?? '') ?? 0, skipped: skipped);
            if (!context.mounted) return;
          } else {
            AlertsService.success(
                context: context,
                title: AppStrings.success.tr(),
                message: v.data['message'] ?? 'New Request Created Successfully');
          }
          Navigator.pop(context, true); // To refresh list or close
        } else {
          AlertsService.error(
              context: context,
              message: v.data['message'] ?? "Failed to create",
              title: AppStrings.error.tr());
          isLoadingPost = false;
          notifyListeners();
        }
      }).catchError((error){
        isLoadingPost = false;
        notifyListeners();
        AlertsService.error(
            context: context,
            message: error is DioError ? (error.response?.data['message'] ?? 'Something went wrong') : error.toString(),
            title: AppStrings.error.tr());
      });
    } catch (e) {
      isLoadingPost = false;
      notifyListeners();
      AlertsService.error(
          context: context,
          message: AppErrorReporter.safeMessage(e),
          title: AppStrings.error.tr());
    }
  }
}
