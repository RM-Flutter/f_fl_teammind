import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/alert_service/alerts.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' if (dart.library.io) '../../../general_services/dart_html_stub.dart' as html;
import '../../../constants/user_consts.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../models/settings/user_settings.model.dart';
import '../models/payroll.model.dart';
import '../services/payroll.service.dart';

class PayrollDetailsViewModel extends ChangeNotifier {
  PayrollModel? payroll;
  UserSettingsModel? currentUserSettings;
  bool isLoading = true;
  bool isLoadingPdf = true;
  String? localFilePath;
  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }

  Future<void> initializePayrollDetailsScreen(
      {required BuildContext context,
      required String? payrollId,
      String? empId}) async {
    if (payrollId == null) return;
    updateLoadingStatus(laodingValue: true);
    var jsonString;
    UserSettingsModel userSettingsModel;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    userSettingsModel = UserSettingsModel.fromJson(gCache);
    currentUserSettings = userSettingsModel;
    await _getPayrollDetailsData(
        context: context, payrollId: payrollId, empId: empId);
    updateLoadingStatus(laodingValue: false);
  }
  downloadPdf(context, id , {slug}) async {
    isLoadingPdf = true;
    notifyListeners();
    try {
      final pdfUrl = '${AppConstants.baseUrl}/rm_payroll/v1/payroll/$id/pdf';
      
      if (kIsWeb) {
        // For web, download directly using dart:html
        try {
          // Fetch the PDF file
          final response = await html.window.fetch(pdfUrl);
          final blob = await (response as dynamic).blob();
          final blobUrl = html.Url.createObjectUrlFromBlob(blob);
          
          // Create anchor element to trigger download
          final anchor = html.AnchorElement(href: blobUrl)
            ..download = 'payroll_$id.pdf'
            ..style.display = 'none';
          html.document.body?.append(anchor);
          anchor.click();
          anchor.remove();
          html.Url.revokeObjectUrl(blobUrl);
          
          isLoadingPdf = false;
          AlertsService.success(
              context: context,
              message: AppStrings.saveSucessFull.tr(),
              title: AppStrings.saved.tr());
          notifyListeners();
        } catch (e) {
          debugPrint('Error downloading PDF with fetch: $e');
          // Fallback: open in new tab
          try {
            final uri = Uri.parse(pdfUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            isLoadingPdf = false;
            AlertsService.success(
                context: context,
                message: AppStrings.saveSucessFull.tr(),
                title: AppStrings.saved.tr());
            notifyListeners();
          } catch (e2) {
            debugPrint('Error opening PDF in new tab: $e2');
            isLoadingPdf = false;
            AlertsService.error(
                context: context,
                message: e2.toString(),
                title: AppStrings.failed.tr());
            notifyListeners();
          }
        }
      } else {
        // For mobile, use path_provider
        var dir = await getApplicationDocumentsDirectory();
        String filePath = '${dir.path}/payroll_$id.pdf';
        await DioHelper.downloadData(context: context,
          url: pdfUrl,
          savePath: filePath,
        );
        localFilePath = filePath;
        isLoadingPdf = false;
        AlertsService.success(
            context: context,
            message: AppStrings.saveSucessFull.tr(),
            title: AppStrings.saved.tr());
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error downloading PDF: $e");
      isLoadingPdf = false;
      AlertsService.error(
          context: context,
          message: e.toString(),
          title: AppStrings.failed.tr());
      notifyListeners();
    }
  }
  Future<void> _getPayrollDetailsData(
      {required BuildContext context,
      required String payrollId,
      String? empId}) async {
    try {
      final result = await PayrollService.getSinglePayrollById(
          context: context,
          payrollId: payrollId,
          empId: empId,
          withValues: ['user_id']);
      if (result.success && result.data != null) {
        payroll = PayrollModel.fromJson(result.data?['item']);
      }
    } catch (err, t) {
      debugPrint(
          "error while getting Payroll Details  ${err.toString()} at :- $t");
    }
  }
}
