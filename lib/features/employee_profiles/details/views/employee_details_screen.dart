import 'dart:convert';
import 'package:app_test/core/helpers/package_helper.dart';

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
import 'package:app_test/features/employee_profiles/details/views/widgets/rewards_and_penalties_section_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_test/features/employee_profiles/details/views/widgets/expense_claims_section_widget.dart';
import 'package:app_test/features/employee_profiles/details/views/widgets/shift_change_requests_section_widget.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../controller/employee_details_controller.dart';
import 'package:app_test/core/widgets/details_loading/details_loading.widget.dart';
import 'package:app_test/core/constants/app_design.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  var id;
  EmployeeDetailsScreen({super.key, required this.id});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class ProfileTabModel {
  final String title;
  final int index;
  ProfileTabModel({required this.title, required this.index});
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  late final EmployeeDetailsViewModel viewModel;
  bool ? getTeam;

  List<ProfileTabModel> get availableTabs {
    List<ProfileTabModel> items = [];
    items.add(ProfileTabModel(title: AppStrings.contact.tr(), index: 0));
    items.add(ProfileTabModel(title: AppStrings.general.tr(), index: 1));
    // Salary and payrolls: decided by the backend from the payroll_view_permissions setting
    if (viewModel.employee?.canSeePayroll ?? false) {
      items.add(ProfileTabModel(title: AppStrings.accounts.tr(), index: 2));
    }

    if (PackageHelper.hasPackage('emp-requests')) {
      items.add(ProfileTabModel(title: AppStrings.requests.tr(), index: 3));
    }

    if (PackageHelper.hasPackage('emp-evaluation')) {
      items.add(ProfileTabModel(title: AppStrings.evaluation.tr(), index: 4));
    }

    if (PackageHelper.hasPackage('emp-reports')) {
      items.add(ProfileTabModel(title: AppStrings.dailyReports.tr(), index: 5));
    }

    if (PackageHelper.hasPackage('fingerprint-sys')) {
      items.add(ProfileTabModel(title: AppStrings.overtimeRequests.tr(), index: 6));
    }

    if (PackageHelper.hasPackage('emp-payroll')) {
      items.add(ProfileTabModel(title: 'salary_advance_requests'.tr(), index: 7));
      items.add(ProfileTabModel(title: 'rewards_and_penalties'.tr(), index: 8));
    }

    if (PackageHelper.hasPackage('emp-payroll')) {
      items.add(ProfileTabModel(title: AppStrings.expenseClaims.tr(), index: 10));
    }

    Map<String, dynamic>? us2Cache;
    final us2String = CacheHelper.getString("US2");
    if (us2String != null && us2String.isNotEmpty) {
      try {
        us2Cache = json.decode(us2String) as Map<String, dynamic>;
      } catch (_) {}
    }
    final bool isCurrentUserShifts =
        us2Cache?['worktime']?['working_hours_type']?.toString() == 'shifts';

    if (PackageHelper.hasPackage('emp-requests') &&
        isCurrentUserShifts &&
        (getTeam == false ||
            viewModel.employee?.workingHoursType == 'shifts' ||
            viewModel.employee?.workingHours?.workingHoursType == 'shifts' ||
            viewModel.employee?.thisWeekShifts != null)) {
      items.add(ProfileTabModel(title: AppStrings.shiftChangeRequests.tr(), index: 11));
    }

    if (PackageHelper.hasPackage('emp-requests')) {
      items.add(ProfileTabModel(title: AppStrings.more.tr(), index: 9));
    }

    return items;
  }

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

              // Decided by the backend (self, HR, top management, department manager incl. sub-departments, team leader)
              final bool hasFullAccess = viewModel.employee?.canSeeAllData ?? false;

              final page = Column(
                children: [
                  // Page Header
                  EmployeeDetailsHeader(employee: viewModel.employee),
                  if (hasFullAccess)
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxWidth: double.infinity
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
                                    borderRadius: BorderRadius.circular(AppRadius.xl),
                                  ),
                                  height: 60,
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                  child: defaultTapBarItem(
                                    isVertical: false,
                                    items: availableTabs.map((e) => e.title).toList(),
                                    tapBarItemsWidth: MediaQuery.sizeOf(context).width * 0.95,
                                    selectIndex: selectIndex,
                                    enableScroll: true,
                                    fitToText: true,
                                    onTapItem: (index) {
                                      setState(() {
                                        selectIndex = index;
                                      });
                                      viewModel.fetchDataForIndex(
                                        availableTabs[index].index, 
                                        context, 
                                        getTeam: getTeam ?? false, 
                                        empId: viewModel.employee!.id.toString()
                                      );
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
                                        if (availableTabs.isEmpty) return const SizedBox.shrink();
                                        int actualIndex = availableTabs[selectIndex].index;
                                        if (actualIndex == 0) {
                                          return ContactsSectionWidget(employee: viewModel.employee);
                                        } else if (actualIndex == 1) {
                                          return GeneralSectionWidget(employee: viewModel.employee);
                                        } else if (actualIndex == 2) {
                                          if (viewModel.salaryAdvances == null) return const Center(child: CircularProgressIndicator());
                                          return AccountsSectionWidget(
                                            employee: viewModel.employee,
                                            salaryAdvance: viewModel.salaryAdvances ?? [],
                                            payrolls: viewModel.payrolls,
                                            isLoadingPayrolls: viewModel.isLoadingPayrolls,
                                          );
                                        } else if (actualIndex == 3) {
                                          return RequestsSectionWidget(employee: viewModel.employee);
                                        } else if (actualIndex == 4) {
                                          return EvalutaionSectionWidget(
                                            employee: viewModel.employee,
                                            evaluations: viewModel.evaluations,
                                            id: viewModel.employee!.id.toString(),
                                            empName: viewModel.employee!.name.toString(),
                                          );
                                        } else if (actualIndex == 5) {
                                          if (viewModel.dailyReports == null) return const Center(child: CircularProgressIndicator());
                                          return DailyReportsSectionWidget(
                                            employee: viewModel.employee,
                                            reports: viewModel.dailyReports,
                                            id: viewModel.employee!.id.toString(),
                                            empName: viewModel.employee!.name.toString(),
                                          );
                                        } else if (actualIndex == 6) {
                                          if (viewModel.overtimeRequests == null) return const Center(child: CircularProgressIndicator());
                                          return OvertimeRequestsSectionWidget(
                                            employee: viewModel.employee,
                                            requests: viewModel.overtimeRequests,
                                            id: viewModel.employee!.id.toString(),
                                            empName: viewModel.employee!.name.toString(),
                                          );
                                        } else if (actualIndex == 7) {
                                          if (viewModel.salaryAdvanceRequestsList == null) return const Center(child: CircularProgressIndicator());
                                          return SalaryAdvanceSectionWidget(
                                            employee: viewModel.employee,
                                            requests: viewModel.salaryAdvanceRequestsList,
                                            id: viewModel.employee!.id.toString(),
                                            empName: viewModel.employee!.name.toString(),
                                          );
                                        } else if (actualIndex == 8) {
                                          return RewardsAndPenaltiesSectionWidget(
                                            employee: viewModel.employee,
                                          );
                                        
                                        } else if (actualIndex == 10) {
                                          if (viewModel.expenseClaimRequestsList == null) return const Center(child: CircularProgressIndicator());
                                          return ExpenseClaimsSectionWidget(
                                            employee: viewModel.employee,
                                            requests: viewModel.expenseClaimRequestsList,
                                            id: viewModel.employee!.id.toString(),
                                            empName: viewModel.employee!.name.toString(),
                                          );
                                        } else if (actualIndex == 11) {
                                          if (viewModel.shiftChangeRequestsList == null) return const Center(child: CircularProgressIndicator());
                                          return ShiftChangeRequestsSectionWidget(
                                            employee: viewModel.employee,
                                            requests: viewModel.shiftChangeRequestsList,
                                            id: viewModel.employee!.id.toString(),
                                            empName: viewModel.employee!.name.toString(),
                                          );
                                        } else if (actualIndex == 9) {
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
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity
                      ),
                      child: ContactsSectionWidget(
                          employee:
                          viewModel.employee),
                    ),
                  ),
                ],
              );

              // Pull-to-refresh for the whole page (header included): the page sits in an always-scrollable
              // view of screen height, and overscroll of the inner tab scroll views also triggers it.
              return RefreshIndicator.adaptive(
                notificationPredicate: (_) => true,
                onRefresh: () => viewModel.refreshData(
                  context: context,
                  employeeId: widget.id.toString(),
                  getTeam: getTeam ?? false,
                  tabIndex: availableTabs[selectIndex].index,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(height: constraints.maxHeight, child: page),
                  ),
                ),
              );
            }
        ),
      ),
    );
  }
}
