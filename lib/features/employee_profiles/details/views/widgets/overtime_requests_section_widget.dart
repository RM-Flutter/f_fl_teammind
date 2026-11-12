import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/widgets/approvable_card_widget.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:app_test/features/overtime_requests/models/overtime_request_model.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:provider/provider.dart';
import 'package:app_test/features/overtime_requests/controllers/overtime_requests_controller.dart' as app_test_overtime_provider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/utils/app_styles.dart';

class OvertimeRequestsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  final List<OvertimeRequestModel>? requests;
  final String? id;
  final String? empName;
  
  const OvertimeRequestsSectionWidget({super.key, required this.employee, this.requests, this.id, this.empName});

  String formatStatus(String? status) {
    if (status == null) return '';
    switch (status) {
      case 'hrApproved': return AppStrings.hrApprovedStatus.tr();
      case 'managerApproved': return AppStrings.managerApprovedStatus.tr();
      case 'pending': return AppStrings.pendingStatus.tr();
      case 'waiting': return AppStrings.pendingStatus.tr();
      case 'rejected': return AppStrings.rejectedStatus.tr();
      case 'refused': return AppStrings.rejectedStatus.tr();
      default:
        return status.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim().replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!);
    }
  }

  Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    if (status.toLowerCase().contains('approved')) return Colors.green;
    if (status.toLowerCase().contains('rejected') || status.toLowerCase().contains('refused')) return Colors.red;
    return Color(AppColors.warningYellow);
  }

  String formatDuration(int? totalMinutes) {
    if (totalMinutes == null) return "0 ${AppStrings.minutes.tr()}";
    int hoursCount = totalMinutes ~/ 60;
    int minutesCount = totalMinutes % 60;
    
    if (hoursCount == 0) return "$minutesCount ${AppStrings.minutes.tr()}";
    if (minutesCount == 0) return "$hoursCount ${AppStrings.hours.tr()}";
    return "$hoursCount ${AppStrings.hours.tr()} $minutesCount ${AppStrings.minutes.tr()}";
  }

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
                      'type': 'overtime',
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
          if (requests!.isNotEmpty) const SizedBox(height: AppSizes.s24),
          if (requests!.isNotEmpty)
            Center(
              child: CustomElevatedButton(
                backgroundColor:  Color(AppColors.secondaryButton),
                titleSize: AppSizes.s12,
                title: 'viewAll'.tr(),
                onPressed: () async {
                  final myIdStr = CacheHelper.getString("US1");
                  final myId = myIdStr != null && myIdStr.isNotEmpty ? json.decode(myIdStr)['employee_profile_id'].toString() : '';
                  final isIncoming = (id?.toString() != myId);
                  
                  await context.pushNamed(
                    AppRoutes.overtimeRequestsScreen.name,
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
