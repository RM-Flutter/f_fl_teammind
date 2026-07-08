import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app_test/core/constants/app_constants.dart';

class DailyReportsService {
  static String get baseUrl => '${AppConstants.baseUrl}/emp_reports/v1/daily_reports';

  static Future<OperationResult<Map<String, dynamic>>> getReports({
    required BuildContext context,
    int itemsCount = 10,
    int page = 1,
    bool isIncoming = false,
  }) async {
    final type = isIncoming ? 'incoming' : 'personal';
    final url = '$baseUrl/$type?itemsCount=$itemsCount&page=$page';

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      dataKey: '',
      allData: true,
      checkOnTokenExpiration: true,
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> getReportDetails({
    required BuildContext context,
    required String reportId,
  }) async {
    final url = '$baseUrl/$reportId';

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      dataKey: '',
      allData: true,
      checkOnTokenExpiration: true,
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> createReport({
    required BuildContext context,
    required String done,
    required String inProgress,
    required String problems,
    required List<FilePickerResult> files,
  }) async {
    final Map<String, String> requestData = {
      'done': done,
      'inProgress': inProgress,
      'problems': problems,
    };

    return await DioApiService().postWithFormData<Map<String, dynamic>>(
      baseUrl,
      requestData,
      files: files,
      fileFieldName: 'attachments',
      dataKey: '',
      context: context,
      allData: true,
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> updateReport({
    required BuildContext context,
    required String reportId,
    required String done,
    required String inProgress,
    required String problems,
    required List<FilePickerResult> files,
  }) async {
    final url = '$baseUrl/$reportId';
    final Map<String, String> requestData = {
      '_method': 'PUT',
      'done': done,
      'inProgress': inProgress,
      'problems': problems,
    };

    return await DioApiService().postWithFormData<Map<String, dynamic>>(
      url,
      requestData,
      files: files,
      fileFieldName: 'attachments',
      dataKey: '',
      context: context,
      allData: true,
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> deleteReport({
    required BuildContext context,
    required String reportId,
  }) async {
    final url = '$baseUrl/$reportId';

    return await DioApiService().delete<Map<String, dynamic>>(
      url,
      {},
      context: context,
      dataKey: '',
      allData: true,
    );
  }
}
