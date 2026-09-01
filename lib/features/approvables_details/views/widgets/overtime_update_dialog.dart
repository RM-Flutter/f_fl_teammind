import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/features/overtime_requests/controllers/overtime_requests_controller.dart';
import '../../cubit/approvable_details_cubit.dart';

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

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isArabic
              ? 'تحديث ساعات الأوفرتايم'
              : 'Update Overtime Duration'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: isArabic ? 'أدخل الساعات الجديدة' : 'Enter new hours',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.buttons),
              ),
              onPressed: () async {
                if (controller.text.isEmpty) return;
                Navigator.pop(dialogContext);
                final ovProvider =
                    provider_pkg.Provider.of<OvertimeRequestsProvider>(
                        context,
                        listen: false);
                final success = await ovProvider.updateRequestDuration(
                    context, id, controller.text);
                if (success && context.mounted) {
                  AlertsService.success(
                    context: context,
                    message:
                        isArabic ? 'تم التحديث بنجاح' : 'Updated successfully',
                    title: isArabic ? 'نجاح' : 'Success',
                  );
                  cubit.fetchDetails(context: context, type: type, id: id);
                }
              },
              child: Text(isArabic ? 'حفظ' : 'Save'),
            ),
          ],
        );
      },
    );
  }
}
