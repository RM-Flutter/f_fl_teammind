import 'dart:convert';

import 'package:easy_localization/easy_localization.dart' as local;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/controller/filter_controller/filter_controller.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/date.service.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/modules/requests/view_models/add_new_request.viewmodel.dart';
import 'package:rmemp/modules/requests/view_models/filter_consts.dart';
import 'package:rmemp/modules/requests/view_models/requests.viewmodel.dart';
import 'package:rmemp/services/requests.services.dart';
import 'package:rmemp/utils/searchable_dropdown_sheet/searchable_dropdown_sheet.dart';
import 'package:rmemp/utils/widgets/text_form_widget.dart';

class SearchFilterWidget extends StatefulWidget {
  BuildContext? contexts;
  final GetRequestsTypes? requestsType;
  final bool? isWeb;
  SearchFilterWidget({super.key, this.contexts, this.requestsType, this.isWeb});

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  var selectIndex;
  int? selectId;
  bool _filtersLoaded = false;

  /// الحالة الحالية للفلتر (نستخدمها عند الإغلاق بدل الكاش لتجنب إرسال id بعد المسح)
  static Map<String, String?> _buildFilterMap(AddNewRequestViewModel viewModels, FilterController viewModel) {
    String? fromStr;
    String? toStr;
    if (viewModels.selectedDateOrDatetimeRange != null &&
        viewModels.selectedDateOrDatetimeRange!.start != null &&
        viewModels.selectedDateOrDatetimeRange!.end != null) {
      final arabicToEnglish = {
        '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
        '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
      };
      String normalize(String input) {
        return input.split('').map((c) => arabicToEnglish[c] ?? c).join();
      }
      final from = DateService.formateDateTimeBeforeSendToServer(
          dateTime: viewModels.selectedDateOrDatetimeRange!.start).toString();
      final to = DateService.formateDateTimeBeforeSendToServer(
          dateTime: viewModels.selectedDateOrDatetimeRange!.end).toString();
      fromStr = normalize(from);
      toStr = normalize(to);
    }
    return {
      'reqId': viewModels.selectReqId,
      'empId': viewModel.selectEmpId,
      'depId': viewModel.selectDepId,
      'selectStatus': viewModels.selectStatus,
      'from': fromStr,
      'to': toStr,
    };
  }

  static Map<String, String?> _emptyFilterMap() => {
    'reqId': null, 'empId': null, 'depId': null, 'selectStatus': null, 'from': null, 'to': null,
  };

  void _loadSavedFilters(BuildContext context, AddNewRequestViewModel viewModels, FilterController viewModel) {
    if (_filtersLoaded) return;
    _filtersLoaded = true;

    // Load saved request type
    final savedReqId = CacheHelper.getString("reqId");
    if (savedReqId != null && savedReqId.isNotEmpty && viewModel.requestsTypes != null) {
      try {
        final requestType = viewModel.requestsTypes!.firstWhere(
          (type) => type['id'].toString() == savedReqId,
          orElse: () => {},
        );
        if (requestType.isNotEmpty) {
          viewModels.selectedRequestType = requestType;
          viewModels.selectReqId = savedReqId;
          viewModels.reqType = requestType['type']?.toString();
        }
      } catch (e) {
        debugPrint('Error loading saved request type: $e');
      }
    }

    // Load saved status
    final savedStatus = CacheHelper.getString("selectStatus");
    if (savedStatus != null && savedStatus.isNotEmpty) {
      viewModels.selectStatus = savedStatus;
    }

    // Load saved department
    final savedDepId = CacheHelper.getString("depId");
    if (savedDepId != null && savedDepId.isNotEmpty && viewModel.departments.isNotEmpty) {
      try {
        final department = viewModel.departments.firstWhere(
          (dept) => dept['id'].toString() == savedDepId,
          orElse: () => {},
        );
        if (department.isNotEmpty) {
          viewModel.selectedDepartment = department;
          viewModel.selectDepId = savedDepId;
        }
      } catch (e) {
        debugPrint('Error loading saved department: $e');
      }
    }

    // Load saved employee
    final savedEmpId = CacheHelper.getString("empId");
    if (savedEmpId != null && savedEmpId.isNotEmpty && viewModel.employees.isNotEmpty) {
      try {
        final employee = viewModel.employees.firstWhere(
          (emp) => emp['id'].toString() == savedEmpId,
          orElse: () => {},
        );
        if (employee.isNotEmpty) {
          viewModel.selectedEmployee = employee;
          viewModel.selectEmpId = savedEmpId;
        }
      } catch (e) {
        debugPrint('Error loading saved employee: $e');
      }
    }

    // Load saved date range
    final savedFrom = CacheHelper.getString("from");
    final savedTo = CacheHelper.getString("to");
    if (savedFrom != null && savedFrom.isNotEmpty && savedTo != null && savedTo.isNotEmpty) {
      try {
        final fromDate = DateTime.parse(savedFrom);
        final toDate = DateTime.parse(savedTo);
        viewModels.selectedDateOrDatetimeRange = DateTimeRange(start: fromDate, end: toDate);
        viewModels.controller.text = viewModels.formatDateTimeRange(context, viewModels.selectedDateOrDatetimeRange!);
      } catch (e) {
        debugPrint('Error loading saved date range: $e');
      }
    }

    // Update UI
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
        ChangeNotifierProvider(create: (context)=>FilterController()..getDepartment(context: context)..getRequestTypes(context: context)..getEmployees(context: context),),
        ChangeNotifierProvider(create: (context)=>RequestsViewModel()),
        ChangeNotifierProvider(create: (context)=>AddNewRequestViewModel()),
    ],
    child: Consumer<RequestsViewModel>(
      builder: (context, value, child) {
        return Consumer<FilterController>(
          builder: (context, viewModel, child) {
            return Consumer<AddNewRequestViewModel>(
              builder: (context, viewModels, child) {
                var jsonString;
                var gCache;
                jsonString = CacheHelper.getString("US1");
                if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
                  gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
                  UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
                }

                // Load saved filters when data is ready
                if (viewModel.requestsTypes != null && viewModel.departments.isNotEmpty && viewModel.employees.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loadSavedFilters(context, viewModels, viewModel);
                  });
                }

                final isWeb = widget.isWeb ?? false;
                return PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (didPop) return;
                    final vm = Provider.of<AddNewRequestViewModel>(context, listen: false);
                    final fc = Provider.of<FilterController>(context, listen: false);
                    Navigator.of(context).pop(_buildFilterMap(vm, fc));
                  },
                  child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: isWeb
                              ? BorderRadius.circular(35.0)
                              : const BorderRadius.vertical(top: Radius.circular(35.0)),
                          color: Color(AppColors.white)
                      ),
                      width: double.infinity,
                      height: isWeb
                          ? null
                          : MediaQuery.sizeOf(context).height * 0.6,
                      constraints: isWeb
                          ? BoxConstraints(
                              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
                            )
                          : null,
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isWeb) ...[
                              const SizedBox(height: 10,),
                              Center(
                                child:Container(
                                  width: 63,
                                  height: 5,
                                  decoration: BoxDecoration(
                                      color: Color(AppColors.lightGrey),
                                      borderRadius: BorderRadius.circular(100)
                                  ),
                                ) ,
                              ),
                              const SizedBox(height: 10,),
                            ] else
                              const SizedBox(height: 20,),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppStrings.requests.tr().toUpperCase(),
                                        style: TextStyle(
                                            color: Color(AppColors.dark),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  SearchableDropdownSheet(
                                      items: viewModel.requestsTypes,
                                      selectedValue: viewModels.selectedRequestType,
                                      nameKey: 'title',
                                      hintText: AppStrings.requestType.tr(),
                                      hintStyle: TextStyle(color: Color(AppColors.grey46), fontSize: 12),
                                      height: 65,
                                      borderRadius: BorderRadius.circular(AppSizes.s10),
                                      borderSide: BorderSide(color: Color(AppColors.whiteGrey), width: 1.0),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      fieldSuffixIcon: InkWell(
                                        onTap: () async {
                                          viewModels.selectedRequestType = null;
                                          viewModels.selectReqId = null;
                                          viewModels.reqType = null;
                                          await CacheHelper.deleteData(key: "reqId");
                                          if (!context.mounted) return;
                                          setState(() {});
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                      onChanged: (value){
                                        viewModels.selectedRequestType = value;
                                        viewModels.selectReqId = value['id']?.toString();
                                        viewModels.reqType = value['type']?.toString();
                                        if (viewModels.selectReqId != null && viewModels.selectReqId!.isNotEmpty) {
                                          CacheHelper.setString(key: "reqId", value: viewModels.selectReqId!);
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  const SizedBox(height: 15),
                                  defaultDropdownField(
                                    value: viewModels.selectStatus,
                                    title: viewModels.selectStatus ?? AppStrings.status.tr(),
                                    hasShadows: false,
                                    items: viewModels.status!.map((e) => DropdownMenuItem(
                                      value: e.toString(),
                                      child: Text(
                                        e.toString().tr().toString(),
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color(AppColors.almostBlack)
                                        ),),
                                    ),
                                    ).toList(),
                                    onChanged: (String? values) {
                                      setState(() {
                                        viewModels.selectStatus = values;
                                      },
                                      );
                                    }
                                  ),
                                  if((gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty)&& widget.requestsType != GetRequestsTypes.mine)   const SizedBox(height: 15),
                                  if((gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty)&& widget.requestsType != GetRequestsTypes.mine)
                                    SearchableDropdownSheet(
                                      items: viewModel.departments,
                                      selectedValue: viewModel.selectedDepartment,
                                      nameKey: 'title',
                                      fieldSuffixIcon: InkWell(
                                        onTap: () async {
                                          viewModel.selectedDepartment = null;
                                          viewModel.selectDepId = null;
                                          await CacheHelper.deleteData(key: "depId");
                                          if (!context.mounted) return;
                                          setState(() {});
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                      hintText: AppStrings.department.tr(),
                                      hintStyle: TextStyle(color: Color(AppColors.grey46), fontSize: 12),
                                      height: 65,
                                      borderRadius: BorderRadius.circular(AppSizes.s10),
                                      borderSide: BorderSide(color: Color(AppColors.whiteGrey), width: 1.0),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      onChanged: (value){
                                        viewModel.selectedDepartment = value;
                                        viewModel.selectDepId = value['id']?.toString();
                                        setState(() {});
                                      },
                                    ),
                                  if((gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty) && widget.requestsType != GetRequestsTypes.mine)   const SizedBox(height: 15),
                                  if((gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty)&& widget.requestsType != GetRequestsTypes.mine)
                                    SearchableDropdownSheet(
                                      items: viewModel.employees,
                                      selectedValue: viewModel.selectedEmployee,
                                      nameKey: 'name',
                                    fieldSuffixIcon: InkWell(
                                      onTap: () async {
                                        viewModel.selectedEmployee = null;
                                        viewModel.selectEmpId = null;
                                        viewModel.selectedDatecontroller.clear();
                                        await CacheHelper.deleteData(key: "empId");
                                        if (!context.mounted) return;
                                        setState(() {});
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                      hintText: AppStrings.employeeName.tr(),
                                      hintStyle: TextStyle(color: Color(AppColors.grey46), fontSize: 12),
                                      height: 65,
                                      borderRadius: BorderRadius.circular(AppSizes.s10),
                                      borderSide: BorderSide(color: Color(AppColors.whiteGrey), width: 1.0),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      onChanged: (value){
                                        viewModel.selectedEmployee = value;
                                        viewModel.selectedDatecontroller.clear();
                                        viewModel.selectEmpId = value['id']?.toString();
                                        setState(() {});
                                      },
                                    ),
                                  const SizedBox(height: 15),
                                  viewModels.selectedRequestType?['type'] ==
                                      'instead_of_holidays'
                                      ? SearchableDropdownSheet(
                                      items: viewModels.requestsTypes,
                                      selectedValue: viewModels.selectedRequestType,
                                      nameKey: 'name',
                                      hintText: AppStrings.requestTime.tr(),
                                      hintStyle: TextStyle(color: Color(AppColors.grey46), fontSize: 12),
                                      height: 65,
                                      borderRadius: BorderRadius.circular(AppSizes.s10),
                                      borderSide: BorderSide(color: Color(AppColors.whiteGrey), width: 1.0),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      onChanged: (value) =>
                                          viewModels.selectInsteadOfHolidays(context,
                                              startDateOrDatetime: value['from'],
                                              endDateOrDatetime: value['to']),
                                    )
                                      : TextField(
                                    controller: viewModels.controller,
                                    decoration: InputDecoration(
                                      hintText: AppStrings.requestTime.tr(),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.calendar_today),
                                        onPressed: () =>
                                            viewModels.selectDateFilter(context, filter: true),
                                      ),
                                    ),
                                    readOnly: true,
                                    onTap: () => viewModels.selectDateFilter(context, filter: true),
                                  ),
                                  const SizedBox(height: 30,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: ()async{
                                          String normalizeDateToEnglish(String input) {
                                            final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
                                            final arabicToEnglish = {
                                              '٠': '0',
                                              '١': '1',
                                              '٢': '2',
                                              '٣': '3',
                                              '٤': '4',
                                              '٥': '5',
                                              '٦': '6',
                                              '٧': '7',
                                              '٨': '8',
                                              '٩': '9',
                                            };

                                            // Check if the input contains Arabic numerals
                                            bool containsArabic = input.split('').any((char) => arabicDigits.contains(char));

                                            // Convert Arabic numerals to English if needed
                                            String normalized = containsArabic
                                                ? input.split('').map((c) => arabicToEnglish[c] ?? c).join()
                                                : input;

                                            // Parse and reformat
                                            DateTime date = DateTime.parse(normalized); // assumes yyyy-MM-dd
                                            return "${date.year.toString().padLeft(4, '0')}-"
                                                "${date.month.toString().padLeft(2, '0')}-"
                                                "${date.day.toString().padLeft(2, '0')}";
                                          }
                                          
                                          // امسح من الكاش أي فيلتر المستخدم شاله من الدروب داون، بعدين سجّل الباقي (await عشان الحذف يخلص قبل ما الـ API يقرأ)
                                          bool _isEmpty(String? v) => v == null || v.isEmpty || v == "null";
                                          if (_isEmpty(viewModel.selectEmpId)) {
                                            await CacheHelper.deleteData(key: "empId");
                                          } else {
                                            await CacheHelper.setString(key: "empId", value: viewModel.selectEmpId ?? "");
                                          }
                                          if (_isEmpty(viewModel.selectDepId)) {
                                            await CacheHelper.deleteData(key: "depId");
                                          } else {
                                            await CacheHelper.setString(key: "depId", value: viewModel.selectDepId ?? "");
                                          }
                                          if (_isEmpty(viewModels.selectStatus)) {
                                            await CacheHelper.deleteData(key: "selectStatus");
                                          } else {
                                            await CacheHelper.setString(key: "selectStatus", value: viewModels.selectStatus ?? "");
                                          }
                                          if (_isEmpty(viewModels.selectReqId)) {
                                            await CacheHelper.deleteData(key: "reqId");
                                          } else {
                                            await CacheHelper.setString(key: "reqId", value: viewModels.selectReqId ?? "");
                                          }
                                          if (viewModels.selectedDateOrDatetimeRange == null ||
                                              viewModels.selectedDateOrDatetimeRange?.start == null ||
                                              viewModels.selectedDateOrDatetimeRange?.end == null) {
                                            await CacheHelper.deleteData(key: "from");
                                            await CacheHelper.deleteData(key: "to");
                                          } else {
                                            await CacheHelper.setString(key: "from", value: normalizeDateToEnglish(DateService.formateDateTimeBeforeSendToServer(
                                                dateTime: viewModels.selectedDateOrDatetimeRange!.start)).toString() ?? "");
                                            await CacheHelper.setString(key: "to", value: normalizeDateToEnglish(DateService.formateDateTimeBeforeSendToServer(
                                                dateTime: viewModels.selectedDateOrDatetimeRange!.end)).toString() ?? "");
                                          }
                                          if (!context.mounted) return;
                                          Navigator.pop(context, _buildFilterMap(viewModels, viewModel));
                                        },
                                        child: Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Color(AppColors.dark),
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 40),
                                          child: Text(
                                            AppStrings.applyFilter.tr().toUpperCase(),
                                            style:TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color(AppColors.white)
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await CacheHelper.deleteData(key: "empId");
                                          await CacheHelper.deleteData(key: "from");
                                          await CacheHelper.deleteData(key: "to");
                                          await CacheHelper.deleteData(key: "depId");
                                          await CacheHelper.deleteData(key: "reqId");
                                          await CacheHelper.deleteData(key: "selectStatus");
                                          if (!context.mounted) return;
                                          Navigator.pop(context, _emptyFilterMap());
                                        },
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(50),
                                            border: Border.all(color: Color(AppColors.dark))
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 40),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                AppStrings.cancel.tr().toUpperCase(),
                                                style:TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(AppColors.dark)
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30,),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                );
              },
            );
          },
        );
      },
    )
    );
  }
  Widget defaultTextFormField({
    TextEditingController? controller,
    String? hintText,
    onTap
  }){
    return Container(
      height: 48,
      width: 120,
      alignment: Alignment.center,
      padding:const EdgeInsets.symmetric(horizontal: 10,),
      decoration: BoxDecoration(
          color:Color(AppColors.white),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextFormField(
          controller: controller,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText ?? "Input",
            labelStyle: TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(AppColors.almostBlack)
            ),
            hintStyle:const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(AppColors.grey46)
            ),
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
          ),
          keyboardType: TextInputType.number,
      ),
    );
  }
  Widget defaultTitleText({
     title
})=> Text(
      title.toUpperCase(),
      style: TextStyle(
          color: Color(AppColors.dark),
          fontWeight: FontWeight.w500,
          fontSize: 10
      ),
    );
  Widget defaultCircleColor(final Color? color, final Color? borderColor,  {width, height, radius, colors}){
    return (color != null && color != Color(0xff123456))?Container(
      margin:const EdgeInsets.symmetric(horizontal: 4),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color:  color,
         boxShadow: [
           (color == Color(AppColors.white))? BoxShadow(
          color: Color(AppColors.lightGrey).withOpacity(0.7),
      blurRadius: 0.5,
      spreadRadius: 0.5,
    ): const BoxShadow(
             color: Colors.transparent,
             blurRadius: AppSizes.s5,
             spreadRadius: 1,
           )
    ],
        borderRadius: BorderRadius.circular(radius),

      ),
    ) :(color != null && color == Color(0xff123456))? Container(
      margin:const EdgeInsets.symmetric(horizontal: 4),
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color:Color(AppColors.lightGrey)),
      ),
      child: Text(AppStrings.all.tr(), style: (colors != Colors.black)?
      Theme.of(context).textTheme.bodySmall : Theme.of(context).textTheme.bodySmall!.copyWith(color: Color(AppColors.white))),
    ) : Container();
  }
}
