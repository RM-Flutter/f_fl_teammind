import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/salary_advance_request_model.dart';
import '../update_salary_advance_screen.dart';

class SalaryAdvanceListItemWidget extends StatelessWidget {
  final SalaryAdvanceRequestModel request;
  final bool isIncoming;
  final bool canEdit;
  final VoidCallback? onRefresh;

  const SalaryAdvanceListItemWidget({
    super.key,
    required this.request,
    required this.isIncoming,
    this.canEdit = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bool isApproved = (request.employeeApproved == true &&
        request.hrApproved == true &&
        request.managerApproved == true);

    final String status =
        request.status?.toLowerCase() ?? (isApproved ? 'approved' : 'pending');
    final Color statusColor = AppStatusBadge.colorForStatus(status);
    final bool showTakeAction = request.takeAction == true ||
        request.canTakeActionAsSomeoneElse == true;

    final String title = '${request.total ?? '0'} ${'egp'.tr()}';
    final String subtitle = [
      if (request.from != null && request.from!.isNotEmpty)
        '${'from_date'.tr()}: ${request.from}',
      if (request.howLongToPay != null)
        '${'how_long_to_pay'.tr()}: ${request.howLongToPay} ${'months'.tr()}',
    ].join(' · ');

    final String employeeName =
        isIncoming ? (request.employeeProfile?.name ?? '') : '';

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: AppSpacing.cardPadding,
      onTap: () async {
        final updated = await context.pushNamed<bool>(
          AppRoutes.salaryAdvanceDetails.name,
          pathParameters: {
            'id': request.id.toString(),
            'lang': context.locale.languageCode,
          },
        );
        if (updated == true) {
          onRefresh?.call();
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppCardLeadingAvatar(
            nameForInitials: employeeName.isNotEmpty ? employeeName : title,
            icon: employeeName.isNotEmpty ? null : Icons.payments_outlined,
            borderColor: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showTakeAction) ...[
                  AppStatusBadge(
                    icon: Icons.gavel_rounded,
                    color: Color(AppColors.failureRed),
                    label: 'take_action'.tr(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    fontSize: 10,
                    iconSize: 11,
                  ),
                  const SizedBox(height: 5),
                ],
                Text(
                  title,
                  style: AppStyles.heading(context).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppStyles.subtitleContent(context).copyWith(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (employeeName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    employeeName,
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
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppStatusBadge.fromStatus(status: status),
              if (canEdit &&
                  status != 'approved' &&
                  status != 'cancelled' &&
                  status != 'canceled') ...[
                const SizedBox(height: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    final updated = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => UpdateSalaryAdvanceScreen(
                          existingRequest: request,
                        ),
                      ),
                    );
                    if (updated == true) {
                      onRefresh?.call();
                    }
                  },
                  child: AppStatusBadge(
                    label: 'edit_request'.tr(),
                    color: Color(AppColors.buttons),
                    icon: Icons.edit_rounded,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    fontSize: 10,
                    iconSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
