import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/utils/tab_bar_widget.dart';
import 'package:app_test/features/employee_profiles/details/views/widgets/accounts_section_widget.dart';
import 'package:app_test/features/employee_profiles/details/views/widgets/assets_section_widget.dart';
import 'package:app_test/features/employee_profiles/details/views/widgets/contact_section/contacts_section_widget.dart';
import 'package:app_test/features/employee_profiles/details/views/widgets/evalutaion_section_widget.dart';
import 'package:app_test/features/employee_profiles/details/views/widgets/general_section_widget.dart';
import 'package:app_test/features/employee_profiles/details/views/widgets/profile_details_header.widget.dart';
import 'package:app_test/features/employee_profiles/details/views/widgets/request_section/requests_section_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../controller/employee_details_controller.dart';
import 'package:app_test/core/widgets/details_loading/details_loading.widget.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  var id;
  EmployeeDetailsScreen({super.key, required this.id});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  late final EmployeeDetailsViewModel viewModel;
  bool ? getTeam;
  List<String> taps = [
    AppStrings.contact.tr(),
    AppStrings.general.tr(),
    AppStrings.accounts.tr(),
    AppStrings.requests.tr(),
    AppStrings.evaluation.tr(),
    AppStrings.more.tr(),
  ];
  int selectIndex = 0;
  @override
  void initState() {
    super.initState();
    viewModel = EmployeeDetailsViewModel();
    if (widget.id != null) {
      var jsonString;
      var gCache;
      jsonString = CacheHelper.getString("US1");
      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
        gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      }
      if(widget.id.toString() == gCache['employee_profile_id'].toString()){
        debugPrint("THIS PROFILE IS MINE");
        getTeam = false;
      }else{
        debugPrint("THIS PROFILE IS NOT MINE");
        getTeam = true;
      }
      viewModel.initializeEmployeesListScreen(
          context: context, employeeId: widget.id.toString(),
        getTeam: getTeam!
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<EmployeeDetailsViewModel>(
        create: (_) => viewModel,
        child: Consumer<EmployeeDetailsViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  // Page Header
                  viewModel.employee == null
                      ? const DetailsLoadingWidget()
                      : EmployeeDetailsHeader(employee: viewModel.employee),
                  if (viewModel.employee != null && (!viewModel.isLoading) &&(viewModel.employee != null)&&
                      ((viewModel.employee?.id != null && viewModel.currentUserSettings?.empId != null)&&
                          (viewModel.employee?.id == viewModel.currentUserSettings?.empId) ) ||
                      //if the current user is manager || the current user is leader of the opened employee profile
                      (viewModel.currentUserSettings?.isManagerIn != null && (viewModel.currentUserSettings?.isManagerIn?.isNotEmpty ?? false) &&(viewModel.currentUserSettings!.isManagerIn!.contains(viewModel.employee?.departmentId) == true)) ||
                      (viewModel.currentUserSettings?.isHr !=
                          null &&
                          (viewModel.currentUserSettings?.isHr== true)) ||
                      (viewModel.currentUserSettings?.topManagement !=
                          null &&
                          (viewModel.currentUserSettings?.topManagement== true)) ||
                      (viewModel.currentUserSettings?.isTeamleaderIn !=
                          null &&
                          (viewModel.currentUserSettings?.isTeamleaderIn?.isNotEmpty ?? false)  &&
                          (viewModel.employee != null && viewModel.currentUserSettings!.isTeamleaderIn!.contains(viewModel.employee!.departmentId) == true)))
                    viewModel.isLoading
                        ? const DetailsLoadingWidget()
                        : viewModel.employee == null
                        ?  NoExistingPlaceholderScreen(
                        height: AppSizes.s300.h,
                        title: AppStrings.thereIsNoEmployeeDataFound.tr() )
                        : Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: kIsWeb ? 1100.w : double.infinity
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.s8.w,
                                vertical: AppSizes.s12.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // 👈 Align start in column
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                  decoration: BoxDecoration(
                                    color:  Theme.of(context).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(AppSizes.s32.r),
                                  ),
                                  height: 60.h,
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                                  child: defaultTapBarItem(
                                    isVertical: false,
                                    items: taps,
                                    tapBarItemsWidth: MediaQuery.sizeOf(context).width * 0.95,
                                    selectIndex: selectIndex,
                                    enableScroll: true,
                                    onTapItem: (index) {
                                      setState(() {
                                        selectIndex = index;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                    EdgeInsets.symmetric(
                                        horizontal: AppSizes.s8.w,
                                        vertical: AppSizes.s8.h),
                                    child: Column(
                                      children: [
                                        if(selectIndex == 0)  ContactsSectionWidget(
                                            employee:
                                            viewModel.employee),

                                        //GENERAL SECTION
                                        if(selectIndex == 1)   SingleChildScrollView(
                                          child: SizedBox(
                                            height: MediaQuery.sizeOf(context).height * 0.5,
                                            child: GeneralSectionWidget(
                                                employee:
                                                viewModel.employee),
                                          ),
                                        ),
                                        //ACCOUNTS
                                        if(selectIndex == 2) AccountsSectionWidget(
                                          employee: viewModel.employee,
                                          salaryAdvance: viewModel.salaryAdvances ?? [],
                                        ),
                                        //REQUESTS SECTION
                                        if(selectIndex == 3)   RequestsSectionWidget(
                                            employee:
                                            viewModel.employee),
                                        if(selectIndex == 4) EvalutaionSectionWidget( employee:
                                        viewModel.employee,
                                          evaluations: viewModel.evaluations,
                                          id : viewModel.employee!.id.toString(),
                                          empName : viewModel.employee!.name.toString(),
                                        ),
                                        if(selectIndex == 5) SizedBox(
                                          child: SizedBox(
                                            height: MediaQuery.sizeOf(context).height * 0.5,
                                            child: AssetsSectionWidget( employee:
                                            viewModel.employee,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: kIsWeb ? 1100.w : double.infinity
                      ),
                      child: ContactsSectionWidget(
                          employee:
                          viewModel.employee),
                    ),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }
}
