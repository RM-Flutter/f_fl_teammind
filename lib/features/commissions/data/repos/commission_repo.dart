import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:flutter/material.dart';

class CommissionRepo {
  static const String _baseEndpoint = '/v1/commissions/my-commissions';

  /// Fetch paginated list of commissions.
  ///
  /// [status]    — filter: 'pending', 'applied', 'paid_separately', or null for all.
  /// [fromDate]  — filter from date (YYYY-MM-DD).
  /// [toDate]    — filter to date (YYYY-MM-DD).
  /// [perPage]   — items per page (default 15).
  /// [page]      — page number (default 1).
  static Future<OperationResult<Map<String, dynamic>>> getMyCommissions({
    required BuildContext context,
    String? status,
    String? fromDate,
    String? toDate,
    int perPage = 15,
    int page = 1,
  }) async {
    final url = '${AppConstants.baseUrl}$_baseEndpoint';

    final Map<String, dynamic> queryParams = {
      'per_page': perPage,
      'page': page,
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (fromDate != null && fromDate.isNotEmpty) {
      queryParams['from_date'] = fromDate;
    }
    if (toDate != null && toDate.isNotEmpty) {
      queryParams['to_date'] = toDate;
    }

    return await DioApiService().get<Map<String, dynamic>>(
      url,
      dataKey: '',
      queryParameters: queryParams,
      context: context,
      allData: true,
    );
  }
}
