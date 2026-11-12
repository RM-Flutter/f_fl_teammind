import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import '../../data/models/approvable_details_model.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';

class ApprovableHeaderWidget extends StatelessWidget {
  final ApprovableDetailsModel details;

  const ApprovableHeaderWidget({super.key, required this.details});

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase().trim()) {
      case 'approved':
        return  Color(AppColors.successGreen);
      case 'refused':
      case 'rejected':
      case 'canceled':
        return  Color(AppColors.failureRed);
      case 'waiting':
      case 'waiting_seen':
      case 'pending':
        return Color(AppColors.warningYellow);
      default:
        return Colors.blue;
    }
  }

  String _formatDate(String? rawDate, BuildContext context) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final lang = LocalizationService.isArabic(context: context) ? 'ar' : 'en';
      return DateService.formatDate(lang, context, rawDate) ?? rawDate.split('T').first;
    } catch (_) {
      return rawDate.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = details.profile;
    final statusColor = _getStatusColor(details.status);
    final isArabic = LocalizationService.isArabic(context: context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSizes.s16),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: AppBorders.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile & Applicant Info Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppCardLeadingAvatar(
                imageUrl: profile?.avatar,
                name: profile?.name,
                borderColor: statusColor,
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.name ?? 'employee'.tr(),
                      style: AppStyles.heading(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.s2),
                    Text(
                      '${profile?.jobTitle ?? ''}${details.department?.title != null ? ' · ${details.department!.title}' : ''}',
                      style: AppStyles.subtitleContent(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.s8),
              AppStatusBadge.fromStatus(
                status: details.status ?? '',
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.s12),
            child: Divider(height: 1),
          ),

          // Request Details Summary Info
          if (details.typeName != null && details.typeName!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.assignment_outlined,
              label: 'type'.tr(),
              value: details.typeName!,
              context: context,
            ),
            const SizedBox(height: AppSizes.s8),
          ],

          if (details.dateFrom != null && details.dateFrom!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.calendar_month_outlined,
              label: 'date'.tr(),
              value: details.dateTo != null && details.dateTo!.isNotEmpty
                  ? '${_formatDate(details.dateFrom, context)} : ${_formatDate(details.dateTo, context)}'
                  : _formatDate(details.dateFrom, context),
              context: context,
            ),
            const SizedBox(height: AppSizes.s8),
          ],

          if (details.duration != null) ...[
            _buildInfoRow(
              icon: Icons.timer_outlined,
              label: 'duration'.tr(),
              value: '${details.duration} ${(details.unit ?? '').tr()}',
              context: context,
            ),
            const SizedBox(height: AppSizes.s8),
          ],

          if (details.moneyValue != null &&
              details.moneyValue != '0.00' &&
              details.moneyValue != '0') ...[
            _buildInfoRow(
              icon: Icons.attach_money_outlined,
              label: 'amount'.tr(),
              value: '${details.moneyValue} ${'egp'.tr()}',
              context: context,
            ),
            const SizedBox(height: AppSizes.s8),
          ],

          if (details.reason != null && details.reason!.trim().isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.info_outline_rounded,
              label: 'reason'.tr(),
              value: details.reason!.trim(),
              context: context,
            ),
            const SizedBox(height: AppSizes.s8),
          ],

          if (details.notes != null && details.notes!.trim().isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.note_outlined,
              label: 'notes'.tr(),
              value: details.notes!.trim(),
              context: context,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Color(AppColors.buttons)),
        const SizedBox(width: AppSizes.s8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
