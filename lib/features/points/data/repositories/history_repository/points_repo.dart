import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';

class PointsRepo {
  static Future<Response> addFriend({
    required BuildContext context,
    required List<Map<String, dynamic>> items,
  }) {
    return DioHelper.postData(
      url: "/rm_pointsys/v1/add_new",
      context: context,
      data: {
        "items": items,
      },
    );
  }

  static Future<Response> getPrizesByCategory({
    required BuildContext context,
    required String categoryId,
    int itemsCount = 9,
    int page = 1,
  }) {
    return DioHelper.getData(
      url: "/prizes/entities-operations?category_id=$categoryId",
      context: context,
      query: {
        "itemsCount": itemsCount,
        "page": page,
      },
    );
  }

  static Future<Response> getPrizeCategories({
    required BuildContext context,
    int itemsCount = 9,
    int page = 1,
  }) {
    return DioHelper.getData(
      url: "/prize-categories/entities-operations",
      context: context,
      query: {
        "itemsCount": itemsCount,
        "page": page,
      },
    );
  }

  static Future<Response> redeemPrizeViaPointsys({
    required BuildContext context,
    required String prizeId,
    String? name,
    String? phone,
    String? nationalId,
  }) {
    final data = {
      "prize_id": prizeId,
      if (name != null && name.isNotEmpty) "name": name,
      if (phone != null && phone.isNotEmpty) "phone": phone,
      if (nationalId != null && nationalId.isNotEmpty) "national_id": nationalId,
    };
    return DioHelper.postData(
      url: "/rm_pointsys/v1/prizes",
      context: context,
      data: data,
    );
  }

  static Future<Response> transferPoints({
    required BuildContext context,
    required String user,
    required String amount,
    bool confirmed = false,
  }) {
    return DioHelper.postData(
      url: "/rm_pointsys/v1/transfer-points",
      context: context,
      data: {
        "user": user,
        "amount": amount,
        if (confirmed == true) "confirmed": confirmed,
      },
    );
  }
}
