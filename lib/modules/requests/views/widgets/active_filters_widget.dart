import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/controller/filter_controller/filter_controller.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/date.service.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/general_services/settings.service.dart';
import 'package:rmemp/modules/requests/view_models/requests.viewmodel.dart';
import 'package:rmemp/routing/app_router.dart';
import 'package:rmemp/services/requests.services.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s8),
      color: Colors.grey.shade50,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(AppColors.primary).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(AppColors.dark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(AppColors.dark),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
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

