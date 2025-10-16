import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/string_convert.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import '../../../general_services/alert_service/alerts.service.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';

class AddRewardAndPenaltyViewModel extends ChangeNotifier {
  // days || hours || amount
  bool isLoading = false;
  bool isLoadingPost = false;
  String? errorMessage;
  String? selectEmpId;
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
  Map<String, dynamic>? selectedEmployee;
  List<Map<String, dynamic>> employees = [];
  Map<String, dynamic>? selectedCategory;

  Map<String, dynamic>? selectedType;
  String? selectedTypes;
  TextEditingController selectedDatecontroller = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  DateTime? selectedDate;

  void initializeAddRewardAndPenaltyScreen({required BuildContext context}) {
    getEmployees(context: context);
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
  }
  void getEmployees({required BuildContext context}) {
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
      url: "/emp_requests/v1/employees",
      context: context,
    ).then((value){
      isLoading = false;
      employees = List<Map<String, dynamic>>.from(value.data['employees']);
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
      }if (selectedDatecontroller.text.isEmpty) {
        AlertsService.info(
            context: context,
            message: AppStrings.pleaseSelectRequestDate.tr(),
            title: AppStrings.information.tr());
        isLoadingPost = false;
        return;
      }
      if (selectEmpId.toString().isEmpty) {
        AlertsService.info(
            context: context,
            message: AppStrings.theAssignToFieldIsRequired.tr(),
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
      print("selectedDatecontroller.text --> ${StringConvert.sanitizeDateString(selectedDatecontroller.text)}");
      // Finally, send Request to server create new request
      final requestMainData = {
        "type": selectedType?['type'],
        "amount": amountController.text,
        "category": selectedTypes.toString(),
        "reason": reasonController.text,
        "employee_id": selectEmpId.toString(),
        "due_date": StringConvert.sanitizeDateString(selectedDatecontroller.text)
      };

      DioHelper.postData(
          context: context,
          url: "/rm_payroll/v1/payroll/penalities-and-rewards",
          data: requestMainData
      ).then((v){
        if (v.data['status'] == true) {
          AlertsService.success(
              context: context,
              title: AppStrings.success.tr(),
              message: v.data['message'] ?? 'New Request Created Successfully');
          isLoadingPost = false;
          _resetValues();
          notifyListeners();
          return;
        } else {
           AlertsService.error(
              context: context,
              title: AppStrings.failed.tr(),
              message: v.data['message'] ?? 'Failed to create new request');
           isLoadingPost = false;
           notifyListeners();
          return;
        }
      });

    } catch (ex, t) {
      isLoadingPost = false;
      debugPrint(
          'Error creating new Penalty Or Reward ${ex.toString()} at :- ${t.toString()}');
      await AlertsService.error(
          context: context,
          title: AppStrings.failed.tr(),
          message: 'Failed to create Penalty Or Reward ${ex.toString()}');
      isLoadingPost = false;

      return;
    }
  }
}
