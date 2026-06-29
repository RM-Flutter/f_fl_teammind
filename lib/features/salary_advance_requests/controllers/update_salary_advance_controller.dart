import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'dart:convert';
import '../../../../core/services/alert_service/alerts_service.dart';
import '../../daily_reports/models/daily_report_model.dart';
import '../shared/models/salary_advance_request_model.dart';
import '../shared/repos/salary_advance_repo.dart';

class UpdateSalaryAdvanceController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  late TextEditingController totalController;
  late TextEditingController howLongToPayController;
  late TextEditingController fromDateController;

  List<FilePickerResult> newAttachments = [];
  List<ReportAttachmentModel> existingAttachments = [];
  bool isLoading = false;
  
  UserSettingsModel? userSettings;

  bool get isHr {
    return userSettings?.isHr == true;
  }

  void _loadUserSettings() {
    var jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      var gCache = json.decode(jsonString) as Map<String, dynamic>;
      userSettings = UserSettingsModel.fromJson(gCache);
    }
  }

  /// ID of the request to update
  final int requestId;

  UpdateSalaryAdvanceController({
    required this.requestId,
    required SalaryAdvanceRequestModel existingRequest,
  }) {
    _loadUserSettings();
    existingAttachments = List.from(existingRequest.attachments ?? []);
    totalController = TextEditingController(text: existingRequest.total ?? '');
    howLongToPayController =
        TextEditingController(text: existingRequest.howLongToPay ?? '');
    fromDateController =
        TextEditingController(text: existingRequest.from ?? '');
  }

  void setFromDate(String date) {
    fromDateController.text = date;
    notifyListeners();
  }

  void addAttachment(FilePickerResult result) {
    if (result.files.isNotEmpty) {
      for (var file in result.files) {
        newAttachments.add(FilePickerResult([file]));
      }
      notifyListeners();
    }
  }

  void removeAttachment(int index) {
    newAttachments.removeAt(index);
    notifyListeners();
  }

  Future<bool> submitUpdate(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    isLoading = true;
    notifyListeners();

    try {
      final result = await SalaryAdvanceRepo.updateSalaryAdvanceRequest(
        context: context,
        id: requestId,
        total: totalController.text.trim(),
        howLongToPay: howLongToPayController.text.trim(),
        from: fromDateController.text.trim(),
        files: newAttachments,
      );

      if (result.success) {
        if (context.mounted) {
          AlertsService.success(
            context: context,
            message: 'updated_successfully'.tr(),
            title: 'success'.tr(),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          AlertsService.error(
            context: context,
            message: result.message ?? 'error_occurred'.tr(),
            title: 'error'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating salary advance request: $e');
      if (context.mounted) {
        AlertsService.error(
          context: context,
          message: 'error_occurred'.tr(),
          title: 'error'.tr(),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteExistingAttachment(BuildContext context, int attachmentId) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await SalaryAdvanceRepo.removeAttachment(
        context: context,
        requestId: requestId,
        attachmentId: attachmentId,
      );
      if (result.success) {
        existingAttachments.removeWhere((element) => element.id == attachmentId);
        notifyListeners();
        return true;
      } else {
        if (context.mounted) {
          AlertsService.error(
            context: context,
            message: result.message ?? 'error_occurred'.tr(),
            title: 'error'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint('Error removing attachment: $e');
      if (context.mounted) {
        AlertsService.error(
          context: context,
          message: 'error_occurred'.tr(),
          title: 'error'.tr(),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  @override
  void dispose() {
    totalController.dispose();
    howLongToPayController.dispose();
    fromDateController.dispose();
    super.dispose();
  }
}
