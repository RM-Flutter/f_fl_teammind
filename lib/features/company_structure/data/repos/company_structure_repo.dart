import 'package:app_test/core/models/endpoint.model.dart';
import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:app_test/core/services/backend_services/get_endpoint_service.dart';
import 'package:flutter/material.dart';

abstract class CompanyStructureRepo {
  static Future<OperationResult<Map<String, dynamic>>> getCompanyTreeStructure({
    required BuildContext context,
  }) async {
    final url =
        EndpointServices.getApiEndpoint(EndpointsNames.companyStructure).url;
    final response = await DioApiService().get<Map<String, dynamic>>(url,
        context: context,
        allData: true,
        dataKey: 'data',
        checkOnTokenExpiration: false);
    return response;
  }
}
