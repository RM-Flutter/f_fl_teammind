import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/models/endpoint_model.dart';
import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:app_test/core/services/backend_services/get_endpoint_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';

abstract class FingerprintRepo {
  static Future<OperationResult<Map<String, dynamic>>> getFingerprints({
    required BuildContext context,
    String? pfor,
    int? page,
    String? orderBy,
    String order = 'asc',
    String? status,
  }) async {
    final baseUrl = EndpointServices.getApiEndpoint(EndpointsNames.getFingerprints).url;

    final Map<String, String> params = {
      if (pfor != null && pfor.isNotEmpty && pfor != "0") 'pfor': pfor,
      if (page != null) 'page': page.toString(),
      if (orderBy != null) 'orderBy': orderBy,
      'order': order,
      if (status != null) 'status': status,
    };

    final queryParams = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final url = queryParams.isEmpty ? baseUrl : '$baseUrl?$queryParams';

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      dataKey: 'data',
      context: context,
      allData: true,
    );
  }

  static Future<OperationResult<Map<String, dynamic>>> addFingerprints({
    required BuildContext context,
    required FormData formData,
  }) async {
    final url = '${AppConstants.baseUrl}/rm_fingerprint/v1/add_fingerprints';

    // Using DioHelper for direct FormData support while keeping OperationResult return type
    final response = await DioHelper.postFormData(
      url: url,
      context: context,
      formdata: formData,
      query: null,
      data: null,
    );

    if (response.statusCode == 200) {
      return OperationResult<Map<String, dynamic>>(
        success: response.data['status'] == true,
        message: response.data['message'] ?? '',
        data: response.data is Map<String, dynamic> ? response.data : null,
      );
    } else {
      return OperationResult<Map<String, dynamic>>(
        success: false,
        message: 'Server Error: ${response.statusCode}',
      );
    }
  }
}
