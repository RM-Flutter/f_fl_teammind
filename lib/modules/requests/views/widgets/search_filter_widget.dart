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
import 'package:rmemp/utils/animated_custom_dropdown/custom_dropdown.dart';
import 'package:rmemp/utils/widgets/text_form_widget.dart';

class SearchFilterWidget extends StatefulWidget {
  BuildContext? contexts;
  final GetRequestsTypes? requestsType;
  SearchFilterWidget({super.key, this.contexts, this.requestsType});

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  var selectIndex;
  int? selectId;
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
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
                          color: Color(0xffFFFFFF)
                      ),
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height * 0.6,
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 10,),
                            Center(
                              child:Container(
                                width: 63,
                                height: 5,
                                decoration: BoxDecoration(
                                    color:const Color(0xffB9C0C9),
                                    borderRadius: BorderRadius.circular(100)
                                ),
                              ) ,
                            ),
                            const SizedBox(height: 10,),
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
                                        style: const TextStyle(
                                            color: Color(AppColors.dark),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  CustomDropdown.search(
                                      selectedValue: viewModels.selectedRequestType,
                                      borderRadius: BorderRadius.circular(AppSizes.s15),
                                      borderSide: Theme.of(context)
                                          .inputDecorationTheme
                                          .enabledBorder
                                          ?.borderSide,
                                      hintText: AppStrings.requestType.tr(),
                                      hintStyle: Theme.of(context)
                                          .inputDecorationTheme
                                          .hintStyle,
                                      items: viewModel.requestsTypes,
                                      nameKey: "title",
                                      onChanged: (value){
                                        viewModels.selectedRequestType = value;
                                        viewModels.selectReqId = value['id'].toString();
                                        viewModels.reqType = value['type'].toString();
                                        CacheHelper.setString(key: "reqId", value: value['id'].toString());
                                        viewModels.controller.clear();
                                        setState(() {

                                        });
                                      },
                                      contentPadding: Theme.of(context)
                                          .inputDecorationTheme
                                          .contentPadding
                                          ?.resolve(LocalizationService.isArabic(
                                          context: context)
                                          ? TextDirection.rtl
                                          : TextDirection.ltr)),
                                  const SizedBox(height: 15),
                                  defaultDropdownField(
                                    value: viewModels.selectStatus,
                                    title: viewModels.selectStatus ?? AppStrings.status.tr(),
                                    items: viewModels.status!.map((e) => DropdownMenuItem(
                                      value: e.toString(),
                                      child: Text(
                                        e.toString().tr().toString(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff191C1F)
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
                                  if(gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty&& widget.requestsType != GetRequestsTypes.mine)   const SizedBox(height: 15),
                                  if(gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty&& widget.requestsType != GetRequestsTypes.mine)CustomDropdown.search(
                                      selectedValue: viewModel.selectedDepartment,
                                      borderRadius: BorderRadius.circular(AppSizes.s15),
                                      borderSide: Theme.of(context)
                                          .inputDecorationTheme
                                          .enabledBorder
                                          ?.borderSide,
                                      hintText: AppStrings.department.tr(),
                                      hintStyle: Theme.of(context)
                                          .inputDecorationTheme
                                          .hintStyle,
                                      items: viewModel.departments,
                                      nameKey: "title",
                                      onChanged: (value){
                                        viewModel.selectedDepartment = value;
                                        viewModel.selectDepId = value['id'].toString();
                                        setState(() {});
                                      },
                                      contentPadding: Theme.of(context)
                                          .inputDecorationTheme
                                          .contentPadding
                                          ?.resolve(LocalizationService.isArabic(
                                          context: context)
                                          ? TextDirection.rtl
                                          : TextDirection.ltr)),
                                  if(gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty && widget.requestsType != GetRequestsTypes.mine)   const SizedBox(height: 15),
                                  if(gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty&& widget.requestsType != GetRequestsTypes.mine)  CustomDropdown.search(
                                      selectedValue: viewModel.selectedEmployee,
                                      borderRadius: BorderRadius.circular(AppSizes.s15),
                                      borderSide: Theme.of(context)
                                          .inputDecorationTheme
                                          .enabledBorder
                                          ?.borderSide,
                                      hintText: AppStrings.employeeName.tr(),
                                      hintStyle: Theme.of(context)
                                          .inputDecorationTheme
                                          .hintStyle,
                                      items: viewModel.employees,
                                      nameKey: "name",
                                      onChanged: (value){
                                        viewModel.selectedEmployee = value;
                                        viewModel.selectedDatecontroller.clear();
                                        viewModel.selectEmpId = value['id'].toString();
                                        print("Selected employee ID: ${value["id"]}");
                                        setState(() {});
                                        setState(() {});
                                      },
                                      contentPadding: Theme.of(context)
                                          .inputDecorationTheme
                                          .contentPadding
                                          ?.resolve(LocalizationService.isArabic(
                                          context: context)
                                          ? TextDirection.rtl
                                          : TextDirection.ltr)),
                                  const SizedBox(height: 15),
                                  viewModels.selectedRequestType?['type'] ==
                                      'instead_of_holidays'
                                      ? CustomDropdown.search(
                                      selectedValue: viewModels.selectedRequestType,
                                      borderRadius:
                                      BorderRadius.circular(AppSizes.s15),
                                      borderSide: Theme.of(context)
                                          .inputDecorationTheme
                                          .enabledBorder
                                          ?.borderSide,
                                      hintText: AppStrings.requestTime.tr(),
                                      hintStyle: Theme.of(context)
                                          .inputDecorationTheme
                                          .hintStyle,
                                      items: viewModels.requestsTypes,
                                      nameKey: "name",
                                      onChanged: (value) =>
                                          viewModels.selectInsteadOfHolidays(context,
                                              startDateOrDatetime: value['from'],
                                              endDateOrDatetime: value['to']),
                                      contentPadding: Theme.of(context)
                                          .inputDecorationTheme
                                          .contentPadding
                                          ?.resolve(LocalizationService.isArabic(
                                          context: context)
                                          ? TextDirection.rtl
                                          : TextDirection.ltr))
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
                                          CacheHelper.deleteData(key: "empId");
                                          print("IDS IS FINAL--> ${viewModels.selectReqId}");
                                          CacheHelper.deleteData(key: "from");
                                          print("IDS IS FINAL--> ${viewModels.selectReqId}");
                                          CacheHelper.deleteData(key: "to");
                                          print("IDS IS FINAL--> ${viewModels.selectReqId}");
                                          CacheHelper.deleteData(key: "selectStatus");
                                          print("IDS IS FINAL--> ${viewModels.selectReqId}");
                                          CacheHelper.deleteData(key: "depId");
                                          print("IDS IS FINAL--> ${viewModels.selectReqId}");
                                          CacheHelper.deleteData(key: "reqId");
                                          print("IDS IS FINAL--> ${viewModels.selectReqId}");
                                          CacheHelper.setString(key: "empId", value: viewModel.selectEmpId ?? "");
                                          print("IDS IS FINAL--> ${viewModels.selectReqId}");
                                          if(viewModel.selectDepId != null){
                                            CacheHelper.setString(key: "depId", value: viewModel.selectDepId ?? "");
                                          }
                                          print("IDS IS FINAL--> ${viewModels.selectReqId}");
                                          if(viewModels.selectStatus != null){
                                            CacheHelper.setString(key: "selectStatus", value: viewModels.selectStatus ?? "");
                                          }
                                          print("IDS IS FINAL--> ${viewModels.selectReqId}");
                                          if(viewModels.selectReqId != null){
                                            CacheHelper.setString(key: "reqId", value: viewModels.selectReqId ?? "");
                                          }
                                            if(viewModels.selectedDateOrDatetimeRange != null && viewModels.selectedDateOrDatetimeRange?.start != null){CacheHelper.setString(key: "from", value: normalizeDateToEnglish(DateService.formateDateTimeBeforeSendToServer(
                                                dateTime: viewModels.selectedDateOrDatetimeRange!.start)).toString() ?? "", );}
                                          if(viewModels.selectedDateOrDatetimeRange != null &&viewModels.selectedDateOrDatetimeRange?.end != null) {  CacheHelper.setString(key: "to", value: normalizeDateToEnglish(DateService.formateDateTimeBeforeSendToServer(
                                                dateTime: viewModels.selectedDateOrDatetimeRange!.end)).toString() ?? "",);}
                                            Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(AppColors.dark),
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 40),
                                          child: Text(
                                            AppStrings.applyFilter.tr().toUpperCase(),
                                            style:const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xffFFFFFF)
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: ()async{
                                         if(CacheHelper.getString( "empId") != "" && CacheHelper.getString( "empId") != null) {
                                           CacheHelper.deleteData(key: "empId");
                                         }if(CacheHelper.getString( "from") != "" && CacheHelper.getString( "from") != null) {
                                           CacheHelper.deleteData(key: "from");
                                         }if(CacheHelper.getString( "to") != "" && CacheHelper.getString( "to") != null) {
                                           CacheHelper.deleteData(key: "to");
                                         }if(CacheHelper.getString( "depId") != "" && CacheHelper.getString( "depId") != null) {
                                           CacheHelper.deleteData(key: "depId");
                                         }if(CacheHelper.getString( "reqId") != "" && CacheHelper.getString( "reqId") != null) {
                                           CacheHelper.deleteData(key: "reqId");
                                         }
                                         Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(50),
                                            border: Border.all(color: const Color(AppColors.dark))
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 40),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                AppStrings.cancel.tr().toUpperCase(),
                                                style:const TextStyle(
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
          color:const Color(0xffFFFFFF),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextFormField(
          controller: controller,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText ?? "Input",
            labelStyle: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xff191C1F)
            ),
            hintStyle:const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xff464646)
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
      style: const TextStyle(
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
           (color == Color(0xffffffff))? BoxShadow(
          color: Color(0xffC9CFD2).withOpacity(0.7),
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
        border: Border.all(color:Color(0xffC9CFD2)),
      ),
      child: Text(AppStrings.all.tr(), style: (colors != Colors.black)?
      Theme.of(context).textTheme.bodySmall : Theme.of(context).textTheme.bodySmall!.copyWith(color: Color(0xffFFFFFF))),
    ) : Container();
  }
}
