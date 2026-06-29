import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/models/endpoint_model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:app_test/core/services/backend_services/get_endpoint_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SalaryAdvanceRepo {
  // Create Salary Advance Request
  static Future<OperationResult<Map<String, dynamic>>> createSalaryAdvanceRequest({
    required BuildContext context,
    required String total,
    required String howLongToPay,
    required String from,
    List<FilePickerResult> files = const [],
  }) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.salaryAdvanceCreate).url;

    Map<String, String> data = {
      'total': total,
      'how_long_to_pay': howLongToPay,
      'from': from,
    };

    return await DioApiService().postWithFormData<Map<String, dynamic>>(
      url,
      data,
      dataKey: 'data',
      files: files,
      fileFieldName: 'attachments[]',
      context: context,
      allData: true,
    );
  }

  // Get Personal List
  static Future<OperationResult<Map<String, dynamic>>> getPersonalList({
    required BuildContext context,
    int itemsCount = 15,
    int page = 1,
    String from = '',
    String to = '',
  }) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.salaryAdvancePersonal).url;
    
    Map<String, dynamic> queryParams = {
      'itemsCount': itemsCount,
      'page': page,
      'from': from,
      'to': to,
    };

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      dataKey: 'data',
      queryParameters: queryParams,
      context: context,
      allData: true,
    );
  }

  // Get Incoming List (HR / Manager)
  static Future<OperationResult<Map<String, dynamic>>> getIncomingList({
    required BuildContext context,
    int itemsCount = 15,
    int page = 1,
    String employeeId = '',
    String from = '',
    String to = '',
  }) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.salaryAdvanceIncoming).url;
    
    Map<String, dynamic> queryParams = {
      'itemsCount': itemsCount,
      'page': page,
      'from': from,
      'to': to,
    };

    if (employeeId.isNotEmpty) {
      queryParams['employee_id'] = employeeId;
    }

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      dataKey: 'data',
      queryParameters: queryParams,
      context: context,
      allData: true,
    );
  }

  // Get Details
  static Future<OperationResult<Map<String, dynamic>>> getDetails({
    required BuildContext context,
    required int id,
  }) async {
    final baseUrl = EndpointServices.getApiEndpoint(EndpointsNames.salaryAdvanceDetails).url;
    final url = '$baseUrl/$id';

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      dataKey: 'data',
      context: context,
      allData: true,
    );
  }

  // Review Request
  static Future<OperationResult<Map<String, dynamic>>> reviewRequest({
    required BuildContext context,
    required int id,
    required String status,
  }) async {
    final baseUrl = EndpointServices.getApiEndpoint(EndpointsNames.salaryAdvanceReview).url;
    final url = '$baseUrl/$id/review';

    Map<String, String> data = {
      'status': status,
    };

    // Assuming Review API uses POST (from the user request format)
    return await DioApiService().postWithFormData<Map<String, dynamic>>(
      url,
      data,
      dataKey: 'data',
      files: [],
      context: context,
      allData: true,
    );
  }

  // Cancel Request
  static Future<OperationResult<Map<String, dynamic>>> cancelRequest({
    required BuildContext context,
    required int id,
  }) async {
    final baseUrl = EndpointServices.getApiEndpoint(EndpointsNames.salaryAdvanceDelete).url;
    final url = '$baseUrl/$id/cancel';

    return await DioApiService().post<Map<String, dynamic>>(
      url,
      {},
      dataKey: 'data',
      context: context,
      allData: true,
    );
  }

  // Remove Attachment
  static Future<OperationResult<Map<String, dynamic>>> removeAttachment({
    required BuildContext context,
    required int requestId,
    required int attachmentId,
  }) async {
    final baseUrl = EndpointServices.getApiEndpoint(EndpointsNames.salaryAdvanceDetails).url;
    final url = '$baseUrl/$requestId/attachments/$attachmentId';

    return await DioApiService().postWithFormData<Map<String, dynamic>>(
      url,
      {}, // Empty map for FormData
      dataKey: 'data',
      files: [],
      context: context,
      allData: true,
    );
  }

  // Update Request
  static Future<OperationResult<Map<String, dynamic>>> updateSalaryAdvanceRequest({
    required BuildContext context,
    required int id,
    required String total,
    required String howLongToPay,
    required String from,
    List<FilePickerResult> files = const [],
  }) async {
    final baseUrl = EndpointServices.getApiEndpoint(EndpointsNames.salaryAdvanceUpdate).url;
    final url = '$baseUrl/$id';

    Map<String, String> data = {
      'total': total,
      'how_long_to_pay': howLongToPay,
      'from': from,
    };

    return await DioApiService().postWithFormData<Map<String, dynamic>>(
      url,
      data,
      dataKey: 'data',
      files: files,
      fileFieldName: 'attachments[]',
      context: context,
      allData: true,
    );
  }
}
