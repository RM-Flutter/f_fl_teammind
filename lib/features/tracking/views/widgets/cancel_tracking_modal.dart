import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
            child: Text('cancel_tracking_sessions'.tr(),
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
          Text('select_admin_cancellation_scope_for_this_request'.tr(),
            style: AppStyles.content(context).copyWith(fontSize: 12, color: const Color(0xff606060)),
          ),
          const SizedBox(height: 12),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text('cancel_current_active_leg_only'.tr(),
              style: AppStyles.content(context).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            subtitle: Text('keep_history_of_previous_completed_legs'.tr(),
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
            title: Text('cancel_all_tracking_for_request_all_legs'.tr(),
              style: AppStyles.content(context).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.failureRed),
              ),
            ),
            subtitle: Text('mark_overall_tracking_as_cancelled_and_void'.tr(),
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
          child: Text('back'.tr(),
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
          child: Text('confirm_cancel'.tr(),
            style: AppStyles.whiteContent(context).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
