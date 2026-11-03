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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label : ",
            style: AppStyles.darkContent(context).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: AppStyles.primaryContent(context).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
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
          const SizedBox(height: 25),
          if (createdAt != null && createdAt!.isNotEmpty)
            _buildInfoCard(
              context,
              AppStrings.createdOn.tr(),
              _formatInfoDate(createdAt, context),
            ),
          if (seenAt != null && seenAt!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              AppStrings.seenOn.tr(),
              _formatInfoDate(seenAt, context),
            ),
          ],
          if (updatedAt != null && updatedAt!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              AppStrings.statusUpdate.tr(),
              _formatInfoDate(updatedAt, context),
            ),
          ],
          if (seenBy != null && seenBy!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('seen_by'.tr(),
              style: AppStyles.darkContent(context).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ...seenBy!.map((person) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: (person.avatar != null && person.avatar!.isNotEmpty)
                          ? (kIsWeb ? NetworkImage(person.avatar!) : CachedNetworkImageProvider(person.avatar!)) as ImageProvider
                          : null,
                      child: (person.avatar == null || person.avatar!.isEmpty)
                          ? Icon(Icons.person, color: Colors.grey.shade400)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person.name ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (person.date != null && person.date!.isNotEmpty)
                            Text(
                              _formatInfoDate(person.date, context),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          if (employeeActions != null && employeeActions!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              AppStrings.history.tr(),
              style: AppStyles.darkContent(context).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
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
        actionColor = Colors.orange;
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: actionColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: actionColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(actionIcon, color: actionColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actionLabel, style: TextStyle(fontWeight: FontWeight.bold, color: actionColor.withOpacity(0.8), fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(action.valueFrom ?? "", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey.shade500, fontSize: 13)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: actionColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: actionColor.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(actionIcon, color: actionColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actionLabel, style: TextStyle(fontWeight: FontWeight.bold, color: actionColor, fontSize: 14)),
                  if (action.message != null && action.message!.isNotEmpty) ...[
                    const SizedBox(height: 4),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (time.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.access_time, size: 10, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
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
