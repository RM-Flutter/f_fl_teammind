import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';

/// Backend: rm/ai package, MCP server (`/api/rm_mcp/v1/*`).
class AiConnectRepo {
  /// `{status, data: {enabled, reason, mcp_url, steps[]}}`
  static Future<Response> getConnectInfo({required BuildContext context}) {
    return DioHelper.getData(url: "/rm_mcp/v1/connect-info", query: null, context: context);
  }

  /// `{status, data: [{id, client_name, access, connected_at, last_used_at}]}`
  static Future<Response> getConnections({required BuildContext context}) {
    return DioHelper.getData(url: "/rm_mcp/v1/connections", query: null, context: context);
  }

  /// `{status, message}`
  static Future<Response> disconnect({required BuildContext context, required int id}) {
    return DioHelper.deleteData(url: "/rm_mcp/v1/connections/$id", query: null, context: context);
  }
}
