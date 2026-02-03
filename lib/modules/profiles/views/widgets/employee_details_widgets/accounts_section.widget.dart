import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import '../../../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../../../constants/app_sizes.dart';
import '../../../../../routing/app_router.dart';
import '../../../models/employee_profile.model.dart';
import '../profile_tile.widget.dart';

class AccountsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  List? salaryAdvance = [];
  AccountsSectionWidget({super.key, required this.employee, required this.salaryAdvance});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.5,
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
                  trailingTitle: "${employee?.basicSalary.toString()} ${AppStrings.egp.tr()}",
                  icon: const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
                ),
              //WORK HOURS TYPE
              if (employee?.additions != null)
                ProfileTile(
                  isTitleOnly: false,isList: false,
                  title: AppStrings.additions.tr().toUpperCase(),
                  trailingTitle: "${employee?.additions.toString()} ${AppStrings.egp.tr()}",
                  icon: const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
                ),
              // WORK HOURS
              if (employee?.totalDeductions != null)
                ProfileTile(
                  isTitleOnly: false,isList: false,
                  title: AppStrings.totalDeductions.tr().toUpperCase(),
                  trailingTitle: "${employee?.totalDeductions.toString()} ${AppStrings.egp.tr()}",
                  icon: const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
                ),
              //WEEKENDS
              if (employee?.netSalary != null)
                ProfileTile(
                  isTitleOnly: false,isList: false,
                  title: AppStrings.netSalaryPayable.tr().toUpperCase(),
                  trailingTitle: "${employee?.netSalary.toString()} ${AppStrings.egp.tr()}" ?? '',
                  icon: const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
                ),
              // const SizedBox(height: AppSizes.s12,),
              // ListView.separated(
              //     shrinkWrap: true,
              //     reverse: false,
              //     physics: const ClampingScrollPhysics(),
              //     padding: EdgeInsetsGeometry.zero,
              //     itemBuilder: (context, index) => ProfileTile(
              //       isTitleOnly: false,isList: false,
              //       title: "${salaryAdvance![index]['reason'] ?? ""} - ${salaryAdvance![index]['collect_date'] ?? ""}",
              //       trailingTitle: salaryAdvance![index]['amount'].toString() ?? "0",
              //       icon: const Icon(Icons.check_circle_outline, color: Color(AppColors.black),),
              //     ),
              //     separatorBuilder: (context, index) => const SizedBox(height: AppSizes.s12,),
              //     itemCount: salaryAdvance!.length
              // )
            ],
            gapH24,
            Center(
                child: CustomElevatedButton(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
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
      ),
    );
  }
}
