import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_strings.dart';
import 'widgets/service_card_widget.dart';

class ServicesGridWidget extends StatelessWidget {
  final String? userPhotoUrl;
  final Function(String serviceId)? onServiceTap;

  const ServicesGridWidget({
    super.key,
    this.userPhotoUrl,
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // First row - 2 items
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: ServiceCard(
                    title: AppStrings.myCV.tr(),
                    icon: Icons.description_outlined,
                    iconColor: Color(AppColors.buttons),
                    onTap: () => onServiceTap?.call('my_cv'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: ServiceCard(
                    title: AppStrings.smartCard.tr(),
                    icon: Icons.credit_card,
                    showProfileAvatar: false,
                    avatarUrl: userPhotoUrl,
                    iconColor: Color(AppColors.secondaryButton),
                    onTap: () => onServiceTap?.call('smart_card'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second row - 2 items
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: ServiceCard(
                    title: AppStrings.cvGenerator.tr(),
                    icon: Icons.auto_fix_high,
                    iconColor: const Color(AppColors.purple),
                    onTap: () => onServiceTap?.call('cv_generator'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: ServiceCard(
                    title: AppStrings.salaryCalc.tr(),
                    icon: Icons.calculate_outlined,
                    showProfileAvatar: false,
                    avatarUrl: userPhotoUrl,
                    iconColor: const Color(AppColors.green),
                    onTap: () => onServiceTap?.call('salary_calc'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Third row - 2 items with profile avatar overlay
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: ServiceCard(
                    title: AppStrings.premiumTemplates.tr(),
                    icon: Icons.stars_outlined,
                    iconColor: Color(AppColors.warningYellow),
                    onTap: () => onServiceTap?.call('premium_templates'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: ServiceCard(
                    title: AppStrings.jobOfferGenerator.tr(),
                    icon: Icons.beach_access_outlined,
                    iconColor: const Color(AppColors.lightBlue),
                    onTap: () => onServiceTap?.call('job_offer_generator'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Fourth row - 2 items
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: ServiceCard(
                    title: AppStrings.vacationCalc.tr(),
                    icon: Icons.beach_access_outlined,
                    iconColor: const Color(AppColors.lightBlue),
                    onTap: () => onServiceTap?.call('vacation_calc'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: ServiceCard(
                    title: AppStrings.personalityTest.tr(),
                    icon: Icons.psychology_outlined,
                    showProfileAvatar: false,
                    avatarUrl: userPhotoUrl,
                    iconColor: const Color(AppColors.pinkEE),
                    onTap: () => onServiceTap?.call('personality_test'),
                  ),
                ),
              ),

            ],
          ),
          const SizedBox(height: 12),
          // Fourth row - 2 items
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: ServiceCard(
                    title: AppStrings.getTeamMindSystem.tr(),
                    icon: Icons.groups_outlined,
                    iconColor: Color(AppColors.secondaryButton),
                    onTap: () => onServiceTap?.call('team_mind_system'),
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
