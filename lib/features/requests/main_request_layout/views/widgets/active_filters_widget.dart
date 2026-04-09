import 'dart:async';
import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/services/settings_service.dart';
import 'package:app_test/features/requests/main_request_layout/controller/filter_controller.dart';
import 'package:app_test/features/requests/main_request_layout/controller/requests_controller.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveFiltersWidget extends StatelessWidget {
  final GetRequestsTypes? requestsType;
  final RequestsViewModel viewModel;

  const ActiveFiltersWidget({
    super.key,
    required this.requestsType,
    required this.viewModel,
  });

  static bool hasActiveFilters() {
    final reqId = CacheHelper.getString("reqId");
    final status = CacheHelper.getString("selectStatus");
    final depId = CacheHelper.getString("depId");
    final empId = CacheHelper.getString("empId");
    final from = CacheHelper.getString("from");
    final to = CacheHelper.getString("to");

    return (reqId != null && reqId.isNotEmpty) ||
        (status != null && status.isNotEmpty) ||
        (depId != null && depId.isNotEmpty) ||
        (empId != null && empId.isNotEmpty) ||
        (from != null && from.isNotEmpty) ||
        (to != null && to.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to FilterController changes to rebuild when departments/employees are loaded
    Provider.of<FilterController>(context, listen: true);

    final activeFilters = _getActiveFilters(context);

    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      color: Colors.grey.shade50,
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: activeFilters.map((filter) {
          return _FilterChip(
            label: filter['label'] as String,
            onRemove: () => _removeFilter(context, filter['key'] as String),
          );
        }).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _getActiveFilters(BuildContext context) {
    final filters = <Map<String, dynamic>>[];

    // Request Type Filter
    final reqId = CacheHelper.getString("reqId");
    if (reqId != null && reqId.isNotEmpty) {
      final requestTitle = AppSettingsService.getRequestTitleFromGenenralSettings(
        requestId: reqId,
        context: context,
      );
      if (requestTitle != null) {
        filters.add({
          'key': 'reqId',
          'label': '${AppStrings.requestType.tr()}: $requestTitle',
        });
      }
    }

    // Status Filter
    final status = CacheHelper.getString("selectStatus");
    if (status != null && status.isNotEmpty) {
      filters.add({
        'key': 'selectStatus',
        'label': '${AppStrings.status.tr()}: ${status.toString().tr()}',
      });
    }

    // Department Filter
    final depId = CacheHelper.getString("depId");
    if (depId != null && depId.isNotEmpty) {
      // Try to get department name from FilterController
      final departmentName = _getDepartmentName(context, depId);
      filters.add({
        'key': 'depId',
        'label': '${AppStrings.department.tr()}: $departmentName',
      });
    }

    // Employee Filter
    final empId = CacheHelper.getString("empId");
    if (empId != null && empId.isNotEmpty) {
      final employeeName = _getEmployeeName(context, empId);
      filters.add({
        'key': 'empId',
        'label': '${AppStrings.employeeName.tr()}: $employeeName',
      });
    }

    // Date Range Filter
    final from = CacheHelper.getString("from");
    final to = CacheHelper.getString("to");
    if (from != null && from.isNotEmpty && to != null && to.isNotEmpty) {
      final formattedDate = _formatDateRange(context, from, to);
      filters.add({
        'key': 'dateRange',
        'label': '${AppStrings.requestTime.tr()}: $formattedDate',
      });
    } else if (from != null && from.isNotEmpty) {
      final formattedDate = _formatDate(context, from);
      filters.add({
        'key': 'from',
        'label': '${AppStrings.from.tr()}: $formattedDate',
      });
    } else if (to != null && to.isNotEmpty) {
      final formattedDate = _formatDate(context, to);
      filters.add({
        'key': 'to',
        'label': '${AppStrings.to.tr()}: $formattedDate',
      });
    }

    return filters;
  }

  String _getDepartmentName(BuildContext context, String depId) {
    try {
      // Try to get from FilterController if available
      final filterController = Provider.of<FilterController>(context, listen: false);
      final department = filterController.departments.firstWhere(
            (dept) => dept['id'].toString() == depId,
        orElse: () => <String, dynamic>{},
      );
      if (department.isNotEmpty && department['title'] != null) {
        return department['title'].toString();
      }
    } catch (e) {
      // If not found, return ID
    }
    return depId;
  }

  String _getEmployeeName(BuildContext context, String empId) {
    try {
      // Try to get from FilterController if available
      final filterController = Provider.of<FilterController>(context, listen: false);
      final employee = filterController.employees.firstWhere(
            (emp) => emp['id'].toString() == empId,
        orElse: () => <String, dynamic>{},
      );
      if (employee.isNotEmpty && employee['name'] != null) {
        return employee['name'].toString();
      }
    } catch (e) {
      // If not found, return ID
    }
    return empId;
  }

  String _formatDateRange(BuildContext context, String from, String to) {
    try {
      final fromDate = DateTime.parse(from);
      final toDate = DateTime.parse(to);
      final isArabic = LocalizationService.isArabic(context: context);
      final dateFormat = DateFormat(isArabic ? 'yyyy-MM-dd' : 'yyyy-MM-dd');
      return '${dateFormat.format(fromDate)} - ${dateFormat.format(toDate)}';
    } catch (e) {
      return '$from - $to';
    }
  }

  String _formatDate(BuildContext context, String date) {
    try {
      final dateTime = DateTime.parse(date);
      final isArabic = LocalizationService.isArabic(context: context);
      final dateFormat = DateFormat(isArabic ? 'yyyy-MM-dd' : 'yyyy-MM-dd');
      return dateFormat.format(dateTime);
    } catch (e) {
      return date;
    }
  }

  void _removeFilter(BuildContext context, String filterKey) {
    if (filterKey == 'dateRange') {
      CacheHelper.deleteData(key: "from");
      CacheHelper.deleteData(key: "to");
    } else {
      CacheHelper.deleteData(key: filterKey);
    }

    // Refresh the requests with updated filters - full refresh
    viewModel.currentPage = 1;
    viewModel.hasMore = true;
    // Clear existing data for full refresh
    if (requestsType == GetRequestsTypes.mine) {
      viewModel.requests?.clear();
    } else if (requestsType == GetRequestsTypes.myTeam) {
      viewModel.myTeamRequests?.clear();
    } else if (requestsType == GetRequestsTypes.otherDepartment) {
      viewModel.otherDepartmentRequestModel?.clear();
    }

    // Use rootNavigatorKey to get a stable context that won't be deactivated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        try {
          // Use rootNavigatorKey.currentContext instead of widget context
          final navigatorContext = rootNavigatorKey.currentContext;
          if (navigatorContext != null && navigatorContext.mounted) {
            viewModel.initializeRequestsScreen(
              context: navigatorContext,
              requestsType: requestsType ?? GetRequestsTypes.mine,
              requestTypeId: CacheHelper.getString("reqId"),
              empIds: CacheHelper.getString("empId"),
              from: CacheHelper.getString("from"),
              to: CacheHelper.getString("to"),
              depId: CacheHelper.getString("depId"),
              status: CacheHelper.getString("selectStatus"),
              loadMore: false, // Full refresh, not load more
            );
          }
        } catch (e) {
          debugPrint('Error refreshing requests after filter removal: $e');
        }
      });
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppStyles.darkContent(context).copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  color: Color(AppColors.dark),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 14.r,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
