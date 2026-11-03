import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import '../../../data/models/approvable_details_model.dart';
import 'single_approval_row.dart';
import 'package:app_test/core/constants/app_design.dart';

class ApprovalLevelCard extends StatelessWidget {
  final int levelNum;
  final List<RequiredApprovalModel> items;
  final bool isArabic;

  const ApprovalLevelCard({
    super.key,
    required this.levelNum,
    required this.items,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color(AppColors.buttons).withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttons),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    '${'level'.tr()} $levelNum',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (items.length > 1) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${items.length} ${isArabic ? 'موافقات في هذا المستوى' : 'approvers'})',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    if (idx > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: Colors.grey.shade300),
                      ),
                    SingleApprovalRow(item: item, isArabic: isArabic),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
