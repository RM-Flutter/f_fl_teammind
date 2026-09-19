import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:flutter/material.dart';

class FilesCenterRepo {
  static Future<OperationResult<Map<String, dynamic>>> getFiles({
    required BuildContext context,
  }) async {
    final url = '${AppConstants.baseUrl}/emp_requests/v1/files-center/files';
    return await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      allData: true,
      dataKey: '',

    );
  }

  static Future<OperationResult<Map<String, dynamic>>> getTypes({
    required BuildContext context,
  }) async {
    final url = '${AppConstants.baseUrl}/emp_requests/v1/files-center/types';
    return await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      allData: true,
      dataKey: '',
    );
  }
}
