import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/services/alert_service/alerts_service.dart';
import '../shared/repos/salary_advance_repo.dart';

class CreateSalaryAdvanceController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  TextEditingController totalController = TextEditingController();
  TextEditingController howLongToPayController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();

  List<FilePickerResult> attachments = [];
  bool isLoading = false;

  void setFromDate(String date) {
    fromDateController.text = date;
    notifyListeners();
  }

  void addAttachment(FilePickerResult result) {
    attachments.add(result);
    notifyListeners();
  }

  void removeAttachment(int index) {
    attachments.removeAt(index);
    notifyListeners();
  }

  Future<bool> submitRequest(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    isLoading = true;
    notifyListeners();

    try {
      final result = await SalaryAdvanceRepo.createSalaryAdvanceRequest(
        context: context,
        total: totalController.text,
        howLongToPay: howLongToPayController.text,
        from: fromDateController.text,
        files: attachments,
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
      debugPrint("Error creating salary advance request: $e");
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
