import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';

class NotificationsRepo {
  static Future<Response> getEmployees({
    required BuildContext context,
    bool underMyManagement = true,
  }) {
    return DioHelper.getData(
      url: "/emp_requests/v1/employees",
      context: context,
      query: {
        "under_my_management": underMyManagement,
      },
    );
  }

  static Future<Response> getDepartments({
    required BuildContext context,
    bool underMyManagement = true,
  }) {
    return DioHelper.getData(
      url: "/departments/entities-operations",
      context: context,
      query: {
        "under_my_management": underMyManagement,
      },
    );
  }

  static Future<Response> getNotifications({
    required BuildContext context,
    required int itemsCount,
    required int page,
    String? forWho,
  }) {
    return DioHelper.getData(
      url: "/emp_requests/v1/notifications/list",
      context: context,
      query: {
        "itemsCount": itemsCount,
        "page": page,
        "for": forWho,
      },
    );
  }

  static Future<Response> getNotificationSingle({
    required BuildContext context,
    required String id,
  }) {
    return DioHelper.getData(
      url: "/rmnotifications/entities-operations/$id",
      context: context,
    );
  }

  static Future<Response> addNotification({
    required BuildContext context,
    required FormData formData,
  }) {
    return DioHelper.postFormData(
      url: "/emp_requests/v1/notifications/create",
      context: context,
      formdata: formData,
    );
  }

  /// GET /rmnotifications/entities-operations/{id}/emotions/count
  /// Returns allowed status, total_count, user_reaction, and summary.
  static Future<Response> getEmotionCount({
    required BuildContext context,
    required dynamic notificationId,
  }) {
    return DioHelper.getData(
      url: "/rmnotifications/entities-operations/$notificationId/emotions/count",
      context: context,
      query: null,
    );
  }

  /// POST /rmnotifications/entities-operations/{id}/emotions
  /// [action] must be "add" or "remove".
  /// [emotion] is required when action == "add".
  static Future<Response> reactToNotification({
    required BuildContext context,
    required dynamic notificationId,
    required String action,
    String? emotion,
  }) {
    final Map<String, dynamic> body = {'action': action};
    if (emotion != null) body['emotion'] = emotion;

    return DioHelper.postData(
      url: "/rmnotifications/entities-operations/$notificationId/emotions",
      context: context,
      query: null,
      data: body,
    );
  }
}

