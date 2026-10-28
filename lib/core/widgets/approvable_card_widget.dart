import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/services/settings_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/features/cv_hub/models/cv_hub_models.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:app_test/features/overtime_requests/models/overtime_request_model.dart';
import 'package:app_test/features/salary_advance_requests/shared/models/salary_advance_request_model.dart';
import 'package:app_test/features/expense_claim_requests/shared/models/expense_claim_model.dart';
import 'package:app_test/features/shifts/models/shift_change_request_model.dart';
import 'package:app_test/core/widgets/quick_action_sheet.dart';
import 'package:app_test/features/approvables_details/views/widgets/overlapping_vacations_sheet.dart';

class ApprovableCardWidget extends StatelessWidget {
  final dynamic request; // RequestModel, OvertimeRequestModel, SalaryAdvanceRequestModel
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
    String? status;
    String title = '';
    String subtitle = '';
    String employeeName = '';
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
            ? (DateService.formatDate(isArabic ? 'ar' : 'en', context, ot.date) ?? dateStr)
            : dateStr;

        int totalMins = ot.overtime ?? 0;
        final hours = totalMins ~/ 60;
        final mins = totalMins % 60;
        String durationStr = '';
        if (hours == 0) {
          durationStr = '$mins ${isArabic ? 'دقيقة' : 'min'}';
        } else if (mins == 0) {
          durationStr = '$hours ${isArabic ? 'ساعة' : 'hr'}';
        } else {
          durationStr = isArabic
              ? '$hours ساعة و $mins دقيقة'
              : '$hours hr $mins min';
        }

        if (totalMins > 0) {
          title = durationStr;
          subtitle = formattedDate.isNotEmpty
              ? (isArabic ? 'التاريخ: $formattedDate' : 'Date: $formattedDate')
              : '';
        } else {
          title = formattedDate.isNotEmpty
              ? formattedDate
              : (isArabic ? 'وقت إضافي' : 'Overtime');
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
        title = '$amount ${isArabic ? 'ج.م' : 'EGP'}';
        String durationText = isArabic
            ? '$months شهر'
            : '$months ${months == '1' ? 'month' : 'months'}';
        String details = '${isArabic ? 'مدة السداد' : 'Duration'}: $durationText';
        if (sa.from != null && sa.from!.isNotEmpty) {
          final formattedFrom =
              DateService.formatDate(isArabic ? 'ar' : 'en', context, sa.from) ?? sa.from!;
          details += ' • ${isArabic ? 'من' : 'From'}: $formattedFrom';
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

        // Title = reason (or money value if reason is empty)
        final amount = ec.moneyValue ?? '0';
        title = ec.reason?.isNotEmpty == true
            ? ec.reason!
            : '$amount ${isArabic ? 'ج.م' : 'EGP'}';

        // Subtitle = amount + category
        String sub = '$amount ${isArabic ? 'ج.م' : 'EGP'}';
        if (ec.categoryName != null && ec.categoryName!.isNotEmpty) {
          sub += ' • ${ec.categoryName}';
        } else if (ec.category != null && ec.category!.isNotEmpty) {
          sub += ' • ${ec.category}';
        }
        if (ec.dateFrom != null && ec.dateFrom!.isNotEmpty) {
          final formattedDate =
              DateService.formatDate(isArabic ? 'ar' : 'en', context, ec.dateFrom) ??
                  ec.dateFrom!;
          sub += ' • $formattedDate';
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
              ? '$reqShift (${isArabic ? 'تحويل شيفت' : 'Shift Transfer'})'
              : (isArabic ? 'طلب تبديل شيفت' : 'Shift Change Request');
        }

        final String fromDate = sc.dateFrom != null && sc.dateFrom!.isNotEmpty
            ? (DateService.formatDate(isArabic ? 'ar' : 'en', context, sc.dateFrom) ??
                sc.dateFrom!.split(' ').first)
            : '';
        final String toDate = sc.dateTo != null && sc.dateTo!.isNotEmpty
            ? (DateService.formatDate(isArabic ? 'ar' : 'en', context, sc.dateTo) ??
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
        employeeName = interview.candidate?.fullName ?? 'Unknown Candidate'.tr();
        id = interview.id.toString();
        approvableType = 'interview';
        
        title = '${interview.candidate?.job?.title ?? ''} • ${interview.interviewType ?? ''}';
        subtitle = interview.scheduledAt ?? '';
      } else {
        final dyn = request as dynamic;
        takeAction = dyn.takeAction == true;
        takeActionAsSomeoneElse = dyn.canTakeActionAsSomeoneElse == true;
        status = dyn.status;
        employeeName = dyn.employeeName ?? '';
        id = dyn.id?.toString() ?? '';
        approvableType = 'employee_requests';
        String? depName = dyn.departmentName;
        if (depName != null && depName.isNotEmpty) {
          employeeName = '$employeeName - $depName';
        }

        title = AppSettingsService.getRequestTitleFromGenenralSettings(
                context: context,
                requestId: dyn.typeId != null ? dyn.typeId?.toString() : '') ??
            '';

        final String fromDate = dyn.from != null
            ? (DateService.formatDate(isArabic ? 'ar' : 'en', context, dyn.from) ?? '')
            : '';
        final String toDate = dyn.to != null
            ? (DateService.formatDate(isArabic ? 'ar' : 'en', context, dyn.to) ?? '')
            : '';

        if (dyn.duration == 0) {
          subtitle = fromDate;
        } else if (fromDate == toDate || toDate.isEmpty) {
          subtitle = '$fromDate (${dyn.duration} ${dyn.durationType?.toString().tr()})';
        } else {
          subtitle = '$fromDate : $toDate (${dyn.duration} ${dyn.durationType?.toString().tr()})';
        }
      }
    } catch (_) {}

    if (status != null) {
      final s = status.toLowerCase().trim();
      if (s == 'approved' || s == 'accepted' || s == 'refused' || s == 'canceled' || s == 'cancelled' || s == 'rejected') {
        takeAction = false;
        takeActionAsSomeoneElse = false;
      }
    }

    return _ApprovableInfo(
      takeAction: takeAction,
      takeActionAsSomeoneElse: takeActionAsSomeoneElse,
      status: status,
      title: title,
      subtitle: subtitle,
      employeeName: employeeName,
      approvableType: approvableType,
      id: id,
    );
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
          foregroundColor: const Color(0xFFB71C1C),
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFB71C1C).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.gavel_rounded, color: Color(0xFFB71C1C), size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                isArabic ? 'إجراء' : 'Action',
                style: const TextStyle(
                  color: Color(0xFFB71C1C),
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
          foregroundColor: const Color(0xFFE65100),
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE65100).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.manage_accounts_rounded, color: Color(0xFFE65100), size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                isArabic ? 'نيابةً عن' : 'As Someone',
                style: const TextStyle(
                  color: Color(0xFFE65100),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final cardBody = Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: ShapeDecoration(
        color: Color(AppColors.cardBackground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: [
          BoxShadow(
            color: Color(AppColors.disableButton).withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (info.takeAction || info.takeActionAsSomeoneElse) ...[
                    Row(
                      children: [
                        if (info.takeAction) ...[
                          _ActionBadge(
                            icon: Icons.gavel_rounded,
                            color: const Color(0xFFD32F2F),
                            label: isArabic ? 'مطلوب إجراء' : 'Action Required',
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (info.takeActionAsSomeoneElse)
                          _ActionBadge(
                            icon: Icons.manage_accounts_rounded,
                            color: const Color(0xFFE65100),
                            label: isArabic ? 'نيابةً عن موظف' : 'Act as Someone',
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  AutoSizeText(
                    info.title,
                    style: AppStyles.titleTextContent(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.75,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Opacity(
                    opacity: 0.5,
                    child: AutoSizeText(
                      info.subtitle,
                      style: AppStyles.titleTextContent(context).copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isForDepartment && info.employeeName.isNotEmpty)
                    const SizedBox(height: 4),
                  if (isForDepartment && info.employeeName.isNotEmpty)
                    Text(
                      info.employeeName,
                      style: AppStyles.titleTextContent(context).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
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
                        InkWell(
                          onTap: () {
                            showOverlappingVacationsSheet(
                              context: context,
                              approvableId:
                                  (request as dynamic).id.toString(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(AppColors.warningYellow)
                                  .withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.people_alt_rounded,
                                color: Color(AppColors.warningYellow),
                                size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
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
                  context: context, status: info.status),
            ],
          ],
        ),
      ),
    );

    Widget finalWidget;
    // If no slide actions are needed, return card as-is
    if (slideActions.isEmpty) {
      finalWidget = cardBody;
    } else {
      // Wrap with Slidable — swipe left to reveal action buttons
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
      padding: margin ?? const EdgeInsets.only(bottom: 16),
      child: finalWidget,
    );
  }
}

/// Small badge shown inline on the card when swipe action is available.
class _ActionBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _ActionBadge({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
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
        : const Color(0xFFE65100);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEvaluated
                ? Icons.check_circle_outline_rounded
                : Icons.pending_actions_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isEvaluated ? 'Evaluated'.tr() : 'Required'.tr(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal data class to hold resolved info from a dynamic request object.
class _ApprovableInfo {
  final bool takeAction;
  final bool takeActionAsSomeoneElse;
  final String? status;
  final String title;
  final String subtitle;
  final String employeeName;
  final String approvableType;
  final String id;

  const _ApprovableInfo({
    required this.takeAction,
    required this.takeActionAsSomeoneElse,
    required this.status,
    required this.title,
    required this.subtitle,
    required this.employeeName,
    required this.approvableType,
    required this.id,
  });
}
