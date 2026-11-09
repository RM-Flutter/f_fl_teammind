import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/modal_sheet_helper.dart';
import 'package:app_test/features/rewards_and_penalties/view_rewards/views/widgets/widgets/rewards_and_penalties_details_modal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repos/rewards_and_penalties.service.dart';
import '../../controllers/rewards_and_penalties_controller.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';

class RewardAndPenaltyCardWidget extends StatelessWidget {
  var rewardAndPenalty;
  final bool isTeam;
  RewardAndPenaltyCardWidget({super.key, required this.rewardAndPenalty, this.isTeam = false});

  String _getTypeValue(dynamic type) {
    if (type == null) return "";
    if (type is String) return type;
    try {
      return type.value ?? type.key ?? "";
    } catch (_) {
      return type.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeValue = _getTypeValue(rewardAndPenalty.type);
    final isReward = typeValue.toLowerCase().contains('reward');
    final accentColor = isReward
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);
    final dateText =
        RewardsAndPenaltiesRepo.formatDate(context, rewardAndPenalty.dueDate) ??
            '';
    final employeeName = rewardAndPenalty.profile?.name?.toString();
    final titleText = (isTeam && employeeName != null && employeeName.isNotEmpty)
        ? employeeName
        : (dateText.isNotEmpty
            ? dateText
            : (isReward
                ? AppStrings.rewardInfo.tr()
                : AppStrings.penaltyInfo.tr()));
    final subtitleText =
        (isTeam && employeeName != null && employeeName.isNotEmpty)
            ? dateText
            // The type comes from the server in English: show it translated.
            : (typeValue.isEmpty ? '' : (isReward ? 'reward'.tr() : 'penalty'.tr()));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: AppCard(
        onTap: () async => await ModalSheetHelper.showModalSheet(
            context: context,
            viewProfile: false,
            modalContent: RewardsAndPenaltiesDetailsModal(
              rewardAndPenalty: rewardAndPenalty,
              onCancel: () {
                try {
                  final viewModel =
                      context.read<RewardsAndPenaltiesViewModel>();
                  viewModel.cancelRewardAndPenalty(
                      context: context, id: rewardAndPenalty.id!);
                } catch (e) {
                  debugPrint('RewardsAndPenaltiesViewModel not found: $e');
                }
              },
            ),
            title: isReward
                ? AppStrings.rewardInfo.tr()
                : AppStrings.penaltyInfo.tr(),
            height: MediaQuery.of(context).size.height * 0.75),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppCardLeadingAvatar(
              name: isTeam ? employeeName : null,
              icon: isReward
                  ? Icons.emoji_events_outlined
                  : Icons.warning_amber_rounded,
              borderColor: accentColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.heading(context),
                  ),
                  if (subtitleText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.subtitleContent(context),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppStatusBadge(
              label: isReward
                  ? AppStrings.rewardInfo.tr()
                  : AppStrings.penaltyInfo.tr(),
              color: accentColor,
              icon: isReward
                  ? Icons.emoji_events_outlined
                  : Icons.warning_amber_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

