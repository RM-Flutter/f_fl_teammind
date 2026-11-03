import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/localization_service.dart';
import '../../data/models/approvable_details_model.dart';
import 'approvals_table/approval_level_card.dart';
import 'package:app_test/core/constants/app_design.dart';

class RequiredApprovalsTableWidget extends StatelessWidget {
  final List<RequiredApprovalModel> requiredApprovals;

  const RequiredApprovalsTableWidget({
    super.key,
    required this.requiredApprovals,
  });

  Map<int, List<RequiredApprovalModel>> _groupApprovalsByLevel() {
    final Map<int, List<RequiredApprovalModel>> map = {};
    for (final item in requiredApprovals) {
      final lvl = item.level ?? 1;
      map.putIfAbsent(lvl, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (requiredApprovals.isEmpty) {
      return const SizedBox.shrink();
    }

    final groupedMap = _groupApprovalsByLevel();
    final sortedLevels = groupedMap.keys.toList()..sort();
    final isArabic = LocalizationService.isArabic(context: context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_list_bulleted_rounded,
                  size: 20, color: Color(AppColors.buttons)),
              const SizedBox(width: 8),
              Text(
                'approvals'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedLevels.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final levelNum = sortedLevels[index];
              final items = groupedMap[levelNum]!;
              return ApprovalLevelCard(
                levelNum: levelNum,
                items: items,
                isArabic: isArabic,
              );
            },
          ),
        ],
      ),
    );
  }
}
