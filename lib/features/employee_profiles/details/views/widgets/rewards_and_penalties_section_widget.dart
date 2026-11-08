import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/features/rewards_and_penalties/view_rewards/data/models/reward_and_penalty_model.dart';
import 'package:app_test/features/rewards_and_penalties/view_rewards/views/widgets/reward_and_penalty_card.widget.dart';
import 'package:app_test/core/constants/app_design.dart';

class RewardsAndPenaltiesSectionWidget extends StatefulWidget {
  final EmployeeProfileModel? employee;
  const RewardsAndPenaltiesSectionWidget({super.key, required this.employee});

  @override
  State<RewardsAndPenaltiesSectionWidget> createState() =>
      _RewardsAndPenaltiesSectionWidgetState();
}

class _RewardsAndPenaltiesSectionWidgetState
    extends State<RewardsAndPenaltiesSectionWidget> {
  // 0 = all, 1 = rewards, 2 = penalties
  int _filter = 0;

  List<EmpRewardPenalty> get _items {
    final all = widget.employee?.rewardsAndPenalties ?? [];
    if (_filter == 1) return all.where((e) => e.type == 'reward').toList();
    if (_filter == 2) return all.where((e) => e.type == 'penalty').toList();
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.employee?.rewardsAndPenalties ?? [];

    if (all.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(AppStrings.noDataFounded.tr()),
        ),
      );
    }

    final rewards = all.where((e) => e.type == 'reward').length;
    final penalties = all.where((e) => e.type == 'penalty').length;

    return Column(
      children: [
        gapH12,

        // ── Summary chips ─────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _SummaryChip(
              label: 'all'.tr(),
              count: all.length,
              isSelected: _filter == 0,
              color: Color(AppColors.buttons),
              onTap: () => setState(() => _filter = 0),
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              label: 'rewards'.tr(),
              count: rewards,
              isSelected: _filter == 1,
              color: const Color(0xFF2D6A4F),
              onTap: () => setState(() => _filter = 1),
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              label: 'penalties'.tr(),
              count: penalties,
              isSelected: _filter == 2,
              color: const Color(0xFFC72C41),
              onTap: () => setState(() => _filter = 2),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                context.pushNamed(
                  AppRoutes.rewardsAndPenalties.name,
                  pathParameters: {'lang': context.locale.languageCode},
                  extra: {
                    'employeeName': widget.employee?.name,
                    'employeeId': widget.employee?.id?.toString(),
                  },
                );
              },
              child: Text(
                AppStrings.viewAll.tr(),
                style: AppStyles.titleTextContent(context).copyWith(
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── List ─────────────────────────────────────────────
        Expanded(
          child: _items.isEmpty
              ? Center(child: Text(AppStrings.noDataFounded.tr()))
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  clipBehavior: Clip.none,
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox.shrink(),
                  itemBuilder: (context, index) {
                    final eItem = _items[index];
                    
                    // Convert EmpRewardPenalty to RewardAndPenaltyModel for compatibility
                    final model = RewardAndPenaltyModel(
                      id: eItem.id,
                      type: eItem.type,
                      category: eItem.category,
                      amount: eItem.amount?.toInt(),
                      reason: eItem.reason,
                      dueDate: eItem.dueDate,
                      action: eItem.action,
                      canCancel: eItem.canCancel,
                      createdAt: eItem.createdAt,
                      employeeId: eItem.profileId,
                      files: eItem.signatureDocumentUrl != null 
                          ? [MediaFile(file: eItem.signatureDocumentUrl, title: 'Attachment')] 
                          : null,
                    );
                    
                    return RewardAndPenaltyCardWidget(
                      rewardAndPenalty: model,
                      isTeam: false,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Summary chip ──────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
              color: isSelected ? color : color.withOpacity(0.25), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

