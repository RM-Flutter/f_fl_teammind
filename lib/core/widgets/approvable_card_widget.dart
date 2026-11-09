import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/services/settings_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_action_confirmation_dialog.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:app_test/core/widgets/quick_action_sheet.dart';
import 'package:app_test/features/approvables_details/data/services/approvables_details_service.dart';
import 'package:app_test/features/approvables_details/views/widgets/overlapping_vacations_sheet.dart';
import 'package:app_test/features/cv_hub/models/cv_hub_models.dart';
import 'package:app_test/features/expense_claim_requests/shared/models/expense_claim_model.dart';
import 'package:app_test/features/overtime_requests/models/overtime_request_model.dart';
import 'package:app_test/features/salary_advance_requests/shared/models/salary_advance_request_model.dart';
import 'package:app_test/features/shifts/models/shift_change_request_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ApprovableCardWidget extends StatelessWidget {
  final dynamic
      request; // RequestModel, OvertimeRequestModel, SalaryAdvanceRequestModel
  final bool isForDepartment;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onActionTaken;
  final EdgeInsetsGeometry? margin;
  final Widget? customTrailing;

  const ApprovableCardWidget({
    Key? key,
    required this.request,
    required this.isForDepartment,
    required this.onTap,
    this.onLongPress,
    this.onActionTaken,
    this.margin,
    this.customTrailing,
  }) : super(key: key);

  /// Resolves the approvable type and id from the request object.
  _ApprovableInfo _resolveInfo(bool isArabic, BuildContext context) {
    bool takeAction = false;
    bool takeActionAsSomeoneElse = false;
    bool waitingCancel = false;
    bool canApproveCancel = false;
    String? status;
    String title = '';
    String subtitle = '';
    String employeeName = '';
    String? avatarUrl;
    String approvableType = 'employee_requests';
    String id = '';

    try {
      if (request is OvertimeRequestModel) {
        final ot = request as OvertimeRequestModel;
        takeAction = ot.takeAction == true;
        takeActionAsSomeoneElse = ot.canTakeActionAsSomeoneElse == true;
        status = ot.status;
        employeeName = ot.employeeName ?? ot.employeeProfile?.name ?? '';
        id = ot.id?.toString() ?? '';
        approvableType = 'overtime';

        final dateStr = (ot.date != null && ot.date!.length >= 10)
            ? ot.date!.substring(0, 10)
            : (ot.date ?? '');
        final formattedDate = (ot.date != null && ot.date!.isNotEmpty)
            ? (DateService.formatDate(
                    isArabic ? 'ar' : 'en', context, ot.date) ??
                dateStr)
            : dateStr;

        int totalMins = ot.overtime ?? 0;
        final hours = totalMins ~/ 60;
        final mins = totalMins % 60;
        String durationStr = '';
        if (hours == 0) {
          durationStr = '$mins ${'min'.tr()}';
        } else if (mins == 0) {
          durationStr = '$hours ${'hr'.tr()}';
        } else {
          durationStr =
              'hr_min'.tr(namedArgs: {'hours': '$hours', 'mins': '$mins'});
        }

        if (totalMins > 0) {
          title = durationStr;
          subtitle = formattedDate.isNotEmpty
              ? ('date_2'.tr(namedArgs: {'formatted_date': '$formattedDate'}))
              : '';
        } else {
          title =
              formattedDate.isNotEmpty ? formattedDate : ('overtime_2'.tr());
          subtitle = '';
        }
      } else if (request is SalaryAdvanceRequestModel) {
        final sa = request as SalaryAdvanceRequestModel;
        takeAction = sa.takeAction == true;
        takeActionAsSomeoneElse = sa.canTakeActionAsSomeoneElse == true;
        status = sa.status;
        employeeName = sa.employeeProfile?.name ?? '';
        id = sa.id?.toString() ?? '';
        approvableType = 'salary_advance';

        String amount = sa.total?.toString() ?? '0';
        String months = sa.howLongToPay?.toString() ?? '1';
        title = '$amount ${'egp_2'.tr()}';
        String durationText = isArabic
            ? '$months شهر'
            : '$months ${months == '1' ? 'month' : 'months'}';
        String details = '${'duration_2'.tr()}: $durationText';
        if (sa.from != null && sa.from!.isNotEmpty) {
          final formattedFrom = DateService.formatDate(
                  isArabic ? 'ar' : 'en', context, sa.from) ??
              sa.from!;
          details += ' · ${'from'.tr()}: $formattedFrom';
        }
        subtitle = details;
      } else if (request is ExpenseClaimModel) {
        final ec = request as ExpenseClaimModel;
        takeAction = ec.takeAction == true;
        takeActionAsSomeoneElse = ec.canTakeActionAsSomeoneElse == true;
        status = ec.status;
        employeeName = ec.employeeName ?? '';
        id = ec.id?.toString() ?? '';
        approvableType = 'employee_expense_claims';

        final amount = ec.moneyValue ?? '0';
        title = ec.reason?.isNotEmpty == true
            ? ec.reason!
            : '$amount ${'egp_2'.tr()}';

        String sub = '$amount ${'egp_2'.tr()}';
        if (ec.categoryName != null && ec.categoryName!.isNotEmpty) {
          sub += ' · ${ec.categoryName}';
        } else if (ec.category != null && ec.category!.isNotEmpty) {
          sub += ' · ${ec.category}';
        }
        if (ec.dateFrom != null && ec.dateFrom!.isNotEmpty) {
          final formattedDate = DateService.formatDate(
                  isArabic ? 'ar' : 'en', context, ec.dateFrom) ??
              ec.dateFrom!;
          sub += ' · $formattedDate';
        }
        subtitle = sub;
      } else if (request is ShiftChangeRequestModel) {
        final sc = request as ShiftChangeRequestModel;
        takeAction = sc.takeAction == true;
        takeActionAsSomeoneElse = sc.canTakeActionAsSomeoneElse == true;
        status = sc.status;
        id = sc.id?.toString() ?? '';
        approvableType = 'shift_change_requests';

        final reqName = sc.requesterEmployeeName ?? sc.employeeName ?? '';
        final recName = sc.receiverEmployeeName ?? '';
        employeeName = recName.isNotEmpty ? '$reqName ↔ $recName' : reqName;

        final reqShift = sc.requesterShiftName ?? '';
        final recShift = sc.receiverShiftName ?? '';
        if (sc.isTwoWaySwap && recShift.isNotEmpty) {
          title = '$reqShift ↔ $recShift';
        } else {
          title = reqShift.isNotEmpty
              ? '$reqShift (${'shift_transfer'.tr()})'
              : ('shift_change_request'.tr());
        }

        final String fromDate = sc.dateFrom != null && sc.dateFrom!.isNotEmpty
            ? (DateService.formatDate(
                    isArabic ? 'ar' : 'en', context, sc.dateFrom) ??
                sc.dateFrom!.split(' ').first)
            : '';
        final String toDate = sc.dateTo != null && sc.dateTo!.isNotEmpty
            ? (DateService.formatDate(
                    isArabic ? 'ar' : 'en', context, sc.dateTo) ??
                sc.dateTo!.split(' ').first)
            : '';

        if (fromDate.isNotEmpty && toDate.isNotEmpty && fromDate != toDate) {
          subtitle = '$fromDate ↔ $toDate';
        } else {
          subtitle = fromDate;
        }
      } else if (request is InterviewModel) {
        final interview = request as InterviewModel;
        takeAction = false;
        takeActionAsSomeoneElse = false;
        status = interview.status;
        employeeName =
            interview.candidate?.fullName ?? 'Unknown Candidate'.tr();
        id = interview.id.toString();
        approvableType = 'interview';

        title =
            '${interview.candidate?.job?.title ?? ''} · ${interview.interviewType ?? ''}';
        subtitle = interview.scheduledAt ?? '';
      } else {
        final dyn = request as dynamic;
        takeAction = dyn.takeAction == true;
        takeActionAsSomeoneElse = dyn.canTakeActionAsSomeoneElse == true;
        status = dyn.status;
        employeeName = dyn.employeeName ?? '';
        id = dyn.id?.toString() ?? '';
        approvableType = 'employee_requests';
        try {
          avatarUrl = dyn.employeeAvatar?.toString() ?? dyn.avatar?.toString();
        } catch (_) {}
        String? depName = dyn.departmentName;
        if (depName != null && depName.isNotEmpty) {
          employeeName = '$employeeName · $depName';
        }

        String? typeNameFallback;
        try {
          typeNameFallback = dyn.typeName?.toString();
        } catch (_) {}
        title = AppSettingsService.getRequestTitleFromGenenralSettings(
                context: context,
                requestId: dyn.typeId != null ? dyn.typeId?.toString() : '',
                fallbackTitle: typeNameFallback) ??
            '';

        final String fromDate = dyn.from != null
            ? (DateService.formatDate(
                    isArabic ? 'ar' : 'en', context, dyn.from) ??
                '')
            : '';
        final String toDate = dyn.to != null
            ? (DateService.formatDate(
                    isArabic ? 'ar' : 'en', context, dyn.to) ??
                '')
            : '';

        if (dyn.duration == 0) {
          subtitle = fromDate;
        } else if (fromDate == toDate || toDate.isEmpty) {
          subtitle =
              '$fromDate (${dyn.duration} ${dyn.durationType?.toString().tr()})';
        } else {
          subtitle =
              '$fromDate : $toDate (${dyn.duration} ${dyn.durationType?.toString().tr()})';
        }

        try {
          waitingCancel = dyn.waitingCancel == true ||
              dyn.waitingCancel == 1 ||
              dyn.waitingCancel == '1';
        } catch (_) {}
        try {
          canApproveCancel = dyn.canApproveCancel == true ||
              dyn.canApproveCancel == 1 ||
              dyn.canApproveCancel == '1';
        } catch (_) {}
      }
    } catch (_) {}

    if (status != null) {
      final s = status.toLowerCase().trim();
      if (s == 'approved' ||
          s == 'accepted' ||
          s == 'refused' ||
          s == 'canceled' ||
          s == 'cancelled' ||
          s == 'rejected') {
        takeAction = false;
        takeActionAsSomeoneElse = false;
      }
      if (s == 'canceled' ||
          s == 'cancelled' ||
          s == 'refused' ||
          s == 'rejected') {
        waitingCancel = false;
        canApproveCancel = false;
      }
    }

    return _ApprovableInfo(
      takeAction: takeAction,
      takeActionAsSomeoneElse: takeActionAsSomeoneElse,
      waitingCancel: waitingCancel,
      canApproveCancel: canApproveCancel,
      status: status,
      title: title,
      subtitle: subtitle,
      employeeName: employeeName,
      avatarUrl: avatarUrl,
      approvableType: approvableType,
      id: id,
    );
  }

  static IconData _iconForApprovableType(String type) {
    switch (type) {
      case 'overtime':
        return Icons.more_time_rounded;
      case 'salary_advance':
        return Icons.payments_outlined;
      case 'employee_expense_claims':
        return Icons.receipt_long_outlined;
      case 'shift_change_requests':
        return Icons.swap_horiz_rounded;
      case 'interview':
        return Icons.assignment_ind_outlined;
      default:
        return Icons.event_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.locale.languageCode == 'ar';
    final info = _resolveInfo(isArabic, context);

    // Build slide actions based on capabilities
    final List<Widget> slideActions = [];

    if (info.takeAction) {
      slideActions.add(
        CustomSlidableAction(
          onPressed: (_) {
            if (info.id.isNotEmpty) {
              showQuickActionSheet(
                context: context,
                type: info.approvableType,
                id: info.id,
                isAsSomeoneElse: false,
                onActionTaken: onActionTaken,
              );
            }
          },
          backgroundColor: Colors.transparent,
          foregroundColor: Color(AppColors.failureRed),
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(AppColors.failureRed).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.gavel_rounded,
                    color: Color(AppColors.failureRed), size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                'action'.tr(),
                style: TextStyle(
                  color: Color(AppColors.failureRed),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (info.takeActionAsSomeoneElse) {
      slideActions.add(
        CustomSlidableAction(
          onPressed: (_) {
            if (info.id.isNotEmpty) {
              showQuickActionSheet(
                context: context,
                type: info.approvableType,
                id: info.id,
                isAsSomeoneElse: true,
                onActionTaken: onActionTaken,
              );
            }
          },
          backgroundColor: Colors.transparent,
          foregroundColor: Color(AppColors.warningYellow),
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.statusTones(Color(AppColors.warningYellow)).tint,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.manage_accounts_rounded,
                    color: AppColors.statusTones(Color(AppColors.warningYellow)).text, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                'as_someone'.tr(),
                style: TextStyle(
                  color: AppColors.statusTones(Color(AppColors.warningYellow)).text,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (info.canApproveCancel) {
      slideActions.add(
        CustomSlidableAction(
          onPressed: (_) async {
            if (info.id.isNotEmpty) {
              final confirmed = await showAppActionConfirmationDialog(
                context: context,
                title: AppStrings.approveCancel.tr(),
                message: AppStrings.confirmApproveCancel.tr(),
                confirmText: isArabic ? 'موافقة على الإلغاء' : 'Approve',
                confirmColor: Color(AppColors.secondaryButton),
                icon: Icons.assignment_return_rounded,
                iconColor: Color(AppColors.secondaryButton),
              );
              if (confirmed == true && context.mounted) {
                final res = await ApprovablesDetailsService.approveCancel(
                  context: context,
                  type: info.approvableType,
                  id: info.id,
                );
                if (res.success) {
                  Fluttertoast.showToast(
                      msg: res.message ??
                          (isArabic
                              ? 'تمت الموافقة على الإلغاء بنجاح'
                              : 'Cancellation approved successfully'));
                  onActionTaken?.call();
                } else {
                  Fluttertoast.showToast(
                      msg: res.message ??
                          (isArabic
                              ? 'فشل في الموافقة على الإلغاء'
                              : 'Failed to approve cancel'),
                      backgroundColor: Colors.red);
                }
              }
            }
          },
          backgroundColor: Colors.transparent,
          foregroundColor: Color(AppColors.failureRed),
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(AppColors.failureRed).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cancel_outlined,
                    color: Color(AppColors.failureRed), size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                isArabic ? 'موافقة إلغاء' : 'Approve Cancel',
                style: TextStyle(
                  color: Color(AppColors.failureRed),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final Color statusColor = AppStatusBadge.colorForStatus(
      info.takeAction
          ? 'action_required'
          : (info.status ?? '').trim().toLowerCase(),
    );

    final bool showEmployeeAvatar =
        isForDepartment && info.employeeName.trim().isNotEmpty;

    final cardBody = AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: AppSpacing.cardPadding,
      // No horizontal margin: slidable and normal cards must share the same edges (rule 1).
      margin: slideActions.isNotEmpty
          ? const EdgeInsets.symmetric(vertical: 2)
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Leading 46x46 Avatar (matching TeamMemberStatusCard) ────────
          AppCardLeadingAvatar(
            imageUrl: info.avatarUrl,
            nameForInitials:
                showEmployeeAvatar ? info.employeeName : info.title,
            icon: showEmployeeAvatar
                ? null
                : _iconForApprovableType(info.approvableType),
            borderColor: statusColor,
          ),
          const SizedBox(width: 12),

          // ── Content: Action badges + Title + Subtitle + Employee ────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (info.takeAction ||
                    info.takeActionAsSomeoneElse ||
                    info.canApproveCancel ||
                    info.waitingCancel) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (info.takeAction)
                        AppStatusBadge(
                          icon: Icons.gavel_rounded,
                          color: Color(AppColors.failureRed),
                          label: 'action_required'.tr(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          fontSize: 10,
                          iconSize: 11,
                        ),
                      if (info.takeActionAsSomeoneElse)
                        AppStatusBadge(
                          icon: Icons.manage_accounts_rounded,
                          color: Color(AppColors.warningYellow),
                          label: 'act_as_someone'.tr(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          fontSize: 10,
                          iconSize: 11,
                        ),
                      if (info.canApproveCancel)
                        AppStatusBadge(
                          icon: Icons.cancel_outlined,
                          color: Color(AppColors.failureRed),
                          label: isArabic
                              ? 'مطلوب موافقة إلغاء'
                              : 'Cancel Approval Required',
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          fontSize: 10,
                          iconSize: 11,
                        ),
                      if (info.waitingCancel)
                        AppStatusBadge(
                          icon: Icons.hourglass_top_rounded,
                          color: Color(AppColors.warningYellow),
                          label: isArabic
                              ? 'طلب إلغاء معلق'
                              : 'Cancellation Pending',
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          fontSize: 10,
                          iconSize: 11,
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
                Text(
                  info.title.isNotEmpty ? info.title : '-',
                  style: AppStyles.heading(context).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (info.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    info.subtitle,
                    style: AppStyles.subtitleContent(context).copyWith(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (isForDepartment && info.employeeName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    info.employeeName,
                    style: AppStyles.subtitleContent(context).copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // ── Overlapping Vacations button (for department view) ──────────
          if (isForDepartment)
            Builder(
              builder: (context) {
                bool showOverlappingIcon = false;
                try {
                  final dyn = request as dynamic;
                  if (dyn.id != null) {
                    showOverlappingIcon = dyn.hasOverlapping == true;
                  }
                } catch (_) {}

                if (showOverlappingIcon) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          showOverlappingVacationsSheet(
                            context: context,
                            approvableId: (request as dynamic).id.toString(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.statusTones(Color(AppColors.warningYellow)).tint,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.people_alt_rounded,
                            color: AppColors.statusTones(Color(AppColors.warningYellow)).text,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

          // ── Trailing Status Badge ───────────────────────────────────────
          if (customTrailing != null) ...[
            const SizedBox(width: 8),
            customTrailing!,
          ] else if (request is InterviewModel) ...[
            const SizedBox(width: 8),
            _EvaluationStatusBadge(
              isEvaluated: (request as InterviewModel).myEvaluation != null,
            ),
          ] else if (info.status != null &&
              info.status!.trim().isNotEmpty &&
              info.status!.trim().toLowerCase() != 'null') ...[
            const SizedBox(width: 8),
            RequestsServices.getRequestsStatusIcon(
              context: context,
              status: info.status,
            ),
          ],
        ],
      ),
    );

    Widget finalWidget;
    if (slideActions.isEmpty) {
      finalWidget = cardBody;
    } else {
      finalWidget = Slidable(
        key: ValueKey(info.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: slideActions.length == 1 ? 0.22 : 0.42,
          children: slideActions,
        ),
        child: cardBody,
      );
    }

    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: finalWidget,
    );
  }
}

/// Small badge shown on interview cards indicating whether evaluation is completed or required.
class _EvaluationStatusBadge extends StatelessWidget {
  final bool isEvaluated;

  const _EvaluationStatusBadge({required this.isEvaluated});

  @override
  Widget build(BuildContext context) {
    final Color color = isEvaluated
        ? Color(AppColors.successGreen)
        : Color(AppColors.warningYellow);

    return AppStatusBadge(
      label: isEvaluated ? 'Evaluated'.tr() : 'Required'.tr(),
      color: color,
      icon: isEvaluated
          ? Icons.check_circle_outline_rounded
          : Icons.pending_actions_rounded,
    );
  }
}

/// Internal data class to hold resolved info from a dynamic request object.
class _ApprovableInfo {
  final bool takeAction;
  final bool takeActionAsSomeoneElse;
  final bool waitingCancel;
  final bool canApproveCancel;
  final String? status;
  final String title;
  final String subtitle;
  final String employeeName;
  final String? avatarUrl;
  final String approvableType;
  final String id;

  const _ApprovableInfo({
    required this.takeAction,
    required this.takeActionAsSomeoneElse,
    this.waitingCancel = false,
    this.canApproveCancel = false,
    required this.status,
    required this.title,
    required this.subtitle,
    required this.employeeName,
    this.avatarUrl,
    required this.approvableType,
    required this.id,
  });
}
