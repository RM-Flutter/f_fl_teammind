import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TaskListTileWidget extends StatelessWidget {
  final String title;
  final String date;
  final String createdAt;
  final String id;
  final String assetName;
  final String complete;
  final VoidCallback? onTap;

  const TaskListTileWidget({
    super.key,
    required this.date,
    required this.onTap,
    required this.createdAt,
    required this.complete,
    required this.id,
    required this.title,
    required this.assetName,
  });

  String _formatDateDifference(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      final temp = start;
      start = end;
      end = temp;
    }
    final int totalDays = end.difference(start).inDays;
    final int months = totalDays ~/ 30;
    final int days = totalDays % 30;
    if (months > 0) {
      return "$months ${AppStrings.month.tr()}";
    }
    return "$days ${AppStrings.days.tr()}";
  }

  @override
  Widget build(BuildContext context) {
    final String normalizedStatus = complete.trim().toLowerCase();
    final Color statusColor = normalizedStatus == 'completed'
        ? Color(AppColors.successGreen)
        : normalizedStatus == 'closed'
            ? Color(AppColors.tabInactive)
            : Color(AppColors.buttons);

    final parts = <String>[];
    try {
      if (createdAt.isNotEmpty) {
        parts.add(DateFormat('yyyy-MM-dd').format(DateTime.parse(createdAt)));
      }
      if (date.isNotEmpty) {
        parts.add(DateFormat('yyyy-MM-dd').format(DateTime.parse(date)));
      }
      if (createdAt.isNotEmpty && date.isNotEmpty) {
        final diff = _formatDateDifference(
          DateTime.parse(createdAt),
          DateTime.parse(date),
        );
        final durationLabel = (diff != "0 ${AppStrings.days.tr()}" &&
                diff != "0 ${AppStrings.month.tr()}")
            ? diff
            : "1 ${AppStrings.days.tr()}";
        parts.add('($durationLabel)');
      }
    } catch (_) {}

    final String subtitle = parts.join(' · ');

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: AppSpacing.cardPadding,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withOpacity(0.12),
              border: Border.all(color: statusColor, width: 2),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              assetName,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(statusColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppStyles.heading(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppStatusBadge(
            label: normalizedStatus.isNotEmpty
                ? normalizedStatus.tr()
                : 'pending'.tr(),
            color: statusColor,
            icon: normalizedStatus == 'completed'
                ? Icons.check_circle_outline_rounded
                : normalizedStatus == 'closed'
                    ? Icons.lock_clock_outlined
                    : Icons.access_time_rounded,
          ),
        ],
      ),
    );
  }
}
