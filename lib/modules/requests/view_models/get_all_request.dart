import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';

import 'dart:convert';

import 'package:rmemp/models/all_company_request.model.dart';
import 'package:rmemp/models/myteam_request.model.dart';
import 'package:rmemp/models/other_department_request.model.dart';
import 'package:rmemp/models/request.model.dart';

class GetAllRequests {
  late String? mRequestString;
  late String? mtRequestString;
  late String? odRequestString;
  late String? acRequestString;

  late Map<String, dynamic> mRequestCache;
  late Map<String, dynamic> odRequestCache;
  late Map<String, dynamic> mtRequestCache;
  late Map<String, dynamic> alRequestCache;

 static List<RequestModel>? myRequests;
  static List<MyTeamRequestModel>? myTeamRequests;
  static  List<OtherDepartmentRequestModel>? odRequests;
  static  List<AllCompanyRequestModel>? acRequests;

  void init() {
    mRequestString = CacheHelper.getString("mRequest");
    odRequestString = CacheHelper.getString("odRequest");
    mtRequestString = CacheHelper.getString("mtRequest");
    acRequestString = CacheHelper.getString("acRequest");

    if (mRequestString != null && mRequestString!.isNotEmpty) {
      mRequestCache = json.decode(mRequestString!) as Map<String, dynamic>;
      UserSettingConst.requestModel = RequestModel.fromJson(mRequestCache);

      final requests = mRequestCache['requests'] as List<dynamic>;
      myRequests = requests
          .map((item) => RequestModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (odRequestString != null && odRequestString!.isNotEmpty) {
      odRequestCache = json.decode(odRequestString!) as Map<String, dynamic>;
      UserSettingConst.otherDepartmentRequestModel =
          OtherDepartmentRequestModel.fromJson(odRequestCache);

      final requests = odRequestCache['requests'] as List<dynamic>;
      odRequests = requests
          .map((item) =>
          OtherDepartmentRequestModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (acRequestString != null && acRequestString!.isNotEmpty) {
      alRequestCache = json.decode(acRequestString!) as Map<String, dynamic>;
      UserSettingConst.allCompanyRequestModel =
          AllCompanyRequestModel.fromJson(alRequestCache);

      final requests = alRequestCache['requests'] as List<dynamic>;
      acRequests = requests
          .map((item) =>
          AllCompanyRequestModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (mtRequestString != null && mtRequestString!.isNotEmpty) {
      mtRequestCache = json.decode(mtRequestString!) as Map<String, dynamic>;
      UserSettingConst.myTeamRequestModel =
          MyTeamRequestModel.fromJson(mtRequestCache);

      final requests = mtRequestCache['requests'] as List<dynamic>;
      myTeamRequests = requests
          .map((item) =>
          MyTeamRequestModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }
}
