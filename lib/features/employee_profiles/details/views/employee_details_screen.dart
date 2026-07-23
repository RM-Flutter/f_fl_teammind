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
import 'package:app_test/features/employee_profiles/details/views/widgets/daily_reports_section_widget.dart';
import 'package:app_test/features/employee_profiles/details/views/widgets/overtime_requests_section_widget.dart';
import 'package:app_test/features/employee_profiles/details/views/widgets/salary_advance_section_widget.dart';
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
    AppStrings.dailyReports.tr(),
    AppStrings.overtimeRequests.tr(),
    'salary_advance_requests'.tr(),
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
              if (viewModel.isLoading) {
                return const DetailsLoadingWidget();
              }
              
              if (viewModel.employee == null) {
                return NoExistingPlaceholderScreen(
                  height: AppSizes.s300,
                  title: AppStrings.thereIsNoEmployeeDataFound.tr(),
                );
              }

              bool hasFullAccess = ((viewModel.employee?.id != null && viewModel.currentUserSettings?.empId != null) &&
                      (viewModel.employee?.id == viewModel.currentUserSettings?.empId)) ||
                  (viewModel.currentUserSettings?.isManagerIn != null &&
                      (viewModel.currentUserSettings?.isManagerIn?.isNotEmpty ?? false) &&
                      (viewModel.currentUserSettings!.isManagerIn!.contains(viewModel.employee?.departmentId) == true)) ||
                  (viewModel.currentUserSettings?.isHr != null && (viewModel.currentUserSettings?.isHr == true)) ||
                  (viewModel.currentUserSettings?.topManagement != null &&
                      (viewModel.currentUserSettings?.topManagement == true)) ||
                  (viewModel.currentUserSettings?.isTeamleaderIn != null &&
                      (viewModel.currentUserSettings?.isTeamleaderIn?.isNotEmpty ?? false) &&
                      (viewModel.currentUserSettings!.isTeamleaderIn!.contains(viewModel.employee!.departmentId) == true));

              return Column(
                children: [
                  // Page Header
                  EmployeeDetailsHeader(employee: viewModel.employee),
                  if (hasFullAccess)
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: kIsWeb ? 1100 : double.infinity
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.s8,
                                vertical: AppSizes.s12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color:  Color(AppColors.secondaryButton),
                                    borderRadius: BorderRadius.circular(AppSizes.s32),
                                  ),
                                  height: 60,
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.s8,
                                        vertical: AppSizes.s8),
                                    child: Builder(
                                      builder: (context) {
                                        if (selectIndex == 0) {
                                          return ContactsSectionWidget(employee: viewModel.employee);
                                        } else if (selectIndex == 1) {
                                          return GeneralSectionWidget(employee: viewModel.employee);
                                        } else if (selectIndex == 2) {
                                          return AccountsSectionWidget(
                                            employee: viewModel.employee,
                                            salaryAdvance: viewModel.salaryAdvances ?? [],
                                          );
                                        } else if (selectIndex == 3) {
                                          return RequestsSectionWidget(employee: viewModel.employee);
                                        } else if (selectIndex == 4) {
                                          return EvalutaionSectionWidget(
                                            employee: viewModel.employee,
                                            evaluations: viewModel.evaluations,
                                            id: viewModel.employee!.id.toString(),
                                            empName: viewModel.employee!.name.toString(),
                                          );
                                        } else if (selectIndex == 5) {
                                          return DailyReportsSectionWidget(
                                            employee: viewModel.employee,
                                            reports: viewModel.dailyReports,
                                            id: viewModel.employee!.id.toString(),
                                            empName: viewModel.employee!.name.toString(),
                                          );
                                        } else if (selectIndex == 6) {
                                          return OvertimeRequestsSectionWidget(
                                            employee: viewModel.employee,
                                            requests: viewModel.overtimeRequests,
                                            id: viewModel.employee!.id.toString(),
                                            empName: viewModel.employee!.name.toString(),
                                          );
                                        } else if (selectIndex == 7) {
                                          return SalaryAdvanceSectionWidget(
                                            employee: viewModel.employee,
                                            requests: viewModel.salaryAdvanceRequestsList,
                                            id: viewModel.employee!.id.toString(),
                                            empName: viewModel.employee!.name.toString(),
                                          );
                                        } else if (selectIndex == 8) {
                                          return AssetsSectionWidget(employee: viewModel.employee);
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
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
                          maxWidth: kIsWeb ? 1100 : double.infinity
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
