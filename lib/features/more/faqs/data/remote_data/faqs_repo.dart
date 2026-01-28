import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';

class FaqsRepo {
  static Future<Response> getFaq(BuildContext context) {
    return DioHelper.getData(
      url: "/rm_page/v1/show?slug=faq",
      context: context,
    );
  }
}
