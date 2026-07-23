import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/searchable_dropdown_sheet.dart';
import 'package:app_test/features/requests/main_request_layout/controller/filter_controller.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

class SharedListFilterWidget extends StatefulWidget {
  final bool showEmployee;
  final bool showDepartment;
  final bool showDateRange;
  final bool showStatus;
  final List<String> statusOptions;
  final Map<String, String?> initialFilters;

  const SharedListFilterWidget({
    Key? key,
    this.showEmployee = true,
    this.showDepartment = true,
    this.showDateRange = true,
    this.showStatus = false,
    this.statusOptions = const [],
    this.initialFilters = const {},
  }) : super(key: key);

  @override
  State<SharedListFilterWidget> createState() => _SharedListFilterWidgetState();
}

class _SharedListFilterWidgetState extends State<SharedListFilterWidget> {
  String? selectEmpId;
  String? selectDepId;
  String? selectStatus;
  DateTimeRange? selectedDateRange;
  TextEditingController dateController = TextEditingController();

  Map<String, dynamic>? selectedEmployee;
  Map<String, dynamic>? selectedDepartment;
  Map<String, dynamic>? selectedStatusMap;

  @override
  void initState() {
    super.initState();
    _initFilters();
  }

  void _initFilters() {
    selectEmpId = widget.initialFilters['empId'];
    selectDepId = widget.initialFilters['depId'];
    selectStatus = widget.initialFilters['status'];

    if (selectStatus != null && widget.statusOptions.isNotEmpty) {
      try {
        selectedStatusMap = {'id': selectStatus, 'name': selectStatus!.tr()};
      } catch (_) {}
    }

    if (widget.initialFilters['from'] != null && widget.initialFilters['to'] != null) {
      try {
        final fromDate = DateTime.parse(widget.initialFilters['from']!);
        final toDate = DateTime.parse(widget.initialFilters['to']!);
        selectedDateRange = DateTimeRange(start: fromDate, end: toDate);
        dateController.text = _formatDateTimeRange(selectedDateRange!);
      } catch (e) {
        debugPrint('Error parsing date range: $e');
      }
    }
  }

  String _formatDateTimeRange(DateTimeRange range) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: selectedDateRange ??
          DateTimeRange(start: DateTime.now(), end: DateTime.now()),
    );
    if (newDateRange == null) return;
    setState(() {
      selectedDateRange = newDateRange;
      dateController.text = _formatDateTimeRange(selectedDateRange!);
    });
  }

  Map<String, String?> _buildFilterMap() {
    String? fromStr;
    String? toStr;
    if (selectedDateRange != null) {
      fromStr = DateService.formateDateTimeBeforeSendToServer(dateTime: selectedDateRange!.start).toString();
      toStr = DateService.formateDateTimeBeforeSendToServer(dateTime: selectedDateRange!.end).toString();
    }
    return {
      'empId': selectEmpId,
      'empName': selectedEmployee?['name']?.toString(),
      'depId': selectDepId,
      'depName': selectedDepartment?['title']?.toString(),
      'status': selectStatus,
      'from': fromStr,
      'to': toStr,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final controller = FilterController();
        if (widget.showDepartment) controller.getDepartment(context: context);
        if (widget.showEmployee) controller.getEmployees(context: context);
        return controller;
      },
      child: Consumer<FilterController>(
        builder: (context, filterController, child) {
          // Initialize selected objects from ID if lists are loaded
          if (filterController.departments.isNotEmpty && selectDepId != null && selectedDepartment == null) {
            try {
              selectedDepartment = filterController.departments.firstWhere((dept) => dept['id'].toString() == selectDepId);
            } catch (_) {}
          }
          if (filterController.employees.isNotEmpty && selectEmpId != null && selectedEmployee == null) {
            try {
              selectedEmployee = filterController.employees.firstWhere((emp) => emp['id'].toString() == selectEmpId);
            } catch (_) {}
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                    color: Color(AppColors.background),
                  ),
                  width: double.infinity,
                  constraints: BoxConstraints(maxHeight: 0.8.sh),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 10),
                        Center(
                          child: Container(
                            width: 63,
                            height: 5,
                            decoration: BoxDecoration(
                                color: Color(AppColors.disableButton),
                                borderRadius: BorderRadius.circular(100)),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.filter.tr().toUpperCase(),
                                    style: AppStyles.heading(context).copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                              SizedBox(height: 25),

                              if (widget.showDepartment) ...[
                                SearchableDropdownSheet(
                                  items: filterController.departments,
                                  selectedValue: selectedDepartment,
                                  nameKey: 'title',
                                  hintText: AppStrings.department.tr(),
                                  hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 12),
                                  height: 65,
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(AppColors.border), width: 1.0),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  fieldSuffixIcon: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedDepartment = null;
                                        selectDepId = null;
                                      });
                                    },
                                    child: Icon(Icons.close, color: Colors.red, size: 20),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDepartment = value;
                                      selectDepId = value['id']?.toString();
                                    });
                                  },
                                ),
                                SizedBox(height: 15),
                              ],

                              if (widget.showEmployee) ...[
                                SearchableDropdownSheet(
                                  items: filterController.employees,
                                  selectedValue: selectedEmployee,
                                  nameKey: 'name',
                                  hintText: AppStrings.employeeName.tr(),
                                  hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 12),
                                  height: 65,
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(AppColors.border), width: 1.0),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  fieldSuffixIcon: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedEmployee = null;
                                        selectEmpId = null;
                                      });
                                    },
                                    child: Icon(Icons.close, color: Colors.red, size: 20),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedEmployee = value;
                                      selectEmpId = value['id']?.toString();
                                    });
                                  },
                                ),
                                SizedBox(height: 15),
                              ],

                              if (widget.showStatus) ...[
                                SearchableDropdownSheet(
                                  items: widget.statusOptions.map((e) => {'id': e, 'name': e.tr()}).toList(),
                                  selectedValue: selectedStatusMap,
                                  nameKey: 'name',
                                  hintText: AppStrings.status.tr(),
                                  hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 12),
                                  height: 65,
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(AppColors.border), width: 1.0),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  fieldSuffixIcon: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedStatusMap = null;
                                        selectStatus = null;
                                      });
                                    },
                                    child: Icon(Icons.close, color: Colors.red, size: 20),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedStatusMap = value;
                                      selectStatus = value['id']?.toString();
                                    });
                                  },
                                ),
                                SizedBox(height: 15),
                              ],

                              if (widget.showDateRange) ...[
                                TextField(
                                  controller: dateController,
                                  style: AppStyles.darkContent(context).copyWith(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: AppStrings.date.tr(),
                                    hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 12),
                                    suffixIcon: dateController.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(Icons.close, color: Colors.red, size: 20),
                                            onPressed: () {
                                              setState(() {
                                                selectedDateRange = null;
                                                dateController.clear();
                                              });
                                            },
                                          )
                                        : IconButton(
                                            icon: Icon(Icons.calendar_today, size: 20),
                                            onPressed: () => _selectDateRange(context),
                                          ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(AppColors.border), width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(AppColors.border), width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(AppColors.border), width: 1.0),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () => _selectDateRange(context),
                                ),
                                SizedBox(height: 30),
                              ],

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context, _buildFilterMap());
                                    },
                                    child: Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(AppColors.secondaryButton),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 40),
                                      child: Text(
                                        AppStrings.applyFilter.tr().toUpperCase(),
                                        style: AppStyles.whiteContent(context).copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context, {
                                        'empId': null,
                                        'depId': null,
                                        'status': null,
                                        'from': null,
                                        'to': null,
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(AppColors.background),
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(color: Color(AppColors.secondaryButton), width: 1),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        AppStrings.clear.tr().toUpperCase(),
                                        style: AppStyles.darkContent(context).copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
        },
      ),
    );
  }
}
