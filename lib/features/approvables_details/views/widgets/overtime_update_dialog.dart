import 'package:app_test/core/services/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/overtime_requests/controllers/overtime_requests_controller.dart';
import '../../cubit/approvable_details_cubit.dart';
import 'package:app_test/core/constants/app_design.dart';

class OvertimeUpdateDialog {
  static void show(
    BuildContext context, {
    required ApprovableDetailsCubit cubit,
    required String id,
    required String type,
    dynamic currentOvertime,
  }) {
    final controller =
        TextEditingController(text: currentOvertime?.toString() ?? '');
    final isArabic = LocalizationService.isArabic(context: context);

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
                      Text(
                        isArabic ? 'تعديل ساعات الأوفرتايم' : 'Edit Overtime Duration',
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

                  // Old Value Badge
                  if (currentOvertime != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(AppColors.cardBackground),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 18, color: Colors.blueGrey),
                          const SizedBox(width: 8),
                          Text(
                            isArabic
                                ? 'المدة الحالية: $currentOvertime دقيقة'
                                : 'Current duration: $currentOvertime mins',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Label
                  Text(
                    isArabic ? 'المدة الجديدة (بالدقائق)' : 'New Duration (in minutes)',
                    style: AppStyles.darkContent(context).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Input Field
                  TextField(
                    controller: controller,
                    enabled: !isLoading,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: isArabic ? 'أدخل المدة الجديدة' : 'Enter new duration',
                      suffixText: isArabic ? 'دقيقة' : 'mins',
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
                    title: isArabic ? 'حفظ التعديل' : 'Save Changes',
                    backgroundColor: Color(AppColors.buttons),
                    onPressed: isLoading
                        ? () async {}
                        : () async {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;

                            setState(() => isLoading = true);

                            final ovProvider =
                                provider_pkg.Provider.of<OvertimeRequestsProvider>(
                                    context,
                                    listen: false);

                            // 1. Call API to update duration
                            final res = await ovProvider.updateRequestDuration(
                                context, id, text);

                            // 2. Close Bottom Sheet FIRST so nothing covers the toast/alert!
                            if (bottomSheetContext.mounted) {
                              Navigator.of(bottomSheetContext).pop();
                            }

                            // 3. Extract exact backend response message
                            final resMap = res.data is Map ? (res.data as Map) : null;
                            final serverMsg = (resMap != null && resMap['message'] != null)
                                ? resMap['message'].toString()
                                : res.message;
                            final displayMsg = (serverMsg != null && serverMsg.isNotEmpty)
                                ? serverMsg
                                : (res.success
                                    ? (isArabic
                                        ? 'تم تحديث الأوفرتايم بنجاح'
                                        : 'Overtime request duration updated successfully')
                                    : (isArabic
                                        ? 'حدث خطأ أثناء التحديث'
                                        : 'Failed to update overtime duration'));

                            // 4. Update UI details if success
                            if (res.success) {
                              await cubit.fetchDetails(
                                  context: context, type: type, id: id);
                            }

                            // 5. Display Toast & Alert ALWAYS on main context!
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
                                  title: isArabic ? 'نجاح' : 'Success',
                                );
                              } else {
                                AlertsService.error(
                                  context: context,
                                  message: displayMsg,
                                  title: isArabic ? 'خطأ' : 'Error',
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
