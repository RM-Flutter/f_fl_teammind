import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/approvable_card_widget.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:app_test/features/rewards_and_penalties/view_rewards/data/models/reward_penalty_approvable_model.dart';
import 'package:app_test/features/rewards_and_penalties/view_rewards/data/repos/rewards_and_penalties.service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Rewards and penalties tab of an employee profile. Same source and cards as More → Rewards and
/// penalties: approval-system items (`rewards_and_penalties`) shown with [ApprovableCardWidget];
/// a card opens the shared approvable details. Shows the latest 5; "View all" opens the full list
/// (filtered to this employee when it is someone else's profile).
class RewardsAndPenaltiesSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  final List<RewardPenaltyApprovableModel>? items;

  /// Whether the signed-in user looks at another employee (cards show the employee name).
  final bool isTeam;

  /// Reloads the tab after returning from the details (an action may have changed an item).
  final VoidCallback? onChanged;

  const RewardsAndPenaltiesSectionWidget({
    super.key,
    required this.employee,
    required this.items,
    this.isTeam = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final list = items ?? const <RewardPenaltyApprovableModel>[];
    if (list.isEmpty) {
      return NoExistingPlaceholderScreen(
        compact: true,
        title: AppStrings.noExistingPenaltiesAndRewards.tr(),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            clipBehavior: Clip.none,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: list.length <= 5 ? list.length : 5,
            separatorBuilder: (context, index) => const SizedBox.shrink(),
            itemBuilder: (context, index) {
              final item = list[index];
              return ApprovableCardWidget(
                request: item,
                isForDepartment: isTeam,
                onActionTaken: onChanged,
                onTap: () async {
                  await context.pushNamed(
                    AppRoutes.approvableDetails.name,
                    pathParameters: {
                      'lang': context.locale.languageCode,
                      'type': RewardsAndPenaltiesRepo.approvableType,
                      'id': item.id.toString(),
                    },
                  );
                  onChanged?.call();
                },
              );
            },
          ),
          const SizedBox(height: AppSizes.s24),
          Center(
            child: CustomElevatedButton(
              backgroundColor: Color(AppColors.secondaryButton),
              titleSize: AppSizes.s12,
              title: 'viewAll'.tr(),
              onPressed: () async {
                await context.pushNamed(
                  AppRoutes.rewardsAndPenalties.name,
                  pathParameters: {'lang': context.locale.languageCode},
                  extra: {
                    'employeeName': employee?.name?.toString(),
                    'employeeId': employee?.id?.toString(),
                  },
                );
                onChanged?.call();
              },
            ),
          ),
        ],
      ),
    );
  }
}
