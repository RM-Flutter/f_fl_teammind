import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:dio/dio.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

import '../../../core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';

class CvHubRepo {
  static Future<OperationResult<Map<String, dynamic>>> getMyInterviews({
    required BuildContext context,
  }) async {
    return await DioApiService().get<Map<String, dynamic>>(
      '${AppConstants.baseUrl}/v1/cv-hub/my-interviews',
      context: context,
      dataKey: 'data',
      allData: true,
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> getInterviewDetails({
    required BuildContext context,
    required String interviewId,
  }) async {
    return await DioApiService().get<Map<String, dynamic>>(
      '${AppConstants.baseUrl}/v1/cv-hub/my-interviews/$interviewId',
      context: context,
      dataKey: 'data',
      allData: true,
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> submitEvaluation({
    required BuildContext context,
    required String interviewId,
    required Map<String, dynamic> data,
  }) async {
    return await DioApiService().post<Map<String, dynamic>>(
      '${AppConstants.baseUrl}/v1/cv-hub/interviews/$interviewId/evaluations',
      data,
      context: context,
      dataKey: 'data',
      allData: true,
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> updateEvaluation({
    required BuildContext context,
    required String evaluationId,
    required Map<String, dynamic> data,
  }) async {
    return await DioApiService().put<Map<String, dynamic>>(
      '${AppConstants.baseUrl}/v1/cv-hub/evaluations/$evaluationId',
      data,
      context: context,
      dataKey: 'data',
      allData: true,
    );
  }
}
