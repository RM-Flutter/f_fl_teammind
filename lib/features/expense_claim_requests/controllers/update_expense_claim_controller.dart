import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/services/alert_service/alerts_service.dart';
import '../shared/models/expense_claim_model.dart';
import '../shared/repos/expense_claim_repo.dart';

class UpdateExpenseClaimController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  late TextEditingController reasonController;
  late TextEditingController moneyValueController;
  late TextEditingController dateFromController;
  late TextEditingController categoryController;
  late TextEditingController notesController;

  List<FilePickerResult> newAttachments = [];
  List<ExpenseClaimFileModel> existingFiles = [];
  bool isLoading = false;

  final int requestId;

  UpdateExpenseClaimController({
    required this.requestId,
    required ExpenseClaimModel existingRequest,
  }) {
    existingFiles = List.from(existingRequest.files ?? []);
    reasonController = TextEditingController(text: existingRequest.reason ?? '');
    moneyValueController = TextEditingController(text: existingRequest.moneyValue ?? '');
    dateFromController = TextEditingController(text: existingRequest.dateFrom ?? '');
    categoryController = TextEditingController(text: existingRequest.category ?? '');
    notesController = TextEditingController(text: existingRequest.notes ?? '');
  }

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
        newAttachments.add(FilePickerResult([file]));
      }
      notifyListeners();
    }
  }

  void removeNewAttachment(int index) {
    newAttachments.removeAt(index);
    notifyListeners();
  }

  Future<bool> submitUpdate(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    isLoading = true;
    notifyListeners();

    try {
      final result = await ExpenseClaimRepo.updateExpenseClaim(
        context: context,
        id: requestId,
        reason: reasonController.text.trim(),
        moneyValue: moneyValueController.text.trim(),
        dateFrom: dateFromController.text.trim(),
        category: categoryController.text.trim(),
        notes: notesController.text.trim(),
        files: newAttachments,
      );

      if (result.success) {
        if (context.mounted) {
          AlertsService.success(
            context: context,
            message: result.message ?? 'updated_successfully'.tr(),
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
      debugPrint('Error updating expense claim: $e');
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
