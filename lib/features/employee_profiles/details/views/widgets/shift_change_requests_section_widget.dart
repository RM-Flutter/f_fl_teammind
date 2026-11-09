import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'dart:convert';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/widgets/approvable_card_widget.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:app_test/features/shifts/models/shift_change_request_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShiftChangeRequestsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  final List<ShiftChangeRequestModel>? requests;
  final String? id;
  final String? empName;

  const ShiftChangeRequestsSectionWidget({
    super.key,
    required this.employee,
    this.requests,
    this.id,
    this.empName,
  });

  @override
  Widget build(BuildContext context) {
    if (requests == null || requests!.isEmpty) {
      return NoExistingPlaceholderScreen(
        compact: true,
        title: AppStrings.noDataFounded.tr(),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            reverse: false,
            shrinkWrap: true,
            clipBehavior: Clip.none,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final request = requests![index];
              return ApprovableCardWidget(
                request: request,
                isForDepartment: false,
                onTap: () {
                  context.pushNamed(
                    AppRoutes.approvableDetails.name,
                    pathParameters: {
                      'type': 'shift_change_requests',
                      'id': request.id.toString(),
                      'lang': context.locale.languageCode,
                    },
                  );
                },
              );
            },
            separatorBuilder: (context, index) => const SizedBox.shrink(),
            itemCount: requests!.length <= 5 ? requests!.length : 5,
          ),
          const SizedBox(height: 24),
          Center(
            child: CustomElevatedButton(
              backgroundColor: Color(AppColors.secondaryButton),
              titleSize: AppSizes.s12,
              title: 'viewAll'.tr(),
              onPressed: () async {
                final myIdStr = CacheHelper.getString("US1");
                final myId = myIdStr != null && myIdStr.isNotEmpty
                    ? json.decode(myIdStr)['employee_profile_id'].toString()
                    : '';
                final isIncoming = (id?.toString() != myId);

                await context.pushNamed(
                  AppRoutes.shiftChangeRequests.name,
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
