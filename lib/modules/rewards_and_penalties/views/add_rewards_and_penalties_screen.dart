import 'dart:convert';

import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../common_modules_widgets/template_page.widget.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/user_consts.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../general_services/localization.service.dart';
import '../../../models/settings/general_settings.model.dart';
import '../../../utils/animated_custom_dropdown/custom_dropdown.dart';
import '../../../utils/widgets/text_form_widget.dart';
import '../view_models/add_reward_and_penalty.viewmodel.dart';

class AddRewardAndPenaltyScreen extends StatefulWidget {
  const AddRewardAndPenaltyScreen({super.key});

  @override
  State<AddRewardAndPenaltyScreen> createState() =>
      _AddRewardAndPenaltyScreenState();
}

class _AddRewardAndPenaltyScreenState extends State<AddRewardAndPenaltyScreen> {
  late final AddRewardAndPenaltyViewModel viewModel;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>>? types ;
  @override
  void initState() {
    super.initState();
    viewModel = AddRewardAndPenaltyViewModel();
    viewModel.initializeAddRewardAndPenaltyScreen(context: context);
  }

  @override
  Widget build(BuildContext context) {
    var gCache;
    var jsonString;
    jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.generalSettingsModel = GeneralSettingsModel.fromJson(gCache);
    }
    var s1Cache;
    var s1JsonString;
    s1JsonString = CacheHelper.getString("US1");
    if (s1JsonString != null && s1JsonString.isNotEmpty && s1JsonString != "") {
      s1Cache = json.decode(s1JsonString) as Map<String, dynamic>; // Convert String back to JSON
    }

    if(s1Cache['can_add_reward'] == true && s1Cache['can_add_penalty'] == true){
      types = [
        {
          'type': 'penalty',
          'name': AppStrings.penalty.tr(),
        },
        {
          'type': 'reward',
          'name': AppStrings.reward.tr(),
        },
      ];
      setState(() {

      });
    }else if(s1Cache['can_add_reward'] == true && s1Cache['can_add_penalty'] == false){
      types = [
        {
          'type': 'reward',
          'name': AppStrings.reward.tr(),
        },
      ];
      setState(() {

      });
    }else if(s1Cache['can_add_reward'] == false && s1Cache['can_add_penalty'] == true){
      types = [
        {
          'type': 'penalty',
          'name': AppStrings.penalty.tr(),
        },
      ];
    }else{
      types = [];
      setState(() {

      });
    }
    return ChangeNotifierProvider<AddRewardAndPenaltyViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          pageContext: context,
          title: AppStrings.addRewardAndPenalty.tr(),
          body: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.s16, horizontal: AppSizes.s12),
                child: Consumer<AddRewardAndPenaltyViewModel>(
                  builder: (context, viewModel, child) => Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        gapH14,
                        //Date Field
                        CustomDropdown.search(
                            selectedValue: viewModel.selectedType,
                            borderRadius: BorderRadius.circular(AppSizes.s15),
                            borderSide: Theme.of(context)
                                .inputDecorationTheme
                                .enabledBorder
                                ?.borderSide,
                            hintText: AppStrings.rewardsOrPenalties.tr(),
                            onRemoveClicked: (){
                              viewModel.selectedType = null;
                              viewModel.selectedDatecontroller.clear();
                              viewModel.amountController.clear();
                              viewModel.reasonController.clear();
                              viewModel.selectedCategory = null;
                              viewModel.selectedEmployee = null;
                              setState(() {
                              });
                            },
                            hintStyle:
                            Theme.of(context).inputDecorationTheme.hintStyle,
                            items: types,
                            nameKey: "name",
                            onChanged: (value) {
                              if (value == null || value.toString().isEmpty) {
                                viewModel.selectedType = null;
                              }
                              viewModel.selectedType = value;
                              viewModel.selectedDatecontroller.clear();
                              viewModel.amountController.clear();
                              viewModel.reasonController.clear();
                              viewModel.reasonController.clear();
                              viewModel.selectedCategory = null;
                              viewModel.selectedEmployee = null;
                              setState(() {
                              });
                            },
                            contentPadding: Theme.of(context)
                                .inputDecorationTheme
                                .contentPadding
                                ?.resolve(
                                LocalizationService.isArabic(context: context)
                                    ? TextDirection.rtl
                                    : TextDirection.ltr)),
                        gapH14,
                        TextField(
                          controller: viewModel.selectedDatecontroller,
                          decoration: InputDecoration(
                            hintText: AppStrings.date.tr(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => viewModel.selectDate(context),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => viewModel.selectDate(context),
                        ),
                        gapH14,
                        defaultDropdownField(
                          value: viewModel.selectedTypes,
                          title: viewModel.selectedTypes ?? AppStrings.requestType.tr(),
                          items: (gCache['allowed_rewards_and_penalty_types'] as List)
                              .map((e) => DropdownMenuItem<String>(
                            value: e.toString(),
                            child: Text(
                              e.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff191C1F),
                              ),
                            ),
                          ))
                              .toList(),
                          onChanged: (String? values) {
                            print(values);
                            setState(() {
                              viewModel.selectedTypes = values;
                            });
                          },
                        ),

                        // CustomDropdown.search(
                        //     selectedValue: viewModel.selectedCategory,
                        //     borderRadius: BorderRadius.circular(AppSizes.s15),
                        //     borderSide: Theme.of(context)
                        //         .inputDecorationTheme
                        //         .enabledBorder
                        //         ?.borderSide,
                        //     hintText: AppStrings.category.tr(),
                        //     onRemoveClicked: (){
                        //       viewModel.selectedCategory = null;
                        //       setState(() {
                        //       });
                        //     },
                        //     hintStyle:
                        //         Theme.of(context).inputDecorationTheme.hintStyle,
                        //     items: viewModel.categories,
                        //     nameKey: "name",
                        //     onChanged: (value) =>
                        //         viewModel.selectedCategory = value,
                        //     contentPadding: Theme.of(context)
                        //         .inputDecorationTheme
                        //         .contentPadding
                        //         ?.resolve(
                        //             LocalizationService.isArabic(context: context)
                        //                 ? TextDirection.rtl
                        //                 : TextDirection.ltr)),
                        gapH14,
                        TextFormField(
                          controller: viewModel.amountController,
                          keyboardType: TextInputType.number,
                          validator: (String? value){
                            if(value!.isEmpty){
                              return "${AppStrings.amounts.tr()} ${AppStrings.isRequired.tr()}";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: AppStrings.amounts.tr(),
                          ),
                        ),
                        gapH14,
                        CustomDropdown.search(
                            selectedValue: viewModel.selectedEmployee,
                            borderRadius: BorderRadius.circular(AppSizes.s15),
                            borderSide: Theme.of(context)
                                .inputDecorationTheme
                                .enabledBorder
                                ?.borderSide,
                            hintText: AppStrings.employeeName.tr(),
                            onRemoveClicked: (){
                              viewModel.selectedEmployee = null;
                              viewModel.selectEmpId = null;
                              setState(() {
                              });
                            },
                            hintStyle: Theme.of(context)
                                .inputDecorationTheme
                                .hintStyle,
                            items: viewModel.employees,
                            nameKey: "name",
                            onChanged: (value){
                              viewModel.selectedEmployee = value;
                              viewModel.selectEmpId = value['id'].toString();
                              print("Selected employee ID: ${value["id"]}");
                              setState(() {});
                            },
                            contentPadding: Theme.of(context)
                                .inputDecorationTheme
                                .contentPadding
                                ?.resolve(LocalizationService.isArabic(
                                context: context)
                                ? TextDirection.rtl
                                : TextDirection.ltr)),
                        gapH14,
                        // Reason
                        TextFormField(
                          controller: viewModel.reasonController,
                          maxLines: 5,
                          validator: (String? value){
                            if(value!.isEmpty){
                              return "${AppStrings.reason.tr()} ${AppStrings.isRequired.tr()}";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: AppStrings.reason.tr(),
                          ),
                        ),
                        //TODO:ADDING EMPLOYEE THAT MANAGED BY ME IN DROPDOWN
                        const SizedBox(height: 30,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          if(viewModel.isLoadingPost == false)  CustomElevatedButton(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              titleSize: AppSizes.s14,
                              radius: AppSizes.s24,
                              title: AppStrings.send.tr(),
                              onPressed: () async {
                                if(formKey.currentState!.validate()){
                                  viewModel
                                      .createRewardAndPenalty(context: context);
                                }
                              }
                            ),
                            if(viewModel.isLoadingPost == true) const CircularProgressIndicator()
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
