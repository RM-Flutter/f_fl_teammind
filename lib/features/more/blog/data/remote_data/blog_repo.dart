import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';

class BlogRepo {
  static Future<Response> getOneBlog({
    required BuildContext context,
    required String id,
    required String type,
    int itemsCount = 9,
    int page = 1,
  }) {
    return DioHelper.getData(
      url: "/$type/entities-operations/$id?with=tags,category_id",
      context: context,
      query: {
        "itemsCount": itemsCount,
        "page": page,
      },
    );
  }

  static Future<Response> getBlog({
    required BuildContext context,
    required String slug,
    int itemsCount = 9,
    int page = 1,
  }) {
    return DioHelper.getData(
      url: "/$slug/entities-operations?with=tags,category_id",
      context: context,
      query: {
        "itemsCount": itemsCount,
        "page": page,
      },
    );
  }
}
