import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/app_error_reporter.dart';
import 'package:app_test/features/more/ai_connect/data/ai_connect_repo.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// One connection made from Claude / ChatGPT to this user's account.
class AiConnection {
  final int id;
  final String clientName;
  final bool canAct;
  final String? connectedAt;
  final String? lastUsedAt;

  AiConnection({
    required this.id,
    required this.clientName,
    required this.canAct,
    this.connectedAt,
    this.lastUsedAt,
  });

  factory AiConnection.fromJson(Map<String, dynamic> json) => AiConnection(
        id: int.tryParse(json['id'].toString()) ?? 0,
        clientName: (json['client_name'] ?? '').toString().trim().isEmpty
            ? 'AI assistant'
            : json['client_name'].toString(),
        canAct: json['access'] == 'write',
        connectedAt: json['connected_at']?.toString(),
        lastUsedAt: json['last_used_at']?.toString(),
      );
}

/// "Connect ChatGPT / Claude" and "Connected apps" screens.
class AiConnectController extends ChangeNotifier {
  bool isInfoLoading = false;
  bool isConnectionsLoading = false;
  int? disconnectingId;
  String? errorMessage;

  bool enabled = false;
  String? disabledReason;
  String? mcpUrl;
  List<AiConnection> connections = [];

  Future<void> loadInfo(BuildContext context) async {
    isInfoLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await AiConnectRepo.getConnectInfo(context: context);
      final body = response.data;
      if (body is Map && body['status'] == true && body['data'] is Map) {
        final data = body['data'] as Map;
        enabled = data['enabled'] == true;
        disabledReason = data['reason']?.toString();
        mcpUrl = data['mcp_url']?.toString();
      } else {
        // The package is off for this company, so the route does not exist.
        enabled = false;
        mcpUrl = null;
        disabledReason = AppStrings.aiConnectNotEnabled.tr();
      }
    } catch (error) {
      enabled = false;
      errorMessage = _message(error);
    }
    isInfoLoading = false;
    notifyListeners();
  }

  Future<void> loadConnections(BuildContext context) async {
    isConnectionsLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await AiConnectRepo.getConnections(context: context);
      final body = response.data;
      if (body is Map && body['status'] == true && body['data'] is List) {
        connections = (body['data'] as List)
            .whereType<Map>()
            .map((e) => AiConnection.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        connections = [];
        errorMessage = body is Map ? body['message']?.toString() : null;
      }
    } catch (error) {
      errorMessage = _message(error);
    }
    isConnectionsLoading = false;
    notifyListeners();
  }

  Future<void> disconnect(BuildContext context, AiConnection connection) async {
    disconnectingId = connection.id;
    notifyListeners();
    try {
      final response = await AiConnectRepo.disconnect(context: context, id: connection.id);
      final body = response.data;
      if (body is Map && body['status'] == true) {
        connections.removeWhere((c) => c.id == connection.id);
        if (context.mounted) {
          AlertsService.success(
            context: context,
            title: AppStrings.success.tr(),
            message: AppStrings.aiDisconnected.tr(),
          );
        }
      } else if (context.mounted) {
        AlertsService.error(
          context: context,
          title: AppStrings.failed.tr(),
          message: (body is Map ? body['message']?.toString() : null) ?? AppStrings.failed.tr(),
        );
      }
    } catch (error) {
      if (context.mounted) {
        AlertsService.error(context: context, title: AppStrings.failed.tr(), message: _message(error));
      }
    }
    disconnectingId = null;
    notifyListeners();
  }

  String _message(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
      return 'something_went_wrong'.tr();
    }
    return AppErrorReporter.safeMessage(error);
  }
}
