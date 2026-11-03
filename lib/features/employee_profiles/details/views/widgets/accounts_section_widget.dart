import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:app_test/features/evaluation/shared/widgets/profile_tile_widget.dart';
import 'package:app_test/features/payrolls/payroll_list/views/widgets/payroll_list_item_widget.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AccountsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  List? salaryAdvance = [];
  /// Latest payrolls, loaded separately from the profile; null while not loaded yet
  final List<PayrollModel>? payrolls;
  final bool isLoadingPayrolls;
  AccountsSectionWidget({super.key, required this.employee, required this.salaryAdvance, this.payrolls, this.isLoadingPayrolls = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH12,
          if ((employee?.basicSalary != null ||
                  employee?.basicSalary?.isNotEmpty == true) ||
              employee?.additions != null ||
              employee?.totalDeductions != null ||
              employee?.netSalary != null) ...[

                //HIRE DATE
            if (employee?.basicSalary != null)
              ProfileTile(
                isTitleOnly: false,
                isList: false,
                title: AppStrings.basicSalary.tr().toUpperCase(),
                trailingTitle: "${employee?.basicSalary.toString()} ${employee?.currency ?? AppStrings.egp.tr()}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color:  Color(AppColors.buttons)),
              ),
            //WORK HOURS TYPE
            if (employee?.additions != null)
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.additions.tr().toUpperCase(),
                trailingTitle: "${employee?.additions.toString()} ${employee?.currency ?? AppStrings.egp.tr()}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color:  Color(AppColors.buttons)),
              ),
            // WORK HOURS
            if (employee?.totalDeductions != null)
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.totalDeductions.tr().toUpperCase(),
                trailingTitle: "${employee?.totalDeductions.toString()} ${employee?.currency ?? AppStrings.egp.tr()}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color:  Color(AppColors.buttons)),
              ),
            //WEEKENDS
            if (employee?.netSalary != null)
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.netSalaryPayable.tr().toUpperCase(),
                trailingTitle: "${employee?.netSalary.toString()} ${employee?.currency ?? AppStrings.egp.tr()}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20, height: 20, color:  Color(AppColors.buttons)),
              ),
          ],
          gapH24,
          if (isLoadingPayrolls || payrolls?.isNotEmpty == true) ...[
            Text(
              AppStrings.payrolls.tr(),
              style: AppStyles.heading(context).copyWith(fontWeight: FontWeight.w600, fontSize: AppSizes.s16),
            ),
            gapH12,
            if (isLoadingPayrolls)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.s16),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              ...payrolls!.map((payroll) => PayrollListItemWidget(payroll: payroll)),
            gapH12,
          ],
          Center(
              child: CustomElevatedButton(
                  backgroundColor: Color(AppColors.secondaryButton),
                  titleSize: AppSizes.s12,
                  title: AppStrings.viewPayrolls.tr().toUpperCase(),
                  onPressed: () async => await context
                          .pushNamed(AppRoutes.payrollsList.name, extra: {
                        'employeeName': employee?.name,
                        'employeeId': employee?.id?.toString()
                      }, pathParameters: {
                        'lang': context.locale.languageCode
                      }))),
        ],
      ),
    );
  }
}
