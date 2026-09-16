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
    
    return Column(
      children: [
        InkWell(
          onTap: () async => await ModalSheetHelper.showModalSheet(
              context: context,viewProfile: false,
              modalContent: RewardsAndPenaltiesDetailsModal(
                rewardAndPenalty: rewardAndPenalty,
              ),
              title: typeValue.toLowerCase().contains('reward') == true
                  ? AppStrings.rewardInfo.tr()
                  : AppStrings.penaltyInfo.tr(),
              height: MediaQuery.of(context).size.height * 0.75),
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: AppSizes.s14, horizontal: AppSizes.s16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.s10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  RewardsAndPenaltiesRepo.getRewardAndPenaltyImage(
                      type: typeValue),
                  width: AppSizes.s24,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error_outline,
                    size: AppSizes.s24,
                    color: Colors.red,
                  ),
                ),
                gapW12,
                Expanded(
                  child: Text(
                    isTeam && rewardAndPenalty.profile?.name != null
                        ? '${RewardsAndPenaltiesRepo.formatDate(context, rewardAndPenalty.dueDate) ?? ''} - ${rewardAndPenalty.profile!.name}'
                        : RewardsAndPenaltiesRepo.formatDate(context, rewardAndPenalty.dueDate) ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.s14,
                      color: Colors.black,
                    ),
                  ),
                ),

                Container(
                  height: AppSizes.s28,
                  width: AppSizes.s28,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(AppColors.buttons)),
                  child: const Icon(
                    Icons.arrow_forward_outlined,
                    color: Colors.white,
                    size: AppSizes.s12,
                  ),
                ),
              ],
            ),
          ),
        ),
        gapH20
      ],
    );
  }
}

