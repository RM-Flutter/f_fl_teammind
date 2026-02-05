import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/operation_result.model.dart';
import '../../../../core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';

abstract class EvaluationRepo {
  static Future<OperationResult<Map<String, dynamic>>> getEvaluations({
    required BuildContext context,
    int? empId,
  }) async {
    final url = '${AppConstants.baseUrl}/rm_evaluation/v1/evaluation/emp_evaluations';
    return await DioApiService().get<Map<String, dynamic>>(
      url,
      queryParameters: empId != null ? {"emp_id": empId} : null,
      context: context,
      dataKey: 'evaluations', // Note: LoginRepo uses this but also allData: true. We'll follow that.
      allData: true,
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> getRequiredEvaluations({
    required BuildContext context,
  }) async {
    final url = '${AppConstants.baseUrl}/rm_evaluation/v1/evaluation/required_evaluations';
    return await DioApiService().get<Map<String, dynamic>>(
      url,
      context: context,
      dataKey: 'evaluations',
      allData: true,
    );
  }
}
