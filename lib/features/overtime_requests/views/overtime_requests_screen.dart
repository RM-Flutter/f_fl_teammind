import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/template_page.widget.dart';
import '../../more/notifications/views/widgets/switch_row_notification.dart';
import '../controllers/overtime_requests_controller.dart';
import '../models/overtime_request_model.dart';
import '../../../../core/services/requests_services.dart';
import '../../../../core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';

class OvertimeRequestsScreen extends StatefulWidget {
  const OvertimeRequestsScreen({super.key});

  @override
  State<OvertimeRequestsScreen> createState() => _OvertimeRequestsScreenState();
}

class _OvertimeRequestsScreenState extends State<OvertimeRequestsScreen> {
  late OvertimeRequestsProvider provider;
  Map<String, dynamic>? gCache;

  @override
  void initState() {
    super.initState();
    final jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      gCache = json.decode(jsonString);
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<OvertimeRequestsProvider>(context, listen: false);
      provider.fetchRequests(context);
    });
  }

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
    bool isManager = gCache != null && (
        (gCache!['is_manager_in'] != null && gCache!['is_manager_in'].isNotEmpty) ||
        (gCache!['is_teamleader_in'] != null && gCache!['is_teamleader_in'].isNotEmpty)
    );

    return TemplatePage(
      pageContext: context,
      title: AppStrings.overtimeRequests.tr(),
      routeName: AppRoutes.overtimeRequestsScreen.name,
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_overtime',
        backgroundColor: Color(AppColors.buttons),
        onPressed: () {
           context.pushNamed(
             AppRoutes.addOvertimeRequestScreen.name,
             pathParameters: {'lang': context.locale.languageCode},
           );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<OvertimeRequestsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.isForDepartment ? provider.teamRequests : provider.myRequests;

          return Column(
            children: [
              if (isManager) ...[
                SizedBox(height: 10.h),
                SwitchRowNotification(
                  value: provider.isForDepartment,
                  leftText: AppStrings.myRequests.tr(),
                  rightText: AppStrings.teamRequests.tr(),
                  onChanged: (val) {
                    provider.toggleDepartmentView(val);
                  },
                ),
                SizedBox(height: 10.h),
              ],
              Expanded(
                child: list.isEmpty
                    ? NoExistingPlaceholderScreen(
                        height: 300.h,
                        title: AppStrings.noDataFounded.tr(),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(top: 8.h, bottom: 80.h),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return _buildRequestCard(item, provider.isForDepartment);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(OvertimeRequestModel request, bool isForDepartment) {
    String? displayName = request.employeeName ?? request.employeeProfile?.name;

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.s16.h, left: 16.w, right: 16.w),
      padding: EdgeInsets.symmetric(
          vertical: AppSizes.s14.h, horizontal: AppSizes.s16.w),
      decoration: ShapeDecoration(
        color: Color(AppColors.cardBackground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isForDepartment && displayName != null) ...[
              Row(
                children: [
                  // CircleAvatar(
                  //   radius: 12.r,
                  //   backgroundColor: Color(AppColors.buttons).withOpacity(0.1),
                  //   child: Icon(Icons.person, size: 14.r, color: Color(AppColors.buttons)),
                  // ),
                  // SizedBox(width: 8.w),
                  Text(
                    displayName,
                    style: AppStyles.primaryContent(context).copyWith(
                      fontSize: 15.sp, 
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.secondaryButton)
                    ),
                  ),
                ],
              ),
              Divider(height: 20.h, color: Colors.grey.shade100),
            ],
            Row(
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
                          fontSize: AppSizes.s16.sp,
                          letterSpacing: 0.5,
                        )
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "${AppStrings.duration.tr()}: ${formatDuration(request.overtime)}", 
                        style: AppStyles.titleTextContent(context).copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: AppSizes.s12.sp,
                          color: Colors.grey,
                        )
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSizes.s8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RequestsServices.getRequestsStatusIcon(
                      context: context, 
                      status: request.status?.toLowerCase().contains('approved') == true ? 'approved' : 
                              request.status?.toLowerCase().contains('rejected') == true ? 'refused' : 'waiting',
                      iconColor: getStatusColor(request.status)
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      formatStatus(request.status),
                      textAlign: TextAlign.end,
                      style: AppStyles.titleTextContent(context).copyWith(
                        color: getStatusColor(request.status),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
