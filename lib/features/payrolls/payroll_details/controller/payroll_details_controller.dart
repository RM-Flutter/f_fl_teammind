import 'dart:convert';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';
import 'package:app_test/features/payrolls/shared/repos/payroll_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' if (dart.library.io) '../../../general_services/dart_html_stub.dart' as html;

class PayrollDetailsViewModel extends ChangeNotifier {
  PayrollModel? payroll;
  UserSettingsModel? currentUserSettings;
  bool isLoading = true;
  bool isLoadingPdf = true;
  String? localFilePath;

  void updateLoadingStatus({required bool loadingValue}) {
    isLoading = loadingValue;
    notifyListeners();
  }

  Future<void> initializePayrollDetailsScreen({
    required BuildContext context,
    required String? payrollId,
    String? empId,
  }) async {
    if (payrollId == null) return;

    updateLoadingStatus(loadingValue: true);

    final jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      final gCache = json.decode(jsonString) as Map<String, dynamic>;
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
      currentUserSettings = UserSettingsModel.fromJson(gCache);
    }

    await _getPayrollDetailsData(
      context: context,
      payrollId: payrollId,
      empId: empId,
    );

    updateLoadingStatus(loadingValue: false);
  }

  /// Download PDF file (Web & Mobile)
  Future<void> downloadPdf(BuildContext context, String id, {String? slug}) async {
    isLoadingPdf = true;
    notifyListeners();

    try {
      final pdfUrl = '${AppConstants.baseUrl}/rm_payroll/v1/payroll/$id/pdf';

      if (kIsWeb) {
        // Web: use dart:html
        try {
          final response = await html.window.fetch(pdfUrl);
          final blob = await (response as dynamic).blob();
          final blobUrl = html.Url.createObjectUrlFromBlob(blob);

          final anchor = html.AnchorElement(href: blobUrl)
            ..download = 'payroll_$id.pdf'
            ..style.display = 'none';
          html.document.body?.append(anchor);
          anchor.click();
          anchor.remove();
          html.Url.revokeObjectUrl(blobUrl);

          AlertsService.success(
            context: context,
            message: AppStrings.saveSucessFull.tr(),
            title: AppStrings.saved.tr(),
          );
        } catch (e) {
          debugPrint('Error downloading PDF (Web): $e');
          // Fallback: open in new tab
          final uri = Uri.parse(pdfUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      } else {
        // Mobile: save to local storage
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/payroll_$id.pdf';

        await DioHelper.downloadData(
          context: context,
          url: pdfUrl,
          savePath: filePath,
        );

        localFilePath = filePath;

        AlertsService.success(
          context: context,
          message: AppStrings.saveSucessFull.tr(),
          title: AppStrings.saved.tr(),
        );
      }
    } catch (e) {
      debugPrint("Error downloading PDF: $e");
      AlertsService.error(
        context: context,
        message: e.toString(),
        title: AppStrings.failed.tr(),
      );
    } finally {
      isLoadingPdf = false;
      notifyListeners();
    }
  }

  /// Fetch payroll details from API
  Future<void> _getPayrollDetailsData({
    required BuildContext context,
    required String payrollId,
    String? empId,
  }) async {
    try {
      final result = await PayrollRepo.getSinglePayrollById(
        context: context,
        payrollId: payrollId,
        empId: empId,
        withValues: ['user_id'],
      );

      if (result.success && result.data != null) {
        payroll = PayrollModel.fromJson(result.data?['item']);
      }
    } catch (err, t) {
      debugPrint("Error getting payroll details: $err at $t");
    }
  }
}
