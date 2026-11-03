import 'package:app_test/core/services/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/expense_claim_requests/shared/repos/expense_claim_repo.dart';
import '../../cubit/approvable_details_cubit.dart';
import '../../data/models/approvable_details_model.dart';
import 'package:app_test/core/constants/app_design.dart';

class ExpenseClaimUpdateAmountDialog {
  static void show(
    BuildContext context, {
    required ApprovableDetailsCubit cubit,
    required String id,
    required String type,
    required ApprovableDetailsModel details,
  }) {
    final currentAmount = details.moneyValue?.toString() ?? '';
    final controller = TextEditingController(text: currentAmount);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (stContext, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl),
                  topRight: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                  ),
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('edit_expense_claim_amount'.tr(),
                        style: AppStyles.darkContent(context).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.secondaryButton),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(bottomSheetContext).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Label
                  Text('total_amount_2'.tr(),
                    style: AppStyles.darkContent(context).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Input Field with old value prefilled for editing
                  TextField(
                    controller: controller,
                    enabled: !isLoading,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'enter_amount'.tr(),
                      prefixIcon: Icon(Icons.monetization_on_outlined,
                          color: Color(AppColors.buttons)),
                      suffixText: 'egp_2'.tr(),
                      suffixStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: Color(AppColors.buttons), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  CustomElevatedButton(
                    title: 'save_changes_2'.tr(),
                    backgroundColor: Color(AppColors.buttons),
                    onPressed: isLoading
                        ? () async {}
                        : () async {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;

                            setState(() => isLoading = true);

                            // 1. Call API to update claim amount
                            final claimId = int.tryParse(id) ?? details.id ?? 0;
                            final res = await ExpenseClaimRepo.updateExpenseClaim(
                              context: context,
                              id: claimId,
                              moneyValue: text,
                              reason: details.reason ?? '',
                              dateFrom: details.dateFrom ?? '',
                              category: details.typeId?.toString() ?? '',
                              notes: details.notes ?? '',
                            );

                            // 2. Close Bottom Sheet
                            if (bottomSheetContext.mounted) {
                              Navigator.of(bottomSheetContext).pop();
                            }

                            // 3. Extract message
                            final resMap = res.data is Map ? (res.data as Map) : null;
                            final serverMsg = (resMap != null && resMap['message'] != null)
                                ? resMap['message'].toString()
                                : res.message;
                            final displayMsg = (serverMsg != null && serverMsg.isNotEmpty)
                                ? serverMsg
                                : (res.success
                                    ? ('expense_claim_amount_updated_successfully'.tr())
                                    : ('failed_to_update_expense_claim_amount'.tr()));

                            // 4. Update UI details if success
                            if (res.success) {
                              await cubit.fetchDetails(
                                  context: context, type: type, id: id);
                            }

                            // 5. Display Toast & Alert on main context
                            AppToast.showToast(
                              msg: displayMsg,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: res.success
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );

                            if (context.mounted) {
                              if (res.success) {
                                AlertsService.success(
                                  context: context,
                                  message: displayMsg,
                                  title: 'success_3'.tr(),
                                );
                              } else {
                                AlertsService.error(
                                  context: context,
                                  message: displayMsg,
                                  title: 'error_2'.tr(),
                                );
                              }
                            }
                          },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
