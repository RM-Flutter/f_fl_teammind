import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ExpenseClaimRepo {
  static const String _baseEndpoint = 'emp_requests/v1/expense-claims';

  // ──────────────────────────────────────────────
  // Create Expense Claim (multipart/form-data)
  // POST /api/emp_requests/v1/expense-claims
  // Required: reason, money_value
  // Optional: date_from, category, notes, files[]
  // ──────────────────────────────────────────────
  static Future<OperationResult<Map<String, dynamic>>> createExpenseClaim({
    required BuildContext context,
    required String reason,
    required String moneyValue,
    String dateFrom = '',
    String category = '',
    String notes = '',
    List<FilePickerResult> files = const [],
  }) async {
    final url = '${AppConstants.baseUrl}/$_baseEndpoint';

    final Map<String, String> data = {
      'reason': reason,
      'money_value': moneyValue,
    };
    if (dateFrom.isNotEmpty) data['date_from'] = dateFrom;
    if (category.isNotEmpty) data['category'] = category;
    if (notes.isNotEmpty) data['notes'] = notes;

    return await DioApiService().postWithFormData<Map<String, dynamic>>(
      url,
      data,
      dataKey: 'claim',
      files: files,
      fileFieldName: 'files',
      context: context,
      allData: true,
    );
  }

  // ──────────────────────────────────────────────
  // Update Expense Claim (multipart/form-data + _method=PUT)
  // POST /api/emp_requests/v1/expense-claims/{id}
  // Required: _method=PUT
  // Optional: reason, money_value, date_from, category, notes, files[]
  // ──────────────────────────────────────────────
  static Future<OperationResult<Map<String, dynamic>>> updateExpenseClaim({
    required BuildContext context,
    required int id,
    String reason = '',
    String moneyValue = '',
    String dateFrom = '',
    String category = '',
    String notes = '',
    List<FilePickerResult> files = const [],
  }) async {
    final url = '${AppConstants.baseUrl}/$_baseEndpoint/$id';

    final Map<String, String> data = {
      '_method': 'PUT',
    };
    if (reason.isNotEmpty) data['reason'] = reason;
    if (moneyValue.isNotEmpty) data['money_value'] = moneyValue;
    if (dateFrom.isNotEmpty) data['date_from'] = dateFrom;
    if (category.isNotEmpty) data['category'] = category;
    if (notes.isNotEmpty) data['notes'] = notes;

    return await DioApiService().postWithFormData<Map<String, dynamic>>(
      url,
      data,
      dataKey: 'claim',
      files: files,
      fileFieldName: 'files',
      context: context,
      allData: true,
    );
  }

  // ──────────────────────────────────────────────
  // Personal List (my expense claims)
  // GET /approval-system/v1/employee_expense_claims/employee/my-approvables
  // ──────────────────────────────────────────────
  static Future<OperationResult<Map<String, dynamic>>> getPersonalList({
    required BuildContext context,
    int page = 1,
    int perPage = 15,
    List<String>? departmentIds,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    final url =
        '${AppConstants.baseUrl}/approval-system/v1/employee_expense_claims/employee/my-approvables';

    final Map<String, dynamic> queryParams = {
      'page': page,
      'per_page': perPage,
    };
    if (departmentIds != null && departmentIds.isNotEmpty) {
      queryParams['department_ids[]'] = departmentIds;
    }
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (dateFrom != null && dateFrom.isNotEmpty) queryParams['date_from'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) queryParams['date_to'] = dateTo;

    debugPrint('🟢 ExpenseClaimRepo.getPersonalList → $url | params: $queryParams');

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      dataKey: '',
      queryParameters: queryParams,
      context: context,
      allData: true,
    );
  }

  // ──────────────────────────────────────────────
  // Incoming List (manager/HR view)
  // GET /approval-system/v1/employee_expense_claims/manager/under-my-management-approvables
  // ──────────────────────────────────────────────
  static Future<OperationResult<Map<String, dynamic>>> getIncomingList({
    required BuildContext context,
    required String scope,
    int page = 1,
    int perPage = 15,
    List<String>? employeesIds,
    List<String>? departmentIds,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    final url =
        '${AppConstants.baseUrl}/approval-system/v1/employee_expense_claims/manager/under-my-management-approvables';

    final Map<String, dynamic> queryParams = {
      'scope': scope,
      'page': page,
      'per_page': perPage,
    };
    if (employeesIds != null && employeesIds.isNotEmpty) {
      queryParams['employees_ids[]'] = employeesIds;
    }
    if (departmentIds != null && departmentIds.isNotEmpty) {
      queryParams['department_ids[]'] = departmentIds;
    }
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (dateFrom != null && dateFrom.isNotEmpty) queryParams['date_from'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) queryParams['date_to'] = dateTo;

    debugPrint('🟢 ExpenseClaimRepo.getIncomingList → $url | params: $queryParams');

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      dataKey: '',
      queryParameters: queryParams,
      context: context,
      allData: true,
    );
  }
}
