import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/user_consts.dart';
import '../../../general_services/app_info.service.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../general_services/settings.service.dart';
import '../../../general_services/url_launcher.service.dart';
import '../../../models/settings/general_settings.model.dart';

class CompanyStructureInfoViewModel extends ChangeNotifier {
  final double pageLeftRightPadding = AppSizes.s14;
  final double backgroundHeight = AppSizes.s270;
  final double notchedContainerHeight = AppSizes.s200;
  final double notchRadius = AppSizes.s50;
  final double notchPadding = AppSizes.s4;
  String? applicationName;
  String? applicationVersion;
  String? applicationDescription;
  final ScrollController scrollController = ScrollController();
  GeneralSettingsModel? settings;
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> initializeCompanyinformationScreen(
      {required BuildContext context}) async {
    try {
      var jsonString;
      GeneralSettingsModel generalSettingsModel;
      var gCache;
      jsonString = CacheHelper.getString("USG");
      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
        gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
        UserSettingConst.generalSettingsModel = GeneralSettingsModel.fromJson(gCache);
      }
      generalSettingsModel = GeneralSettingsModel.fromJson(gCache);
      settings = generalSettingsModel;
      applicationName = await ApplicationInformationService.getAppName();
      applicationVersion = await ApplicationInformationService.getAppVersion();
      applicationDescription =
          await ApplicationInformationService.getAppDescription();
    } catch (ex, t) {
      debugPrint(
          "Failed to initialize and getting applicaiton information -> $ex at-> $t");
    }
    notifyListeners();
  }

  Future<void> sendMailToCompany(
      {required BuildContext context,
      required String email,
      required String? subject,
      required String? body}) async {
    if (email.isEmpty) return;
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${subject ?? 'Contact Us'}&body=${body ?? 'Hello'}',
    );
    var url = params.toString();
    await UrlLauncherServiceEx.launch(context: context, url: url);
  }
}
