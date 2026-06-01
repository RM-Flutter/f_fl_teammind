import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:app_test/features/evaluation/shared/widgets/profile_tile_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AccountsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  List? salaryAdvance = [];
  AccountsSectionWidget({super.key, required this.employee, required this.salaryAdvance});

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
                trailingTitle: "${employee?.basicSalary.toString()} ${AppStrings.egp.tr()}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color:  Color(AppColors.buttons)),
              ),
            //WORK HOURS TYPE
            if (employee?.additions != null)
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.additions.tr().toUpperCase(),
                trailingTitle: "${employee?.additions.toString()} ${AppStrings.egp.tr()}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color:  Color(AppColors.buttons)),
              ),
            // WORK HOURS
            if (employee?.totalDeductions != null)
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.totalDeductions.tr().toUpperCase(),
                trailingTitle: "${employee?.totalDeductions.toString()} ${AppStrings.egp.tr()}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color:  Color(AppColors.buttons)),
              ),
            //WEEKENDS
            if (employee?.netSalary != null)
              ProfileTile(
                isTitleOnly: false,isList: false,
                title: AppStrings.netSalaryPayable.tr().toUpperCase(),
                trailingTitle: "${employee?.netSalary.toString()} ${AppStrings.egp.tr()}".toUpperCase(),
                icon: Image.asset("assets/images/new-cale.png", width: 20.w, height: 20.h, color:  Color(AppColors.buttons)),
              ),
          ],
          gapH24,
          Center(
              child: CustomElevatedButton(
                  backgroundColor: Color(AppColors.secondaryButton),
                  titleSize: AppSizes.s12.sp,
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
