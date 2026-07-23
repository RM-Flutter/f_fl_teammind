import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
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
        return status.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim().replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase());
    }
  }

  Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    if (status.toLowerCase().contains('approved')) return Colors.green;
    if (status.toLowerCase().contains('rejected') || status.toLowerCase().contains('refused')) return Colors.red;
    return Colors.orange;
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('no_data_found'.tr()),
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
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: ShapeDecoration(
                  color:  Color(AppColors.cardBackground),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                       AppRoutes.overtimeRequestDetailsScreen.name,
                       pathParameters: {'lang': context.locale.languageCode},
                       extra: request,
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              request.date ?? "", 
                              style: AppStyles.titleTextContent(context).copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes.s16,
                                letterSpacing: 0.5,
                              )
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${AppStrings.duration.tr()}: ${formatDuration(request.overtime)}", 
                              style: AppStyles.titleTextContent(context).copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: AppSizes.s12,
                                color: Colors.grey,
                              )
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.s8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RequestsServices.getRequestsStatusIcon(
                            context: context, 
                            status: request.status?.toLowerCase().contains('approved') == true ? 'approved' : 
                                    request.status?.toLowerCase().contains('rejected') == true ? 'refused' : 'waiting',
                            iconColor: getStatusColor(request.status)
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatStatus(request.status),
                            textAlign: TextAlign.end,
                            style: AppStyles.titleTextContent(context).copyWith(
                              color: getStatusColor(request.status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
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
                  final provider = Provider.of<app_test_overtime_provider.OvertimeRequestsProvider>(context, listen: false);
                  final myIdStr = CacheHelper.getString("US1");
                  final myId = myIdStr != null && myIdStr.isNotEmpty ? json.decode(myIdStr)['employee_profile_id'].toString() : '';
                  final isIncoming = (id?.toString() != myId);
                  provider.isForDepartment = isIncoming;
                  if (isIncoming) {
                    provider.incomingFilters['empId'] = id?.toString();
                    provider.incomingFilters['empName'] = empName?.toString();
                  }
                  await context.pushNamed(
                    AppRoutes.overtimeRequestsScreen.name,
                    pathParameters: {
                      'lang': context.locale.languageCode,
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
