import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/services/localization_service.dart';
import '../../data/models/approvable_details_model.dart';

/// Banner shown on the approvable details screen when the request has a
/// pending cancellation (`waiting_cancel == true`).
///
/// The message adapts to the viewer:
/// - Applicant: waiting for the direct manager to approve the cancellation.
/// - Manager with `can_approve_cancel`: employee asked to cancel, approve below.
/// - Anyone else: generic pending-cancellation notice.
class PendingCancelBanner extends StatelessWidget {
  final ApprovableDetailsModel details;
  final bool isApplicant;

  const PendingCancelBanner({
    super.key,
    required this.details,
    required this.isApplicant,
  });

  static bool shouldShow(ApprovableDetailsModel details) {
    final status = (details.status ?? '').toLowerCase().trim();
    return details.waitingCancel == true &&
        status != 'canceled' &&
        status != 'cancelled' &&
        status != 'refused' &&
        status != 'rejected';
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = LocalizationService.isArabic(context: context);
    final bool canApprove = !isApplicant && details.canApproveCancel == true;

    final String title = canApprove
        ? (isArabic ? 'مطلوب موافقتك على الإلغاء' : 'Cancellation Approval Required')
        : (isArabic ? 'طلب إلغاء معلق' : 'Cancellation Pending');

    final String subtitle = isApplicant
        ? (isArabic
            ? 'تم إرسال طلب الإلغاء، في انتظار موافقة المدير المباشر.'
            : 'Your cancellation request was sent and is awaiting your direct manager\'s approval.')
        : canApprove
            ? (isArabic
                ? 'الموظف طلب إلغاء هذا الطلب، يمكنك الموافقة على الإلغاء من الزر بالأسفل.'
                : 'The employee asked to cancel this request. You can approve the cancellation below.')
            : (isArabic
                ? 'يوجد طلب إلغاء على هذا الطلب في انتظار موافقة المدير المباشر.'
                : 'This request has a cancellation pending the direct manager\'s approval.');

    const Color accent = Color(0xFFE65100);
    final Color iconColor = canApprove ? const Color(0xFFC62828) : accent;

    // Web: compact one-line banner, aligned with the tab bar below it, so it takes
    // less height from the tabs on short screens. Mobile keeps the two-line layout.
    const bool compact = kIsWeb;

    final Widget icon = Container(
      padding: EdgeInsets.all(compact ? 5 : 8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        canApprove
            ? Icons.assignment_return_rounded
            : Icons.hourglass_top_rounded,
        color: iconColor,
        size: compact ? 16 : 20,
      ),
    );

    final TextStyle titleStyle = TextStyle(
      color: iconColor,
      fontSize: compact ? 13 : 14,
      fontWeight: FontWeight.bold,
    );
    final TextStyle subtitleStyle = TextStyle(
      color: Colors.black.withOpacity(0.7),
      fontSize: 12,
      height: 1.35,
    );

    final Widget text = compact
        ? Text.rich(
            TextSpan(children: [
              TextSpan(text: title, style: titleStyle),
              TextSpan(text: '  ·  ', style: subtitleStyle),
              TextSpan(text: subtitle, style: subtitleStyle),
            ]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: titleStyle),
              const SizedBox(height: 2),
              Text(subtitle, style: subtitleStyle),
            ],
          );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: double.infinity),
        child: Container(
          // Web: same side inset as the tab bar (8) so the edges line up
          margin: compact
              ? const EdgeInsets.fromLTRB(8, 10, 8, 0)
              : const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 7)
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: [
                iconColor.withOpacity(0.12),
                iconColor.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(compact ? 12 : 14),
            border: Border.all(color: iconColor.withOpacity(0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: compact ? 10 : 12),
              Expanded(child: text),
            ],
          ),
        ),
      ),
    );
  }
}
