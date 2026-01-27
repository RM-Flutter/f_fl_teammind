import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Remote data source for complaints feature
/// Handles all API calls related to complaints/requests
abstract class ComplaintsRepo {
  /// Get request types
  static Future<Response> getRequestTypes(BuildContext context) async {
    return await DioHelper.getData(
      url: "/csrequests-type/entities-operations",
      context: context,
    );
  }

  /// Get requests with pagination
  static Future<Response> getRequests(
    BuildContext context, {
    required int itemsCount,
    required int page,
  }) async {
    return await DioHelper.getData(
      url: "/csrequests/entities-operations",
      context: context,
      query: {
        "itemsCount": itemsCount,
        "page": page,
      },
    );
  }

  /// Get single request by ID
  static Future<Response> getOneRequest(
    BuildContext context,
    dynamic id,
  ) async {
    return await DioHelper.getData(
      url: "/csrequests/$id/entities-operations",
      context: context,
    );
  }

  /// Add new request
  static Future<Response> addRequest(
    BuildContext context, {
    required String? title,
    required String? content,
    required String typeId,
    List<XFile>? images,
  }) async {
    // If images are provided, use FormData
    if (images != null && images.isNotEmpty) {
      FormData formData = FormData.fromMap({
        if (title != null && title.isNotEmpty) "title": title,
        if (content != null && content.isNotEmpty) "content": content,
        "type_id": typeId,
        "main_thumbnail[]": !kIsWeb
            ? await Future.wait(
                images.map((file) async =>
                    await MultipartFile.fromFile(file.path, filename: file.name))
              )
            : await Future.wait(
                images.map((file) async {
                  final bytes = await file.readAsBytes();
                  return MultipartFile.fromBytes(
                    bytes,
                    filename: file.name,
                  );
                }),
              ),
      });

      return await DioHelper.postData(
        url: "/rm_postcontrol/v1/add_request",
        context: context,
        data: formData,
      );
    } else {
      // No images, use regular JSON data
      return await DioHelper.postData(
        url: "/rm_postcontrol/v1/add_request",
        context: context,
        data: {
          if (title != null && title.isNotEmpty) "title": title,
          if (content != null && content.isNotEmpty) "content": content,
          "type_id": typeId,
        },
      );
    }
  }
}
