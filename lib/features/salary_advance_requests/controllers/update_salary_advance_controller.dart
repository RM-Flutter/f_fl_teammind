import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/services/alert_service/alerts_service.dart';
import '../shared/models/salary_advance_request_model.dart';
import '../shared/repos/salary_advance_repo.dart';

class UpdateSalaryAdvanceController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  late TextEditingController totalController;
  late TextEditingController howLongToPayController;
  late TextEditingController fromDateController;

  List<FilePickerResult> newAttachments = [];
  bool isLoading = false;

  /// ID of the request to update
  final int requestId;

  UpdateSalaryAdvanceController({
    required this.requestId,
    required SalaryAdvanceRequestModel existingRequest,
  }) {
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
    newAttachments.add(result);
    notifyListeners();
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

  @override
  void dispose() {
    totalController.dispose();
    howLongToPayController.dispose();
    fromDateController.dispose();
    super.dispose();
  }
}
