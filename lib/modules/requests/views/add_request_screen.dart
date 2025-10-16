import 'dart:convert';

import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/modules/home/view_models/home.viewmodel.dart';
import 'package:rmemp/utils/widgets/text_form_widget.dart';
import '../../../common_modules_widgets/template_page.widget.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../general_services/layout.service.dart';
import '../../../general_services/localization.service.dart';
import '../../../utils/animated_custom_dropdown/custom_dropdown.dart';
import '../view_models/add_new_request.viewmodel.dart';
import 'widgets/custom_request_details_button.widget.dart';

class AddRequestScreen extends StatefulWidget {
  const AddRequestScreen({super.key});

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  late final AddNewRequestViewModel viewModel;
  late final HomeViewModel homeViewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AddNewRequestViewModel();
    homeViewModel = HomeViewModel();
    _initAsync();
    viewModel.initializeAddNewRequestScreen(context: context);
  }

  Future<void> _initAsync() async {
    await homeViewModel.initializeHomeScreen(context, ['user2_settings']);
  }
  @override
  Widget build(BuildContext context) {
    var gCache;
    final jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;// Convert String back to JSON
    }
    final textStyle = TextStyle(
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.primary,
      fontSize: AppSizes.s16,
      fontFamily: "Ibrand"
    );
    return ChangeNotifierProvider<AddNewRequestViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          pageContext: context,
          title: AppStrings.newRequest.tr(),
          body: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.s16, horizontal: AppSizes.s12),
              child: Consumer<AddNewRequestViewModel>(
                builder: (context, viewModel, child){
                  // viewModel.requestsTypes = (json['request_types'] as Map<String, dynamic>?)?.values.map((e) {
                  //   final map = e as Map<String, dynamic>;
                  //   final titleMap = map['title'] as Map<String, dynamic>?;
                  //   final titleEn = titleMap?['en'] ?? '';
                  //   return {
                  //     ...map,
                  //     'titleEn': titleEn,
                  //   };
                  // }).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.mainData.tr().toUpperCase(),
                                  style: textStyle,
                                ),
                                gapH14,
                                if(viewModel.requestsTypes != null && viewModel.requestsTypes!.isNotEmpty)
                                  defaultDropdownField(
                                  value: viewModel.selectReqType,
                                  title: viewModel.selectReqType ?? AppStrings.requestType.tr(),
                                  items: viewModel.requestsTypes!.map((e) => DropdownMenuItem(
                                    value: e['id'].toString(),
                                    child: Text(
                                      e['title'][context.locale.languageCode].toString(),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff191C1F)
                                      ),),
                                  ),
                                  ).toList(),
                                  onChanged: (String? values) {
                                    print(values);
                                    final selectedItems = gCache['request_types'].values.firstWhere(
                                          (element) => element['id'].toString() == values,
                                      orElse: () => null,
                                    );
                                    setState(() {
                                     // viewModel.selectReqType = values;
                                      viewModel.controller.clear();
                                      viewModel.reasonController.clear();
                                      viewModel.amountController.clear();
                                      viewModel.duration = null;
                                      viewModel.formattedDuration = null;
                                      viewModel.selectReqType = values;
                                      viewModel.reqType = selectedItems['type'];
                                      viewModel.halfDay = selectedItems['half_day_leave'];
                                      viewModel.reqTypeFile = selectedItems['fields']?['attaching_file'] ;
                                      viewModel.reqTypeMoney = selectedItems['fields']?['money_value'] ;
                                    });

                                  },
                                ),
                                if((viewModel.requestsTypes == null || viewModel.requestsTypes!.isEmpty)
                                    && (AppConstants.requestsTypess != null &&
                                        AppConstants.requestsTypess!.isNotEmpty))defaultDropdownField(
                                  value: viewModel.selectReqType,
                                  title: viewModel.selectReqType ?? AppStrings.requestType.tr(),
                                  items: AppConstants.requestsTypess!.map((e) => DropdownMenuItem(
                                    value: e['id'].toString(),
                                    child: Text(
                                      e['title'][context.locale.languageCode].toString(),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff191C1F)
                                      ),),
                                  ),
                                  ).toList(),
                                  onChanged: (String? values) {
                                    print(values);
                                    final selectedItem = gCache['request_types'].values.firstWhere(
                                          (element) => element['id'].toString() == values,
                                      orElse: () => null,
                                    );
                                    setState(() {
                                     // viewModel.selectReqType = values;
                                      viewModel.duration = null;
                                      viewModel.formattedDuration = null;
                                      viewModel.controller.clear();
                                      viewModel.reasonController.clear();
                                      viewModel.amountController.clear();
                                      viewModel.selectReqType = values;
                                      viewModel.reqType = selectedItem['type'];
                                      viewModel.halfDay = selectedItem['half_day_leave'];
                                      viewModel.reqTypeFile = selectedItem['fields']?['attaching_file'] ;
                                      viewModel.reqTypeFile = selectedItem['fields']?['attaching_file'] ;
                                      viewModel.reqTypeMoney = selectedItem['fields']?['money_value'] ;
                                    });
                                    print("selectedItem --> ${selectedItem}");
                                    print("selectedItem --> ${AppConstants.requestsTypess}");
                                    print("TYPE  IS --> ${viewModel.reqType}");
                                    print("TYPE  IS --> ${viewModel.reqTypeFile}");
                                  },
                                ),
                                gapH14,
                                viewModel.reqType ==
                                    'instead_of_holidays'
                                    ? CustomDropdown.search(
                                    selectedValue: viewModel.selectedRequestType,
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
                                    items: viewModel.requestsTypes ?? AppConstants.requestsTypess!,
                                    nameKey: "name",
                                    onChanged: (value) =>
                                        viewModel.selectInsteadOfHolidays(context,
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
                                  controller: viewModel.controller,
                                  decoration: InputDecoration(
                                    hintText: AppStrings.requestTime.tr(),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.calendar_today),
                                      onPressed: () =>
                                          viewModel.selectDate(context, filter: false),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () => viewModel.selectDate(context, filter: false),
                                ),
                                gapH14,
                                TextFormField(
                                  controller: viewModel.reasonController,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    hintText: AppStrings.reason.tr(),
                                  ),
                                ),
                                gapH14,
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    if(viewModel.reqTypeFile == "required" || viewModel.reqTypeFile == "optional"
                                    || viewModel.reqTypeMoney == "required" || viewModel.reqTypeMoney == "optional")  Text(
                                      AppStrings.additionalData.tr().toUpperCase(),
                                      style: textStyle,
                                    ),
                                    if(viewModel.reqTypeFile == "required" || viewModel.reqTypeFile == "optional") gapH14,
                                    if(viewModel.reqTypeFile == "required"|| viewModel.reqTypeFile == "optional")TextFormField(
                                      controller: viewModel.fileController,
                                      decoration: InputDecoration(
                                        hintText:
                                        AppStrings.uploadFiles.tr(),
                                        suffixIcon: IconButton(
                                          icon:
                                          const Icon(Icons.upload_file),
                                          onPressed: () async =>
                                              viewModel.pickFile(),
                                        ),
                                      ),
                                      readOnly: true,
                                      onTap: () async =>
                                      await viewModel.pickFile(),
                                    ),
                                    if(viewModel.reqTypeMoney == "required" || viewModel.reqTypeMoney == "optional") gapH14,
                                    if(viewModel.reqTypeMoney == "required" || viewModel.reqTypeMoney == "optional")  TextFormField(
                                      controller:
                                      viewModel.amountController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: AppStrings.amount.tr(),
                                      ),
                                    )
                                  ],
                                ),
                                // Consumer<AddNewRequestViewModel>(
                                //     builder: (context, viewModel, child) {
                                //       print("FIELDS IS --> ${viewModel.selectedRequestType?['fields']}");
                                //   final attachingFile =
                                //       (viewModel.selectedRequestType?['fields']
                                //               ?['attaching_file'] as String?)
                                //           ?.toLowerCase()
                                //           .trim();
                                //   final moneyValue =
                                //       (viewModel.selectedRequestType?['fields']
                                //               ?['money_value'] as String?)
                                //           ?.toLowerCase()
                                //           .trim();
                                //   return (attachingFile == 'active' ||
                                //               attachingFile == 'required' ||
                                //               attachingFile == 'optional') ||
                                //           (moneyValue == 'active' ||
                                //               moneyValue == 'required' ||
                                //               moneyValue == 'optional')
                                //       ?
                                //       : const SizedBox.shrink();
                                // }),
                                gapH14,
                                // Text(viewModel.notes ?? ''),
                              ],
                            ),
                          )),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.s6, horizontal: AppSizes.s16),
                        width: LayoutService.getWidth(context),
                        decoration: BoxDecoration(
                            color: const Color(AppColors.dark),
                            borderRadius: BorderRadius.circular(AppSizes.s50)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              gapW12,
                              Expanded(
                                  child: Text(
                                    viewModel.formattedDuration != null?
                                    "${viewModel.formattedDuration}" :
                                    viewModel.duration != null?
                                    '${viewModel.duration} ${AppStrings.days.tr()}' : "0",
                                    style: textStyle.copyWith(color: Colors.white),
                                  )),
                              gapW8,
                              CustomRequestDetailsButton(
                                title: AppStrings.sendRequest.tr(),
                                color: Color(AppColors.primary),
                                onPressed: () async =>
                                    viewModel.createNewRequest(context: context),
                              )
                            ]),
                      )
                    ],
                  );
                }
              ),
            ),
          )),
    );
  }
}
