import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/services/alert_service/alerts_service.dart';
import '../shared/repos/expense_claim_repo.dart';

class CreateExpenseClaimController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  TextEditingController reasonController = TextEditingController();
  TextEditingController moneyValueController = TextEditingController();
  TextEditingController dateFromController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  List<FilePickerResult> attachments = [];
  bool isLoading = false;

  void setDateFrom(String date) {
    dateFromController.text = date;
    notifyListeners();
  }

  void setCategory(String value) {
    categoryController.text = value;
    notifyListeners();
  }

  void addAttachment(FilePickerResult result) {
    if (result.files.isNotEmpty) {
      for (var file in result.files) {
        attachments.add(FilePickerResult([file]));
      }
      notifyListeners();
    }
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
      final result = await ExpenseClaimRepo.createExpenseClaim(
        context: context,
        reason: reasonController.text.trim(),
        moneyValue: moneyValueController.text.trim(),
        dateFrom: dateFromController.text.trim(),
        category: categoryController.text.trim(),
        notes: notesController.text.trim(),
        files: attachments,
      );

      if (result.success) {
        if (context.mounted) {
          AlertsService.success(
            context: context,
            message: result.message ?? 'submitted_successfully'.tr(),
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
      debugPrint('Error creating expense claim: $e');
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
    reasonController.dispose();
    moneyValueController.dispose();
    dateFromController.dispose();
    categoryController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
