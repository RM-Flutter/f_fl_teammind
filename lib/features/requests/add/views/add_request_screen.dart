import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/animated_custom_dropdown/custom_dropdown.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
import 'package:app_test/features/requests/add/controller/add_new_request_controller.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/text_form_widget.dart';
import '../../shared/ui/widgets/custom_request_details_button.widget.dart';

class AddRequestScreen extends StatefulWidget {
  const AddRequestScreen({super.key});

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  late final AddNewRequestController viewModel;
  late final HomeController homeViewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AddNewRequestController();
    homeViewModel = HomeController();
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
    final textStyle = AppStyles.heading(context).copyWith(
        fontWeight: FontWeight.w400,
        color: Color(AppColors.buttons),
        fontSize: 16,
    );
    return ChangeNotifierProvider<AddNewRequestController>(
      create: (_) => viewModel,
      child: TemplatePage(
          pageContext: context,
          title: AppStrings.newRequest.tr(),
          titleStyle: AppStyles.heading(context).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          body: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: kIsWeb ? 1100 : 1.sw
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 16, horizontal: !kIsWeb? 12 : 0),
                  child: Consumer<AddNewRequestController>(
                      builder: (context, viewModel, child){
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
                                      SizedBox(height: 14),
                                      if(viewModel.requestsTypes != null && viewModel.requestsTypes!.isNotEmpty)
                                        defaultDropdownField(
                                          value: viewModel.selectReqType,
                                          title: viewModel.selectReqType ?? AppStrings.requestType.tr(),
                                          items: viewModel.requestsTypes!.map((e) => DropdownMenuItem(
                                            value: e['id'].toString(),
                                            child: Text(
                                              e['title'][context.locale.languageCode].toString(),
                                              style: AppStyles.almostBlackContent(context).copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
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
                                            style: AppStyles.almostBlackContent(context).copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
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
                                      SizedBox(height: 14),
                                      viewModel.reqType ==
                                          'instead_of_holidays'
                                          ? CustomDropdown.search(
                                          selectedValue: viewModel.selectedRequestType,
                                          borderRadius:
                                          BorderRadius.circular(15),
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
                                        style: AppStyles.darkContent(context).copyWith(fontSize: 14),
                                        decoration: InputDecoration(
                                          hintText: AppStrings.requestTime.tr(),
                                          hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 13),
                                          suffixIcon: IconButton(
                                            icon: Image.asset('assets/images/new-cale.png', width: 22, height: 22, color: Colors.grey[600]),
                                            onPressed: () =>
                                                viewModel.selectDate(context, filter: false),
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () => viewModel.selectDate(context, filter: false),
                                      ),
                                      SizedBox(height: 14),
                                      TextFormField(
                                        controller: viewModel.reasonController,
                                        maxLines: 3,
                                        style: AppStyles.darkContent(context).copyWith(fontSize: 14),
                                        decoration: InputDecoration(
                                          hintText: AppStrings.reason.tr(),
                                          hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 13),
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          if(viewModel.reqTypeFile == "required" || viewModel.reqTypeFile == "optional"
                                              || viewModel.reqTypeMoney == "required" || viewModel.reqTypeMoney == "optional")  Text(
                                            AppStrings.additionalData.tr().toUpperCase(),
                                            style: textStyle,
                                          ),
                                          if(viewModel.reqTypeFile == "required" || viewModel.reqTypeFile == "optional") SizedBox(height: 14),
                                          if(viewModel.reqTypeFile == "required"|| viewModel.reqTypeFile == "optional")TextFormField(
                                            controller: viewModel.fileController,
                                            style: AppStyles.darkContent(context).copyWith(fontSize: 14),
                                            decoration: InputDecoration(
                                              hintText: AppStrings.uploadFiles.tr(),
                                              hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 13),
                                              suffixIcon: IconButton(
                                                icon: Icon(Icons.cloud_upload_outlined, color: Colors.grey, size: 26),
                                                onPressed: () async =>
                                                    viewModel.pickFile(),
                                              ),
                                            ),
                                            readOnly: true,
                                            onTap: () async =>
                                            await viewModel.pickFile(),
                                          ),
                                          if(viewModel.reqTypeMoney == "required" || viewModel.reqTypeMoney == "optional") SizedBox(height: 14),
                                          if(viewModel.reqTypeMoney == "required" || viewModel.reqTypeMoney == "optional")  TextFormField(
                                            controller:
                                            viewModel.amountController,
                                            style: AppStyles.darkContent(context).copyWith(fontSize: 14),
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              hintText: AppStrings.amount.tr(),
                                              hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 13),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 14),
                                      // Text(viewModel.notes ?? ''),
                                    ],
                                  ),
                                )),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 16),
                              width: 1.sw,
                              decoration: BoxDecoration(
                                  color: Color(AppColors.secondaryButton),
                                  borderRadius: BorderRadius.circular(50)),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width: 12),
                                    Expanded(
                                        child: Text(
                                          viewModel.formattedDuration != null?
                                          "${viewModel.formattedDuration}" :
                                          viewModel.duration != null?
                                          '${viewModel.duration} ${AppStrings.days.tr()}' : "0",
                                          style: textStyle.copyWith(color: Colors.white, fontSize: 14),
                                        )),
                                    SizedBox(width: 8),
                                    CustomRequestDetailsButton(
                                      title: AppStrings.sendRequest.tr(),
                                      color: Color(AppColors.buttons),
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
              ),
            ),
          )),
    );
  }
}
