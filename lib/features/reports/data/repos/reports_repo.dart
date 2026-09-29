import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:flutter/material.dart';

class ReportsRepo {
  static Future<OperationResult<Map<String, dynamic>>> getCatalog({
    required BuildContext context,
  }) async {
    final url = '${AppConstants.baseUrl}/emp_reports/v1/mobile/reports/catalog';
    return await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      allData: true,
      dataKey: '',
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> getFilterOptions({
    required BuildContext context,
    required String reportKey,
  }) async {
    final url = '${AppConstants.baseUrl}/emp_reports/v1/mobile/reports/filter-options';
    return await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      allData: true,
      dataKey: '',
      queryParameters: {'report_key': reportKey},
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> getReportData({
    required BuildContext context,
    required Map<String, dynamic> filters,
  }) async {
    final url = '${AppConstants.baseUrl}/emp_reports/v1/mobile/reports/data';
    return await DioApiService().post<Map<String, dynamic>>(
      url,
      filters,
      context: context,
      allData: true,
      dataKey: '',
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> getWebviewUrl({
    required BuildContext context,
    required String reportKey,
    required Map<String, dynamic> filters,
  }) async {
    final url = '${AppConstants.baseUrl}/emp_reports/v1/mobile/reports/webview-url';
    return await DioApiService().post<Map<String, dynamic>>(
      url,
      {
        'report_key': reportKey,
        ...filters,
      },
      context: context,
      allData: true,
      dataKey: '',
    );
  }
}
