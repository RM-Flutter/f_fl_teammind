import 'package:app_test/core/constants/app_sizes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/approvable_details_model.dart';
import '../../../../../core/models/employee_action_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';

class InformationTab extends StatelessWidget {
  final String? createdAt;
  final String? seenAt;
  final String? updatedAt;
  final List<SeenByModel>? seenBy;
  final List<EmployeeActionModel>? employeeActions;

  const InformationTab({
    super.key,
    this.createdAt,
    this.seenAt,
    this.updatedAt,
    this.seenBy,
    this.employeeActions,
  });

  String _formatInfoDate(String? rawDate, BuildContext context) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final lang = LocalizationService.isArabic(context: context) ? "ar" : "en";
      return DateFormat('d-M-y | hh:mm a', lang).format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }

  Widget _buildInfoCard(BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: AppBorders.card,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label : ",
            style: AppStyles.subtitleContent(context).copyWith(fontSize: 12),
          ),
          Text(
            value,
            style: AppStyles.heading(context).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSizes.s25),
          if (createdAt != null && createdAt!.isNotEmpty)
            _buildInfoCard(
              context,
              AppStrings.createdOn.tr(),
              _formatInfoDate(createdAt, context),
            ),
          if (seenAt != null && seenAt!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s12),
            _buildInfoCard(
              context,
              AppStrings.seenOn.tr(),
              _formatInfoDate(seenAt, context),
            ),
          ],
          if (updatedAt != null && updatedAt!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s12),
            _buildInfoCard(
              context,
              AppStrings.statusUpdate.tr(),
              _formatInfoDate(updatedAt, context),
            ),
          ],
          if (seenBy != null && seenBy!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s24),
            Text('seen_by'.tr(),
              style: AppStyles.darkContent(context).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSizes.s12),
            ...seenBy!.map((person) {
              return Container(
                margin: const EdgeInsets.symmetric(
                    vertical: AppSpacing.cardGap / 2),
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: AppBorders.card,
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    AppCardLeadingAvatar(
                      imageUrl: person.avatar,
                      name: person.name,
                      borderColor: Color(AppColors.buttons),
                    ),
                    const SizedBox(width: AppSizes.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person.name ?? '',
                            style: AppStyles.heading(context),
                          ),
                          if (person.date != null && person.date!.isNotEmpty) ...[
                            const SizedBox(height: AppSizes.s2),
                            Text(
                              _formatInfoDate(person.date, context),
                              style: AppStyles.subtitleContent(context),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          if (employeeActions != null && employeeActions!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s24),
            Text(
              AppStrings.history.tr(),
              style: AppStyles.darkContent(context).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSizes.s12),
            ...employeeActions!.map((action) => _buildActionCard(context, action)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, EmployeeActionModel action) {
    String date = "";
    String time = "";
    if (action.createdAt != null && action.createdAt!.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(action.createdAt!);
        final lang = LocalizationService.isArabic(context: context) ? "ar" : "en";
        date = DateFormat('dd MMM yyyy', lang).format(dateTime);
        time = DateFormat('hh:mm a', lang).format(dateTime);
      } catch (_) {
        if (action.createdAt!.contains(" ")) {
          final parts = action.createdAt!.split(" ");
          date = parts[0];
          time = parts[1];
        } else {
          date = action.createdAt!;
        }
      }
    }

    Color actionColor;
    IconData actionIcon;
    String actionLabel = "";

    switch (action.action) {
      case 'approve':
        actionColor = Colors.green;
        actionIcon = Icons.check_circle_outline;
        actionLabel = 'approve'.tr();
        break;
      case 'reject':
      case 'refused':
        actionColor = Colors.red;
        actionIcon = Icons.cancel_outlined;
        actionLabel = 'reject'.tr();
        break;
      case 'update-amount':
        actionColor = Colors.blue;
        actionIcon = Icons.attach_money_rounded;
        actionLabel = 'update_amount'.tr();
        break;
      case 'update-duration':
        actionColor = Color(AppColors.warningYellow);
        actionIcon = Icons.update_rounded;
        actionLabel = 'update_duration'.tr();
        break;
      default:
        actionColor = Colors.grey;
        actionIcon = Icons.info_outline;
        actionLabel = action.action ?? '';
    }

    Widget actionWidget;
    if (action.action == 'update-duration' || action.action == 'update-amount') {
      actionWidget = Container(
        padding: const EdgeInsets.all(AppSizes.s12),
        decoration: BoxDecoration(
          color: actionColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: actionColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(actionIcon, color: actionColor, size: 24),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actionLabel, style: TextStyle(fontWeight: FontWeight.bold, color: actionColor.withOpacity(0.8), fontSize: 12)),
                  const SizedBox(height: AppSizes.s4),
                  Row(
                    children: [
                      Text(action.valueFrom ?? "", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey.shade500, fontSize: 13)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
                        child: Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey.shade400),
                      ),
                      Text(action.valueTo ?? "", style: TextStyle(fontWeight: FontWeight.bold, color: actionColor, fontSize: 14)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
    } else {
      actionWidget = Container(
        padding: const EdgeInsets.all(AppSizes.s12),
        decoration: BoxDecoration(
          color: actionColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: actionColor.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(actionIcon, color: actionColor, size: 24),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actionLabel, style: TextStyle(fontWeight: FontWeight.bold, color: actionColor, fontSize: 14)),
                  if (action.message != null && action.message!.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.s4),
                    Text(action.message!, style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.4)),
                  ]
                ],
              ),
            )
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.cardGap / 2),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.profileName ?? "", style: AppStyles.darkContent(context).copyWith(fontWeight: FontWeight.bold)),
                    if (action.profileJobTitle != null && action.profileJobTitle!.isNotEmpty)
                      Text(action.profileJobTitle!, style: AppStyles.greyContent(context).copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Colors.transparent),
          actionWidget,
          const SizedBox(height: AppSizes.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (time.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.access_time, size: 10, color: Colors.grey.shade400),
                    const SizedBox(width: AppSizes.s4),
                    Text(time, style: AppStyles.greyContent(context).copyWith(fontSize: 10)),
                  ],
                ),
              Text(date, style: AppStyles.greyContent(context).copyWith(fontSize: 10, fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }
}
