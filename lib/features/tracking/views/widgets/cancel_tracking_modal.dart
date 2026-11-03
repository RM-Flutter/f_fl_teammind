import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/app_styles.dart';
import 'package:app_test/core/constants/app_design.dart';

class CancelTrackingModal extends StatefulWidget {
  final Function(String scope) onConfirm;

  const CancelTrackingModal({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context, {required Function(String scope) onConfirm}) {
    return showDialog(
      context: context,
      builder: (ctx) => CancelTrackingModal(onConfirm: onConfirm),
    );
  }

  @override
  State<CancelTrackingModal> createState() => _CancelTrackingModalState();
}

class _CancelTrackingModalState extends State<CancelTrackingModal> {
  String _selectedScope = 'current_session';

  @override
  Widget build(BuildContext context) {
    final bool isAr = LocalizationService.isArabic(context: context);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Color(AppColors.warningYellow).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded, color: Color(AppColors.warningYellow), size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAr ? 'إلغاء جلسات التتبع' : 'Cancel Tracking Sessions',
              style: AppStyles.heading(context).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.titleText),
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr
                ? 'يرجى تحديد نطاق إلغاء التتبع الإداري لهذا الطلب:'
                : 'Select admin cancellation scope for this request:',
            style: AppStyles.content(context).copyWith(fontSize: 12, color: const Color(0xff606060)),
          ),
          const SizedBox(height: 12),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text(
              isAr ? 'إلغاء الجلسة النشطة الحالية فقط' : 'Cancel current active leg only',
              style: AppStyles.content(context).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              isAr
                  ? 'الاحتفاظ بسجل الجلسات السابقة المكتملة'
                  : 'Keep history of previous completed legs',
              style: AppStyles.hintContent(context).copyWith(fontSize: 10),
            ),
            value: 'current_session',
            groupValue: _selectedScope,
            activeColor: Color(AppColors.buttons),
            onChanged: (val) {
              if (val != null) setState(() => _selectedScope = val);
            },
          ),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text(
              isAr ? 'إلغاء كل التتبع للطلب (كل الجلسات)' : 'Cancel all tracking for request (all legs)',
              style: AppStyles.content(context).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.failureRed),
              ),
            ),
            subtitle: Text(
              isAr
                  ? 'تحويل حالة التتبع بالكامل إلى ملغي وإخلاء المسؤولية'
                  : 'Mark overall tracking as cancelled and void requirement',
              style: AppStyles.hintContent(context).copyWith(fontSize: 10),
            ),
            value: 'all_sessions',
            groupValue: _selectedScope,
            activeColor: Color(AppColors.failureRed),
            onChanged: (val) {
              if (val != null) setState(() => _selectedScope = val);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            isAr ? 'تراجع' : 'Back',
            style: AppStyles.content(context).copyWith(color: const Color(0xff606060)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedScope == 'all_sessions'
                ? Color(AppColors.failureRed)
                : Color(AppColors.buttons),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () {
            widget.onConfirm(_selectedScope);
            Navigator.of(context).pop();
          },
          child: Text(
            isAr ? 'تأكيد الإلغاء' : 'Confirm Cancel',
            style: AppStyles.whiteContent(context).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
