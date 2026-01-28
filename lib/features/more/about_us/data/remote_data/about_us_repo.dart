import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:dio/dio.dart';

class AboutUsRepo {
  static Future<Response> getAboutUs(BuildContext context) {
    return DioHelper.getData(
      url: "/rm_page/v1/show?with=metas&slug=about-us-app",
      sendLang: true,
      context: context,
    );
  }
}
