import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:app_test/features/salary_advance_requests/shared/models/salary_advance_request_model.dart';
import 'package:app_test/features/salary_advance_requests/views/widgets/salary_advance_list_item_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:provider/provider.dart';
import 'package:app_test/features/salary_advance_requests/controllers/salary_advance_list_controller.dart' as app_test_salary_provider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/utils/app_styles.dart';

class SalaryAdvanceSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  final List<SalaryAdvanceRequestModel>? requests;
  final String? id;
  final String? empName;
  
  const SalaryAdvanceSectionWidget({super.key, required this.employee, this.requests, this.id, this.empName});

  @override
  Widget build(BuildContext context) {
    if (requests == null || requests!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(AppStrings.noDataFounded.tr()),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH12,
          ListView.separated(
            reverse: false,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final request = requests![index];
              return SalaryAdvanceListItemWidget(
                request: request,
                isIncoming: false, // We just display it without edit capabilities
                canEdit: false,
                onRefresh: () {},
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: requests!.length <= 5 ? requests!.length : 5,
          ),
          if (requests!.isNotEmpty) const SizedBox(height: 24),
          if (requests!.isNotEmpty)
            Center(
              child: CustomElevatedButton(
                backgroundColor:  Color(AppColors.secondaryButton),
                titleSize: AppSizes.s12,
                title: 'viewAll'.tr().toUpperCase(),
                onPressed: () async {
                  final myIdStr = CacheHelper.getString("US1");
                  final myId = myIdStr != null && myIdStr.isNotEmpty ? json.decode(myIdStr)['employee_profile_id'].toString() : '';
                  final isIncoming = (id?.toString() != myId);
                  await context.pushNamed(
                    AppRoutes.salaryAdvanceList.name,
                    pathParameters: {
                      'lang': context.locale.languageCode,
                    },
                    extra: {
                      "isIncoming": isIncoming,
                      "empId": id?.toString(),
                      "empName": empName?.toString(),
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
